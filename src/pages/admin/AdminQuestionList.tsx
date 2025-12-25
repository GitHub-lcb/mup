import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Question, Category } from '../../types';
import { Plus, Edit, Trash2, Search, Lock, ChevronLeft, ChevronRight } from 'lucide-react';
import api from '../../lib/api';

const PAGE_SIZE = 10;

export default function AdminQuestionList() {
  const [questions, setQuestions] = useState<Question[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [page, setPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);

  useEffect(() => {
    fetchCategories();
  }, []);

  useEffect(() => {
    // Debounce search to avoid too many requests
    const timer = setTimeout(() => {
      fetchQuestions();
    }, 300);

    return () => clearTimeout(timer);
  }, [searchTerm, selectedCategory, page]);

  const fetchCategories = async () => {
    try {
      const data = await api.categories.list() as Category[];
      setCategories(data || []);
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  };

  const fetchQuestions = async () => {
    try {
      setLoading(true);
      
      const params: any = {
        page,
        limit: PAGE_SIZE,
      };
      
      if (searchTerm) {
        params.search = searchTerm;
      }
      
      if (selectedCategory !== 'all') {
        params.category_id = selectedCategory;
      }
      
      const response = await api.questions.list(params) as any;
      const { questions: data, total } = response;
      
      setQuestions(data || []);
      setTotalCount(total || 0);
    } catch (error) {
      console.error('Error fetching questions:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('确定要删除这道题目吗？此操作不可恢复。')) return;

    try {
      await api.questions.delete(id);
      fetchQuestions();
    } catch (error) {
      console.error('Error deleting question:', error);
      alert('删除失败，请重试');
    }
  };

  const getCategoryName = (categoryId: string | null) => {
    if (!categoryId) return '未分类';
    return categories.find((c) => c.id === categoryId)?.name || '未知分类';
  };

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(e.target.value);
    setPage(1); // Reset to first page on search
  };

  const handleCategoryChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedCategory(e.target.value);
    setPage(1); // Reset to first page on filter
  };

  const totalPages = Math.ceil(totalCount / PAGE_SIZE);

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">题目管理</h1>
        <Link
          to="/admin/questions/new"
          className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
        >
          <Plus className="h-4 w-4 mr-2" />
          添加题目
        </Link>
      </div>

      <div className="bg-white p-4 rounded-lg shadow mb-6 flex flex-col md:flex-row gap-4">
        <div className="flex-1 relative">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search className="h-5 w-5 text-gray-400" />
          </div>
          <input
            type="text"
            className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            placeholder="搜索题目标题..."
            value={searchTerm}
            onChange={handleSearchChange}
          />
        </div>
        <select
          className="block w-full md:w-48 pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm rounded-md"
          value={selectedCategory}
          onChange={handleCategoryChange}
        >
          <option value="all">所有分类</option>
          {categories.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>
      </div>

      <div className="bg-white shadow overflow-hidden sm:rounded-md">
        <ul className="divide-y divide-gray-200">
          {loading ? (
             <li className="px-6 py-12 text-center text-gray-500">加载中...</li>
          ) : questions.length === 0 ? (
            <li className="px-6 py-12 text-center text-gray-500">暂无题目</li>
          ) : (
            questions.map((question) => (
              <li key={question.id}>
                <div className="px-4 py-4 sm:px-6 flex items-center justify-between hover:bg-gray-50 transition">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-2">
                      <p className="text-sm font-medium text-blue-600 truncate flex items-center">
                        {question.is_premium && <Lock className="h-3 w-3 text-yellow-500 mr-1" />}
                        {question.title}
                      </p>
                      <div className="ml-2 flex-shrink-0 flex">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                          ${question.difficulty === 'easy' ? 'bg-green-100 text-green-800' : 
                            question.difficulty === 'medium' ? 'bg-yellow-100 text-yellow-800' : 
                            'bg-red-100 text-red-800'}`}>
                          {question.difficulty === 'easy' ? '简单' : question.difficulty === 'medium' ? '中等' : '困难'}
                        </span>
                      </div>
                    </div>
                    <div className="flex justify-between items-center text-sm text-gray-500">
                      <div className="flex items-center gap-4">
                        <span>{getCategoryName(question.category_id)}</span>
                        <span className="hidden sm:inline">浏览: {question.view_count}</span>
                        <span className="hidden sm:inline">答题: {question.attempt_count}</span>
                      </div>
                      <span className="text-xs text-gray-400">
                        {new Date(question.created_at).toLocaleDateString()}
                      </span>
                    </div>
                  </div>
                  <div className="ml-5 flex-shrink-0 flex space-x-2">
                    <Link
                      to={`/admin/questions/${question.id}`}
                      className="p-2 text-gray-400 hover:text-blue-600 transition"
                      title="编辑"
                    >
                      <Edit className="h-5 w-5" />
                    </Link>
                    <button
                      onClick={() => handleDelete(question.id)}
                      className="p-2 text-gray-400 hover:text-red-600 transition"
                      title="删除"
                    >
                      <Trash2 className="h-5 w-5" />
                    </button>
                  </div>
                </div>
              </li>
            ))
          )}
        </ul>
        
        {/* Pagination */}
        {!loading && totalPages > 1 && (
          <div className="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
            <div className="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
              <div>
                <p className="text-sm text-gray-700">
                  显示第 <span className="font-medium">{(page - 1) * PAGE_SIZE + 1}</span> 到 <span className="font-medium">{Math.min(page * PAGE_SIZE, totalCount)}</span> 条，
                  共 <span className="font-medium">{totalCount}</span> 条
                </p>
              </div>
              <div>
                <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                  <button
                    onClick={() => setPage(p => Math.max(1, p - 1))}
                    disabled={page === 1}
                    className="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <span className="sr-only">Previous</span>
                    <ChevronLeft className="h-5 w-5" />
                  </button>
                  
                  {/* Simple Pagination Numbers */}
                  {Array.from({ length: totalPages }, (_, i) => i + 1)
                    .filter(p => p === 1 || p === totalPages || Math.abs(page - p) <= 1)
                    .map((p, i, arr) => {
                      // Add ellipsis logic if needed, simple version here
                      const showEllipsis = i > 0 && p - arr[i - 1] > 1;
                      return (
                        <React.Fragment key={p}>
                          {showEllipsis && <span className="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700">...</span>}
                          <button
                            onClick={() => setPage(p)}
                            className={`relative inline-flex items-center px-4 py-2 border text-sm font-medium ${
                              page === p
                                ? 'z-10 bg-blue-50 border-blue-500 text-blue-600'
                                : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'
                            }`}
                          >
                            {p}
                          </button>
                        </React.Fragment>
                      );
                    })}

                  <button
                    onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                    disabled={page === totalPages}
                    className="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <span className="sr-only">Next</span>
                    <ChevronRight className="h-5 w-5" />
                  </button>
                </nav>
              </div>
            </div>
            
            {/* Mobile Pagination */}
            <div className="flex items-center justify-between sm:hidden w-full">
               <button
                  onClick={() => setPage(p => Math.max(1, p - 1))}
                  disabled={page === 1}
                  className="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
                >
                  上一页
                </button>
                <span className="text-sm text-gray-700">
                  {page} / {totalPages}
                </span>
                <button
                  onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                  disabled={page === totalPages}
                  className="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
                >
                  下一页
                </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
