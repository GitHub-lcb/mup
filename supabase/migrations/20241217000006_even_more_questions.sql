-- Insert even more high-quality questions covering Redis, MySQL, Network, Design Patterns

INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active) 
VALUES 
-- 1. Redis: Data Structures
(
  'Redis 常用数据结构及应用场景', 
  'Redis 支持多种数据结构，以下关于它们的典型应用场景描述，错误的是？',
  'single', 
  '["String: 缓存用户信息、分布式锁、计数器", "List: 消息队列、朋友圈点赞列表", "Hash: 存储对象（如商品详情）", "ZSet (Sorted Set): 排行榜、带权重的队列"]',
  'B',
  '### 深度解析

#### 选项 B 错误分析
**朋友圈点赞列表**通常**不推荐使用 List**。
*   List 是有序列表（双向链表），适合做**消息队列**（lpush/rpop）或**最新消息流**（Timeline）。
*   但点赞列表通常需要**去重**（一个用户只能点赞一次）且可能需要判断“我是否点赞过”。
*   因此，**Set**（无序集合，自动去重）或 **ZSet**（如果需要按时间排序）是更合适的选择。

#### 其他选项正确性分析
*   **A (String)**: 最基础的类型。`SETNX` 用于分布式锁，`INCR` 用于原子计数（如阅读量）。
*   **C (Hash)**: 适合存储结构化对象。例如存储 User 对象，Key 是 UserId，Field 是 name/age。比 String 序列化存储更节省空间且方便修改单个字段。
*   **D (ZSet)**: 内部实现是**跳表 (SkipList)**。每个元素关联一个 Score，适合做实时排行榜（TopN）、延时队列（Score 为执行时间）。

### 扩展：Redis 其他高级数据结构
*   **Bitmap**: 位图，适合签到统计、用户在线状态（极省空间）。
*   **HyperLogLog**: 基数统计，适合统计百万级 UV（允许微小误差）。
*   **Geo**: 地理位置信息，附近的人。',
  'medium',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Mapping Redis to IO/Network
  ARRAY['Redis', '缓存', '数据结构'],
  true
),

-- 2. MySQL: Index B+ Tree
(
  '为什么 MySQL InnoDB 索引选择 B+ 树而不是 B 树？', 
  '关于 B+ 树和 B 树的区别，以及为什么 MySQL 选择 B+ 树作为索引结构，以下说法错误的是？',
  'single', 
  '["B+ 树的非叶子节点不存储数据，只存储索引值，因此同样大小的磁盘页可以容纳更多节点", "B+ 树的叶子节点用链表连接，适合范围查询", "B 树的所有节点都存储数据，查询效率更稳定（都必须查到叶子节点）", "B+ 树的查询效率更稳定，因为所有数据都在叶子节点"]',
  'C',
  '### 深度解析

#### 选项 C 错误分析
**B 树的查询效率是不稳定的。**
*   在 B 树中，数据存储在所有节点（包括根节点、内部节点）。
*   如果运气好，可能在根节点就找到了数据（最好的情况 O(1)）；如果运气不好，要查到叶子节点。
*   而 **B+ 树** 所有真实数据都只存储在**叶子节点**，非叶子节点只起索引作用。因此，B+ 树的查询**必须**走到叶子节点，查询路径长度相同，性能更稳定。

#### 为什么选择 B+ 树？
1.  **磁盘读写代价更低**：非叶子节点不存数据，意味着一个磁盘页（Page，默认 16KB）能存更多的索引项。这使得 B+ 树的层高更低（通常 3 层就能存 2000万+ 数据），减少了磁盘 I/O 次数。
2.  **查询效率稳定**：如上所述。
3.  **天然支持范围查询**：B+ 树的叶子节点通过**双向链表**连接。执行 `SELECT * FROM table WHERE id > 100` 时，只需找到 id=100 的节点，然后顺着链表遍历即可。而 B 树需要进行复杂的树的中序遍历。',
  'hard',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Mapping DB to IO
  ARRAY['MySQL', '索引', 'B+Tree'],
  true
),

