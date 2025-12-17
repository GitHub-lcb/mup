import { BookOpen, Github, Twitter } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Footer() {
  return (
    <footer className="bg-white border-t border-gray-200 mt-auto">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="col-span-1 md:col-span-1">
            <Link to="/" className="flex items-center">
              <BookOpen className="h-8 w-8 text-blue-600" />
              <span className="ml-2 text-xl font-bold text-gray-900">JavaMaster</span>
            </Link>
            <p className="mt-4 text-gray-500 text-sm">
              专注于 Java 程序员的面试备战平台。系统化刷题，助你轻松拿下大厂 Offer。
            </p>
          </div>
          
          <div>
            <h3 className="text-sm font-semibold text-gray-400 tracking-wider uppercase">产品</h3>
            <ul className="mt-4 space-y-4">
              <li>
                <Link to="/questions" className="text-base text-gray-500 hover:text-gray-900">
                  题库
                </Link>
              </li>
              <li>
                <Link to="/daily" className="text-base text-gray-500 hover:text-gray-900">
                  每日一练
                </Link>
              </li>
              <li>
                <Link to="/pricing" className="text-base text-gray-500 hover:text-gray-900">
                  会员计划
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="text-sm font-semibold text-gray-400 tracking-wider uppercase">资源</h3>
            <ul className="mt-4 space-y-4">
              <li>
                <Link to="/leaderboard" className="text-base text-gray-500 hover:text-gray-900">
                  排行榜
                </Link>
              </li>
              <li>
                <span className="text-base text-gray-500 cursor-not-allowed">
                  面试指南 (Coming Soon)
                </span>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="text-sm font-semibold text-gray-400 tracking-wider uppercase">关于</h3>
            <ul className="mt-4 space-y-4">
              <li>
                <a href="#" className="text-base text-gray-500 hover:text-gray-900">
                  关于我们
                </a>
              </li>
              <li>
                <a href="#" className="text-base text-gray-500 hover:text-gray-900">
                  联系方式
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="mt-8 border-t border-gray-200 pt-8 flex justify-between items-center">
          <p className="text-base text-gray-400">
            &copy; {new Date().getFullYear()} JavaMaster. All rights reserved.
          </p>
          <div className="flex space-x-6">
            <a href="#" className="text-gray-400 hover:text-gray-500">
              <span className="sr-only">GitHub</span>
              <Github className="h-6 w-6" />
            </a>
            <a href="#" className="text-gray-400 hover:text-gray-500">
              <span className="sr-only">Twitter</span>
              <Twitter className="h-6 w-6" />
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
