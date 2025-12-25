import bcrypt from 'bcryptjs';

const password = 'admin123';
const saltRounds = 10;

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('Error:', err);
    return;
  }
  
  console.log('\n=== 管理员账号信息 ===');
  console.log('邮箱: admin@example.com');
  console.log('密码: admin123');
  console.log('\nBcrypt Hash:');
  console.log(hash);
  console.log('\n=== SQL 插入语句 ===');
  console.log(`
INSERT INTO users (email, password_hash, nickname, role, is_pro, created_at, updated_at)
VALUES (
  'admin@example.com',
  '${hash}',
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
  `);
});
