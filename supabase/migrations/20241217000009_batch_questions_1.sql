-- Insert Batch 1 of massive question update
-- Topics: ConcurrentHashMap, Spring Transaction, MySQL MVCC, HTTPS, ClassLoader, etc.

INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active) 
VALUES 
-- 1. Java: ConcurrentHashMap (Java 8)
(
  'Java 8 ConcurrentHashMap 的底层实现', 
  '相比于 Java 7 的分段锁（Segment），Java 8 对 ConcurrentHashMap 做了重大改动。以下描述正确的是？',
  'single', 
  '["Java 8 依然使用 Segment，只是默认分段数变大了", "Java 8 彻底放弃了 Segment，改用 Node 数组 + CAS + synchronized 实现", "Java 8 使用全局锁（Global Lock）来保证线程安全", "Java 8 的 put 操作完全是无锁的（Lock-Free）"]',
  'B',
  '### 深度解析

#### Java 7 vs Java 8
*   **Java 7**: 使用 **Segment 分段锁**（ReentrantLock 的子类）。整个 Map 被分为 N 个 Segment，每个 Segment 是一把锁。并发度受限于 Segment 的个数（默认 16）。
*   **Java 8**: **放弃了 Segment**，采用了与 HashMap 类似的 **Node 数组 + 链表 + 红黑树** 结构。

#### Java 8 的线程安全机制
1.  **CAS (Compare And Swap)**:
    *   在插入元素时，如果当前桶（Bucket）为空（没有 Hash 冲突），则使用 **CAS** 指令尝试写入。这不需要加锁，性能极高。
2.  **synchronized**:
    *   如果当前桶不为空（发生了 Hash 冲突），则使用 **synchronized** 锁住当前桶的头节点（链表头或树根）。
    *   *为什么用 synchronized 不用 ReentrantLock？* 在 JDK 1.6+ 对 synchronized 做了大量优化（偏向锁、轻量级锁），在低竞争下性能很好，且更节省内存（不用创建 Lock 对象）。

#### 结论
Java 8 极大地提高了并发度，理论上并发度等于桶数组的长度（Capacity）。',
  'hard',
  (SELECT id FROM categories WHERE name = '集合框架'),
  ARRAY['ConcurrentHashMap', 'Java8', '源码分析'],
  true
),

-- 2. Spring: Transaction Propagation
(
  'Spring 事务传播行为：REQUIRED vs REQUIRES_NEW', 
  '在 Spring 事务管理中，A 方法调用 B 方法，如果 B 方法的传播行为是 `REQUIRES_NEW`，A 的是 `REQUIRED`。当 B 方法抛出异常时，会发生什么？',
  'single', 
  '["A 和 B 的事务都会回滚", "只有 B 回滚，A 不受影响", "B 回滚，A 只有在捕获异常后才不会回滚，否则 A 也会回滚", "A 回滚，B 提交"]',
  'C',
  '### 深度解析

#### 传播行为解析
*   **REQUIRED (默认)**: 如果当前存在事务，则加入该事务；如果当前没有事务，则创建一个新事务。
*   **REQUIRES_NEW**: **挂起**当前事务（如果有），并**创建一个新的独立事务**。

#### 场景分析
A (REQUIRED) -> B (REQUIRES_NEW)
1.  A 开启事务 T1。
2.  执行到 B 时，T1 被挂起，B 开启独立事务 T2。
3.  **情况 1：B 正常，A 异常**。T2 提交（因为它已经执行完了），T1 回滚。B 的修改保留，A 的修改撤销。
4.  **情况 2：B 异常**（本题情况）。
    *   T2 因为异常而**回滚**。
    *   异常会抛给调用者 A。
    *   如果 A **捕获**（try-catch）了这个异常并不再抛出，T1 可以继续运行并提交。
    *   如果 A **没有捕获**异常，异常会导致 T1 也**回滚**。

#### 结论
`REQUIRES_NEW` 的核心是 B 的事务完全独立于 A。B 的回滚肯定发生，但 A 是否回滚取决于 A 是否处理了 B 抛出的异常。',
  'hard',
  (SELECT id FROM categories WHERE name = '反射机制'), -- Spring Transaction
  ARRAY['Spring', '事务', '面试必问'],
  true
),

