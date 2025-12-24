# 部署指南

本项目支持两种部署方式：
1. **Vercel 托管 (推荐)** - 适合快速上线，零运维。
2. **私有服务器 (Docker/Node.js)** - 适合需要完全掌控服务器和数据的情况。

## 方式一：Vercel 部署 (推荐)

这是当前正在使用的方式。

1. 将代码推送到 GitHub。
2. 在 Vercel 控制台导入项目。
3. 配置环境变量：
   - `VITE_SUPABASE_URL`: 你的 Supabase URL
   - `VITE_SUPABASE_ANON_KEY`: 你的 Supabase Anon Key
   - `DEEPSEEK_API_KEY`: DeepSeek API Key

## 方式二：私有服务器部署 (Docker)

如果你有自己的服务器 (VPS) 和域名，可以使用 Docker 部署。

### 前置要求
- 一台安装了 Docker 的服务器 (Linux/Windows)
- 一个域名 (例如 `lichenbo.cn`)

### 步骤 1: 准备环境变量
在服务器上创建一个 `.env` 文件：
```env
VITE_SUPABASE_URL=你的_supabase_url
VITE_SUPABASE_ANON_KEY=你的_supabase_key
DEEPSEEK_API_KEY=你的_deepseek_key
PORT=3000
```

### 步骤 2: 构建并运行 Docker 容器

在项目根目录下运行：

```bash
# 1. 构建镜像
docker build -t mup-app .

# 2. 运行容器
docker run -d -p 3000:3000 --env-file .env --name mup-container mup-app
```

现在，应用应该运行在服务器的 `http://IP:3000`。

### 步骤 3: 配置域名 (Nginx 反向代理)

为了使用域名访问 (如 `https://lichenbo.cn`)，你需要配置 Nginx。

**Nginx 配置示例：**

```nginx
server {
    listen 80;
    server_name lichenbo.cn www.lichenbo.cn;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

推荐使用 `certbot` 自动配置 HTTPS 证书。

## 方式三：手动 Node.js 部署

如果不使用 Docker：

1. 在服务器上安装 Node.js 20+。
2. 上传代码。
3. 安装依赖：`npm install`
4. 构建前端：`npm run build`
5. 启动服务器：`node server/index.js`
   (推荐使用 `pm2` 来管理进程: `pm2 start server/index.js --name mup`)
