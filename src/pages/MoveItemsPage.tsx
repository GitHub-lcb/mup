import { useState } from 'react';
import { ArrowLeft, FolderPlus, Search, X, Check } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

// 预设的分类建议
const SUGGESTED_SECTIONS = [
  'Bakery',
  'Dairy',
  'Produce',
  'Frozen',
  'Snacks',
  'Household',
];

export default function MoveItemsPage() {
  const navigate = useNavigate();
  const [selectedItems] = useState(3); // 模拟选中的项目数
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedSection, setSelectedSection] = useState('Bakery');

  const handleMoveItems = () => {
    // 处理移动逻辑
    console.log(`Moving ${selectedItems} items to ${selectedSection}`);
    navigate(-1); // 返回上一页
  };

  const filteredSections = SUGGESTED_SECTIONS.filter(section =>
    section.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-end justify-center sm:items-center">
      {/* 底部弹窗 */}
      <div className="bg-white rounded-t-3xl sm:rounded-2xl w-full max-w-2xl max-h-[85vh] flex flex-col animate-slide-up">
        {/* 顶部拖动条 */}
        <div className="flex justify-center pt-3 pb-2">
          <div className="w-12 h-1 bg-gray-300 rounded-full"></div>
        </div>

        {/* 标题栏 */}
        <div className="px-6 py-4 flex items-center justify-between border-b border-gray-100">
          <button
            onClick={() => navigate(-1)}
            className="p-2 hover:bg-gray-100 rounded-full transition -ml-2"
          >
            <ArrowLeft className="w-5 h-5 text-gray-600" />
          </button>
          <div className="flex-1 text-center">
            <h2 className="text-xl font-bold text-gray-900">Move to section</h2>
          </div>
          <button className="p-2 hover:bg-gray-100 rounded-full transition">
            <FolderPlus className="w-5 h-5 text-emerald-500" />
          </button>
        </div>

        {/* 提示文字 */}
        <div className="px-6 pt-4 pb-3">
          <p className="text-gray-500 text-sm">
            Move <span className="font-semibold text-gray-900">{selectedItems} selected items</span> to an existing section or create a new one.
          </p>
        </div>

        {/* 搜索框 */}
        <div className="px-6 pb-4">
          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search or create section..."
              className="w-full pl-12 pr-10 py-3.5 bg-gray-50 border-0 rounded-xl text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-3 top-1/2 -translate-y-1/2 p-1 hover:bg-gray-200 rounded-full transition"
              >
                <X className="w-4 h-4 text-gray-400" />
              </button>
            )}
          </div>
        </div>

        {/* 分类标签区域 */}
        <div className="px-6 pb-6 flex-1 overflow-y-auto">
          <div className="mb-3">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3">
              SUGGESTED SECTIONS
            </p>
          </div>

          <div className="flex flex-wrap gap-2">
            {filteredSections.map((section) => (
              <button
                key={section}
                onClick={() => setSelectedSection(section)}
                className={`
                  px-5 py-2.5 rounded-full font-medium text-sm transition-all
                  ${
                    selectedSection === section
                      ? 'bg-emerald-500/10 text-emerald-600 border-2 border-emerald-500 shadow-sm'
                      : 'bg-gray-100 text-gray-700 border-2 border-transparent hover:bg-gray-200'
                  }
                  flex items-center gap-2
                `}
              >
                {selectedSection === section && (
                  <Check className="w-4 h-4" />
                )}
                {section}
              </button>
            ))}
          </div>

          {filteredSections.length === 0 && (
            <div className="text-center py-8 text-gray-400">
              <p className="text-sm">No sections found</p>
              <p className="text-xs mt-1">Try a different search term</p>
            </div>
          )}
        </div>

        {/* 底部按钮 */}
        <div className="px-6 pb-8 pt-4 border-t border-gray-100 bg-white">
          <button
            onClick={handleMoveItems}
            disabled={!selectedSection}
            className="w-full bg-emerald-500 text-white font-semibold text-base py-4 rounded-2xl hover:bg-emerald-600 transition disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-emerald-500/20"
          >
            Move items
          </button>
        </div>

        {/* iOS 底部安全区域 */}
        <div className="h-safe-area-inset-bottom bg-white"></div>
      </div>

      <style>{`
        @keyframes slide-up {
          from {
            transform: translateY(100%);
          }
          to {
            transform: translateY(0);
          }
        }
        .animate-slide-up {
          animation: slide-up 0.3s ease-out;
        }
      `}</style>
    </div>
  );
}
