import { createOpenAI } from '@ai-sdk/openai';
import { streamText } from 'ai';

export const config = {
  runtime: 'edge',
};

const openai = createOpenAI({
  apiKey: process.env.DEEPSEEK_API_KEY,
  baseURL: 'https://api.deepseek.com',
});

export default async function handler(req: Request) {
  const { messages, context } = await req.json();

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

  // @ts-ignore
  if (result.toDataStreamResponse) {
    // @ts-ignore
    return result.toDataStreamResponse();
  }
  
  // Fallback for older SDK versions
  // @ts-ignore
  return result.toTextStreamResponse();
}
