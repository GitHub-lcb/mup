import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import { Check, Crown } from 'lucide-react';

export default function PricingPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [processing, setProcessing] = useState(false);

  const handleUpgrade = async () => {
    if (!user) {
      navigate('/auth/login');
      return;
    }

    setProcessing(true);
    try {
      // 1. Get Access Token
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) throw new Error('No session');

      // 2. Call Backend API to create Checkout Session
      const response = await fetch('/api/create-checkout-session', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          token: session.access_token,
          successUrl: `${window.location.origin}/questions?upgraded=true`,
          cancelUrl: window.location.href,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Payment initiation failed');
      }

      const { url } = await response.json();

      // 3. Redirect to Stripe
      if (url) {
        window.location.href = url;
      } else {
        throw new Error('No checkout URL returned');
      }
    } catch (error: any) {
      console.error('Upgrade failed:', error);
      alert('支付启动失败，请稍后重试: ' + error.message);
    } finally {
      setProcessing(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <div className="text-center">
        <h2 className="text-base font-semibold text-blue-600 tracking-wide uppercase">会员计划</h2>
        <p className="mt-1 text-4xl font-extrabold text-gray-900 sm:text-5xl sm:tracking-tight lg:text-6xl">
          投资你的未来
        </p>
        <p className="max-w-xl mt-5 mx-auto text-xl text-gray-500">
          解锁所有高级面试题，助你轻松拿下大厂 Offer。
        </p>
      </div>

      <div className="mt-16 flex justify-center">
        <div className="relative bg-white border border-gray-200 rounded-2xl shadow-sm max-w-lg w-full">
          <div className="absolute top-0 right-0 -mt-4 -mr-4 bg-yellow-400 rounded-full p-2 shadow-lg">
            <Crown className="w-8 h-8 text-white" />
          </div>
          
          <div className="p-8">
            <h3 className="text-2xl font-semibold text-gray-900">Pro 会员</h3>
            <p className="mt-4 text-gray-500">一次性付费，永久解锁所有内容。</p>
            <p className="mt-8">
              <span className="text-5xl font-extrabold text-gray-900">¥99</span>
              <span className="text-base font-medium text-gray-500">/ 永久</span>
            </p>

            <button
              onClick={handleUpgrade}
              disabled={processing || user?.is_pro}
              className={`mt-8 w-full block bg-blue-600 border border-transparent rounded-md py-3 text-sm font-semibold text-white text-center hover:bg-blue-700 transition ${
                user?.is_pro ? 'opacity-50 cursor-not-allowed bg-green-600 hover:bg-green-600' : ''
              }`}
            >
              {user?.is_pro ? '您已是尊贵的 Pro 会员' : processing ? '正在前往支付...' : '立即升级'}
            </button>
            <p className="mt-4 text-xs text-center text-gray-400">
              支持支付宝 / 微信支付 (通过 Stripe)
            </p>
          </div>

          <div className="pt-6 pb-8 px-8 bg-gray-50 rounded-b-2xl">
            <h4 className="text-sm font-medium text-gray-900 tracking-wide uppercase">会员权益</h4>
            <ul className="mt-6 space-y-4">
              {[
                '解锁所有 "困难" 级别的高级题目',
                '查看深度解析与源码分析',
                '专属 "VIP" 身份标识',
                '优先体验新功能 (如模拟面试)',
                '支持开发者持续更新'
              ].map((feature) => (
                <li key={feature} className="flex items-start">
                  <div className="flex-shrink-0">
                    <Check className="h-6 w-6 text-green-500" />
                  </div>
                  <p className="ml-3 text-base text-gray-700">{feature}</p>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
