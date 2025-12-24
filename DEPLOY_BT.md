# 宝塔面板部署指南

本项目是一个基于 React + Node.js 的全栈应用，由于包含了后端 AI 接口，不能仅作为纯静态网站部署。在宝塔面板中，我们推荐使用 **Node.js 项目** 功能或 **Docker** 方式进行部署。

## 准备工作

1. 确保你的宝塔面板已安装 **PM2 管理器** (在软件商店搜索 "PM2" 安装)。
2. 确保服务器已安装 **Git** (通常默认都有)。
3. 准备好你的环境变量：
   - Supabase 地址和 Key
   - DeepSeek API Key

---

## 方式一：Node.js 项目部署 (推荐)

这种方式最直接，性能最好。

### 1. 上传代码
1. 在宝塔面板 -> **文件**，进入 `/www/wwwroot` 目录。
2. 点击 **终端**，执行 git clone (或者直接上传压缩包解压)：
   ```bash
   git clone https://github.com/GitHub-lcb/mup.git
   ```
   (如果网络不好，可以先下载 zip 包上传到该目录解压)

### 2. 安装依赖并构建
1. 在终端中进入项目目录：
   ```bash
   cd /www/wwwroot/mup
   ```
2. 安装依赖 (建议使用淘宝源)：
   ```bash
   npm install --registry=https://registry.npmmirror.com
   ```
3. 构建前端项目：
   ```bash
   npm run build
   ```
   *构建完成后，会生成一个 `dist` 目录。*

### 3. 添加 Node.js 项目
1. 回到宝塔面板 -> **网站** -> **Node项目** -> **添加Node项目**。
2. **项目目录**: 选择 `/www/wwwroot/mup`
3. **启动选项**: `server/index.js` (注意：这里要手动选择 server 目录下的 index.js)
4. **项目名称**: `mup` (任意)
5. **端口**: `3000` (或者其他未被占用的端口)
6. **运行用户**: `www` (默认即可)
7. 点击 **提交**。

### 4. 配置环境变量
由于宝塔的 Node 项目界面可能不方便直接设置环境变量，我们可以在项目根目录新建一个 `.env` 文件（如果已存在则修改它），填入生产环境配置：

```env
# 在 /www/wwwroot/mup/.env 文件中写入：

VITE_SUPABASE_URL=你的_supabase_url
VITE_SUPABASE_ANON_KEY=你的_supabase_anon_key
DEEPSEEK_API_KEY=sk-a758655a18484e9894b45394e22f663d
PORT=3000
```
*注意：修改 .env 后，需要在 PM2 管理器中重启该项目才能生效。*

### 5. 绑定域名 (外网访问)
1. 在 Node 项目列表中，找到刚才创建的项目。
2. 点击右侧的 **映射** (或者 **域名管理**)。
3. 输入你的域名 (例如 `lichenbo.cn`)。
4. 宝塔会自动为你创建反向代理配置。
5. 访问域名，应用应该就可以正常使用了！

---

## 方式二：Docker 部署 (简单)

如果你的宝塔面板安装了 **Docker 管理器**，这种方式更省心。

1. **获取镜像**:
   在服务器终端执行：
   ```bash
   # 在项目目录下
   docker build -t mup-app .
   ```

2. **运行容器**:
   ```bash
   docker run -d \
     --name mup-server \
     -p 3000:3000 \
     -e DEEPSEEK_API_KEY=sk-a758655a18484e9894b45394e22f663d \
     -e VITE_SUPABASE_URL=你的url \
     -e VITE_SUPABASE_ANON_KEY=你的key \
     mup-app
   ```

3. **配置反向代理**:
   1. 在宝塔 **网站** -> **PHP项目** (或静态项目) -> **添加站点**。
   2. 域名填写 `lichenbo.cn`，PHP 版本选择 "纯静态"。
   3. 创建成功后，点击设置 -> **反向代理** -> **添加反向代理**。
   4. **代理名称**: `mup`
   5. **目标URL**: `http://127.0.0.1:3000`
   6. 提交即可。

---

## 常见问题

1. **前端页面空白？**
   - 检查 `npm run build` 是否成功。
   - 检查浏览器控制台是否有报错。

2. **AI 助教无法对话 (404/500)？**
   - 确保 `.env` 文件中有 `DEEPSEEK_API_KEY`。
   - 确保 Node 服务已重启。
   - 检查反向代理配置是否正确转发了 `/api` 请求。

3. **HTTPS 证书**
   - 在绑定域名后，直接在宝塔的 **SSL** 选项卡中申请 Let's Encrypt 免费证书即可。
