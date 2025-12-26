# 宝塔面板部署指南

本项目是一个基于 React + Express + PostgreSQL 的全栈应用，包含前端、后端 API 和数据库三个部分。

## 架构说明

- **前端**: React + Vite (打包后为静态文件)
- **后端**: Express API + DeepSeek AI (端口 3000)
- **数据库**: PostgreSQL (端口 5432)

## 准备工作

1. 确保你的宝塔面板已安装：
   - **PM2 管理器** (运行 Node.js)
   - **PostgreSQL** (数据库)
   - **Nginx** (反向代理)
2. 准备好你的环境变量：
   - PostgreSQL 数据库连接信息
   - DeepSeek API Key

---

## 部署步骤

### 第一步：创建 PostgreSQL 数据库

1. 在宝塔面板 -> **数据库** -> **PostgreSQL**
2. 点击 **添加数据库**：
   - **数据库名**: `mup_db`
   - **用户名**: `mup_user`
   - **密码**: 自动生成或自定义（记住这个密码）
3. 创建成功后，记录下连接信息。

### 第二步：上传代码

1. 在宝塔面板 -> **文件**，进入 `/www/wwwroot` 目录
2. 点击 **终端**，执行：
   ```bash
   cd /www/wwwroot
   git clone https://github.com/GitHub-lcb/mup.git
   cd mup
   ```

### 第三步：配置环境变量

在项目根目录创建 `.env` 文件：

```bash
cat > .env << 'EOF'
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mup_db
DB_USER=mup_user
DB_PASSWORD=你的数据库密码

# JWT 密钥（用于用户认证）
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# AI 配置
DEEPSEEK_API_KEY=sk-a758655a18484e9894b45394e22f663d

# 服务端口
PORT=3000
EOF
```

### 第四步：初始化数据库

```bash
# 1. 连接到 PostgreSQL
psql -U mup_user -d mup_db

# 2. 执行初始化脚本
\i server/database/init.sql

# 3. 导入题目数据
\i server/database/import_questions.sql

# 4. 创建管理员账号
\i server/database/create_admin.sql

# 5. 退出
\q
```

或者使用命令行一次性执行：

```bash
psql -U mup_user -d mup_db -f server/database/init.sql
psql -U mup_user -d mup_db -f server/database/import_questions.sql
psql -U mup_user -d mup_db -f server/database/create_admin.sql
```

**管理员账号**：
- 邮箱: `admin@example.com`
- 密码: `admin123`
- **重要**: 登录后立即修改密码！

### 第五步：安装依赖并构建前端

```bash
# 安装依赖（使用淘宝镜像加速）
npm install --registry=https://registry.npmmirror.com

# 构建前端
npm run build
```

构建完成后会生成 `dist` 目录，包含前端静态文件。

### 第六步：启动后端服务

#### 方法 A：使用 PM2 管理器（推荐）

1. 在宝塔面板 -> **网站** -> **Node项目** -> **添加Node项目**
2. 填写配置：
   - **项目目录**: `/www/wwwroot/mup`
   - **启动文件**: `server/index.js`
   - **项目名称**: `mup-api`
   - **端口**: `3000`
   - **运行用户**: `www`
3. 点击 **提交**

#### 方法 B：手动启动（临时测试）

```bash
# 临时启动（测试用）
node server/index.js

# 或使用 PM2
npm install -g pm2
pm2 start server/index.js --name mup-api
pm2 save
pm2 startup
```

### 第七步：配置 Nginx 反向代理

1. 在宝塔面板 -> **网站** -> **添加站点**
2. 填写配置：
   - **域名**: `lichenbo.cn` (你的域名)
   - **根目录**: `/www/wwwroot/mup/dist`
   - **PHP 版本**: 纯静态
3. 创建成功后，点击站点 -> **设置** -> **配置文件**
4. 在 `server` 块中添加以下配置：

```nginx
server {
    listen 80;
    server_name lichenbo.cn;
    root /www/wwwroot/mup/dist;
    index index.html;

    # 前端静态文件
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 后端 API 代理
    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

5. 保存配置，重载 Nginx

### 第八步：配置 HTTPS（可选但推荐）

1. 在站点设置 -> **SSL**
2. 选择 **Let's Encrypt**
3. 勾选你的域名，点击 **申请**
4. 申请成功后，开启 **强制 HTTPS**

### 第九步：验证部署

访问你的域名：

1. **前端页面**: `https://lichenbo.cn`
2. **API 健康检查**: `https://lichenbo.cn/api/health` (应返回 OK)
3. **登录测试**: 使用管理员账号登录
4. **AI 助教测试**: 打开任意题目，测试 AI 对话功能

