-- Insert Batch 3: System Design & High Concurrency

INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active) 
VALUES 
-- 1. System Design: Short URL
(
  '短链接系统设计 (TinyURL)', 
  '设计一个短链接生成系统（如 bit.ly），将长 URL 转换为短 URL。以下关于生成短码（Hash）的方案，哪种最合适？',
  'single', 
  '["使用 MD5 对长 URL 进行哈希，截取前 6 位", "使用自增 ID（数据库自增主键或 Redis INCR），再转换为 62 进制", "随机生成 6 位字符串，查库判断是否冲突，冲突则重试", "使用 UUID 生成唯一 ID"]',
  'B',
  '### 深度解析

#### 最佳实践：自增 ID + 62 进制
1.  **原理**：
    *   维护一个全局自增 ID（如 Redis `INCR` 或 Snowflake 算法生成的 ID）。
    *   将 10 进制的 ID 转换为 **62 进制**（0-9, a-z, A-Z 共 62 个字符）。
    *   *例如*：ID = 100000000 -> 62 进制可能是 "6LAze"。
2.  **优势**：
    *   **无冲突**：数学上保证唯一，无需查库判重。
    *   **短**：6 位 62 进制可以表示 $62^6 \approx 568$ 亿个 URL，足够使用。
    *   **性能高**：纯计算，速度极快。

#### 其他方案缺点
*   **MD5**：虽然离散性好，但截取前 6 位**可能冲突**。一旦冲突，解决起来很麻烦（加盐重试等）。
*   **随机生成**：随着数据量增加，冲突概率指数级上升，后期性能极差（一直在重试）。
*   **UUID**：太长（32 位），不符合“短”链接的需求。',
  'hard',
  (SELECT id FROM categories WHERE name = '系统设计'),
  ARRAY['系统设计', '短链接', '算法'],
  true
),

-- 2. Distributed Lock
(
  'Redis 分布式锁：Redlock 算法', 
  '为了解决 Redis 单点故障导致锁失效的问题，Redis 作者提出了 Redlock 算法。其核心思想是？',
  'single', 
  '["主从复制：在 Master 加锁后，必须等待 Slave 同步成功才算加锁成功", "多节点冗余：同时向 N 个独立的 Redis 实例请求加锁，只要过半数（N/2 + 1）成功，且耗时小于有效期，则认为加锁成功", "持久化：加锁信息必须写入 AOF 文件才算成功", "哨兵机制：当 Master 挂了，Sentinel 自动选举新 Master 接管锁"]',
  'B',
  '### 深度解析

#### Redlock 原理
在单机 Redis 中，如果 Master 挂了，Slave 还没来得及同步锁数据，failover 后锁就丢了，导致并发安全问题。
Redlock（Redisson 实现）试图解决这个问题：
1.  **独立节点**：部署 N（例如 5）个**完全独立**的 Redis Master（没有主从关系）。
2.  **过半机制**：客户端尝试按顺序向这 5 个节点申请锁。
3.  **成功判定**：
    *   客户端在 **> N/2**（如 3）个节点上成功获取了锁。
    *   且 **总耗时 < 锁的有效期**。
    *   满足以上两点，才算加锁成功。

#### 争议
业界（如 Martin Kleppmann）对 Redlock 的安全性存在争议，主要集中在**时钟跳变**（Clock Drift）可能导致锁提前失效。但在大多数工程场景下，Redlock 依然是 Redis 生态中最可靠的方案之一。',
  'hard',
  (SELECT id FROM categories WHERE name = '系统设计'),
  ARRAY['Redis', '分布式锁', '高并发'],
  true
),

-- 3. MySQL: Transaction Isolation
(
  'MySQL 可重复读 (Repeatable Read) 下的幻读问题', 
  'MySQL InnoDB 在 RR 隔离级别下，是否完全解决了幻读（Phantom Read）问题？',
  'single', 
  '["完全解决了，通过 MVCC", "完全解决了，通过 Next-Key Lock", "大部分解决了，但在特定场景（如先快照读再当前读）下依然可能发生", "没有解决，只有 Serializable 级别才能解决幻读"]',
  'C',
  '### 深度解析

这是一个非常经典的面试陷阱。

#### 结论
**RR 级别很大程度上避免了幻读，但没有“完全”解决。**

1.  **快照读 (Snapshot Read)**：
    *   普通的 `SELECT * FROM ...`。
    *   通过 **MVCC** (Read View) 解决幻读。你开启事务后，看不到别人新插入的行。
2.  **当前读 (Current Read)**：
    *   `SELECT ... FOR UPDATE`, `UPDATE`, `DELETE`。
    *   通过 **Next-Key Lock** (Gap Lock + Record Lock) 解决幻读。锁住间隙，阻止别人插入。

#### 特殊场景（幻读复现）
1.  事务 A 开启。
2.  事务 B 插入一条数据 id=10 并提交。
3.  事务 A 执行 `SELECT * FROM table WHERE id=10` -> **查不到**（因为 MVCC）。
4.  事务 A 执行 `UPDATE table SET ... WHERE id=10` -> **成功！**（因为 UPDATE 是当前读，能看到最新提交的数据）。
5.  事务 A 再次执行 `SELECT * FROM table WHERE id=10` -> **查到了！**（因为自己修改了那行数据，那行数据的 TRX_ID 变成了 A 自己的，所以能看到了）。
    *   *这就产生了幻读：一开始没查到，操作一下又查到了。*',
  'hard',
  (SELECT id FROM categories WHERE name = '数据库'),
  ARRAY['MySQL', '事务', '幻读'],
  true
),