-- 3. Network: TCP 3-way Handshake
(
  'TCP 三次握手 (Three-way Handshake)', 
  '在 TCP 建立连接的三次握手过程中，第二次握手（Server -> Client）发送的报文包含哪些标志位？',
  'single', 
  '["SYN", "ACK", "SYN + ACK", "FIN + ACK"]',
  'C',
  '### 深度解析

TCP 三次握手建立连接的过程如下：

1.  **第一次握手 (Client -> Server)**:
    *   客户端发送 **SYN** (Synchronize Sequence Numbers) 报文。
    *   客户端进入 `SYN_SENT` 状态。
    *   *意图：Client 想要建立连接，初始序列号为 x。*

2.  **第二次握手 (Server -> Client)**:
    *   服务端收到 SYN 后，需要确认客户的 SYN（发送 **ACK** x+1），同时自己也要发起一个 SYN（发送 **SYN** y）。
    *   因此，报文包含 **SYN + ACK** 标志位。
    *   服务端进入 `SYN_RCVD` 状态。
    *   *意图：Server 确认收到 Client 的请求，并询问 Client 能否收到 Server 的信号。*

3.  **第三次握手 (Client -> Server)**:
    *   客户端收到 SYN+ACK 后，向服务端发送 **ACK** (y+1)。
    *   客户端进入 `ESTABLISHED` 状态。服务端收到后也进入 `ESTABLISHED`。
    *   *意图：Client 确认收到了 Server 的信号。连接建立。*

#### 为什么需要三次？
主要是为了**防止已失效的连接请求报文段突然又传送到了服务端**，产生错误。同时确保双方的发送和接收能力都是正常的。',
  'medium',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Network
  ARRAY['网络', 'TCP', '面试必问'],
  true
),

-- 4. Design Pattern: Singleton
(
  '单例模式 (Singleton) 的双重检查锁定', 
  '在实现单例模式的双重检查锁定（Double-Checked Locking）时，为什么 instance 变量必须声明为 volatile？',
  'single', 
  '["为了保证多线程下的原子性", "为了防止对象在初始化过程中发生指令重排序", "为了让该变量存储在栈内存中", "为了让 synchronized 锁失效"]',
  'B',
  '### 深度解析

#### 经典代码
```java
public class Singleton {
    private static volatile Singleton instance; // 必须 volatile
    private Singleton() {}

    public static Singleton getInstance() {
        if (instance == null) { // 第一次检查
            synchronized (Singleton.class) {
                if (instance == null) { // 第二次检查
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
```

#### 为什么要 volatile？
`instance = new Singleton();` 这行代码在 JVM 中并非原子操作，而是分为三步：
1.  **分配内存空间** (`memory = allocate()`)
2.  **初始化对象** (`ctorInstance(memory)`)
3.  **将 instance 指向分配的内存** (`instance = memory`)

如果不加 `volatile`，编译器或处理器可能进行**指令重排序**，将执行顺序变为 **1 -> 3 -> 2**。
*   如果线程 A 执行了 1 和 3，此时 `instance` 已经不为 null，但对象还没初始化（步骤 2 还没做）。
*   此时线程 B 抢占 CPU，执行 `getInstance()`，在第一次检查时发现 `instance != null`，直接返回了**半成品（未初始化）的对象**。
*   这将导致程序报错或逻辑异常。

`volatile` 的作用就是**禁止指令重排序**，保证初始化的顺序严格按照 1 -> 2 -> 3 执行。',
  'medium',
  (SELECT id FROM categories WHERE name = '面向对象'), -- Design Pattern
  ARRAY['设计模式', '单例', '并发'],
  true
),

-- 5. Spring AOP
(
  'Spring AOP 的实现原理', 
  'Spring AOP（面向切面编程）底层主要依赖什么机制实现的？',
  'single', 
  '["Java 静态代理", "JDK 动态代理 + CGLIB 动态代理", "Java 反射机制直接调用", "Java Agent 字节码增强"]',
  'B',
  '### 深度解析

Spring AOP 自动根据目标对象的情况，选择使用 **JDK 动态代理** 或 **CGLIB 动态代理**。

1.  **JDK 动态代理**：
    *   **条件**：目标类**实现了接口**（Interface）。
    *   **原理**：利用 `java.lang.reflect.Proxy` 类和 `InvocationHandler` 接口，在运行时动态生成一个实现了相同接口的代理类。
    *   **局限**：只能代理接口方法。

2.  **CGLIB (Code Generation Library) 动态代理**：
    *   **条件**：目标类**没有实现接口**。
    *   **原理**：利用 ASM 开源包，底层操作字节码，在运行时动态生成目标类的**子类**（Subclass）。
    *   **局限**：不能代理 `final` 修饰的类或方法（因为无法继承或重写）。

#### Spring Boot 2.0+ 的变化
在 Spring Boot 2.0 之后，默认配置 `spring.aop.proxy-target-class=true`，这意味着**默认优先使用 CGLIB**，除非显式配置使用 JDK 代理。这样做的好处是避免了因未实现接口而导致的类型转换错误。',
  'medium',
  (SELECT id FROM categories WHERE name = '反射机制'), -- AOP relies on reflection/proxy
  ARRAY['Spring', 'AOP', '代理模式'],
  true
),