---

## 运行原理说明

```
用户浏览器
    ↓
  Nginx (80/443)
    ├─→ 静态文件 → /www/wwwroot/mup/dist (前端)
    └─→ /api/* → http://localhost:3000 (后端 Express)
              ↓
          PostgreSQL (5432)
```

- **前端**: 打包后的静态文件，由 Nginx 直接提供
- **后端**: Express 服务运行在 3000 端口，处理 API 请求
- **数据库**: PostgreSQL 存储所有数据

---

## Docker 部署方式（替代方案）

如果你安装了 **Docker 管理器**，可以使用容器化部署：

### 1. 构建镜像

```bash
cd /www/wwwroot/mup
docker build -t mup-app .
```

### 2. 创建 docker-compose.yml

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: mup_db
      POSTGRES_USER: mup_user
      POSTGRES_PASSWORD: your_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./server/database:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"

  app:
    image: mup-app
    depends_on:
      - postgres
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: mup_db
      DB_USER: mup_user
      DB_PASSWORD: your_password
      JWT_SECRET: your-jwt-secret
      DEEPSEEK_API_KEY: sk-a758655a18484e9894b45394e22f663d
      PORT: 3000
    ports:
      - "3000:3000"

volumes:
  postgres_data:
```

### 3. 启动容器

```bash
docker-compose up -d
```

### 4. 初始化数据库

```bash
# 等待 PostgreSQL 启动完成（约 10 秒）
sleep 10

# 导入题目数据
docker exec -i mup_postgres_1 psql -U mup_user -d mup_db < server/database/import_questions.sql

# 创建管理员
docker exec -i mup_postgres_1 psql -U mup_user -d mup_db < server/database/create_admin.sql
```

### 5. 配置 Nginx 反向代理

与上面的方法相同，只需将 API 代理指向 `http://127.0.0.1:3000`

---

## 常见问题

### 1. 前端页面空白？

- 检查 `npm run build` 是否成功
- 检查浏览器控制台是否有报错
- 确认 Nginx 配置中的 `root` 路径正确

### 2. API 请求 404？

- 检查后端服务是否启动：`pm2 list` 或 `ps aux | grep node`
- 检查 Nginx 反向代理配置是否正确
- 查看后端日志：`pm2 logs mup-api`

### 3. 数据库连接失败？

- 检查 `.env` 文件中的数据库配置是否正确
- 确认 PostgreSQL 服务是否运行：`systemctl status postgresql`
- 测试数据库连接：`psql -U mup_user -d mup_db`

### 4. AI 助教无法对话？

- 确保 `.env` 文件中有 `DEEPSEEK_API_KEY`
- 重启 Node 服务：`pm2 restart mup-api`
- 检查后端日志是否有 API 调用错误

### 5. 管理后台无法访问？

- 确认已执行 `create_admin.sql` 创建管理员账号
- 使用默认账号登录：`admin@example.com` / `admin123`
- 登录后立即修改密码

### 6. 修改代码后如何更新？

```bash
# 1. 拉取最新代码
cd /www/wwwroot/mup
git pull

# 2. 安装新依赖（如果有）
npm install

# 3. 重新构建前端
npm run build

# 4. 重启后端服务
pm2 restart mup-api
```

### 7. 查看日志

```bash
# 后端日志
pm2 logs mup-api

# Nginx 访问日志
tail -f /www/wwwlogs/lichenbo.cn.log

# Nginx 错误日志
tail -f /www/wwwlogs/lichenbo.cn.error.log

# PostgreSQL 日志
tail -f /www/server/postgresql/log/postgresql-*.log
```

---

## 性能优化建议

1. **启用 Gzip 压缩** (Nginx 配置)
2. **配置 CDN** (静态资源加速)
3. **数据库索引优化** (查询慢日志)
4. **PM2 集群模式** (多核 CPU 利用)

```bash
# 使用集群模式启动（根据 CPU 核心数）
pm2 start server/index.js --name mup-api -i max
```
