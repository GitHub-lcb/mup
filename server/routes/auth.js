import express from 'express';
import pool from '../config/database.js';
import { generateToken, hashPassword, verifyPassword, authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// 注册
router.post('/register', async (req, res) => {
  try {
    const { email, password, nickname } = req.body;

    // 验证输入
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    // 检查邮箱是否已存在
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    // 创建用户
    const passwordHash = await hashPassword(password);
    const userNickname = nickname || email.split('@')[0];

    const result = await pool.query(
      `INSERT INTO users (email, password_hash, nickname, role) 
       VALUES ($1, $2, $3, 'user') 
       RETURNING id, email, nickname, role, created_at`,
      [email, passwordHash, userNickname]
    );

    const user = result.rows[0];
    const token = generateToken(user.id);

    res.status(201).json({
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        role: user.role,
        created_at: user.created_at
      },
      token
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// 登录
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // 查找用户
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = result.rows[0];

    // 验证密码
    const isValidPassword = await verifyPassword(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // 生成 token
    const token = generateToken(user.id);

    res.json({
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        role: user.role,
        created_at: user.created_at
      },
      token
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// 获取当前用户信息
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, email, nickname, role, created_at, updated_at FROM users WHERE id = $1',
      [req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user: result.rows[0] });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to get user info' });
  }
});

// 登出（客户端删除 token 即可，服务端不需要处理）
router.post('/logout', (req, res) => {
  res.json({ message: 'Logout successful' });
});

// 更新用户信息
router.patch('/me', authMiddleware, async (req, res) => {
  try {
    const { nickname } = req.body;
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (nickname !== undefined) {
      updates.push(`nickname = $${paramCount}`);
      values.push(nickname);
      paramCount++;
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updates.push(`updated_at = NOW()`);
    values.push(req.userId);

    const query = `
      UPDATE users 
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, email, nickname, role, created_at, updated_at
    `;

    const result = await pool.query(query, values);

    res.json({ user: result.rows[0] });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Failed to update user' });
  }
});

export default router;
