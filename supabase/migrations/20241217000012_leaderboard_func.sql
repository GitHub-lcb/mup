-- Create a function to calculate leaderboard
-- This avoids complex client-side logic and ensures performance

CREATE OR REPLACE FUNCTION get_leaderboard()
RETURNS TABLE (
  id UUID,
  nickname VARCHAR,
  email VARCHAR,
  correct_count BIGINT,
  accuracy FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.nickname,
    u.email,
    COUNT(DISTINCT qa.question_id) FILTER (WHERE qa.is_correct = true) as correct_count,
    CASE 
      WHEN COUNT(qa.id) = 0 THEN 0.0
      ELSE (COUNT(qa.id) FILTER (WHERE qa.is_correct = true)::FLOAT / COUNT(qa.id)::FLOAT) * 100
    END as accuracy
  FROM 
    public.users u
  LEFT JOIN 
    question_attempts qa ON u.id = qa.user_id
  GROUP BY 
    u.id, u.nickname, u.email
  HAVING 
    COUNT(qa.id) > 0 -- Only show users who have attempted at least one question
  ORDER BY 
    correct_count DESC, 
    accuracy DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
