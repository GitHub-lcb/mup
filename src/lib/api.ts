// API 客户端配置
// 生产环境自动使用相对路径 '/api'，开发环境使用 localhost:3000
const API_BASE_URL = import.meta.env.VITE_API_URL || 
  (import.meta.env.PROD ? '/api' : 'http://localhost:3000/api');

// 存储 token 的 key
const TOKEN_KEY = 'auth_token';

// 获取存储的 token
export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

// 设置 token
export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token);
}

// 清除 token
export function clearToken(): void {
  localStorage.removeItem(TOKEN_KEY);
}

// 通用请求方法
async function request<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token = getToken();
  
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({
      error: response.statusText,
    }));
    throw new Error(error.error || 'Request failed');
  }

  return response.json();
}

// API 客户端
export const api = {
  // 认证相关
  auth: {
    register: (data: { email: string; password: string; nickname?: string }) =>
      request('/auth/register', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    
    login: (data: { email: string; password: string }) =>
      request('/auth/login', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    
    logout: () =>
      request('/auth/logout', {
        method: 'POST',
      }),
    
    getUser: () => request('/auth/me'),
    
    updateUser: (data: { nickname?: string }) =>
      request('/auth/me', {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
  },

  // 题目相关
  questions: {
    list: (params?: {
      page?: number;
      limit?: number;
      category_id?: string;
      difficulty?: string;
      search?: string;
    }) => {
      const query = new URLSearchParams(
        params as Record<string, string>
      ).toString();
      return request(`/questions${query ? `?${query}` : ''}`);
    },
    
    get: (id: string) => request(`/questions/${id}`),
    
    create: (data: any) =>
      request('/questions', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    
    update: (id: string, data: any) =>
      request(`/questions/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
    
    delete: (id: string) =>
      request(`/questions/${id}`, {
        method: 'DELETE',
      }),
  },

  // 分类相关
  categories: {
    list: () => request('/categories'),
    get: (id: string) => request(`/categories/${id}`),
  },

  // 答题记录
  attempts: {
    create: (data: {
      question_id: string;
      user_answer: string;
      is_correct: boolean;
      time_spent?: number;
    }) =>
      request('/attempts', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    
    list: (params?: { question_id?: string; page?: number; limit?: number }) => {
      const query = new URLSearchParams(
        params as Record<string, string>
      ).toString();
      return request(`/attempts/my${query ? `?${query}` : ''}`);
    },
    
    mistakes: (params?: { page?: number; limit?: number }) => {
      const query = new URLSearchParams(
        params as Record<string, string>
      ).toString();
      return request(`/attempts/mistakes${query ? `?${query}` : ''}`);
    },
  },

  // 收藏相关
  favorites: {
    list: (params?: { page?: number; limit?: number }) => {
      const query = new URLSearchParams(
        params as Record<string, string>
      ).toString();
      return request(`/favorites${query ? `?${query}` : ''}`);
    },
    
    check: (questionId: string) =>
      request(`/favorites/check/${questionId}`),
    
    add: (data: { question_id: string; notes?: string }) =>
      request('/favorites', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    
    remove: (questionId: string) =>
      request(`/favorites/${questionId}`, {
        method: 'DELETE',
      }),
  },

  // 评论相关
  comments: {
    list: (questionId: string) =>
      request(`/comments?question_id=${questionId}`),
    
    create: (data: {
      question_id: string;
      content: string;
      parent_id?: string;
    }) =>
      request('/comments', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    
    update: (id: string, data: { content: string }) =>
      request(`/comments/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
    
    delete: (id: string) =>
      request(`/comments/${id}`, {
        method: 'DELETE',
      }),
  },

  // 排行榜
  leaderboard: {
    get: () => request('/leaderboard'),
  },

  // 用户相关（管理员）
  users: {
    list: () => request('/users'),
    
    update: (id: string, data: { nickname?: string; role?: string }) =>
      request(`/users/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
    
    progress: () => request('/users/progress'),
    
    upgrade: () =>
      request('/users/upgrade', {
        method: 'POST',
      }),
  },
};

export default api;
