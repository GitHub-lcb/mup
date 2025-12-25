# 去 Supabase 化 - 快速开始

本项目已成功从 Supabase 迁移到自管理的 PostgreSQL + Express API 架构。

## 🚀 快速开始

### 前置要求

- Node.js 20+
- PostgreSQL 12+

### 1. 创建数据库

```bash
# 方式 1: 使用 createdb
createdb mup_db

# 方式 2: 使用 psql
psql -U postgres
CREATE DATABASE mup_db;
\q
```

### 2. 初始化数据库

```bash
# 使用 npm script 初始化数据库结构
npm run db:init

# 或直接执行
psql -U postgres -d mup_db -f server/database/init.sql
```

### 3. 导入题目数据（可选但推荐）

项目包含大量的题目数据，建议导入：

```bash
# 一键导入所有题目（推荐）
npm run db:import-questions

# 或直接执行 SQL 脚本
psql -U postgres -d mup_db -f server/database/import_questions.sql
```

此命令将自动导入 `supabase/migrations` 目录下的所有题目数据。

### 4. 配置环境变量

确保 `.env` 文件包含正确的配置（已更新）：

```env
# API 配置
VITE_API_URL=http://localhost:3000/api

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mup_db
DB_USER=postgres
DB_PASSWORD=your_password  # 修改为你的密码

# JWT 密钥
JWT_SECRET=your-super-secret-jwt-key-change-in-production

# DeepSeek API
DEEPSEEK_API_KEY=your_deepseek_key
```

### 5. 启动应用

需要两个终端：

```bash
# 终端 1: 启动后端 API
npm run server

# 终端 2: 启动前端开发服务器
npm run dev
```

### 6. 访问应用

- 前端：http://localhost:5173
- API：http://localhost:3000/api

### 7. 创建管理员账户

1. 先在网页上注册一个账户
2. 然后在数据库中设置为管理员：

```sql
psql -U postgres -d mup_db
UPDATE users SET role = 'admin' WHERE email = 'your_email@example.com';
```

## 📚 完整文档

- **DESUPABASE_SUMMARY.md** - 改造总结和架构说明
- **MIGRATION_GUIDE.md** - 详细迁移指南
- **src/lib/api.ts** - 完整 API 客户端文档

## ✅ 已完成的工作

### 后端（100%）
✅ PostgreSQL 数据库设计  
✅ 用户认证系统（JWT）  
✅ 题目管理 API  
✅ 答题记录 API  
✅ 收藏功能 API  
✅ 评论系统 API  
✅ 排行榜 API  
✅ 用户管理 API  

### 前端（核心功能完成）
✅ API 客户端  
✅ 认证系统重构  
✅ 登录/注册页面  
✅ 主页  
✅ 题目列表  

### 需要更新的页面

以下页面仍使用 Supabase，需按模式替换（见 MIGRATION_GUIDE.md）：

- QuestionDetailPage
- ProgressPage
- LeaderboardPage
- MistakesPage
- FavoritesPage
- DailyChallengePage
- 所有管理员页面
- CommentsSection 组件

**更新模式：**
```typescript
// 旧
import { supabase } from '../lib/supabase';
const { data } = await supabase.from('table').select('*');

// 新
import api from '../lib/api';
const data = await api.resource.method();
```

## 🎯 主要改进

1. ✅ 完全自主控制数据和 API
2. ✅ 无供应商锁定
3. ✅ JWT 认证，更灵活
4. ✅ 节省云服务成本
5. ✅ 更好的调试体验

## 📦 技术栈

**后端**
- Express.js
- PostgreSQL + pg
- bcryptjs
- jsonwebtoken
- cors

**前端**  
- React 18
- Vite 6
- TypeScript
- Fetch API

## 🛠 常用命令

```bash
# 开发
npm run dev          # 启动前端
npm run server       # 启动后端
npm run db:init      # 初始化数据库

# 构建
npm run build        # 构建前端
npm run check        # TypeScript 类型检查

# 其他
npm run lint         # ESLint 检查
npm run preview      # 预览生产构建
```

## 🔧 故障排查

### 数据库连接失败
- 检查 PostgreSQL 是否运行：`pg_isready`
- 检查 `.env` 中的数据库配置
- 检查数据库是否已创建

### API 请求失败
- 确保后端服务器已启动（npm run server）
- 检查 VITE_API_URL 配置
- 查看浏览器控制台错误

### 登录失败
- 检查 JWT_SECRET 配置
- 确保用户已在数据库中
- 查看服务器日志

## 📞 获取帮助

遇到问题？检查：
1. 服务器日志（终端 1）
2. 浏览器控制台
3. PostgreSQL 日志
4. MIGRATION_GUIDE.md 详细文档

## 🚢 生产部署

生产环境建议：
- 使用环境变量管理配置
- 启用 HTTPS
- 使用生产级数据库（AWS RDS、Supabase Postgres 等）
- 使用 PM2 或 Docker 管理进程
- 配置 Nginx 反向代理
- 设置强随机 JWT_SECRET
- 配置数据库备份

---

**Happy Coding! 🎉**
