import express from 'express';
import pool from '../config/database.js';

const router = express.Router();

// 获取排行榜
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM get_leaderboard()');
    res.json(result.rows);
  } catch (error) {
    console.error('Get leaderboard error:', error);
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

export default router;
