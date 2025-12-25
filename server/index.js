import express from 'express';
import compression from 'compression';
import cors from 'cors';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import dotenv from 'dotenv';

// Import routes
import authRoutes from './routes/auth.js';
import questionsRoutes from './routes/questions.js';
import categoriesRoutes from './routes/categories.js';
import attemptsRoutes from './routes/attempts.js';
import favoritesRoutes from './routes/favorites.js';
import commentsRoutes from './routes/comments.js';
import leaderboardRoutes from './routes/leaderboard.js';
import usersRoutes from './routes/users.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(compression());
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/questions', questionsRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/attempts', attemptsRoutes);
app.use('/api/favorites', favoritesRoutes);
app.use('/api/comments', commentsRoutes);
app.use('/api/leaderboard', leaderboardRoutes);
app.use('/api/users', usersRoutes);

app.post('/api/chat', async (req, res) => {
  try {
    const { messages, context } = req.body;

    const systemPrompt = `You are an expert Java Technical Interview Tutor.
Your goal is to help students understand Java concepts, analyze their mistakes, and provide clear explanations.

Context:
Question Title: ${context?.title || 'Unknown'}
Question Content: ${context?.content || 'Unknown'}
User's Answer: ${context?.userAnswer || 'None'}
Correct Answer: ${context?.correctAnswer || 'None'}

Instructions:
1. Be encouraging and professional.
2. If the user answered incorrectly, explain WHY their answer is wrong and WHY the correct answer is right.
3. Provide a short code example if applicable.
4. Keep your response concise but informative (under 200 words if possible).
5. Use Markdown formatting.`;

    // 构建消息数组，确保角色是 DeepSeek 支持的
    const apiMessages = [
      { role: 'system', content: systemPrompt },
      ...messages.filter(m => ['user', 'assistant'].includes(m.role)),
    ];

    // 直接调用 DeepSeek API
    const response = await fetch('https://api.deepseek.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'deepseek-chat',
        messages: apiMessages,
        stream: true,
      }),
    });

    if (!response.ok) {
      throw new Error(`DeepSeek API error: ${response.statusText}`);
    }

    // 设置响应头为流式传输
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });

    // 读取流式响应
    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value);
      const lines = chunk.split('\n').filter(line => line.trim() && line.startsWith('data: '));

      for (const line of lines) {
        const data = line.substring(6); // 移除 'data: ' 前缀
        if (data === '[DONE]') continue;

        try {
          const json = JSON.parse(data);
          const content = json.choices?.[0]?.delta?.content;
          if (content) {
            res.write(`0:${JSON.stringify(content)}\n`);
          }
        } catch (e) {
          // 忽略解析错误
        }
      }
    }
    
    res.end();
  } catch (error) {
    console.error('API Error:', error);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Internal Server Error', message: error.message });
    }
  }
});

// Serve static files from the dist directory
const distPath = join(__dirname, '../dist');
app.use(express.static(distPath));

// Handle SPA routing - send all other requests to index.html
// Note: This should be the last route
// Express 5.x doesn't support wildcard routes, use a middleware instead
app.use((req, res, next) => {
  // If it's not an API route and file doesn't exist, serve index.html
  if (!req.path.startsWith('/api')) {
    res.sendFile(join(distPath, 'index.html'));
  } else {
    next();
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
