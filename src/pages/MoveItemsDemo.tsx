import { Link } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';

export default function MoveItemsDemo() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 to-teal-50 flex items-center justify-center p-6">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-xl p-8">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-emerald-100 mb-4">
            <svg className="w-8 h-8 text-emerald-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Move Items</h1>
          <p className="text-gray-500">Grocery List Management</p>
        </div>

        <div className="space-y-4">
          <div className="bg-emerald-50 rounded-xl p-4 border border-emerald-200">
            <h2 className="font-semibold text-emerald-900 mb-2">功能特性</h2>
            <ul className="space-y-2 text-sm text-emerald-800">
              <li className="flex items-start gap-2">
                <span className="text-emerald-500 mt-0.5">✓</span>
                <span>底部弹窗式设计，完美适配移动端</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-emerald-500 mt-0.5">✓</span>
                <span>实时搜索和筛选分类</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-emerald-500 mt-0.5">✓</span>
                <span>选中状态带勾选图标</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-emerald-500 mt-0.5">✓</span>
                <span>流畅的动画和过渡效果</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-emerald-500 mt-0.5">✓</span>
                <span>清除搜索快捷按钮</span>
              </li>
            </ul>
          </div>

          <Link
            to="/move-items"
            className="flex items-center justify-center gap-2 w-full bg-emerald-500 text-white font-semibold py-4 rounded-xl hover:bg-emerald-600 transition shadow-lg shadow-emerald-500/30"
          >
            查看效果
            <ArrowRight className="w-5 h-5" />
          </Link>

          <div className="text-center">
            <Link
              to="/"
              className="text-sm text-gray-500 hover:text-gray-700 transition"
            >
              返回首页
            </Link>
          </div>
        </div>

        <div className="mt-8 pt-6 border-t border-gray-200">
          <p className="text-xs text-gray-400 text-center">
            设计还原自 Grocery List 应用
          </p>
        </div>
      </div>
    </div>
  );
}
