-- Insert more high-quality questions: Redis, MySQL, Spring Cloud, JUC

INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active) 
VALUES 
-- 1. Redis: Cache Penetration/Breakdown/Avalanche
(
  'Redis 缓存穿透、击穿、雪崩的区别与解决方案', 
  '关于 Redis 缓存的三大经典问题，以下描述错误的是？',
  'single', 
  '["缓存穿透：查询不存在的数据，导致请求直接打到数据库。解决方案：布隆过滤器或缓存空对象", "缓存击穿：热点 Key 过期，大量并发请求瞬间打到数据库。解决方案：互斥锁或逻辑过期", "缓存雪崩：大量 Key 同时过期，导致数据库压力剧增。解决方案：过期时间加随机值", "缓存雪崩只能通过 Redis 集群高可用解决，单机无法避免"]',
  'D',
  '### 深度解析

#### 选项 D 错误分析
**缓存雪崩**的主要原因是**大量 Key 在同一时间过期**。
虽然 Redis 宕机也会导致雪崩（这时确实需要高可用集群），但最常见的场景是 Key 集中过期。
**解决方案**：
1.  **随机过期时间**：在原有的过期时间上加上一个随机值（如 1-5 分钟），避免同时过期。
2.  **双层缓存**：A1 为短期，A2 为长期。
3.  **限流降级**：当流量剧增时，通过 Sentinel/Hystrix 限流。

#### 其他概念复习
*   **缓存穿透 (Penetration)**: 查**根本不存在**的数据（如 id=-1）。黑客攻击常用手段。
    *   *解法*：布隆过滤器 (Bloom Filter) 或 `set key null`。
*   **缓存击穿 (Breakdown)**: **一个**热点 Key（如秒杀商品）过期，大量并发请求击穿缓存。
    *   *解法*：互斥锁 (Mutex Lock) 或 逻辑过期 (Logical Expiration)。',
  'hard',
  (SELECT id FROM categories WHERE name = '数据库'), -- Redis belongs to DB category now
  ARRAY['Redis', '缓存', '高并发'],
  true
),

-- 2. MySQL: Index Optimization
(
  'MySQL 索引失效的常见场景', 
  '在 MySQL InnoDB 中，以下哪种 SQL 语句会导致索引失效（假设 `name` 字段有普通索引）？',
  'single', 
  '["SELECT * FROM users WHERE name = ''Alice''", "SELECT * FROM users WHERE name LIKE ''Alice%''", "SELECT * FROM users WHERE name LIKE ''%Alice''", "SELECT id FROM users WHERE name = ''Alice''"]',
  'C',
  '### 深度解析

#### 选项 C (索引失效)
`LIKE ''%Alice''`（左模糊匹配）。
*   B+ 树索引是按照从左到右的顺序建立的。如果最左边的字符都不确定（是 `%`），则无法利用索引进行快速定位，只能**全表扫描** (Full Table Scan)。

#### 其他选项分析
*   **A**: 标准等值查询，走索引。
*   **B**: `LIKE ''Alice%''`（右模糊匹配）。最左前缀匹配，走索引（范围查询）。
*   **D**: 覆盖索引 (Covering Index)。查询的 `id` 就在索引树上，甚至不需要回表，性能极高。

#### 其他常见失效场景
1.  对索引列进行**运算**或**函数操作**：`WHERE YEAR(create_time) = 2023`。
2.  **类型隐式转换**：字符串列不加引号 `WHERE name = 123`。
3.  **OR** 连接条件：如果 OR 两边有一边没有索引，就会失效。',
  'medium',
  (SELECT id FROM categories WHERE name = '数据库'),
  ARRAY['MySQL', '索引', 'SQL优化'],
  true
),

-- 3. JUC: ThreadLocal
(
  'ThreadLocal 的内存泄漏问题', 
  '关于 ThreadLocal 内存泄漏的原因，以下描述正确的是？',
  'single', 
  '["ThreadLocal 实例本身占用的内存太大", "ThreadLocalMap 中的 Key 是强引用，Value 是弱引用", "ThreadLocalMap 中的 Key 是弱引用，Value 是强引用，ThreadLocal 被回收后，Value 依然存在但无法访问", "ThreadLocal 只能在单线程环境使用，多线程必然泄漏"]',
  'C',
  '### 深度解析

#### 核心原因
`ThreadLocalMap` 的 Entry 实现继承自 `WeakReference<ThreadLocal<?>>`。
*   **Key (ThreadLocal 对象)**：是**弱引用**。
*   **Value (业务对象)**：是**强引用**。

#### 泄漏过程
1.  当外部没有对 `ThreadLocal` 对象的强引用时，在下一次 GC 时，`ThreadLocal` 对象（Key）会被回收。
2.  此时，Map 中就会出现 `Key` 为 `null` 的 Entry。
3.  但是，**Value** 依然被当前线程的 `ThreadLocalMap` 强引用着。
4.  如果当前线程一直不结束（例如线程池中的核心线程），这个 `Value` 对象就永远无法被回收，造成内存泄漏。

#### 解决方案
使用完 ThreadLocal 后，**务必手动调用 `remove()` 方法**。
```java
try {
    tl.set(obj);
    // do something
} finally {
    tl.remove(); // Prevent memory leak
}
```',
  'hard',
  (SELECT id FROM categories WHERE name = 'Java并发'),
  ARRAY['多线程', '内存泄漏', 'ThreadLocal'],
  true
),

