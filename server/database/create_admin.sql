-- 创建管理员账号
-- 邮箱: admin@example.com
-- 密码: admin123
-- 密码已使用 bcrypt 加密 (10 rounds)

INSERT INTO users (email, password_hash, nickname, role, is_pro, created_at, updated_at)
VALUES (
  'lcb@admin.com',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', -- admin123
  '超级管理员',
  'admin',
  true,
  NOW(),
  NOW()
)
ON CONFLICT (email) DO UPDATE SET
  role = 'admin',
  is_pro = true,
  nickname = '超级管理员',
  updated_at = NOW();

-- 显示创建结果
SELECT id, email, nickname, role, is_pro, created_at 
FROM users 
WHERE email = 'lcb@admin.com';
