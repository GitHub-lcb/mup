import express from 'express';
import pool from '../config/database.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// 提交答题记录
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { question_id, user_answer, is_correct, time_spent } = req.body;

    if (!question_id || user_answer === undefined || is_correct === undefined) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // 插入答题记录
    const result = await pool.query(
      `INSERT INTO question_attempts (user_id, question_id, user_answer, is_correct, time_spent)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [req.userId, question_id, user_answer, is_correct, time_spent || 0]
    );

    // 更新题目统计
    await pool.query(
      `UPDATE questions 
       SET attempt_count = attempt_count + 1,
           correct_count = correct_count + CASE WHEN $1 THEN 1 ELSE 0 END,
           correct_rate = CASE 
             WHEN attempt_count + 1 > 0 
             THEN (correct_count + CASE WHEN $1 THEN 1 ELSE 0 END)::FLOAT / (attempt_count + 1)::FLOAT 
             ELSE 0 
           END
       WHERE id = $2`,
      [is_correct, question_id]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Create attempt error:', error);
    res.status(500).json({ error: 'Failed to submit answer' });
  }
});

// 获取用户的答题记录
router.get('/my', authMiddleware, async (req, res) => {
  try {
    const { question_id, page = 1, limit = 50 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let query = `
      SELECT qa.*, q.title, q.difficulty 
      FROM question_attempts qa
      LEFT JOIN questions q ON qa.question_id = q.id
      WHERE qa.user_id = $1
    `;
    const values = [req.userId];

    if (question_id) {
      query += ` AND qa.question_id = $2`;
      values.push(question_id);
    }

    query += ` ORDER BY qa.created_at DESC LIMIT $${values.length + 1} OFFSET $${values.length + 2}`;
    values.push(parseInt(limit), offset);

    const result = await pool.query(query, values);

    res.json(result.rows);
  } catch (error) {
    console.error('Get attempts error:', error);
    res.status(500).json({ error: 'Failed to fetch attempts' });
  }
});

// 获取用户错题
router.get('/mistakes', authMiddleware, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    const query = `
      SELECT DISTINCT ON (q.id) 
        q.*, 
        qa.user_answer,
        qa.created_at as attempted_at
      FROM questions q
      INNER JOIN question_attempts qa ON q.id = qa.question_id
      WHERE qa.user_id = $1 AND qa.is_correct = false
      ORDER BY q.id, qa.created_at DESC
      LIMIT $2 OFFSET $3
    `;

    const result = await pool.query(query, [req.userId, parseInt(limit), offset]);

    res.json(result.rows);
  } catch (error) {
    console.error('Get mistakes error:', error);
    res.status(500).json({ error: 'Failed to fetch mistakes' });
  }
});

export default router;
