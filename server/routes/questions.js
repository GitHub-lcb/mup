import express from 'express';
import pool from '../config/database.js';
import { authMiddleware, optionalAuth } from '../middleware/auth.js';

const router = express.Router();

// 获取题目列表（支持分页和筛选）
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      category_id,
      difficulty,
      search,
      is_active = 'true'
    } = req.query;

    const offset = (parseInt(page) - 1) * parseInt(limit);
    const conditions = [];
    const values = [];
    let paramCount = 1;

    // 构建查询条件
    if (is_active === 'true') {
      conditions.push(`is_active = true`);
    }

    if (category_id) {
      conditions.push(`category_id = $${paramCount}`);
      values.push(category_id);
      paramCount++;
    }

    if (difficulty) {
      conditions.push(`difficulty = $${paramCount}`);
      values.push(difficulty);
      paramCount++;
    }

    if (search) {
      conditions.push(`title ILIKE $${paramCount}`);
      values.push(`%${search}%`);
      paramCount++;
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    // 获取总数
    const countQuery = `SELECT COUNT(*) FROM questions ${whereClause}`;
    const countResult = await pool.query(countQuery, values);
    const total = parseInt(countResult.rows[0].count);

    // 获取题目列表
    values.push(parseInt(limit));
    values.push(offset);
    const query = `
      SELECT * FROM questions 
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

    const result = await pool.query(query, values);

    res.json({
      questions: result.rows,
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(total / parseInt(limit))
    });
  } catch (error) {
    console.error('Get questions error:', error);
    res.status(500).json({ error: 'Failed to fetch questions' });
  }
});

// 获取单个题目详情
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'SELECT * FROM questions WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Question not found' });
    }

    // 增加查看次数
    await pool.query(
      'UPDATE questions SET view_count = view_count + 1 WHERE id = $1',
      [id]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get question error:', error);
    res.status(500).json({ error: 'Failed to fetch question' });
  }
});

// 创建题目（需要管理员权限）
router.post('/', authMiddleware, async (req, res) => {
  try {
    // 检查是否是管理员
    const userResult = await pool.query(
      'SELECT role FROM users WHERE id = $1',
      [req.userId]
    );

    if (userResult.rows.length === 0 || userResult.rows[0].role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const {
      title,
      content,
      type,
      options,
      correct_answer,
      explanation,
      difficulty,
      category_id,
      tags,
      is_active = true
    } = req.body;

    if (!title || !content || !type || !correct_answer || !difficulty) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const result = await pool.query(
      `INSERT INTO questions 
       (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Create question error:', error);
    res.status(500).json({ error: 'Failed to create question' });
  }
});

// 更新题目（需要管理员权限）
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
    const {
      title,
      content,
      type,
      options,
      correct_answer,
      explanation,
      difficulty,
      category_id,
      tags,
      is_active
    } = req.body;

    const updates = [];
    const values = [];
    let paramCount = 1;

    if (title !== undefined) {
      updates.push(`title = $${paramCount}`);
      values.push(title);
      paramCount++;
    }
    if (content !== undefined) {
      updates.push(`content = $${paramCount}`);
      values.push(content);
      paramCount++;
    }
    if (type !== undefined) {
      updates.push(`type = $${paramCount}`);
      values.push(type);
      paramCount++;
    }
    if (options !== undefined) {
      updates.push(`options = $${paramCount}`);
      values.push(options);
      paramCount++;
    }
    if (correct_answer !== undefined) {
      updates.push(`correct_answer = $${paramCount}`);
      values.push(correct_answer);
      paramCount++;
    }
    if (explanation !== undefined) {
      updates.push(`explanation = $${paramCount}`);
      values.push(explanation);
      paramCount++;
    }
    if (difficulty !== undefined) {
      updates.push(`difficulty = $${paramCount}`);
      values.push(difficulty);
      paramCount++;
    }
    if (category_id !== undefined) {
      updates.push(`category_id = $${paramCount}`);
      values.push(category_id);
      paramCount++;
    }
    if (tags !== undefined) {
      updates.push(`tags = $${paramCount}`);
      values.push(tags);
      paramCount++;
    }
    if (is_active !== undefined) {
      updates.push(`is_active = $${paramCount}`);
      values.push(is_active);
      paramCount++;
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updates.push(`updated_at = NOW()`);
    values.push(id);

    const query = `
      UPDATE questions 
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Question not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update question error:', error);
    res.status(500).json({ error: 'Failed to update question' });
  }
});

// 删除题目（需要管理员权限）
router.delete('/:id', authMiddleware, async (req, res) => {
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

    const result = await pool.query(
      'DELETE FROM questions WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Question not found' });
    }

    res.json({ message: 'Question deleted successfully' });
  } catch (error) {
    console.error('Delete question error:', error);
    res.status(500).json({ error: 'Failed to delete question' });
  }
});

export default router;
