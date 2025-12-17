export interface User {
  id: string;
  email: string;
  nickname: string | null;
  role: 'user' | 'admin';
  is_pro?: boolean;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  name: string;
  description: string | null;
  icon: string | null;
  sort_order: number;
  parent_id: string | null;
  created_at: string;
}

export interface Question {
  id: string;
  title: string;
  content: string;
  type: 'single' | 'multiple' | 'boolean' | 'fill';
  options: any; // JSONB
  correct_answer: string;
  explanation: string | null;
  difficulty: 'easy' | 'medium' | 'hard';
  category_id: string | null;
  tags: string[] | null;
  view_count: number;
  attempt_count: number;
  correct_count: number;
  correct_rate: number;
  is_active: boolean;
  is_premium?: boolean;
  created_at: string;
  updated_at: string;
}

export interface QuestionAttempt {
  id: string;
  user_id: string;
  question_id: string;
  user_answer: string | null;
  is_correct: boolean | null;
  time_spent: number | null;
  created_at: string;
}

export interface Favorite {
  id: string;
  user_id: string;
  question_id: string;
  notes: string | null;
  created_at: string;
}

export interface LearningProgress {
  id: string;
  user_id: string;
  category_id: string;
  total_questions: number;
  answered_questions: number;
  correct_answers: number;
  accuracy_rate: number;
  last_studied: string | null;
  updated_at: string;
}
