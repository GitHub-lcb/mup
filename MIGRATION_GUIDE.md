# Supabase 迁移指南

本项目已从 Supabase 迁移到自管理的 PostgreSQL 数据库和 Express API。

## 已完成的工作

### 1. 后端 API
- ✅ 创建了 PostgreSQL 数据库连接 (`server/config/database.js`)
- ✅ 创建了数据库初始化脚本 (`server/database/init.sql`)
- ✅ 实现了用户认证 API (`server/routes/auth.js`)
- ✅ 实现了题目管理 API (`server/routes/questions.js`)
- ✅ 实现了分类 API (`server/routes/categories.js`)
- ✅ 实现了答题记录 API (`server/routes/attempts.js`)
- ✅ 实现了收藏功能 API (`server/routes/favorites.js`)
- ✅ 实现了评论功能 API (`server/routes/comments.js`)
- ✅ 实现了排行榜 API (`server/routes/leaderboard.js`)
- ✅ 实现了用户管理 API (`server/routes/users.js`)

### 2. 前端改造
- ✅ 创建了新的 API 客户端 (`src/lib/api.ts`)
- ✅ 更新了 AuthContext 使用新的认证方式
- ✅ 更新了登录/注册页面
- ✅ 更新了 HomePage 和 QuestionListPage
- ✅ 更新了 ProtectedRoute

### 3. 需要手动更新的文件

以下文件仍在使用 Supabase，需要按照模式替换：

#### 替换模式：
```typescript
// 旧的 Supabase 方式
import { supabase } from '../lib/supabase';
const { data, error } = await supabase.from('table_name').select('*');

// 新的 API 方式
import api from '../lib/api';
const data = await api.resource.method(params);
```

#### 需要更新的文件列表：

1. **src/pages/questions/QuestionDetailPage.tsx**
   - 替换题目详情获取
   - 替换收藏检查/添加/删除
   - 替换答题记录提交

2. **src/pages/user/ProgressPage.tsx**
   - 替换进度数据获取
   - 使用 `api.users.progress()`

3. **src/pages/LeaderboardPage.tsx**
   - 替换排行榜数据获取
   - 使用 `api.leaderboard.get()`

4. **src/pages/user/MistakesPage.tsx**
   - 替换错题获取
   - 使用 `api.attempts.mistakes()`

5. **src/pages/user/FavoritesPage.tsx**
   - 替换收藏列表获取
   - 使用 `api.favorites.list()`

6. **src/pages/DailyChallengePage.tsx**
   - 替换每日题目获取
   - 需要实现每日题目逻辑

7. **src/pages/admin/* (所有管理员页面)**
   - AdminDashboard.tsx
   - AdminQuestionEditor.tsx
   - AdminQuestionList.tsx
   - AdminUserList.tsx

8. **src/components/CommentsSection.tsx**
   - 替换评论相关操作

## 部署步骤

### 1. 安装 PostgreSQL

确保系统已安装 PostgreSQL 并创建数据库：

```bash
# 创建数据库
createdb mup_db

# 或使用 psql
psql -U postgres
CREATE DATABASE mup_db;
```

### 2. 初始化数据库

```bash
# 执行初始化脚本（创建表结构和基础数据）
psql -U postgres -d mup_db -f server/database/init.sql

# 导入完整的题目数据（推荐）
npm run db:import-questions
# 或
psql -U postgres -d mup_db -f server/database/import_questions.sql
```

### 3. 配置环境变量

更新 `.env` 文件：

```env
# API 配置
VITE_API_URL=http://localhost:3000/api

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mup_db
DB_USER=postgres
DB_PASSWORD=your_password

# JWT 密钥
JWT_SECRET=your-super-secret-jwt-key-change-in-production

# DeepSeek API (用于AI对话)
DEEPSEEK_API_KEY=your_deepseek_api_key
```

### 4. 安装依赖并运行

```bash
# 安装依赖（如果还没安装）
npm install

# 运行开发服务器
npm run dev

# 在另一个终端启动 API 服务器
node server/index.js
```

### 5. 创建管理员账户

数据库初始化后，需要手动创建第一个管理员：

```sql
-- 首先注册一个账户，然后将其角色改为 admin
UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';
```

## API 文档

### 认证 API

- `POST /api/auth/register` - 注册
- `POST /api/auth/login` - 登录
- `POST /api/auth/logout` - 登出
- `GET /api/auth/me` - 获取当前用户
- `PATCH /api/auth/me` - 更新用户信息

### 题目 API

- `GET /api/questions` - 获取题目列表（支持分页和筛选）
- `GET /api/questions/:id` - 获取题目详情
- `POST /api/questions` - 创建题目（需要管理员）
- `PATCH /api/questions/:id` - 更新题目（需要管理员）
- `DELETE /api/questions/:id` - 删除题目（需要管理员）

### 其他 API

详见 `src/lib/api.ts` 文件中的完整 API 定义。

## 注意事项

1. **Token 存储**：现在使用 localStorage 存储 JWT token，在生产环境建议使用 httpOnly cookie
2. **CORS**：确保后端 CORS 配置正确
3. **数据迁移**：如果有 Supabase 数据需要迁移，需要导出数据并导入到 PostgreSQL
4. **密码安全**：确保在生产环境更改 JWT_SECRET
5. **数据库索引**：初始化脚本已包含必要的索引

## 遇到问题？

- 检查数据库连接配置
- 确保 PostgreSQL 服务正在运行
- 检查 API 服务器是否正常启动
- 查看浏览器控制台和服务器日志