-- 3. JVM: Class Loading
(
  'JVM 类加载机制：双亲委派模型', 
  '为什么 JVM 采用双亲委派模型（Parent Delegation Model）来加载类？主要目的是什么？',
  'single', 
  '["为了提高类加载的速度", "为了实现类的热部署", "为了保证 Java 核心库的安全性，防止核心 API 被篡改", "为了节省内存空间"]',
  'C',
  '### 深度解析

#### 双亲委派模型
当一个类加载器收到类加载请求时，它首先不会自己去尝试加载这个类，而是把这个请求**委派给父类加载器**去完成，每一层次的类加载器都是如此，因此所有的加载请求最终都应该传送到顶层的 **Bootstrap ClassLoader** 中。只有当父加载器反馈自己无法完成这个加载请求时，子加载器才会尝试自己去加载。

#### 核心目的：沙箱安全机制
防止核心 API 被篡改。
*   假设你自己编写了一个 `java.lang.String` 类。
*   如果没有双亲委派，你的自定义加载器可能会加载这个类。
*   有了双亲委派，加载请求会一直向上传递到 Bootstrap ClassLoader。Bootstrap 发现 `rt.jar` 中已经有了 `java.lang.String`，就会直接加载 JDK 自带的那个，而忽略你写的。
*   这样保证了 Java 类型体系中最基础的行为是统一的，不会被恶意代码破坏。',
  'medium',
  (SELECT id FROM categories WHERE name = 'JVM'),
  ARRAY['类加载', '双亲委派', 'JVM'],
  true
),

-- 4. MySQL: MVCC
(
  'MySQL InnoDB 的 MVCC 机制', 
  'MVCC（多版本并发控制）主要解决了什么问题？它是如何实现的？',
  'single', 
  '["解决了脏写问题；通过锁实现", "解决了幻读问题；通过 Next-Key Lock 实现", "实现了读写不阻塞（快照读）；通过 Undo Log 和 Read View 实现", "实现了串行化隔离级别；通过 Redo Log 实现"]',
  'C',
  '### 深度解析

#### MVCC 的核心价值
传统的数据库锁机制中，读-写是互斥的。为了提高并发性能，InnoDB 引入了 MVCC，使得**读-写可以并行执行**（读不阻塞写，写不阻塞读）。

#### 实现原理
1.  **Hidden Columns (隐藏列)**: 每一行数据都有隐藏列，记录了最近修改该行的**事务 ID (DB_TRX_ID)** 和 **回滚指针 (DB_ROLL_PTR)**。
2.  **Undo Log (回滚日志)**: 记录了数据的历史版本。通过回滚指针，可以像链表一样找到该行数据之前的版本。
3.  **Read View (读视图)**:
    *   在执行查询时（快照读），生成一个 Read View。
    *   Read View 包含当前活跃的（未提交的）事务 ID 列表。
    *   通过比较数据的事务 ID 和 Read View，判断当前事务能看到哪个版本的数据（例如：只能看到已提交的，或者自己修改的）。

#### 解决的问题
主要用于实现 **Read Committed (RC)** 和 **Repeatable Read (RR)** 隔离级别下的**快照读**。',
  'hard',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Database
  ARRAY['MySQL', 'MVCC', '数据库原理'],
  true
),

-- 5. Network: HTTPS
(
  'HTTPS 的加密过程', 
  'HTTPS 在建立连接（SSL/TLS 握手）过程中，使用了哪种加密方式？',
  'single', 
  '["全程使用非对称加密", "全程使用对称加密", "握手阶段使用非对称加密交换密钥，传输数据阶段使用对称加密", "握手阶段使用对称加密，传输数据阶段使用非对称加密"]',
  'C',
  '### 深度解析

#### 混合加密机制
HTTPS 结合了非对称加密和对称加密的优点：

1.  **握手阶段（非对称加密）**：
    *   **目的**：安全地交换“会话密钥”（Session Key）。
    *   **过程**：服务器发送公钥证书给客户端。客户端验证证书后，生成一个随机的会话密钥，用服务器的公钥加密发送给服务器。服务器用私钥解密得到会话密钥。
    *   **原因**：非对称加密（RSA 等）安全性高，但计算量大，速度慢，不适合传输大量数据。

2.  **传输阶段（对称加密）**：
    *   **目的**：高效传输 HTTP 数据。
    *   **过程**：双方使用刚才协商好的“会话密钥”，使用对称加密算法（AES 等）对数据进行加密传输。
    *   **原因**：对称加密速度快，适合大数据量传输。

#### 为什么不一直用非对称？
太慢了（比对称加密慢 100-1000 倍），极耗 CPU。',
  'medium',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Network
  ARRAY['网络', 'HTTPS', '安全'],
  true
),

