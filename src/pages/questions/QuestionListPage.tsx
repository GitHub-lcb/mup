import { useEffect, useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import api from '../../lib/api';
import { Category, Question } from '../../types';
import { Search, Filter, ChevronLeft, ChevronRight, Lock } from 'lucide-react';

const PAGE_SIZE = 10;

export default function QuestionListPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [questions, setQuestions] = useState<Question[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [totalCount, setTotalCount] = useState(0);
  
  // Filters
  const categoryId = searchParams.get('category') || '';
  const difficulty = searchParams.get('difficulty') || '';
  const searchTerm = searchParams.get('search') || '';
  const page = parseInt(searchParams.get('page') || '1', 10);

  useEffect(() => {
    fetchCategories();
  }, []);

  useEffect(() => {
    fetchQuestions();
  }, [categoryId, difficulty, searchTerm, page]);

  const fetchCategories = async () => {
    const data: any = await api.categories.list();
    if (data) setCategories(data);
  };

  const fetchQuestions = async () => {
    setLoading(true);
    try {
      const params: any = {
        page,
        limit: PAGE_SIZE,
        is_active: 'true'
      };

      if (categoryId) params.category_id = categoryId;
      if (difficulty) params.difficulty = difficulty;
      if (searchTerm) params.search = searchTerm;

      const response: any = await api.questions.list(params);
      setQuestions(response.questions || []);
      setTotalCount(response.total || 0);
    } catch (error) {
      console.error('Error fetching questions:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const search = formData.get('search') as string;
    setSearchParams(prev => {
      prev.set('search', search);
      prev.set('page', '1'); // Reset to page 1
      return prev;
    });
  };

  const handleFilterChange = (key: string, value: string) => {
    setSearchParams(prev => {
      if (value) {
        prev.set(key, value);
      } else {
        prev.delete(key);
      }
      prev.set('page', '1'); // Reset to page 1
      return prev;
    });
  };

  const handlePageChange = (newPage: number) => {
    setSearchParams(prev => {
      prev.set('page', newPage.toString());
      return prev;
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const getDifficultyColor = (diff: string) => {
    switch (diff) {
      case 'easy': return 'text-green-600 bg-green-50';
      case 'medium': return 'text-yellow-600 bg-yellow-50';
      case 'hard': return 'text-red-600 bg-red-50';
      default: return 'text-gray-600 bg-gray-50';
    }
  };

  const getCategoryName = (id: string) => {
    return categories.find(c => c.id === id)?.name || '未分类';
  };

  const totalPages = Math.ceil(totalCount / PAGE_SIZE);

  return (
    <div className="flex flex-col md:flex-row gap-6">
      {/* Sidebar Filters */}
      <aside className="w-full md:w-64 space-y-6">
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <h3 className="font-semibold mb-4 flex items-center">
            <Filter className="w-4 h-4 mr-2" /> 筛选
          </h3>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">难度</label>
              <select
                value={difficulty}
                onChange={(e) => handleFilterChange('difficulty', e.target.value)}
                className="w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm p-2 border"
              >
                <option value="">全部</option>
                <option value="easy">简单</option>
                <option value="medium">中等</option>
                <option value="hard">困难</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">分类</label>
              <div className="space-y-2 max-h-60 overflow-y-auto">
                <div
                  className={`cursor-pointer px-2 py-1 rounded text-sm ${!categoryId ? 'bg-blue-50 text-blue-700 font-medium' : 'text-gray-600 hover:bg-gray-50'}`}
                  onClick={() => handleFilterChange('category', '')}
                >
                  全部
                </div>
                {categories.map(category => (
                  <div
                    key={category.id}
                    className={`cursor-pointer px-2 py-1 rounded text-sm ${categoryId === category.id ? 'bg-blue-50 text-blue-700 font-medium' : 'text-gray-600 hover:bg-gray-50'}`}
                    onClick={() => handleFilterChange('category', category.id)}
                  >
                    {category.name}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1">
        <div className="mb-6">
          <form onSubmit={handleSearch} className="flex gap-2">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                name="search"
                defaultValue={searchTerm}
                type="text"
                placeholder="搜索题目..."
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
              />
            </div>
            <button
              type="submit"
              className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
            >
              搜索
            </button>
          </form>
        </div>

        {loading ? (
          <div className="text-center py-12 text-gray-500">加载中...</div>
        ) : questions.length === 0 ? (
          <div className="text-center py-12 bg-white rounded-lg shadow-sm">
            <p className="text-gray-500">没有找到相关题目</p>
          </div>
        ) : (
          <div className="space-y-4">
            {questions.map(question => (
              <Link
                key={question.id}
                to={`/questions/${question.id}`}
                className="block bg-white p-6 rounded-lg shadow-sm hover:shadow-md transition border border-gray-100"
              >
                <div className="flex justify-between items-start mb-2">
                  <h3 className="text-lg font-medium text-gray-900 line-clamp-1 flex items-center">
                    {question.is_premium && <Lock className="w-4 h-4 text-yellow-500 mr-2" />}
                    {question.title}
                  </h3>
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${getDifficultyColor(question.difficulty)}`}>
                    {question.difficulty === 'easy' ? '简单' : question.difficulty === 'medium' ? '中等' : '困难'}
                  </span>
                </div>
                <div className="flex items-center gap-4 text-sm text-gray-500 mt-4">
                  <span>{getCategoryName(question.category_id || '')}</span>
                  <span>•</span>
                  <span>{question.view_count || 0} 次浏览</span>
                  <span>•</span>
                  <span>通过率 {((question.correct_rate || 0) * 100).toFixed(1)}%</span>
                </div>
              </Link>
            ))}

            {/* Pagination Controls */}
            {totalPages > 1 && (
              <div className="flex justify-center items-center gap-4 mt-8">
                <button
                  onClick={() => handlePageChange(page - 1)}
                  disabled={page === 1}
                  className="p-2 rounded-full hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <ChevronLeft className="w-5 h-5 text-gray-600" />
                </button>
                <span className="text-sm text-gray-600">
                  第 {page} 页 / 共 {totalPages} 页
                </span>
                <button
                  onClick={() => handlePageChange(page + 1)}
                  disabled={page === totalPages}
                  className="p-2 rounded-full hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <ChevronRight className="w-5 h-5 text-gray-600" />
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
