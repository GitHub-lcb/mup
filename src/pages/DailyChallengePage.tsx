import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { Question } from '../types';
import { Calendar, CheckCircle, ArrowRight } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function DailyChallengePage() {
  const { user } = useAuth();
  const [questions, setQuestions] = useState<Question[]>([]);
  const [loading, setLoading] = useState(true);
  const [completedCount, setCompletedCount] = useState(0);

  useEffect(() => {
    fetchDailyQuestions();
  }, [user]);

  const fetchDailyQuestions = async () => {
    try {
      setLoading(true);
      // Generate a seed based on today's date (YYYY-MM-DD)
      // This ensures everyone gets the same "random" questions for the day
      const today = new Date().toISOString().split('T')[0];
      const seed = today.split('-').join(''); // e.g. "20231027"
      
      // Since Supabase/Postgres random() is not seedable per request easily without stored procedures,
      // and we want a stable set for the day, we can fetch IDs and pick deterministically client-side 
      // or server-side.
      // A simple robust way for a small app:
      // 1. Fetch ALL active question IDs.
      // 2. Use a pseudo-random generator seeded with today's date to pick 3 indices.
      
      const { data: allIds } = await supabase
        .from('questions')
        .select('id')
        .eq('is_active', true);

      if (!allIds || allIds.length === 0) return;

      // Pseudo-random number generator (PRNG) - Mulberry32
      // See: https://stackoverflow.com/a/47593316
      const seedNum = parseInt(seed, 10);
      let t = seedNum + 0x6D2B79F5;
      const random = () => {
        t = Math.imul(t ^ (t >>> 15), t | 1);
        t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
        return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
      };

      // Shuffle array using Fisher-Yates with seeded random
      const shuffled = [...allIds];
      for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
      }

      // Pick top 3
      const selectedIds = shuffled.slice(0, 3).map(q => q.id);

      // Fetch details for these 3
      const { data: dailyQuestions } = await supabase
        .from('questions')
        .select('*')
        .in('id', selectedIds);

      setQuestions(dailyQuestions || []);

      // Check completion status if user is logged in
      if (user && dailyQuestions) {
        // We check if the user has answered these questions *today*? 
        // Or just ever? "Daily Challenge" usually implies doing them today.
        // Let's check if there is an attempt created_at >= today.
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);

        const { data: attempts } = await supabase
          .from('question_attempts')
          .select('question_id')
          .eq('user_id', user.id)
          .in('question_id', selectedIds)
          .gte('created_at', startOfDay.toISOString());

        const completedSet = new Set(attempts?.map(a => a.question_id));
        // Mark questions as completed in local state if needed, or just count
        setCompletedCount(completedSet.size);
      }

    } catch (error) {
      console.error('Error fetching daily questions:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="text-center py-12">加载中...</div>;

  const allCompleted = questions.length > 0 && completedCount === questions.length;

  return (
    <div className="max-w-4xl mx-auto px-4 py-6">
      <div className="bg-gradient-to-r from-blue-600 to-indigo-700 rounded-2xl p-8 text-white mb-8 shadow-lg">
        <div className="flex items-center justify-between">
          <div>
            <div className="flex items-center gap-2 mb-2 opacity-90">
              <Calendar className="w-5 h-5" />
              <span className="text-sm font-medium">{new Date().toLocaleDateString('zh-CN')}</span>
            </div>
            <h1 className="text-3xl font-bold mb-2">每日一练</h1>
            <p className="opacity-90">
              每天 3 道精选面试题，保持手感，积少成多。
            </p>
          </div>
          <div className="hidden md:block">
            <div className="text-center bg-white/10 backdrop-blur-sm rounded-lg p-4">
              <div className="text-3xl font-bold">{completedCount}/{questions.length}</div>
              <div className="text-xs opacity-75">今日完成</div>
            </div>
          </div>
        </div>
      </div>

      {allCompleted && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-6 mb-8 flex items-center text-green-800">
          <CheckCircle className="w-8 h-8 mr-4 text-green-600" />
          <div>
            <h3 className="text-lg font-bold">挑战完成！</h3>
            <p>你已经完成了今天的练习，离 Offer 又近了一步！明天继续加油！</p>
          </div>
        </div>
      )}

      <div className="grid gap-4">
        {questions.map((question, index) => (
          <Link
            key={question.id}
            to={`/questions/${question.id}`}
            className="block bg-white p-6 rounded-lg shadow-sm hover:shadow-md transition border border-gray-100 group"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <span className="flex items-center justify-center w-8 h-8 rounded-full bg-gray-100 text-gray-500 font-bold text-sm">
                  {index + 1}
                </span>
                <div>
                  <h3 className="text-lg font-medium text-gray-900 group-hover:text-blue-600 transition-colors">
                    {question.title}
                  </h3>
                  <div className="flex gap-3 mt-1 text-xs text-gray-500">
                    <span className={`px-2 py-0.5 rounded-full ${
                      question.difficulty === 'easy' ? 'bg-green-50 text-green-700' :
                      question.difficulty === 'medium' ? 'bg-yellow-50 text-yellow-700' :
                      'bg-red-50 text-red-700'
                    }`}>
                      {question.difficulty === 'easy' ? '简单' : question.difficulty === 'medium' ? '中等' : '困难'}
                    </span>
                    {/* Check if we can show completion status per question? 
                        The detail page will show if it's done, but here we could too if we mapped it.
                        For simplicity, let's just link.
                    */}
                  </div>
                </div>
              </div>
              <ArrowRight className="w-5 h-5 text-gray-300 group-hover:text-blue-500 transition-colors" />
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