-- 6. Java Basic: Integer Cache
(
  'Java Integer 缓存池 (Integer Cache)', 
  '执行 `Integer a = 127; Integer b = 127; Integer c = 128; Integer d = 128;` 后，`a == b` 和 `c == d` 的结果分别是？',
  'single', 
  '["true, true", "true, false", "false, true", "false, false"]',
  'B',
  '### 深度解析

#### 结果：true, false

1.  **自动装箱**：`Integer a = 127` 实际上编译为 `Integer.valueOf(127)`。
2.  **Integer Cache**：
    *   `Integer` 类内部维护了一个静态内部类 `IntegerCache`。
    *   默认缓存了 **-128 到 127** 之间的整数对象。
    *   当调用 `valueOf()` 时，如果数值在缓存范围内，直接返回缓存中的对象引用；否则，`new` 一个新的 `Integer` 对象。

#### 分析：
*   **a == b**：127 在缓存范围内，a 和 b 指向同一个缓存对象。结果为 **true**。
*   **c == d**：128 超出了缓存范围（最大 127），`valueOf(128)` 会创建两个不同的对象（new Integer(128)）。比较引用地址时，结果为 **false**。

#### 最佳实践
比较包装类（Integer, Long 等）的值时，**永远使用 `.equals()` 方法**，不要使用 `==`，以避免此类陷阱。',
  'easy',
  (SELECT id FROM categories WHERE name = 'Java基础语法'),
  ARRAY['Java基础', '陷阱题'],
  true
),

-- 7. Distributed: CAP Theorem
(
  '分布式系统 CAP 理论', 
  '在分布式系统中，CAP 理论指出无法同时满足三个特性，只能满足其中两个。这三个特性是？',
  'single', 
  '["Consistency (一致性), Availability (可用性), Partition tolerance (分区容错性)", "Concurrency (并发性), Availability (可用性), Performance (性能)", "Consistency (一致性), Atomicity (原子性), Partition tolerance (分区容错性)", "Consistency (一致性), Availability (可用性), Persistence (持久性)"]',
  'A',
  '### 深度解析

CAP 理论是分布式系统的基石。

1.  **C (Consistency) 一致性**：
    *   在分布式系统中的所有数据备份，在同一时刻是否同样的值。（等同于所有节点访问同一份最新的数据副本）。
2.  **A (Availability) 可用性**：
    *   保证每个请求不管成功或者失败都有响应。（服务一直可用，不挂）。
3.  **P (Partition tolerance) 分区容错性**：
    *   系统中任意信息的丢失或失败不会影响系统的继续运作。（允许网络分区，即节点间通信失败）。

#### CAP 的权衡
由于网络分区（P）在分布式网络中是不可避免的（网线可能被挖断，路由器可能宕机），所以分布式系统**必须保证 P**。
因此，架构师只能在 **CP** 和 **AP** 之间做选择：

*   **CP (一致性 + 分区容错)**：
    *   为了保证一致性，在网络分区发生时，可能需要停止服务（牺牲可用性 A），等待数据同步。
    *   典型代表：**Zookeeper**, **Etcd**, **HBase**。
*   **AP (可用性 + 分区容错)**：
    *   为了保证高可用，允许返回旧数据（牺牲一致性 C，追求最终一致性）。
    *   典型代表：**Eureka**, **Cassandra**, **DynamoDB**。',
  'hard',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Mapping Distributed to IO/Net
  ARRAY['分布式', 'CAP', '架构'],
  true
);
