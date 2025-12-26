import { useEffect, useState } from 'react';
import { Trophy, Medal, Award, User as UserIcon } from 'lucide-react';
import api from '../lib/api';

interface LeaderboardUser {
  id: string;
  nickname: string | null;
  email: string;
  correct_count: number;
  accuracy: number;
  rank?: number;
}

export default function LeaderboardPage() {
  const [users, setUsers] = useState<LeaderboardUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [period, setPeriod] = useState<'all' | 'week'>('all'); // Future: support time periods

  useEffect(() => {
    fetchLeaderboard();
  }, [period]);

  const fetchLeaderboard = async () => {
    try {
      setLoading(true);
      const data = await api.leaderboard.get() as LeaderboardUser[];
      setUsers(data || []);
    } catch (error) {
      console.error('Error fetching leaderboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const getRankIcon = (index: number) => {
    switch (index) {
      case 0: return <Trophy className="w-6 h-6 text-yellow-500" />;
      case 1: return <Medal className="w-6 h-6 text-gray-400" />;
      case 2: return <Medal className="w-6 h-6 text-orange-600" />;
      default: return <span className="text-gray-500 font-bold w-6 text-center">{index + 1}</span>;
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-6">
      <div className="text-center mb-10">
        <h1 className="text-3xl font-bold text-gray-900 mb-2 flex items-center justify-center">
          <Award className="w-8 h-8 text-yellow-500 mr-2" />
          刷题排行榜
        </h1>
        <p className="text-gray-500">看看谁是真正的 Java 面试大师</p>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="p-4 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
          <h3 className="font-semibold text-gray-700">总榜</h3>
          {/* <div className="space-x-2">
            <button className="text-sm px-3 py-1 bg-white border rounded shadow-sm">总榜</button>
            <button className="text-sm px-3 py-1 text-gray-500 hover:bg-gray-100 rounded">周榜</button>
          </div> */}
        </div>

        {loading ? (
          <div className="p-12 text-center text-gray-500">加载排行中...</div>
        ) : (
          <div className="divide-y divide-gray-100">
            {users.length === 0 ? (
              <div className="p-12 text-center text-gray-500">暂无数据，快来抢占榜首！</div>
            ) : (
              users.map((user, index) => (
                <div key={user.id} className="flex items-center p-4 hover:bg-blue-50 transition-colors">
                  <div className="flex-shrink-0 w-12 flex justify-center">
                    {getRankIcon(index)}
                  </div>
                  <div className="flex-shrink-0 mr-4">
                    <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center text-gray-500">
                      <UserIcon className="w-6 h-6" />
                    </div>
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {user.nickname || user.email.split('@')[0] || '匿名用户'}
                    </p>
                    <p className="text-xs text-gray-500 truncate">
                      {user.email.replace(/(.{2})(.*)(@.*)/, '$1***$3')}
                    </p>
                  </div>
                  <div className="text-right">
                    <div className="text-lg font-bold text-blue-600">
                      {user.correct_count} <span className="text-xs font-normal text-gray-500">题</span>
                    </div>
                    <div className="text-xs text-gray-400">
                      正确率 {user.accuracy.toFixed(1)}%
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </div>
    </div>
  );
}
