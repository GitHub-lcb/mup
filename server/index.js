import express from 'express';
import compression from 'compression';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { createOpenAI } from '@ai-sdk/openai';
import { streamText } from 'ai';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = process.env.PORT || 3000;

// Enable compression
app.use(compression());
app.use(express.json());

// API Routes
app.post('/api/chat', async (req, res) => {
  try {
    const { messages, context } = req.body;

    const openai = createOpenAI({
      apiKey: process.env.DEEPSEEK_API_KEY,
      baseURL: 'https://api.deepseek.com/v1',
    });

    const systemPrompt = `
You are an expert Java Technical Interview Tutor.
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
5. Use Markdown formatting.
`;

    const result = await streamText({
      model: openai('deepseek-chat'),
      system: systemPrompt,
      messages,
    });

    result.pipeDataStreamToResponse(res);
  } catch (error) {
    console.error('API Error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Serve static files from the dist directory
const distPath = join(__dirname, '../dist');
app.use(express.static(distPath));

// Handle SPA routing - send all other requests to index.html
app.get('*', (req, res) => {
  res.sendFile(join(distPath, 'index.html'));
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
