import express from 'express';
import pool from '../config/database.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// 获取题目的评论
router.get('/', async (req, res) => {
  try {
    const { question_id } = req.query;

    if (!question_id) {
      return res.status(400).json({ error: 'question_id is required' });
    }

    const result = await pool.query(
      `SELECT c.*, u.nickname, u.email
       FROM comments c
       LEFT JOIN users u ON c.user_id = u.id
       WHERE c.question_id = $1
       ORDER BY c.created_at ASC`,
      [question_id]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Get comments error:', error);
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
});

// 创建评论
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { question_id, content, parent_id } = req.body;

    if (!question_id || !content) {
      return res.status(400).json({ error: 'question_id and content are required' });
    }

    const result = await pool.query(
      `INSERT INTO comments (question_id, user_id, content, parent_id)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [question_id, req.userId, content, parent_id || null]
    );

    // 获取用户信息
    const userResult = await pool.query(
      'SELECT nickname, email FROM users WHERE id = $1',
      [req.userId]
    );

    const comment = {
      ...result.rows[0],
      nickname: userResult.rows[0].nickname,
      email: userResult.rows[0].email
    };

    res.status(201).json(comment);
  } catch (error) {
    console.error('Create comment error:', error);
    res.status(500).json({ error: 'Failed to create comment' });
  }
});

// 更新评论
router.patch('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { content } = req.body;

    if (!content) {
      return res.status(400).json({ error: 'content is required' });
    }

    const result = await pool.query(
      `UPDATE comments 
       SET content = $1, updated_at = NOW()
       WHERE id = $2 AND user_id = $3
       RETURNING *`,
      [content, id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Comment not found or unauthorized' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update comment error:', error);
    res.status(500).json({ error: 'Failed to update comment' });
  }
});

// 删除评论
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM comments WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Comment not found or unauthorized' });
    }

    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    console.error('Delete comment error:', error);
    res.status(500).json({ error: 'Failed to delete comment' });
  }
});

export default router;
