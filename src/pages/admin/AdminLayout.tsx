import React from 'react';
import { Link, Outlet, useLocation } from 'react-router-dom';
import { LayoutDashboard, FileText, Users, Settings } from 'lucide-react';
import clsx from 'clsx';

const navigation = [
  { name: '概览', href: '/admin', icon: LayoutDashboard, exact: true },
  { name: '题目管理', href: '/admin/questions', icon: FileText, exact: false },
  { name: '用户管理', href: '/admin/users', icon: Users, exact: false },
  // { name: '设置', href: '/admin/settings', icon: Settings, exact: false },
];

export default function AdminLayout() {
  const location = useLocation();

  return (
    <div className="flex h-[calc(100vh-64px)]">
      {/* Sidebar */}
      <div className="w-64 bg-white border-r border-gray-200 hidden md:block overflow-y-auto">
        <nav className="p-4 space-y-1">
          {navigation.map((item) => {
            const isActive = item.exact
              ? location.pathname === item.href
              : location.pathname.startsWith(item.href);
            
            return (
              <Link
                key={item.name}
                to={item.href}
                className={clsx(
                  isActive
                    ? 'bg-blue-50 text-blue-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900',
                  'group flex items-center px-3 py-2 text-sm font-medium rounded-md'
                )}
              >
                <item.icon
                  className={clsx(
                    isActive ? 'text-blue-700' : 'text-gray-400 group-hover:text-gray-500',
                    'mr-3 flex-shrink-0 h-6 w-6'
                  )}
                  aria-hidden="true"
                />
                {item.name}
              </Link>
            );
          })}
        </nav>
      </div>

      {/* Main content */}
      <div className="flex-1 overflow-auto bg-gray-50 p-8">
        <Outlet />
      </div>
    </div>
  );
}
