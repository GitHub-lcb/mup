import { useChat } from '@ai-sdk/react';
import { Bot, X, Send, Sparkles } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import ReactMarkdown from 'react-markdown';

interface AITutorProps {
  question: {
    title: string;
    content: string;
    options?: any;
    explanation?: string | null;
  };
  userAnswer?: string | null;
  correctAnswer?: string;
  isOpen: boolean;
  onClose: () => void;
}

export default function AITutor({ question, userAnswer, correctAnswer, isOpen, onClose }: AITutorProps) {
  const [localInput, setLocalInput] = useState('');

  // @ts-ignore
  const { messages, append, isLoading, setMessages } = useChat({
    // @ts-ignore
    api: '/api/chat',
    onError: (error) => {
      console.error('AI Chat Error:', error);
      alert('AI 响应出错，请稍后重试: ' + error.message);
    },
    body: {
      context: {
        title: question.title,
        content: question.content,
        userAnswer,
        correctAnswer,
      },
    },
  });

  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages]);

  // Initial greeting when opening
  useEffect(() => {
    if (isOpen && messages.length === 0) {
      const initialMessage = userAnswer 
        ? `我刚才这道题选了 ${userAnswer}，但是正确答案是 ${correctAnswer}。能帮我分析一下为什么我错了吗？`
        : `你好，能帮我讲解一下这道题的考点吗？`;
      
      // We don't automatically send it to save tokens, just pre-fill or let user type.
      // Or better, let's append a system message from the bot to start.
      setMessages([
        {
          id: 'welcome',
          role: 'assistant',
          // @ts-ignore
          content: '你好！我是你的 AI 面试助教。关于这道题，你有什么想问的吗？我可以帮你分析错误原因，或者讲解相关知识点。',
        },
      ]);
    }
  }, [isOpen]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!localInput.trim() || isLoading) return;

    const content = localInput;
    setLocalInput(''); // Clear input immediately
    
    await append({
      role: 'user',
      content: content,
    });
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-y-0 right-0 w-full md:w-96 bg-white shadow-2xl transform transition-transform duration-300 ease-in-out z-50 flex flex-col border-l border-gray-200">
      {/* Header */}
      <div className="p-4 border-b border-gray-200 bg-gradient-to-r from-blue-600 to-indigo-600 text-white flex justify-between items-center">
        <div className="flex items-center">
          <div className="p-2 bg-white/20 rounded-full mr-3">
            <Bot className="w-6 h-6 text-white" />
          </div>
          <div>
            <h3 className="font-bold text-lg">AI 助教</h3>
            <p className="text-xs text-blue-100">Powered by DeepSeek</p>
          </div>
        </div>
        <button onClick={onClose} className="text-white/80 hover:text-white transition">
          <X className="w-6 h-6" />
        </button>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50">
        {messages.map((m) => (
          <div
            key={m.id}
            className={`flex ${m.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[85%] rounded-2xl p-4 shadow-sm ${
                m.role === 'user'
                  ? 'bg-blue-600 text-white rounded-br-none'
                  : 'bg-white text-gray-800 border border-gray-100 rounded-bl-none'
              }`}
            >
              <div className="prose prose-sm max-w-none dark:prose-invert">
                 {/* @ts-ignore */}
                 <ReactMarkdown>{m.content}</ReactMarkdown>
              </div>
            </div>
          </div>
        ))}
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-white p-4 rounded-2xl rounded-bl-none border border-gray-100 shadow-sm">
              <div className="flex space-x-2">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-100"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-200"></div>
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t border-gray-200 bg-white">
        <form onSubmit={handleSend} className="flex gap-2">
          <input
            value={localInput}
            onChange={(e) => setLocalInput(e.target.value)}
            placeholder="输入你的问题..."
            className="flex-1 border border-gray-300 rounded-full px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm"
          />
          <button
            type="submit"
            disabled={isLoading || !localInput.trim()}
            className="bg-blue-600 text-white p-2 rounded-full hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Send className="w-5 h-5" />
          </button>
        </form>
      </div>
    </div>
  );
}
