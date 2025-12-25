import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../lib/api';
import { Category } from '../types';
import * as Icons from 'lucide-react';
import { ArrowRight, BookOpen, Check, Star } from 'lucide-react';

export default function HomePage() {
  const { user } = useAuth();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      const data: any = await api.categories.list();
      setCategories(data || []);
    } catch (error) {
      console.error('Error fetching categories:', error);
    } finally {
      setLoading(false);
    }
  };

  const renderIcon = (iconName: string | null) => {
    // Default fallback
    const DefaultIcon = Icons.Code;
    if (!iconName) return <DefaultIcon className="w-5 h-5 text-gray-900" />;
    
    // Lucide icon mapping
    const iconMap: Record<string, any> = {
      code: Icons.Code,
      cube: Icons.Box,
      database: Icons.Database,
      cpu: Icons.Cpu,
      memory: Icons.Server,
      alert: Icons.AlertTriangle,
      folder: Icons.Folder,
      mirror: Icons.Monitor,
      layers: Icons.Layers,
      globe: Icons.Globe,
      server: Icons.Cloud,
      'git-branch': Icons.GitBranch,
      tool: Icons.Wrench,
    };
    
    // Special case
    if (iconName === 'git-branch') return <Icons.GitGraph className="w-5 h-5 text-gray-900" />;

    const IconComponent = iconMap[iconName] || DefaultIcon;
    return <IconComponent className="w-5 h-5 text-gray-900" />;
  };

  return (
    <div className="space-y-24 pb-12">
      {/* Hero Section - Minimalist */}
      <section className="text-center pt-12 md:pt-20 max-w-3xl mx-auto">
        <div className="inline-flex items-center px-3 py-1 rounded-full border border-gray-200 bg-gray-50 text-xs font-medium text-gray-600 mb-8">
          <span className="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
          备战 2026 金三银四
        </div>
        
        <h1 className="text-5xl md:text-7xl font-bold tracking-tight text-gray-900 mb-8 leading-[1.1]">
          精通 Java 面试<br />
          <span className="text-gray-400">拿下心仪 Offer</span>
        </h1>
        
        <p className="text-xl text-gray-500 mb-10 leading-relaxed max-w-2xl mx-auto">
          拒绝死记硬背。我们提供海量真题、深度源码解析与模拟面试环境，助你构建完整的知识体系。
        </p>

        <div className="flex flex-col sm:flex-row justify-center gap-4">
          {!user ? (
            <Link
              to="/auth/register"
              className="bg-gray-900 text-white px-8 py-3.5 rounded-lg font-medium hover:bg-black transition-colors flex items-center justify-center"
            >
              免费开始
              <ArrowRight className="w-4 h-4 ml-2" />
            </Link>
          ) : (
             <Link
              to="/questions"
              className="bg-gray-900 text-white px-8 py-3.5 rounded-lg font-medium hover:bg-black transition-colors flex items-center justify-center"
            >
              开始刷题
              <ArrowRight className="w-4 h-4 ml-2" />
            </Link>
          )}
          <Link
            to="/daily"
            className="bg-white text-gray-700 border border-gray-200 px-8 py-3.5 rounded-lg font-medium hover:bg-gray-50 transition-colors flex items-center justify-center"
          >
            每日一练
          </Link>
        </div>
      </section>

      {/* Categories - Clean Grid */}
      <section>
        <div className="flex justify-between items-end mb-10 border-b border-gray-100 pb-4">
          <h2 className="text-2xl font-semibold text-gray-900 tracking-tight">热门分类</h2>
          <Link to="/questions" className="text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors">
            浏览全部
          </Link>
        </div>
        
        {loading ? (
          <div className="py-12 text-center text-gray-400">加载中...</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {categories.map((category) => (
              <Link
                key={category.id}
                to={`/questions?category=${category.id}`}
                className="group p-5 bg-white rounded-xl border border-gray-100 hover:border-gray-300 transition-all duration-200 hover:shadow-sm"
              >
                <div className="w-10 h-10 rounded-lg bg-gray-50 flex items-center justify-center mb-4 group-hover:bg-gray-100 transition-colors">
                  {renderIcon(category.icon)}
                </div>
                <h3 className="font-medium text-gray-900 mb-1">{category.name}</h3>
                <p className="text-sm text-gray-500 line-clamp-2">
                  {category.description || '核心考点与面试真题'}
                </p>
              </Link>
            ))}
          </div>
        )}
      </section>

      {/* Features - Split Layout */}
      <section className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
        <div>
          <h2 className="text-3xl font-bold text-gray-900 mb-6">不仅是题库，<br />更是你的面试教练</h2>
          <div className="space-y-6">
            {[
              { title: '深度解析', desc: '每一道题都配备了详细的源码级解析，知其然更知其所以然。' },
              { title: '智能错题本', desc: '自动收集你的知识盲区，通过艾宾浩斯曲线科学复习。' },
              { title: '模拟面试', desc: '全真模拟大厂面试流程，提前适应高压环境。' },
            ].map((item, i) => (
              <div key={i} className="flex gap-4">
                <div className="flex-shrink-0 mt-1">
                  <div className="w-5 h-5 rounded-full bg-gray-100 flex items-center justify-center">
                    <Check className="w-3 h-3 text-gray-900" />
                  </div>
                </div>
                <div>
                  <h3 className="font-medium text-gray-900">{item.title}</h3>
                  <p className="text-sm text-gray-500 mt-1 leading-relaxed">{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className="bg-gray-50 rounded-2xl p-8 border border-gray-100 aspect-square md:aspect-auto flex items-center justify-center">
           {/* Placeholder for an abstract illustration or code snippet */}
           <div className="w-full max-w-sm bg-white rounded-xl shadow-sm border border-gray-200 p-6">
             <div className="flex items-center gap-3 mb-4 border-b border-gray-100 pb-4">
               <div className="w-3 h-3 rounded-full bg-red-400"></div>
               <div className="w-3 h-3 rounded-full bg-yellow-400"></div>
               <div className="w-3 h-3 rounded-full bg-green-400"></div>
             </div>
             <div className="space-y-2">
               <div className="h-2 bg-gray-100 rounded w-3/4"></div>
               <div className="h-2 bg-gray-100 rounded w-1/2"></div>
               <div className="h-2 bg-gray-100 rounded w-full"></div>
               <div className="h-2 bg-gray-100 rounded w-5/6"></div>
             </div>
             <div className="mt-6 flex justify-between items-center">
                <div className="h-8 w-24 bg-blue-50 rounded text-blue-600 text-xs flex items-center justify-center font-medium">
                  HashMap
                </div>
                <div className="text-xs text-gray-400">Difficulty: Hard</div>
             </div>
           </div>
        </div>
      </section>

      {/* Social Proof - Minimal */}
      <section className="border-t border-gray-100 pt-16">
        <div className="text-center mb-10">
          <p className="text-sm font-medium text-gray-500 uppercase tracking-wider">深受来自以下公司的开发者信赖</p>
        </div>
        <div className="flex flex-wrap justify-center gap-8 md:gap-16 opacity-50 grayscale hover:grayscale-0 transition-all duration-500">
          {/* Simple text logos for minimalism */}
          <span className="text-xl font-bold text-gray-800">Alibaba</span>
          <span className="text-xl font-bold text-gray-800">Tencent</span>
          <span className="text-xl font-bold text-gray-800">ByteDance</span>
          <span className="text-xl font-bold text-gray-800">Meituan</span>
          <span className="text-xl font-bold text-gray-800">JD.com</span>
        </div>
      </section>
    </div>
  );
}
