import { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { Category } from '../../types';
import { Chart as ChartJS, ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title } from 'chart.js';
import { Doughnut, Bar } from 'react-chartjs-2';
import api from '../../lib/api';

ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title);

export default function ProgressPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [categories, setCategories] = useState<Category[]>([]);
  const [progressData, setProgressData] = useState<any[]>([]);
  const [overallStats, setOverallStats] = useState({
    total: 0,
    answered: 0,
    correct: 0,
    accuracy: 0,
  });

  useEffect(() => {
    if (user) {
      fetchData();
    }
  }, [user]);

  const fetchData = async () => {
    try {
      setLoading(true);
      
      // 获取分类
      const categoriesData = await api.categories.list() as Category[];
      setCategories(categoriesData || []);

      if (!user) return;

      // 获取用户进度
      const progressResponse = await api.users.progress() as any;
      const { overall, categories: categoryProgress } = progressResponse;

      setOverallStats({
        total: overall.total_questions || 0,
        answered: overall.answered_questions || 0,
        correct: overall.correct_answers || 0,
        accuracy: parseFloat(overall.accuracy) || 0,
      });

      // 构建分类进度数据
      const progressData = categoriesData.map(cat => {
        const catProgress = categoryProgress?.find((p: any) => p.id === cat.id);
        return {
          name: cat.name,
          answered: catProgress?.answered_questions || 0,
          correct: catProgress?.correct_answers || 0,
        };
      });
      
      setProgressData(progressData);
    } catch (error) {
      console.error('Error fetching progress:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="text-center py-12">加载中...</div>;

  const doughnutData = {
    labels: ['已掌握', '错误/未掌握', '未答'],
    datasets: [
      {
        data: [
          overallStats.correct,
          overallStats.answered - overallStats.correct,
          overallStats.total - overallStats.answered
        ],
        backgroundColor: [
          'rgba(34, 197, 94, 0.8)', // Green
          'rgba(239, 68, 68, 0.8)', // Red
          'rgba(229, 231, 235, 0.8)', // Gray
        ],
        borderWidth: 1,
      },
    ],
  };

  const barData = {
    labels: progressData.map(d => d.name),
    datasets: [
      {
        label: '已回答',
        data: progressData.map(d => d.answered),
        backgroundColor: 'rgba(59, 130, 246, 0.5)',
      },
      {
        label: '正确',
        data: progressData.map(d => d.correct),
        backgroundColor: 'rgba(34, 197, 94, 0.5)',
      },
    ],
  };

  const barOptions = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top' as const,
      },
      title: {
        display: true,
        text: '各分类学习情况',
      },
    },
  };

  return (
    <div className="max-w-6xl mx-auto space-y-8">
      <h1 className="text-3xl font-bold text-gray-900">学习进度概览</h1>

      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
          <p className="text-sm text-gray-500 mb-1">总刷题数</p>
          <p className="text-3xl font-bold text-blue-600">{overallStats.answered}</p>
          <p className="text-xs text-gray-400 mt-2">共 {overallStats.total} 道题目</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
          <p className="text-sm text-gray-500 mb-1">正确题数</p>
          <p className="text-3xl font-bold text-green-600">{overallStats.correct}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
          <p className="text-sm text-gray-500 mb-1">正确率</p>
          <p className="text-3xl font-bold text-purple-600">{overallStats.accuracy.toFixed(1)}%</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
          <p className="text-sm text-gray-500 mb-1">完成度</p>
          <p className="text-3xl font-bold text-orange-600">
            {overallStats.total > 0 ? ((overallStats.answered / overallStats.total) * 100).toFixed(1) : 0}%
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Doughnut Chart */}
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100 lg:col-span-1">
          <h2 className="text-lg font-semibold mb-6">总体掌握情况</h2>
          <div className="relative h-64">
            <Doughnut data={doughnutData} options={{ maintainAspectRatio: false }} />
          </div>
        </div>

        {/* Bar Chart */}
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100 lg:col-span-2">
          <h2 className="text-lg font-semibold mb-6">知识点分布</h2>
          <div className="relative h-64">
            <Bar data={barData} options={{ ...barOptions, maintainAspectRatio: false }} />
          </div>
        </div>
      </div>
    </div>
  );
}