-- 6. Spring: Bean Lifecycle
(
  'Spring Bean 的生命周期', 
  '在 Spring Bean 的生命周期中，以下方法的执行顺序正确的是？',
  'single', 
  '["@PostConstruct -> init-method -> afterPropertiesSet", "afterPropertiesSet -> @PostConstruct -> init-method", "@PostConstruct -> afterPropertiesSet -> init-method", "init-method -> @PostConstruct -> afterPropertiesSet"]',
  'C',
  '### 深度解析

Bean 初始化阶段的执行顺序是面试常考细节。

#### 正确顺序
1.  **Instantiation**: 实例化 Bean (new)。
2.  **Populate Properties**: 属性赋值 (DI)。
3.  **Initialization**: 初始化。
    *   **@PostConstruct**: 注解方式，依赖注入完成后立即执行。
    *   **InitializingBean.afterPropertiesSet()**: 接口方式。
    *   **init-method**: XML 或 @Bean(initMethod) 指定的自定义初始化方法。

#### 记忆口诀
**P -> A -> I** (PostConstruct -> AfterPropertiesSet -> InitMethod)

#### 销毁顺序
同理：`@PreDestroy` -> `DisposableBean.destroy()` -> `destroy-method`。',
  'medium',
  (SELECT id FROM categories WHERE name = '面向对象'), -- Spring
  ARRAY['Spring', '生命周期', 'Bean'],
  true
),

-- 7. Distributed: Idempotency
(
  '接口幂等性 (Idempotency) 的实现方案', 
  '幂等性是指多次执行同一个操作，产生的影响与执行一次是相同的。以下哪种方案**不适合**用于保证接口幂等性？',
  'single', 
  '["数据库唯一索引（Unique Key）", "Token 令牌机制（先获取 Token，提交时删除 Token）", "分布式锁（以业务 ID 为 Key）", "前端通过禁用按钮防止重复提交"]',
  'D',
  '### 深度解析

#### 选项 D 分析
**前端禁用按钮只能提升用户体验，不能保证幂等性。**
*   用户可以刷新页面、使用 Postman 直接调用接口、或者在网络卡顿时连续点击导致并发请求。
*   幂等性必须在**服务端**实现。

#### 常见幂等方案
1.  **数据库唯一索引**：最可靠。例如插入订单时，`order_no` 建唯一索引。重复插入会报 Duplicate Key 异常。
2.  **Token 机制**：
    *   进入页面前先请求服务端获取一个 Token（存 Redis）。
    *   提交表单时携带 Token。
    *   服务端校验 Token：如果存在则执行业务并删除 Token；如果不存在（已被删除）则说明是重复提交。
    *   *注意：获取和删除 Token 必须保证原子性（Lua 脚本）。*
3.  **分布式锁**：
    *   处理请求前先尝试获取锁（Key = userId + operationId）。
    *   获取成功则执行，执行完释放。
    *   获取失败说明正在处理，直接返回。
4.  **状态机**：
    *   更新订单状态时：`UPDATE order SET status = 2 WHERE id = 1 AND status = 1`。即便重复执行，第二次因为 status 已经是 2 了，影响行数为 0，数据状态不会错。',
  'medium',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Distributed
  ARRAY['架构', '幂等性', 'API设计'],
  true
),

-- 8. Algorithm: Binary Search
(
  '二分查找 (Binary Search) 的前提条件', 
  '二分查找算法的时间复杂度是 O(log n)，但它对数据集有什么基本要求？',
  'single', 
  '["数据集必须存储在链表中", "数据集必须是有序的顺序表（数组）", "数据集可以是无序的数组", "数据集必须是哈希表"]',
  'B',
  '### 深度解析

#### 核心前提
1.  **顺序存储结构**：必须支持**随机访问**（Random Access），即可以通过下标 O(1) 获取元素。
    *   因此，**数组**适合，**链表**不适合（链表找中间节点需要 O(n)，导致二分查找退化）。
2.  **有序排列**：元素必须按关键字大小有序排列。
    *   如果无序，必须先排序（排序通常 O(n log n)），那还不如直接遍历查找（O(n)）。

#### 细节
*   时间复杂度：O(log n)
*   空间复杂度：O(1) （迭代写法）
*   二分查找特别适合**静态数据**的查找（一次排序，多次查找）。如果有频繁插入删除，维护有序性的成本较高。',
  'easy',
  (SELECT id FROM categories WHERE name = 'Java基础语法'), -- Algo
  ARRAY['算法', '二分查找', '基础'],
  true
);
