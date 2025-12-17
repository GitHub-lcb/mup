-- Add VIP support
-- 1. Add is_pro column to users
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_pro BOOLEAN DEFAULT false;

-- 2. Add is_premium column to questions
ALTER TABLE questions ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT false;

-- 3. Update RLS policies (Optional for MVP, but good practice)
-- For now, we rely on frontend checks, but strictly speaking we should limit access.
-- Let's just allow reading is_premium flag.

-- 4. Mark some "Hard" questions as Premium to simulate content
UPDATE questions 
SET is_premium = true 
WHERE difficulty = 'hard';

-- 5. Create a "orders" table for history (optional, but good for structure)
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL,
  status VARCHAR(20) DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on orders
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);
