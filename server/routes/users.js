import express from 'express';
import pool from '../config/database.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// 获取所有用户（管理员）
router.get('/', authMiddleware, async (req, res) => {
  try {
    // 检查是否是管理员
    const userResult = await pool.query(
      'SELECT role FROM users WHERE id = $1',
      [req.userId]
    );

    if (userResult.rows.length === 0 || userResult.rows[0].role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const result = await pool.query(
      'SELECT id, email, nickname, role, created_at, updated_at FROM users ORDER BY created_at DESC'
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// 更新用户（管理员）
router.patch('/:id', authMiddleware, async (req, res) => {
  try {
    // 检查是否是管理员
    const userResult = await pool.query(
      'SELECT role FROM users WHERE id = $1',
      [req.userId]
    );

    if (userResult.rows.length === 0 || userResult.rows[0].role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const { id } = req.params;
    const { nickname, role } = req.body;

    const updates = [];
    const values = [];
    let paramCount = 1;

    if (nickname !== undefined) {
      updates.push(`nickname = $${paramCount}`);
      values.push(nickname);
      paramCount++;
    }

    if (role !== undefined) {
      updates.push(`role = $${paramCount}`);
      values.push(role);
      paramCount++;
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updates.push(`updated_at = NOW()`);
    values.push(id);

    const query = `
      UPDATE users 
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, email, nickname, role, created_at, updated_at
    `;

    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Failed to update user' });
  }
});

// 获取用户学习进度统计
router.get('/progress', authMiddleware, async (req, res) => {
  try {
    // 获取总体统计
    const totalResult = await pool.query(
      `SELECT 
        COUNT(*) as total_questions,
        COUNT(DISTINCT qa.question_id) as answered_questions,
        COUNT(CASE WHEN qa.is_correct THEN 1 END) as correct_answers
       FROM questions q
       LEFT JOIN question_attempts qa ON q.id = qa.question_id AND qa.user_id = $1
       WHERE q.is_active = true`,
      [req.userId]
    );

    const stats = totalResult.rows[0];
    stats.accuracy = stats.answered_questions > 0 
      ? (stats.correct_answers / stats.answered_questions * 100).toFixed(1)
      : 0;

    // 获取分类进度
    const categoryResult = await pool.query(
      `SELECT 
        c.id,
        c.name,
        c.icon,
        COUNT(DISTINCT q.id) as total_questions,
        COUNT(DISTINCT qa.question_id) as answered_questions,
        COUNT(CASE WHEN qa.is_correct THEN 1 END) as correct_answers
       FROM categories c
       LEFT JOIN questions q ON c.id = q.category_id AND q.is_active = true
       LEFT JOIN question_attempts qa ON q.id = qa.question_id AND qa.user_id = $1
       GROUP BY c.id, c.name, c.icon
       ORDER BY c.sort_order`,
      [req.userId]
    );

    res.json({
      overall: stats,
      categories: categoryResult.rows
    });
  } catch (error) {
    console.error('Get progress error:', error);
    res.status(500).json({ error: 'Failed to fetch progress' });
  }
});

// 升级为 Pro 会员
router.post('/upgrade', authMiddleware, async (req, res) => {
  try {
    // 更新用户为 Pro 会员
    const result = await pool.query(
      `UPDATE users 
       SET is_pro = true, updated_at = NOW()
       WHERE id = $1
       RETURNING id, email, nickname, is_pro, role`,
      [req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    // 创建订单记录
    await pool.query(
      `INSERT INTO orders (user_id, amount, status, created_at, updated_at)
       VALUES ($1, 99.00, 'completed', NOW(), NOW())`,
      [req.userId]
    );

    res.json({
      message: 'Upgrade successful',
      user: result.rows[0]
    });
  } catch (error) {
    console.error('Upgrade error:', error);
    res.status(500).json({ error: 'Failed to upgrade' });
  }
});

export default router;
