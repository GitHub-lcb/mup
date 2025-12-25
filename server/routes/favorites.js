import express from 'express';
import pool from '../config/database.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// 添加收藏
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { question_id, notes } = req.body;

    if (!question_id) {
      return res.status(400).json({ error: 'question_id is required' });
    }

    const result = await pool.query(
      `INSERT INTO favorites (user_id, question_id, notes)
       VALUES ($1, $2, $3)
       ON CONFLICT (user_id, question_id) 
       DO UPDATE SET notes = $3, created_at = NOW()
       RETURNING *`,
      [req.userId, question_id, notes]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ error: 'Failed to add favorite' });
  }
});

// 获取用户收藏
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    const result = await pool.query(
      `SELECT f.*, q.title, q.difficulty, q.type, q.category_id
       FROM favorites f
       LEFT JOIN questions q ON f.question_id = q.id
       WHERE f.user_id = $1
       ORDER BY f.created_at DESC
       LIMIT $2 OFFSET $3`,
      [req.userId, parseInt(limit), offset]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({ error: 'Failed to fetch favorites' });
  }
});

// 检查是否收藏
router.get('/check/:question_id', authMiddleware, async (req, res) => {
  try {
    const { question_id } = req.params;

    const result = await pool.query(
      'SELECT id FROM favorites WHERE user_id = $1 AND question_id = $2',
      [req.userId, question_id]
    );

    res.json({ is_favorite: result.rows.length > 0 });
  } catch (error) {
    console.error('Check favorite error:', error);
    res.status(500).json({ error: 'Failed to check favorite' });
  }
});

// 删除收藏
router.delete('/:question_id', authMiddleware, async (req, res) => {
  try {
    const { question_id } = req.params;

    const result = await pool.query(
      'DELETE FROM favorites WHERE user_id = $1 AND question_id = $2 RETURNING id',
      [req.userId, question_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Favorite not found' });
    }

    res.json({ message: 'Favorite removed successfully' });
  } catch (error) {
    console.error('Delete favorite error:', error);
    res.status(500).json({ error: 'Failed to delete favorite' });
  }
});

export default router;