-- 4. Spring Cloud: Gateway
(
  'Spring Cloud Gateway vs Zuul', 
  'Spring Cloud Gateway 取代了 Zuul 1.x 成为新一代网关，主要原因不包括？',
  'single', 
  '["Gateway 基于 Spring WebFlux（Reactor），是异步非阻塞模型", "Zuul 1.x 基于 Servlet 2.5，是同步阻塞模型", "Gateway 性能通常比 Zuul 1.x 高", "Gateway 只能配合 Eureka 使用，不支持 Nacos"]',
  'D',
  '### 深度解析

#### 选项 D 错误
Spring Cloud Gateway 是 Spring Cloud 生态的亲儿子，支持多种服务发现组件，包括 **Eureka, Nacos, Consul, Zookeeper** 等。

#### Gateway 核心优势
1.  **异步非阻塞**：底层使用 Netty + Reactor，支持高并发长连接（WebSocket），性能显著优于基于 Servlet (BIO) 的 Zuul 1.x。
2.  **功能强大**：内置了限流（RequestRateLimiter）、熔断、重试、路径重写等过滤器。
3.  **断言工厂 (Predicates)**：路由匹配规则极其灵活（Path, Method, Header, Host, Time 等）。

#### Zuul 2.x
虽然 Zuul 2.x 也是异步的，但由于 Spring 官方推出了 Gateway，Zuul 在 Spring Cloud 生态中逐渐被边缘化。',
  'medium',
  (SELECT id FROM categories WHERE name = '系统设计'),
  ARRAY['微服务', '网关', 'Spring Cloud'],
  true
),

-- 5. Design Pattern: Proxy
(
  '静态代理 vs 动态代理', 
  '关于设计模式中的代理模式，以下说法错误的是？',
  'single', 
  '["静态代理在编译期就生成了代理类的 .class 文件", "动态代理在运行期动态生成代理对象", "JDK 动态代理要求目标类必须实现接口", "CGLIB 动态代理通过继承实现，因此可以代理 final 修饰的类"]',
  'D',
  '### 深度解析

#### 选项 D 错误分析
**CGLIB 无法代理 final 类。**
*   CGLIB (Code Generation Library) 的原理是**生成目标类的子类**，并重写父类方法进行增强。
*   Java 规定 `final` 修饰的类**不能被继承**，`final` 修饰的方法**不能被重写**。
*   因此，CGLIB 对 final 类或方法无效。

#### 对比总结
*   **静态代理**：硬编码，一个代理类只能服务一种接口，代码冗余。
*   **JDK 动态代理**：基于接口 (`Proxy.newProxyInstance`)，侵入性小，但必须有接口。
*   **CGLIB**：基于继承 (ASM 字节码)，无需接口，但不能处理 final。',
  'medium',
  (SELECT id FROM categories WHERE name = 'Java基础'), -- Design Pattern moved to Java Basic or Frameworks?
  ARRAY['设计模式', '代理', 'Spring'],
  true
),

-- 6. Algorithm: LinkedList Cycle
(
  '判断链表是否有环 (Linked List Cycle)', 
  '给定一个链表，如何高效判断其中是否有环？',
  'single', 
  '["使用哈希表存储访问过的节点，如果有重复则有环。空间复杂度 O(n)", "快慢指针法：快指针走两步，慢指针走一步。如果相遇则有环。空间复杂度 O(1)", "遍历链表，如果在规定时间内没走到 null 则认为有环", "反转链表，如果头部和尾部相同则有环"]',
  'B',
  '### 深度解析

#### 快慢指针 (Floyd 判圈算法)
这是解决链表环问题的标准最优解。

*   **原理**：
    *   定义两个指针 `slow` 和 `fast`，初始都指向 head。
    *   循环：`slow` 每次前进一步，`fast` 每次前进两步。
    *   如果链表**无环**，`fast` 会先走到 `null`，结束。
    *   如果链表**有环**，`fast` 会先进入环，`slow` 后进入。在环内，`fast` 会像在跑道上套圈一样追上 `slow`。一旦 `slow == fast`，说明有环。

*   **复杂度**：
    *   时间：O(n)
    *   空间：O(1)

*   **进阶**：如何找到环的**入口节点**？
    *   相遇后，让一个指针回到 head，另一个保持在相遇点。
    *   两个指针同时每次走一步。
    *   再次相遇的点就是环入口。',
  'easy',
  (SELECT id FROM categories WHERE name = '算法与数据结构'),
  ARRAY['算法', '链表', '双指针'],
  true
);
