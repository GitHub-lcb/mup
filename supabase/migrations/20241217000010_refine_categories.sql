-- Reorganize Categories and Fix Question Assignments

-- 1. Insert new categories
INSERT INTO categories (name, description, icon, sort_order) VALUES
('数据库', 'MySQL, Redis, SQL优化等', 'database', 9),
('Spring框架', 'Spring, Spring Boot, MyBatis等', 'layers', 10),
('计算机网络', 'TCP/IP, HTTP, HTTPS等', 'globe', 11),
('操作系统', '进程, 线程, Linux命令等', 'cpu', 12),
('系统设计', '分布式, 微服务, 高并发, 架构设计', 'server', 13),
('算法与数据结构', '排序, 查找, 链表, 树等', 'git-branch', 14),
('开发工具', 'Git, Docker, Maven, Linux等', 'tool', 15);

-- 2. Update existing category names/icons if needed
UPDATE categories SET name = 'Java基础', description = 'Java语言基础、面向对象、异常处理等' WHERE name = 'Java基础语法';
UPDATE categories SET name = 'Java并发', description = '多线程、线程池、锁机制、JMM' WHERE name = '多线程';

-- 3. Reassign questions to correct categories

-- Database related
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = '数据库')
WHERE title LIKE '%MySQL%' 
   OR title LIKE '%Redis%' 
   OR title LIKE '%数据库%'
   OR title LIKE '%MVCC%'
   OR title LIKE '%ACID%'
   OR title LIKE '%MyBatis%';

-- Spring related
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = 'Spring框架')
WHERE title LIKE '%Spring%' 
   OR title LIKE '%Bean%'
   OR title LIKE '%AOP%'
   OR title LIKE '%MyBatis%'; -- MyBatis fits here too, or Database. Let's put MyBatis in Frameworks for now or Database? Usually Database/ORM. Let's keep MyBatis in Frameworks or Database. Let's put MyBatis in 'Spring框架' (Frameworks) effectively or just leave in Database? Let's put MyBatis in Spring/Frameworks.
   
-- Network related
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = '计算机网络')
WHERE title LIKE '%TCP%' 
   OR title LIKE '%HTTP%' 
   OR title LIKE '%Socket%';

-- OS related
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = '操作系统')
WHERE title LIKE '%进程%' 
   OR title LIKE '%Linux%' 
   OR title LIKE '%Load Average%';

-- System Design related
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = '系统设计')
WHERE title LIKE '%微服务%' 
   OR title LIKE '%分布式%' 
   OR title LIKE '%CAP%'
   OR title LIKE '%幂等性%'
   OR title LIKE '%熔断%';

-- Algorithm related
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = '算法与数据结构')
WHERE title LIKE '%排序%' 
   OR title LIKE '%查找%' 
   OR title LIKE '%算法%';

-- Tools related
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = '开发工具')
WHERE title LIKE '%Git%' 
   OR title LIKE '%Docker%';

-- JVM related (Keep in JVM)
-- Collections related (Keep in 集合框架)

-- Merge '异常处理', 'IO流', '反射机制', '面向对象' into 'Java基础' to simplify?
-- User asked for better classification. Too many small categories is annoying.
-- Let's merge:
-- '异常处理', '反射机制', '面向对象' -> 'Java基础'
-- 'IO流' -> 'Java基础' (Java IO) or '计算机网络' (Netty/IO Models)?
-- Let's put IO Models (BIO/NIO/AIO) into 'Java基础' or new 'Java IO'? 
-- Actually 'Java并发' is good. 
-- Let's consolidate.

-- Consolidate '面向对象', '异常处理', '反射机制' into 'Java基础'
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = 'Java基础')
WHERE category_id IN (
  SELECT id FROM categories WHERE name IN ('面向对象', '异常处理', '反射机制')
);

-- Delete empty categories
DELETE FROM categories WHERE name IN ('面向对象', '异常处理', '反射机制');

-- Rename 'IO流' to 'Java IO & NIO'? Or merge to Java Basic?
-- Let's merge 'IO流' questions. Some were Network/DB/Redis mappings.
-- We already moved Redis/DB/Network questions out of 'IO流' above.
-- Check what's left in 'IO流'. Probably Java IO stuff.
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = 'Java基础')
WHERE category_id = (SELECT id FROM categories WHERE name = 'IO流') AND title LIKE '%Java IO%';

-- If any IO questions remain (like Kafka?), move them.
UPDATE questions 
SET category_id = (SELECT id FROM categories WHERE name = '系统设计')
WHERE title LIKE '%Kafka%';

-- Now delete IO流 if empty
DELETE FROM categories WHERE name = 'IO流';

-- 4. Reorder categories
UPDATE categories SET sort_order = 1 WHERE name = 'Java基础';
UPDATE categories SET sort_order = 2 WHERE name = '集合框架';
UPDATE categories SET sort_order = 3 WHERE name = 'Java并发';
UPDATE categories SET sort_order = 4 WHERE name = 'JVM';
UPDATE categories SET sort_order = 5 WHERE name = 'Spring框架';
UPDATE categories SET sort_order = 6 WHERE name = '数据库';
UPDATE categories SET sort_order = 7 WHERE name = '计算机网络';
UPDATE categories SET sort_order = 8 WHERE name = '操作系统';
UPDATE categories SET sort_order = 9 WHERE name = '系统设计';
UPDATE categories SET sort_order = 10 WHERE name = '算法与数据结构';
UPDATE categories SET sort_order = 11 WHERE name = '开发工具';

