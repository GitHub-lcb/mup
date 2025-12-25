# 去 Supabase 化改造总结

## 项目改造完成情况

✅ **后端 API 层全部完成**
- 数据库连接和配置
- 用户认证系统（注册、登录、JWT）
- 题目管理 API
- 分类、答题记录、收藏、评论等功能 API
- 排行榜和用户管理

✅ **前端核心功能已完成**
- API 客户端封装
- 认证系统重构
- 登录注册页面
- 主页和题目列表页

## 快速开始

### 1. 数据库准备

```bash
# 创建 PostgreSQL 数据库
createdb mup_db

# 初始化数据库结构
psql -U postgres -d mup_db -f server/database/init.sql

# 导入完整题目数据（推荐）
npm run db:import-questions
# 或
psql -U postgres -d mup_db -f server/database/import_questions.sql
```

### 2. 配置环境变量

已更新 `.env` 文件，包含：
- 数据库连接信息
- JWT 密钥
- API 地址

### 3. 启动项目

```bash
# 终端 1: 启动后端 API 服务器
node server/index.js

# 终端 2: 启动前端开发服务器  
npm run dev
```

### 4. 创建管理员账户

```sql
-- 先通过网页注册一个账户，然后执行
UPDATE users SET role = 'admin' WHERE email = 'your_email@example.com';
```

## 架构变化

### 之前（Supabase）
```
前端 → Supabase SDK → Supabase Cloud
```

### 现在（自管理）
```
前端 → API 客户端 → Express API → PostgreSQL
```

## 主要改进

1. **完全自主控制**：数据库和 API 都在自己掌控中
2. **更灵活的认证**：使用 JWT，可以自定义认证逻辑
3. **无供应商锁定**：不再依赖 Supabase 服务
4. **成本优化**：无需支付 Supabase 费用
5. **更好的调试**：完整的服务器端代码可见

## 技术栈

**后端：**
- Express.js - Web 框架
- PostgreSQL - 数据库
- pg - PostgreSQL 客户端
- bcryptjs - 密码加密
- jsonwebtoken - JWT 认证

**前端：**
- React 18
- Vite 6
- TypeScript
- Fetch API

## 文件结构

```
server/
├── config/
│   └── database.js          # 数据库连接配置
├── database/
│   └── init.sql             # 数据库初始化脚本
├── middleware/
│   └── auth.js              # 认证中间件
├── routes/
│   ├── auth.js              # 认证路由
│   ├── questions.js         # 题目路由
│   ├── categories.js        # 分类路由
│   ├── attempts.js          # 答题记录路由
│   ├── favorites.js         # 收藏路由
│   ├── comments.js          # 评论路由
│   ├── leaderboard.js       # 排行榜路由
│   └── users.js             # 用户管理路由
└── index.js                 # 服务器入口

src/
├── lib/
│   └── api.ts               # API 客户端（替代 supabase.ts）
└── context/
    └── AuthContext.tsx      # 认证上下文（已重构）
```

## 需要注意的地方

### 剩余需要更新的文件

以下文件仍在使用 Supabase，需要更新（详见 MIGRATION_GUIDE.md）：

1. src/pages/questions/QuestionDetailPage.tsx
2. src/pages/user/ProgressPage.tsx
3. src/pages/LeaderboardPage.tsx
4. src/pages/user/MistakesPage.tsx
5. src/pages/user/FavoritesPage.tsx
6. src/pages/DailyChallengePage.tsx
7. src/pages/admin/*.tsx（所有管理员页面）
8. src/components/CommentsSection.tsx

### 更新模式示例

```typescript
// 旧代码
import { supabase } from '../lib/supabase';
const { data, error } = await supabase
  .from('questions')
  .select('*')
  .eq('id', questionId)
  .single();

// 新代码
import api from '../lib/api';
const data = await api.questions.get(questionId);
```

## API 端点示例

### 认证
- POST `/api/auth/register` - 注册
- POST `/api/auth/login` - 登录
- GET `/api/auth/me` - 获取当前用户

### 题目
- GET `/api/questions?page=1&limit=10&category_id=xxx` - 题目列表
- GET `/api/questions/:id` - 题目详情
- POST `/api/questions` - 创建题目（管理员）

### 其他功能
- GET `/api/categories` - 分类列表
- POST `/api/attempts` - 提交答题
- GET `/api/leaderboard` - 排行榜

完整 API 文档见 `src/lib/api.ts`

## 数据迁移（如需要）

如果有 Supabase 数据需要迁移：

1. 从 Supabase 导出数据（CSV 或 SQL）
2. 使用 `psql` 或数据导入工具导入到本地 PostgreSQL
3. 确保数据结构匹配 `server/database/init.sql`

## 生产部署建议

1. 使用环境变量管理敏感信息
2. 启用 HTTPS
3. 配置生产级 PostgreSQL（如 AWS RDS、Supabase Postgres 等）
4. 使用 PM2 或 Docker 管理 Node.js 进程
5. 配置 Nginx 反向代理
6. 设置数据库备份策略
7. 使用强随机 JWT_SECRET

## 下一步

1. 完成剩余页面的 Supabase 替换
2. 测试所有功能
3. 可选：数据从 Supabase 迁移
4. 部署到生产环境

## 遇到问题？

请查看：
- 浏览器控制台错误
- 服务器日志（node server/index.js）
- 数据库连接状态
- 环境变量配置

参考 `MIGRATION_GUIDE.md` 获取更详细的指导。
