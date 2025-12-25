-- 数据库初始化脚本
-- 请先创建数据库: CREATE DATABASE mup_db;

-- 启用 UUID 扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 用户表
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  nickname VARCHAR(100),
  role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  is_pro BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 分类表
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  sort_order INTEGER DEFAULT 0,
  parent_id UUID REFERENCES categories(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 题目表
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  type VARCHAR(20) CHECK (type IN ('single', 'multiple', 'boolean', 'fill')),
  options JSONB,
  correct_answer VARCHAR(500) NOT NULL,
  explanation TEXT,
  difficulty VARCHAR(10) CHECK (difficulty IN ('easy', 'medium', 'hard')),
  category_id UUID REFERENCES categories(id),
  tags VARCHAR(50)[],
  view_count INTEGER DEFAULT 0,
  attempt_count INTEGER DEFAULT 0,
  correct_count INTEGER DEFAULT 0,
  correct_rate FLOAT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  is_premium BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 答题记录表
CREATE TABLE IF NOT EXISTS question_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  user_answer VARCHAR(500),
  is_correct BOOLEAN,
  time_spent INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 收藏表
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, question_id)
);

-- 学习进度表
CREATE TABLE IF NOT EXISTS learning_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  total_questions INTEGER DEFAULT 0,
  answered_questions INTEGER DEFAULT 0,
  correct_answers INTEGER DEFAULT 0,
  accuracy_rate FLOAT DEFAULT 0,
  last_studied TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category_id)
);

-- 评论表
CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 会员订阅表
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  plan_type VARCHAR(20) CHECK (plan_type IN ('monthly', 'yearly')),
  status VARCHAR(20) CHECK (status IN ('active', 'cancelled', 'expired')),
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 订单表
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL,
  status VARCHAR(20) DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_sort ON categories(sort_order);