-- 4. Java: HashMap Infinite Loop
(
  'JDK 7 HashMap 扩容死循环', 
  '在 JDK 7 中，多线程并发扩容 HashMap 时可能会导致死循环（CPU 100%）。这主要发生在哪个环节？',
  'single', 
  '["计算 Hash 值时", "数组扩容分配内存时", "将旧链表迁移到新数组（rehash）时，链表形成了环", "红黑树旋转时"]',
  'C',
  '### 深度解析

#### JDK 7 头插法
JDK 7 的 HashMap 在 resize 时，将旧链表迁移到新数组采用的是**头插法**（Head Insertion）。
*   *目的*：为了热点数据缓存（刚插入的数据被访问概率大）。
*   *后果*：迁移后，链表顺序会**倒置**（A->B 变成 B->A）。

#### 死循环过程
1.  线程 T1 和 T2 同时扩容。
2.  T1 挂起，T2 完成扩容。T2 把链表 A->B 迁移成了 B->A。
3.  T1 恢复运行。T1 依然认为顺序是 A->B，但内存中已经是 B->A。
4.  T1 继续迁移，尝试把 B 指向 A，而 A 已经指向了 B。
5.  **结果**：形成 **A->B->A** 的环形链表。
6.  后续任何对该桶的 `get()` 操作都会陷入死循环。

#### JDK 8 修复
JDK 8 改用了**尾插法**（Tail Insertion），保证迁移前后顺序不变，从而解决了这个问题。',
  'medium',
  (SELECT id FROM categories WHERE name = '集合框架'),
  ARRAY['HashMap', 'JDK7', '源码分析'],
  true
),

-- 5. Network: DNS
(
  'DNS 解析流程', 
  '当你在浏览器输入 www.google.com 时，DNS 解析的查询顺序是？',
  'single', 
  '["根域名服务器 -> 顶级域名服务器 -> 权威域名服务器 -> 本地 DNS", "本地 DNS -> 根域名服务器 -> 顶级域名服务器 -> 权威域名服务器", "本地 DNS -> 权威域名服务器 -> 顶级域名服务器 -> 根域名服务器", "直接向谷歌服务器询问 IP"]',
  'B',
  '### 深度解析

#### 递归查询 vs 迭代查询
1.  **浏览器缓存**：先看自己有没有。
2.  **操作系统缓存 (hosts)**：再看 OS 有没有。
3.  **本地 DNS (Local DNS)**：向 ISP（电信/移动）的 DNS 服务器查询。
    *   *注意*：客户端到 Local DNS 通常是**递归查询**（你帮我查到底）。
4.  **Local DNS 迭代查询**：
    *   问 **Root DNS** (.) -> 告诉你去问 .com 顶级域。
    *   问 **TLD DNS** (.com) -> 告诉你去问 google.com 权威域。
    *   问 **Authoritative DNS** (google.com) -> 拿到 IP (142.250.x.x)。
5.  Local DNS 缓存结果并返回给用户。',
  'medium',
  (SELECT id FROM categories WHERE name = '计算机网络'),
  ARRAY['网络', 'DNS', '基础'],
  true
),

-- 6. Spring Boot: Starter
(
  'Spring Boot Starter 原理', 
  'Spring Boot Starter（如 spring-boot-starter-web）的核心作用是什么？',
  'single', 
  '["提供了一套自动配置代码", "提供了一组经过测试的、版本兼容的依赖集合（Dependency Descriptor）", "提供了一个内置的 Tomcat 服务器", "提供了一个 main 方法入口"]',
  'B',
  '### 深度解析

#### Starter = 依赖聚合
`Starter` 本质上是一个 **Maven/Gradle 的 BOM (Bill of Materials)**。
*   它本身通常**不包含任何 Java 代码**。
*   它的 `pom.xml` 中定义了一组相关的依赖（dependencies）。
*   *例如*：`spring-boot-starter-web` 引入了：
    *   spring-webmvc
    *   spring-web
    *   jackson-databind
    *   spring-boot-starter-tomcat
    *   ...

#### 自动配置 (AutoConfiguration)
自动配置的代码通常在 `spring-boot-autoconfigure.jar` 中，而不是在 starter 中。Starter 只是把 autoconfigure 作为一个依赖引进来。

#### 价值
开发者只需引入一个 `starter-web`，就能获得开发 Web 应用所需的所有 jar 包，且**版本不用自己操心**，避免了“Jar Hell”（依赖冲突）。',
  'easy',
  (SELECT id FROM categories WHERE name = 'Spring框架'),
  ARRAY['Spring Boot', 'Maven', '原理'],
  true
);
