import React, { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase';
import { Users, FileText, CheckCircle, Eye } from 'lucide-react';

export default function AdminDashboard() {
  const [stats, setStats] = useState({
    userCount: 0,
    questionCount: 0,
    attemptCount: 0,
    viewCount: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      setLoading(true);
      const [
        { count: userCount },
        { count: questionCount },
        { count: attemptCount },
        { data: questions },
      ] = await Promise.all([
        supabase.from('users').select('*', { count: 'exact', head: true }),
        supabase.from('questions').select('*', { count: 'exact', head: true }),
        supabase.from('question_attempts').select('*', { count: 'exact', head: true }),
        supabase.from('questions').select('view_count'),
      ]);

      const totalViews = questions?.reduce((sum, q) => sum + (q.view_count || 0), 0) || 0;

      setStats({
        userCount: userCount || 0,
        questionCount: questionCount || 0,
        attemptCount: attemptCount || 0,
        viewCount: totalViews,
      });
    } catch (error) {
      console.error('Error fetching stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const statCards = [
    { name: '总用户数', value: stats.userCount, icon: Users, color: 'text-blue-600', bg: 'bg-blue-100' },
    { name: '总题目数', value: stats.questionCount, icon: FileText, color: 'text-green-600', bg: 'bg-green-100' },
    { name: '总答题次数', value: stats.attemptCount, icon: CheckCircle, color: 'text-purple-600', bg: 'bg-purple-100' },
    { name: '题目浏览量', value: stats.viewCount, icon: Eye, color: 'text-orange-600', bg: 'bg-orange-100' },
  ];

  if (loading) {
    return <div>加载中...</div>;
  }

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">仪表盘</h1>
      
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {statCards.map((item) => (
          <div
            key={item.name}
            className="relative bg-white pt-5 px-4 pb-12 sm:pt-6 sm:px-6 shadow rounded-lg overflow-hidden"
          >
            <dt>
              <div className={`absolute rounded-md p-3 ${item.bg}`}>
                <item.icon className={`h-6 w-6 ${item.color}`} aria-hidden="true" />
              </div>
              <p className="ml-16 text-sm font-medium text-gray-500 truncate">{item.name}</p>
            </dt>
            <dd className="ml-16 pb-1 flex items-baseline sm:pb-2">
              <p className="text-2xl font-semibold text-gray-900">{item.value}</p>
            </dd>
          </div>
        ))}
      </div>

      <div className="mt-8">
        <h2 className="text-lg font-medium text-gray-900 mb-4">快速操作</h2>
        <div className="bg-white shadow sm:rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-base font-semibold leading-6 text-gray-900">管理题目</h3>
            <div className="mt-2 max-w-xl text-sm text-gray-500">
              <p>您可以添加新的面试题，编辑现有题目，或者管理题目的分类和难度。</p>
            </div>
            <div className="mt-5">
              <a
                href="/admin/questions/new"
                className="inline-flex items-center rounded-md bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
              >
                添加新题目
              </a>
              <a
                href="/admin/questions"
                className="ml-3 inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
              >
                查看题目列表
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