CREATE INDEX IF NOT EXISTS idx_questions_category ON questions(category_id);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON questions(difficulty);
CREATE INDEX IF NOT EXISTS idx_questions_type ON questions(type);
CREATE INDEX IF NOT EXISTS idx_questions_active ON questions(is_active);
CREATE INDEX IF NOT EXISTS idx_questions_created ON questions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_attempts_user ON question_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_attempts_question ON question_attempts(question_id);
CREATE INDEX IF NOT EXISTS idx_attempts_created ON question_attempts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_attempts_user_question ON question_attempts(user_id, question_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_question ON favorites(question_id);
CREATE INDEX IF NOT EXISTS idx_favorites_created ON favorites(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_progress_user ON learning_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_category ON learning_progress(category_id);
CREATE INDEX IF NOT EXISTS idx_progress_updated ON learning_progress(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_question ON comments(question_id);
CREATE INDEX IF NOT EXISTS idx_comments_created ON comments(created_at);

-- 初始化分类数据
INSERT INTO categories (name, description, icon, sort_order) VALUES
('Java基础', 'Java语言基础、面向对象、异常处理等', 'code', 1),
('集合框架', 'List、Set、Map等集合类', 'database', 2),
('Java并发', '多线程、线程池、锁机制、JMM', 'cpu', 3),
('JVM', '内存模型、垃圾回收、性能调优等', 'memory', 4),
('Spring框架', 'Spring, Spring Boot, MyBatis等', 'layers', 5),
('数据库', 'MySQL, Redis, SQL优化等', 'database', 6),
('计算机网络', 'TCP/IP, HTTP, HTTPS等', 'globe', 7),
('操作系统', '进程, 线程, Linux命令等', 'cpu', 8),
('系统设计', '分布式, 微服务, 高并发, 架构设计', 'server', 9),
('算法与数据结构', '排序, 查找, 链表, 树等', 'git-branch', 10),
('开发工具', 'Git, Docker, Maven, Linux等', 'tool', 11)
ON CONFLICT DO NOTHING;

-- 辅助函数：根据名称获取分类ID
CREATE OR REPLACE FUNCTION get_category_id(cat_name TEXT) RETURNS UUID AS $$
  SELECT id FROM categories WHERE name = cat_name LIMIT 1;
$$ LANGUAGE sql;

-- 初始化示例题目
INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active)
VALUES
(
  'Java中String类是不可变的吗？',
  '请判断Java中String类的设计是否为不可变（Immutable）。',
  'single',
  '[{"label": "是", "value": "true"}, {"label": "否", "value": "false"}]'::jsonb,
  'true',
  'String类在Java中是不可变的（Immutable）。String类被final修饰，且其内部用于存储字符的char数组也被final修饰（JDK 9之前）或byte数组（JDK 9及之后），并且没有提供修改内部数组的方法。',
  'easy',
  get_category_id('Java基础'),
  ARRAY['String', '基础'],
  true
),
(
  'ArrayList和LinkedList的区别是什么？',
  '关于ArrayList和LinkedList的区别，下列说法错误的是？',
  'single',
  '[{"label": "ArrayList基于动态数组实现，LinkedList基于双向链表实现", "value": "A"}, {"label": "ArrayList随机访问效率高，LinkedList随机访问效率低", "value": "B"}, {"label": "LinkedList在任意位置插入和删除元素的效率通常优于ArrayList", "value": "C"}, {"label": "ArrayList比LinkedList更占内存，因为ArrayList需要维护额外的指针", "value": "D"}]'::jsonb,
  'D',
  'D选项错误。LinkedList比ArrayList更占内存，因为LinkedList的每个节点除了存储数据外，还需要存储指向前驱和后继节点的两个引用（指针），而ArrayList只需要存储数据本身（虽然会有扩容预留空间，但总体上LinkedList开销更大）。',
  'medium',
  get_category_id('集合框架'),
  ARRAY['List', '集合'],
  true
),
(
  'HashMap的底层实现原理',
  'JDK 1.8中，HashMap的底层数据结构是？',
  'single',
  '[{"label": "数组 + 链表", "value": "A"}, {"label": "数组 + 红黑树", "value": "B"}, {"label": "数组 + 链表 + 红黑树", "value": "C"}, {"label": "双向链表", "value": "D"}]'::jsonb,
  'C',
  'JDK 1.8中，HashMap采用数组 + 链表 + 红黑树的结构。当链表长度超过阈值（默认为8）且数组长度大于64时，链表会转换为红黑树，以提高查询效率。',
  'medium',
  get_category_id('集合框架'),
  ARRAY['HashMap', '集合'],
  true
),
(
  'Java线程的状态有哪些？',
  '下列哪个不是Java线程的状态？',
  'single',
  '[{"label": "NEW", "value": "A"}, {"label": "RUNNABLE", "value": "B"}, {"label": "RUNNING", "value": "C"}, {"label": "BLOCKED", "value": "D"}]'::jsonb,
  'C',
  'Java线程状态（Thread.State枚举）包括：NEW, RUNNABLE, BLOCKED, WAITING, TIMED_WAITING, TERMINATED。RUNNING不是Java定义的线程状态，虽然在操作系统层面线程可能处于Running状态，但在Java API中归为RUNNABLE。',
  'medium',
  get_category_id('Java并发'),
  ARRAY['Thread', '并发'],
  true
),
(
  'JVM内存区域中，哪个区域是线程私有的？',
  'JVM运行时数据区中，哪些区域是线程私有的？',
  'single',
  '[{"label": "堆 (Heap)", "value": "A"}, {"label": "方法区 (Method Area)", "value": "B"}, {"label": "虚拟机栈 (VM Stack)", "value": "C"}, {"label": "直接内存 (Direct Memory)", "value": "D"}]'::jsonb,
  'C',
  'JVM内存区域中，虚拟机栈、本地方法栈和程序计数器是线程私有的。堆和方法区是所有线程共享的。',
  'easy',
  get_category_id('JVM'),
  ARRAY['JVM', '内存模型'],
  true
);

-- 标记困难题目为会员专属
UPDATE questions SET is_premium = true WHERE difficulty = 'hard';

-- 创建排行榜函数
CREATE OR REPLACE FUNCTION get_leaderboard()
RETURNS TABLE (
  id UUID,
  nickname VARCHAR,
  email VARCHAR,
  correct_count BIGINT,
  accuracy NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.nickname,
    u.email,
    COUNT(CASE WHEN qa.is_correct = true THEN 1 END) as correct_count,
    CASE 
      WHEN COUNT(qa.id) > 0 
      THEN ROUND((COUNT(CASE WHEN qa.is_correct = true THEN 1 END)::NUMERIC / COUNT(qa.id)::NUMERIC * 100), 2)
      ELSE 0
    END as accuracy
  FROM users u
  LEFT JOIN question_attempts qa ON u.id = qa.user_id
  GROUP BY u.id, u.nickname, u.email
  HAVING COUNT(qa.id) > 0
  ORDER BY correct_count DESC, accuracy DESC
  LIMIT 100;
END;
$$ LANGUAGE plpgsql;
