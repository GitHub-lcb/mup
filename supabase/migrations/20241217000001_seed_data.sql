-- Insert sample questions

-- Helper function to get category id by name
CREATE OR REPLACE FUNCTION get_category_id(cat_name TEXT) RETURNS UUID AS $$
  SELECT id FROM categories WHERE name = cat_name LIMIT 1;
$$ LANGUAGE sql;

INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active)
VALUES
(
  'Java中String类是不可变的吗？',
  '请判断Java中String类的设计是否为不可变（Immutable）。',
  'single',
  '[
    {"label": "是", "value": "true"},
    {"label": "否", "value": "false"}
  ]'::jsonb,
  'true',
  'String类在Java中是不可变的（Immutable）。String类被final修饰，且其内部用于存储字符的char数组也被final修饰（JDK 9之前）或byte数组（JDK 9及之后），并且没有提供修改内部数组的方法。',
  'easy',
  get_category_id('Java基础语法'),
  ARRAY['String', '基础'],
  true
),
(
  'ArrayList和LinkedList的区别是什么？',
  '关于ArrayList和LinkedList的区别，下列说法错误的是？',
  'single',
  '[
    {"label": "ArrayList基于动态数组实现，LinkedList基于双向链表实现", "value": "A"},
    {"label": "ArrayList随机访问效率高，LinkedList随机访问效率低", "value": "B"},
    {"label": "LinkedList在任意位置插入和删除元素的效率通常优于ArrayList", "value": "C"},
    {"label": "ArrayList比LinkedList更占内存，因为ArrayList需要维护额外的指针", "value": "D"}
  ]'::jsonb,
  'D',
  'D选项错误。LinkedList比ArrayList更占内存，因为LinkedList的每个节点除了存储数据外，还需要存储指向前驱和后继节点的两个引用（指针），而ArrayList只需要存储数据本身（虽然会有扩容预留空间，但总体上LinkedList开销更大）。',
  'medium',
  get_category_id('集合框架'),
  ARRAY['List', '集合'],
  true
),
(
  'HashMap的底层实现原理',
  'JDK 1.8中，HashMap的底层数据结构是？',
  'single',
  '[
    {"label": "数组 + 链表", "value": "A"},
    {"label": "数组 + 红黑树", "value": "B"},
    {"label": "数组 + 链表 + 红黑树", "value": "C"},
    {"label": "双向链表", "value": "D"}
  ]'::jsonb,
  'C',
  'JDK 1.8中，HashMap采用数组 + 链表 + 红黑树的结构。当链表长度超过阈值（默认为8）且数组长度大于64时，链表会转换为红黑树，以提高查询效率。',
  'medium',
  get_category_id('集合框架'),
  ARRAY['HashMap', '集合'],
  true
),
(
  'Java线程的状态有哪些？',
  '下列哪个不是Java线程的状态？',
  'single',
  '[
    {"label": "NEW", "value": "A"},
    {"label": "RUNNABLE", "value": "B"},
    {"label": "RUNNING", "value": "C"},
    {"label": "BLOCKED", "value": "D"}
  ]'::jsonb,
  'C',
  'Java线程状态（Thread.State枚举）包括：NEW, RUNNABLE, BLOCKED, WAITING, TIMED_WAITING, TERMINATED。RUNNING不是Java定义的线程状态，虽然在操作系统层面线程可能处于Running状态，但在Java API中归为RUNNABLE。',
  'medium',
  get_category_id('多线程'),
  ARRAY['Thread', '并发'],
  true
),
(
  'JVM内存区域中，哪个区域是线程私有的？',
  'JVM运行时数据区中，哪些区域是线程私有的？',
  'single',
  '[
    {"label": "堆 (Heap)", "value": "A"},
    {"label": "方法区 (Method Area)", "value": "B"},
    {"label": "虚拟机栈 (VM Stack)", "value": "C"},
    {"label": "直接内存 (Direct Memory)", "value": "D"}
  ]'::jsonb,
  'C',
  'JVM内存区域中，虚拟机栈、本地方法栈和程序计数器是线程私有的。堆和方法区是所有线程共享的。',
  'easy',
  get_category_id('JVM'),
  ARRAY['JVM', '内存模型'],
  true
);
