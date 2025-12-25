import { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import api from '../../lib/api';
import { Question } from '../../types';
import { useAuth } from '../../context/AuthContext';
import { Star, ArrowLeft, CheckCircle, XCircle } from 'lucide-react';
// @ts-ignore
import ReactMarkdown from 'react-markdown';
// @ts-ignore
import rehypeHighlight from 'rehype-highlight';
import 'highlight.js/styles/github-dark.css';
import CommentsSection from '../../components/CommentsSection';

import { Lock, Sparkles } from 'lucide-react';
import AITutor from '../../components/AITutor';

export default function QuestionDetailPage() {
  const { id } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [question, setQuestion] = useState<Question | null>(null);
  const [loading, setLoading] = useState(true);
  
  const [showAITutor, setShowAITutor] = useState(false);
  
  // Single selection: string; Multiple selection: string[]
  const [selectedOption, setSelectedOption] = useState<string | string[] | null>(null);
  
  const [submitted, setSubmitted] = useState(false);
  const [isCorrect, setIsCorrect] = useState(false);
  const [isFavorite, setIsFavorite] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (id) {
      fetchQuestion(id);
      if (user) {
        checkFavorite(id);
      }
    }
  }, [id, user]);

  const fetchQuestion = async (questionId: string) => {
    try {
      const data = await api.questions.get(questionId) as Question;
      setQuestion(data);
      // Reset state when question changes
      setSelectedOption(data.type === 'multiple' ? [] : null);
      setSubmitted(false);
      setIsCorrect(false);
    } catch (error) {
      console.error('Error fetching question:', error);
    } finally {
      setLoading(false);
    }
  };

  const checkFavorite = async (questionId: string) => {
    if (!user) return;
    try {
      const result = await api.favorites.check(questionId) as { isFavorite: boolean };
      setIsFavorite(result.isFavorite);
    } catch (error) {
      console.error('Error checking favorite:', error);
    }
  };

  const toggleFavorite = async () => {
    if (!user || !question) return;

    try {
      if (isFavorite) {
        await api.favorites.remove(question.id);
        setIsFavorite(false);
      } else {
        await api.favorites.add({ question_id: question.id });
        setIsFavorite(true);
      }
    } catch (error) {
      console.error('Error toggling favorite:', error);
    }
  };

  const handleOptionChange = (value: string) => {
    if (submitted) return;

    if (question?.type === 'multiple') {
      // Multiple selection logic
      const current = Array.isArray(selectedOption) ? selectedOption : [];
      if (current.includes(value)) {
        setSelectedOption(current.filter(v => v !== value));
      } else {
        setSelectedOption([...current, value].sort()); // Sort to ensure consistent order
      }
    } else {
      // Single selection logic
      setSelectedOption(value);
    }
  };

  const handleSubmit = async () => {
    if (!question || !selectedOption || submitting) return;
    
    setSubmitting(true);
    
    let correct = false;
    let userAnswerStr = '';

    if (question.type === 'multiple') {
      // Compare arrays
      const userAns = Array.isArray(selectedOption) ? selectedOption.sort().join(',') : '';
      // Correct answer in DB is stored as "A,B" string usually for multiple
      const correctAns = question.correct_answer.split(',').map(s => s.trim()).sort().join(',');
      correct = userAns === correctAns;
      userAnswerStr = userAns;
    } else {
      correct = selectedOption === question.correct_answer;
      userAnswerStr = selectedOption as string;
    }

    setIsCorrect(correct);
    setSubmitted(true);

    if (user) {
      try {
        await api.attempts.create({
          question_id: question.id,
          user_answer: userAnswerStr,
          is_correct: correct,
          time_spent: 0,
        });
      } catch (error) {
        console.error('Error recording attempt:', error);
      }
    }
    setSubmitting(false);
  };

  if (loading) return <div className="text-center py-12">加载中...</div>;
  if (!question) return <div className="text-center py-12">题目不存在</div>;

  // Access Control Check
  if (question.is_premium && !user?.is_pro) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-12 text-center">
        <div className="bg-white p-8 rounded-xl shadow-sm border border-gray-200">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-yellow-100 mb-6">
            <Lock className="w-8 h-8 text-yellow-600" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-4">此题目仅限 Pro 会员可见</h2>
          <p className="text-gray-500 mb-8 max-w-md mx-auto">
            这是一道精选的高级面试题，包含深度解析和源码分析。升级会员即可永久解锁所有高级内容。
          </p>
          <div className="space-x-4">
            <button
              onClick={() => navigate('/pricing')}
              className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
            >
              立即升级
            </button>
            <button
              onClick={() => navigate('/questions')}
              className="inline-flex items-center px-6 py-3 border border-gray-300 text-base font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              返回列表
            </button>
          </div>
        </div>
      </div>
    );
  }

  const renderOptions = () => {
    if (!question.options || !Array.isArray(question.options)) return null;

    return question.options.map((optionText: any, index: number) => {
      let value = '';
      let label = '';

      if (typeof optionText === 'string') {
        if (question.type === 'boolean') {
           value = String.fromCharCode(65 + index); // A, B
           label = optionText;
           // If boolean type, DB usually stores "true"/"false" as correct_answer?
           // My seed data used 'true'/'false' for boolean correct_answer, but options are just ["true", "false"]?
           // Let's check seed data. 
           // Example: '["true", "false"]', correct: 'true'.
           // If I map A->true, B->false.
           // Actually, for boolean, let's just use the value directly if it looks like boolean?
           // Or just stick to A/B mapping if correct_answer is 'A' or 'B'.
           // Wait, my seed data for boolean: options NULL usually? No, seed data 5 has boolean but options JSONB.
           // Re-reading seed data:
           // ('...Boolean...', '...boolean...', '["true", "false"]', 'true', ...)
           // So value should be "true" or "false".
           if (optionText === 'true' || optionText === 'false') {
             value = optionText;
           } else {
             value = String.fromCharCode(65 + index);
           }
        } else {
           value = String.fromCharCode(65 + index);
           label = `${value}. ${optionText}`;
        }
      } else if (typeof optionText === 'object') {
        value = optionText.value;
        label = optionText.label;
      }
      
      const isMultiple = question.type === 'multiple';
      let isSelected = false;
      
      if (isMultiple) {
        isSelected = Array.isArray(selectedOption) && selectedOption.includes(value);
      } else {
        isSelected = selectedOption === value;
      }

      // Check correctness for highlighting
      // For multiple: correct_answer is "A,B". value is "A".
      // isCorrectAnswer means this specific option IS part of the correct answer.
      const correctAnswers = question.type === 'multiple' 
        ? question.correct_answer.split(',').map(s => s.trim()) 
        : [question.correct_answer];
      
      const isPartOfCorrectAnswer = correctAnswers.includes(value);

      let borderClass = 'border-gray-200 hover:bg-gray-50';
      let bgClass = 'bg-white';
      
      if (submitted) {
        if (isPartOfCorrectAnswer) {
          borderClass = 'border-green-500';
          bgClass = 'bg-green-50';
        } else if (isSelected && !isPartOfCorrectAnswer) {
          borderClass = 'border-red-500';
          bgClass = 'bg-red-50';
        } else {
          bgClass = 'bg-gray-50 opacity-60';
        }
      } else if (isSelected) {
        borderClass = 'border-blue-500';
        bgClass = 'bg-blue-50';
      }

      return (
        <label
          key={index}
          className={`flex items-center p-4 border rounded-lg cursor-pointer transition ${borderClass} ${bgClass}`}
        >
          <input
            type={isMultiple ? 'checkbox' : 'radio'}
            name="option"
            value={value}
            checked={isSelected}
            onChange={() => handleOptionChange(value)}
            disabled={submitted}
            className={`mr-3 text-blue-600 focus:ring-blue-500 h-4 w-4 ${isMultiple ? 'rounded' : ''}`}
          />
          <span className="text-gray-800 flex-1">{label}</span>
          
          {submitted && isPartOfCorrectAnswer && (
            <CheckCircle className="w-5 h-5 text-green-500 ml-2 flex-shrink-0" />
          )}
          {submitted && isSelected && !isPartOfCorrectAnswer && (
            <XCircle className="w-5 h-5 text-red-500 ml-2 flex-shrink-0" />
          )}
        </label>
      );
    });
  };

  const isSubmitDisabled = submitting || 
    (question?.type === 'multiple' 
      ? (!selectedOption || (selectedOption as string[]).length === 0)
      : !selectedOption);

  return (
    <div className="max-w-4xl mx-auto px-4 py-6">
      <Link to="/questions" className="inline-flex items-center text-gray-500 hover:text-gray-900 mb-6">
        <ArrowLeft className="w-4 h-4 mr-1" /> 返回列表
      </Link>

      <div className="bg-white rounded-lg shadow-sm p-8">
        <div className="flex justify-between items-start mb-6">
          <div className="flex-1 mr-4">
            <div className="flex items-center gap-2 mb-2">
              <span className={`px-2 py-0.5 rounded text-xs font-medium 
                ${question.type === 'multiple' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'}`}>
                {question.type === 'multiple' ? '多选题' : question.type === 'boolean' ? '判断题' : '单选题'}
              </span>
              <span className={`px-2 py-0.5 rounded text-xs font-medium 
                ${question.difficulty === 'easy' ? 'bg-green-100 text-green-700' : 
                  question.difficulty === 'medium' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'}`}>
                {question.difficulty === 'easy' ? '简单' : question.difficulty === 'medium' ? '中等' : '困难'}
              </span>
            </div>
            <h1 className="text-2xl font-bold text-gray-900">{question.title}</h1>
          </div>
          {user && (
            <button
              onClick={toggleFavorite}
              className={`p-2 rounded-full hover:bg-gray-100 transition ${isFavorite ? 'text-yellow-400' : 'text-gray-300'}`}
              title={isFavorite ? '取消收藏' : '收藏题目'}
            >
              <Star className={`w-6 h-6 ${isFavorite ? 'fill-current' : ''}`} />
            </button>
          )}
        </div>

        <div className="prose max-w-none mb-8 text-gray-700">
          <ReactMarkdown rehypePlugins={[rehypeHighlight]}>
            {question.content}
          </ReactMarkdown>
        </div>

        {question.type !== 'fill' && (
          <div className="space-y-3 mb-8">
            {renderOptions()}
          </div>
        )}

        {!submitted ? (
          <button
            onClick={handleSubmit}
            disabled={isSubmitDisabled}
            className="w-full bg-blue-600 text-white py-3 rounded-lg font-medium hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            提交答案
          </button>
        ) : (
          <div className={`p-6 rounded-lg border ${isCorrect ? 'bg-green-50 border-green-100' : 'bg-red-50 border-red-100'}`}>
            <div className="flex items-center mb-4">
              {isCorrect ? (
                <CheckCircle className="w-6 h-6 text-green-600 mr-2" />
              ) : (
                <XCircle className="w-6 h-6 text-red-600 mr-2" />
              )}
              <h3 className={`text-lg font-bold ${isCorrect ? 'text-green-800' : 'text-red-800'}`}>
                {isCorrect ? '回答正确！' : '回答错误'}
              </h3>
            </div>
            
            <div className="mt-4 flex justify-end">
              <button
                onClick={() => setShowAITutor(true)}
                className="flex items-center text-sm text-blue-600 hover:text-blue-700 font-medium bg-blue-50 px-3 py-1.5 rounded-full transition border border-blue-200"
              >
                <Sparkles className="w-4 h-4 mr-1.5" />
                让 AI 帮我分析
              </button>
            </div>

            {question.explanation && (
              <div className="mt-4 pt-4 border-t border-gray-200/50">
                <h4 className="font-semibold text-gray-900 mb-3 flex items-center">
                  <span className="w-1 h-6 bg-blue-500 rounded-full mr-2"></span>
                  题目解析
                </h4>
                <div className="prose max-w-none text-gray-700 bg-white p-4 rounded-md border border-gray-100">
                  <ReactMarkdown rehypePlugins={[rehypeHighlight]}>
                    {question.explanation}
                  </ReactMarkdown>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Comments Section */}
        {question && <CommentsSection questionId={question.id} />}
      </div>

      {/* AI Tutor Sidebar */}
      {question && (
        <AITutor
          isOpen={showAITutor}
          onClose={() => setShowAITutor(false)}
          question={{
            title: question.title,
            content: question.content,
            options: question.options,
            explanation: question.explanation
          }}
          userAnswer={
            Array.isArray(selectedOption) 
              ? selectedOption.join(',') 
              : selectedOption as string
          }
          correctAnswer={question.correct_answer}
        />
      )}
    </div>
  );
}
