import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../../lib/supabase';
import { Question } from '../../types';
import { useAuth } from '../../context/AuthContext';
import { BookX, ArrowRight, Trash2 } from 'lucide-react';

export default function MistakesPage() {
  const { user } = useAuth();
  const [mistakes, setMistakes] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      fetchMistakes();
    }
  }, [user]);

  const fetchMistakes = async () => {
    try {
      setLoading(true);
      // We want to find questions where the *latest* attempt was incorrect, 
      // OR simply all questions that have ever been answered incorrectly and not yet mastered?
      // For simplicity and standard "Mistake Book" logic: 
      // Show questions where the USER has records with is_correct = false.
      // To be smarter: We can show questions where the *last* attempt was false.
      
      // Let's fetch all attempts for this user, ordered by time.
      const { data: attempts, error } = await supabase
        .from('question_attempts')
        .select('question_id, is_correct, created_at, questions(*)')
        .eq('user_id', user!.id)
        .order('created_at', { ascending: false });

      if (error) throw error;

      // Filter to find the latest status of each question
      const questionStatus = new Map();
      attempts.forEach((attempt: any) => {
        if (!questionStatus.has(attempt.question_id)) {
          questionStatus.set(attempt.question_id, {
            ...attempt.questions,
            last_attempt_at: attempt.created_at,
            is_mastered: attempt.is_correct // The latest attempt determines status
          });
        }
      });

      // Filter only those where is_mastered is false (i.e., last attempt was wrong)
      const wrongQuestions = Array.from(questionStatus.values()).filter(q => !q.is_mastered);
      setMistakes(wrongQuestions);

    } catch (error) {
      console.error('Error fetching mistakes:', error);
    } finally {
      setLoading(false);
    }
  };

  const removeMistake = async (e: React.MouseEvent, questionId: string) => {
    e.preventDefault(); // Prevent navigation
    if (!confirm('确定要将此题目移出错题本吗？(这意味着您认为已经掌握了它)')) return;

    // To "remove" from mistakes logically, we could either:
    // 1. Delete the wrong attempts (Bad for history)
    // 2. Insert a "fake" correct attempt? (A bit hacky)
    // 3. Or just UI removal?
    // Let's go with a pragmatic approach: Just hide it from UI state for now, 
    // or maybe we assume the user "Mastered" it manually.
    // Ideally, we'd have a 'mastered_questions' table or flag.
    // For now, let's just delete the history of *wrong* attempts for this question? 
    // No, data loss.
    // Let's just remove it from the list in memory to give feedback, 
    // but persistent removal really requires re-answering it correctly.
    // Let's guide user: "Please answer it correctly to remove it."
    // OR: We insert a correct attempt record manually marked as "Manual Mastery"?
    
    // Let's try inserting a correct record to "fix" the status.
    try {
      await supabase.from('question_attempts').insert({
        user_id: user!.id,
        question_id: questionId,
        is_correct: true,
        user_answer: 'MANUAL_MARK_AS_MASTERED',
        time_spent: 0
      });
      setMistakes(prev => prev.filter(q => q.id !== questionId));
    } catch (error) {
      console.error('Error removing mistake:', error);
    }
  };

  if (loading) return <div className="text-center py-12">加载中...</div>;

  return (
    <div className="max-w-4xl mx-auto px-4 py-6">
      <div className="flex items-center mb-8">
        <div className="p-3 bg-red-100 rounded-full mr-4">
          <BookX className="w-8 h-8 text-red-600" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">错题本</h1>
          <p className="text-gray-500">
            这里收录了您最近一次答错的题目，共 {mistakes.length} 道。加油攻克它们！
          </p>
        </div>
      </div>

      {mistakes.length === 0 ? (
        <div className="text-center py-16 bg-white rounded-lg shadow-sm">
          <div className="inline-block p-4 bg-green-50 rounded-full mb-4">
            <BookX className="w-12 h-12 text-green-400" />
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">太棒了！</h3>
          <p className="text-gray-500 mb-6">您目前没有待复习的错题。</p>
          <Link
            to="/questions"
            className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
          >
            去刷题
          </Link>
        </div>
      ) : (
        <div className="grid gap-4">
          {mistakes.map((question) => (
            <Link
              key={question.id}
              to={`/questions/${question.id}`}
              className="block bg-white p-6 rounded-lg shadow-sm hover:shadow-md transition border border-gray-100 group relative"
            >
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="px-2 py-0.5 rounded text-xs font-medium bg-red-50 text-red-700 border border-red-100">
                      上次答错
                    </span>
                    <span className={`px-2 py-0.5 rounded text-xs font-medium 
                      ${question.difficulty === 'easy' ? 'bg-green-50 text-green-700' : 
                        question.difficulty === 'medium' ? 'bg-yellow-50 text-yellow-700' : 'bg-red-50 text-red-700'}`}>
                      {question.difficulty === 'easy' ? '简单' : question.difficulty === 'medium' ? '中等' : '困难'}
                    </span>
                  </div>
                  <h3 className="text-lg font-medium text-gray-900 mb-2 group-hover:text-blue-600 transition-colors">
                    {question.title}
                  </h3>
                  <p className="text-sm text-gray-500 flex items-center">
                    复习此题 <ArrowRight className="w-4 h-4 ml-1 opacity-0 group-hover:opacity-100 transition-all transform group-hover:translate-x-1" />
                  </p>
                </div>
                
                <button
                  onClick={(e) => removeMistake(e, question.id)}
                  className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-full transition-colors z-10"
                  title="标记为已掌握（移出错题本）"
                >
                  <Trash2 className="w-5 h-5" />
                </button>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
