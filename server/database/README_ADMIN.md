# 管理员账号创建指南

## 🔐 管理员账号信息

- **邮箱**: `admin@example.com`
- **密码**: `admin123`
- **角色**: 管理员 (admin)
- **会员状态**: Pro 会员

## 📝 创建步骤

### 方法 1: 使用 SQL 脚本（推荐）

```bash
# 在数据库中执行
psql -U your_username -d your_database -f server/database/create_admin.sql
```

或者使用 Docker：

```bash
docker exec -i your_postgres_container psql -U postgres -d your_database < server/database/create_admin.sql
```

### 方法 2: 直接在 PostgreSQL 中执行

```sql
INSERT INTO users (email, password_hash, nickname, role, is_pro, created_at, updated_at)
VALUES (
  'admin@example.com',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
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
```

## ✅ 验证

登录后检查用户信息：

```sql
SELECT id, email, nickname, role, is_pro 
FROM users 
WHERE email = 'admin@example.com';
```

## 🔒 安全建议

⚠️ **重要**: 在生产环境中，请务必修改默认密码！

1. 登录后立即修改密码
2. 使用强密码（至少 12 位，包含大小写字母、数字和特殊字符）
3. 不要在公开仓库中提交真实的管理员凭证

## 📋 管理员权限

管理员账号拥有以下权限：

- ✅ 访问管理后台 (`/admin`)
- ✅ 管理所有题目（增删改查）
- ✅ 管理所有用户
- ✅ 查看系统统计数据
- ✅ 免费访问所有 Pro 功能
