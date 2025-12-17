import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { supabase } from '../../lib/supabase';
import { Category, Question } from '../../types';
import { ArrowLeft, Save, Plus, Trash } from 'lucide-react';

export default function AdminQuestionEditor() {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEditMode = !!id;

  const [loading, setLoading] = useState(false);
  const [categories, setCategories] = useState<Category[]>([]);
  
  const [formData, setFormData] = useState<Partial<Question>>({
    title: '',
    content: '',
    type: 'single',
    difficulty: 'medium',
    category_id: '',
    options: ['选项A', '选项B', '选项C', '选项D'],
    correct_answer: '',
    explanation: '',
    tags: [],
    is_active: true,
    is_premium: false,
  });

  const [tagsInput, setTagsInput] = useState('');

  useEffect(() => {
    fetchCategories();
    if (isEditMode) {
      fetchQuestion(id);
    }
  }, [id]);

  const fetchCategories = async () => {
    const { data } = await supabase.from('categories').select('*').order('sort_order');
    if (data) {
      setCategories(data);
      if (!isEditMode && data.length > 0) {
        setFormData(prev => ({ ...prev, category_id: data[0].id }));
      }
    }
  };

  const fetchQuestion = async (questionId: string) => {
    setLoading(true);
    const { data, error } = await supabase
      .from('questions')
      .select('*')
      .eq('id', questionId)
      .single();

    if (error) {
      console.error('Error fetching question:', error);
      alert('加载题目失败');
      navigate('/admin/questions');
    } else if (data) {
      setFormData({
        ...data,
        options: Array.isArray(data.options) ? data.options : [],
      });
      setTagsInput(data.tags ? data.tags.join(', ') : '');
    }
    setLoading(false);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const payload = {
        ...formData,
        tags: tagsInput.split(',').map(t => t.trim()).filter(Boolean),
        updated_at: new Date().toISOString(),
      };

      if (isEditMode) {
        const { error } = await supabase
          .from('questions')
          .update(payload)
          .eq('id', id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from('questions').insert([payload]);
        if (error) throw error;
      }

      navigate('/admin/questions');
    } catch (error) {
      console.error('Error saving question:', error);
      alert('保存失败，请检查网络或输入');
    } finally {
      setLoading(false);
    }
  };

  const handleOptionChange = (index: number, value: string) => {
    const newOptions = [...(formData.options as string[])];
    newOptions[index] = value;
    setFormData({ ...formData, options: newOptions });
  };

  const addOption = () => {
    setFormData({
      ...formData,
      options: [...(formData.options as string[]), `选项${(formData.options as string[]).length + 1}`],
    });
  };

  const removeOption = (index: number) => {
    const newOptions = (formData.options as string[]).filter((_, i) => i !== index);
    setFormData({ ...formData, options: newOptions });
  };

  if (loading && isEditMode) {
    return <div className="p-8 text-center">加载中...</div>;
  }

  return (
    <div className="max-w-4xl mx-auto pb-10">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center">
          <button
            onClick={() => navigate('/admin/questions')}
            className="mr-4 text-gray-500 hover:text-gray-700"
          >
            <ArrowLeft className="h-6 w-6" />
          </button>
          <h1 className="text-2xl font-bold text-gray-900">
            {isEditMode ? '编辑题目' : '添加题目'}
          </h1>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white shadow rounded-lg p-6 space-y-6">
        {/* Title */}
        <div>
          <label className="block text-sm font-medium text-gray-700">标题</label>
          <input
            type="text"
            required
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
          />
        </div>

        {/* Category & Difficulty */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700">分类</label>
            <select
              required
              className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
              value={formData.category_id || ''}
              onChange={(e) => setFormData({ ...formData, category_id: e.target.value })}
            >
              <option value="" disabled>选择分类</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">难度</label>
            <select
              required
              className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
              value={formData.difficulty}
              onChange={(e) => setFormData({ ...formData, difficulty: e.target.value as any })}
            >
              <option value="easy">简单</option>
              <option value="medium">中等</option>
              <option value="hard">困难</option>
            </select>
          </div>
        </div>

        {/* Type */}
        <div>
          <label className="block text-sm font-medium text-gray-700">题型</label>
          <select
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            value={formData.type}
            onChange={(e) => setFormData({ ...formData, type: e.target.value as any })}
          >
            <option value="single">单选题</option>
            <option value="multiple">多选题</option>
            <option value="boolean">判断题</option>
            <option value="fill">填空题</option>
          </select>
        </div>

        {/* Content */}
        <div>
          <label className="block text-sm font-medium text-gray-700">题目内容 (支持 Markdown)</label>
          <textarea
            required
            rows={5}
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm font-mono"
            value={formData.content}
            onChange={(e) => setFormData({ ...formData, content: e.target.value })}
          />
        </div>

        {/* Options (Only for single/multiple) */}
        {(formData.type === 'single' || formData.type === 'multiple') && (
          <div>
            <div className="flex justify-between items-center mb-2">
              <label className="block text-sm font-medium text-gray-700">选项</label>
              <button
                type="button"
                onClick={addOption}
                className="inline-flex items-center px-2 py-1 border border-gray-300 text-xs font-medium rounded text-gray-700 bg-white hover:bg-gray-50"
              >
                <Plus className="h-3 w-3 mr-1" /> 添加选项
              </button>
            </div>
            <div className="space-y-2">
              {(formData.options as string[]).map((option, index) => (
                <div key={index} className="flex items-center gap-2">
                  <span className="text-gray-500 w-6 text-center">{String.fromCharCode(65 + index)}.</span>
                  <input
                    type="text"
                    required
                    className="flex-1 border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                    value={option}
                    onChange={(e) => handleOptionChange(index, e.target.value)}
                  />
                  <button
                    type="button"
                    onClick={() => removeOption(index)}
                    className="text-gray-400 hover:text-red-500"
                    disabled={(formData.options as string[]).length <= 2}
                  >
                    <Trash className="h-4 w-4" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Correct Answer */}
        <div>
          <label className="block text-sm font-medium text-gray-700">正确答案</label>
          {formData.type === 'single' ? (
             <select
               required
               className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
               value={formData.correct_answer}
               onChange={(e) => setFormData({ ...formData, correct_answer: e.target.value })}
             >
               <option value="">选择正确答案</option>
               {(formData.options as string[]).map((_, index) => (
                 <option key={index} value={String.fromCharCode(65 + index)}>
                   {String.fromCharCode(65 + index)}
                 </option>
               ))}
             </select>
          ) : formData.type === 'boolean' ? (
             <select
               required
               className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
               value={formData.correct_answer}
               onChange={(e) => setFormData({ ...formData, correct_answer: e.target.value })}
             >
               <option value="">选择正确答案</option>
               <option value="true">正确</option>
               <option value="false">错误</option>
             </select>
          ) : (
            <input
              type="text"
              required
              placeholder={formData.type === 'multiple' ? '例如: A,C (用逗号分隔)' : '请输入答案'}
              className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
              value={formData.correct_answer}
              onChange={(e) => setFormData({ ...formData, correct_answer: e.target.value })}
            />
          )}
          {formData.type === 'multiple' && (
            <p className="mt-1 text-xs text-gray-500">多选题答案请用逗号分隔，如 A,B,C</p>
          )}
        </div>

        {/* Explanation */}
        <div>
          <label className="block text-sm font-medium text-gray-700">答案解析 (支持 Markdown)</label>
          <textarea
            rows={4}
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm font-mono"
            value={formData.explanation || ''}
            onChange={(e) => setFormData({ ...formData, explanation: e.target.value })}
          />
        </div>

        {/* Tags */}
        <div>
          <label className="block text-sm font-medium text-gray-700">标签</label>
          <input
            type="text"
            placeholder="用逗号分隔，如: 集合,HashMap,源码"
            className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            value={tagsInput}
            onChange={(e) => setTagsInput(e.target.value)}
          />
        </div>

        {/* Is Active & Is Premium */}
        <div className="flex items-center space-x-6">
          <div className="flex items-center">
            <input
              id="is_active"
              type="checkbox"
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
            />
            <label htmlFor="is_active" className="ml-2 block text-sm text-gray-900">
              启用此题目
            </label>
          </div>

          <div className="flex items-center">
            <input
              id="is_premium"
              type="checkbox"
              className="h-4 w-4 text-yellow-600 focus:ring-yellow-500 border-gray-300 rounded"
              checked={formData.is_premium || false}
              onChange={(e) => setFormData({ ...formData, is_premium: e.target.checked })}
            />
            <label htmlFor="is_premium" className="ml-2 block text-sm text-gray-900 flex items-center">
              设为会员题 <span className="text-xs text-yellow-600 ml-1">(仅 Pro 可见)</span>
            </label>
          </div>
        </div>

        <div className="flex justify-end pt-5">
          <button
            type="button"
            onClick={() => navigate('/admin/questions')}
            className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 mr-3"
          >
            取消
          </button>
          <button
            type="submit"
            disabled={loading}
            className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
          >
            {loading ? '保存中...' : '保存题目'}
          </button>
        </div>
      </form>
    </div>
  );
}
