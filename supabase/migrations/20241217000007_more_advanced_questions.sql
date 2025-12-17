-- Insert more questions: OS, Kafka, Spring Boot, Algorithms, IO

INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active) 
VALUES 
-- 1. OS: Process vs Thread
(
  '进程与线程的区别', 
  '关于操作系统中进程（Process）和线程（Thread）的区别，以下描述错误的是？',
  'single', 
  '["进程是资源分配的最小单位，线程是 CPU 调度的最小单位", "一个进程可以包含多个线程，它们共享进程的堆内存和方法区", "线程之间的通信（通信成本）比进程间通信（IPC）要高", "进程崩溃通常不会影响其他进程，但一个线程崩溃可能导致整个进程崩溃"]',
  'C',
  '### 深度解析

#### 选项 C 错误分析
**线程间的通信成本远低于进程间通信。**
*   **线程**：共享同一进程的内存空间（堆、方法区），因此线程间可以直接读写共享变量来通信（需要处理同步问题），无需经过内核，速度极快。
*   **进程**：拥有独立的内存空间。进程间通信（IPC, Inter-Process Communication）需要借助操作系统提供的机制，如管道（Pipe）、消息队列、共享内存、信号量、Socket 等，通常涉及到用户态和内核态的切换，开销较大。

#### 其他选项正确性分析
*   **A 正确**：这是最经典的定义。进程拥有独立的内存资源；线程在 CPU 上执行指令。
*   **B 正确**：线程共享堆（Heap）和方法区（Method Area），但每个线程有自己独立的程序计数器（PC）和虚拟机栈（Stack）。
*   **D 正确**：进程间隔离性好。而线程共享内存，一个线程发生非法访问（如野指针）导致进程内存崩溃，会波及该进程内的所有线程。',
  'easy',
  (SELECT id FROM categories WHERE name = '多线程'), -- Mapping to Thread category
  ARRAY['操作系统', '进程', '线程'],
  true
),

-- 2. Kafka: Consumer Group
(
  'Kafka 消费者组 (Consumer Group) 机制', 
  '在 Kafka 中，关于消费者组（Consumer Group）的描述，正确的是？',
  'single', 
  '["一个消费者组中的多个消费者可以同时消费同一个分区的消息", "一条消息只能被同一个消费者组中的某一个消费者消费", "不同消费者组之间会竞争消息，导致消息只能被其中一个组消费", "消费者组中的消费者数量越多，消费速度一定越快"]',
  'B',
  '### 深度解析

Kafka 的消费者组机制是其实现**发布-订阅**和**点对点**两种模型统一的关键。

#### 选项 B 正确分析
**一条消息只能被同一个消费者组中的某一个消费者消费。**
这是 Kafka 实现“点对点”模型的方式。在一个组内，消息是互斥的，不会重复消费。

#### 错误选项分析
*   **A 错误**：Kafka 规定，**一个分区（Partition）只能被同一个消费者组中的一个消费者消费**。这是为了保证分区内消息的顺序性。如果多个消费者并发读同一个分区，顺序就乱了。
*   **C 错误**：不同消费者组之间是**相互独立**的。一条消息会被分发给订阅了该 Topic 的**所有**消费者组（发布-订阅模型）。
*   **D 错误**：消费者数量受限于**分区数量**。如果消费者数 > 分区数，多出来的消费者会处于**空闲状态**（Idle），不会提升消费速度，反而浪费资源。

### 总结
*   组内：负载均衡（互斥）。
*   组间：发布订阅（广播）。',
  'hard',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Mapping Middleware to IO
  ARRAY['Kafka', '消息队列', '分布式'],
  true
),

-- 3. Spring Boot: Annotation
(
  'Spring Boot 核心注解', 
  '`@SpringBootApplication` 是一个复合注解，它主要包含了哪三个注解？',
  'single', 
  '["@Configuration, @EnableAutoConfiguration, @ComponentScan", "@Controller, @Service, @Repository", "@SpringBootConfiguration, @EnableAsync, @Component", "@Bean, @Autowired, @Value"]',
  'A',
  '### 深度解析

`@SpringBootApplication` 是 Spring Boot 的启动类注解，它本质上是一个组合注解。

#### 核心三要素：
1.  **`@SpringBootConfiguration`** (底层是 `@Configuration`)：
    *   标记当前类是一个配置类，支持 JavaConfig 的方式进行配置。
2.  **`@EnableAutoConfiguration`**：
    *   **这是 Spring Boot 的灵魂**。它告诉 Spring Boot 根据类路径（classpath）下的 jar 包依赖，自动配置 Bean。例如，看到 classpath 下有 `mysql-connector`，就自动配置 DataSource。
3.  **`@ComponentScan`**：
    *   自动扫描当前包及其子包下的所有 `@Component`, `@Controller`, `@Service`, `@Repository` 等注解，并注册为 Bean。

#### 为什么这很重要？
这体现了 Spring Boot **"约定优于配置"** (Convention Over Configuration) 的设计理念。',
  'medium',
  (SELECT id FROM categories WHERE name = '反射机制'), -- Spring relies on reflection
  ARRAY['Spring Boot', '注解', '原理'],
  true
),

-- 4. Java IO: Models
(
  'Java IO 模型：BIO, NIO, AIO', 
  '关于 Java 中的三种 IO 模型，以下比喻最恰当的是？',
  'single', 
  '["BIO 是去餐馆点餐，厨师炒好菜自己去端；NIO 是去餐馆点餐，拿个号，饭好了叫你；AIO 是包厢点餐，菜好了服务员直接端上桌", "BIO 是烧水时一直看着水开；NIO 是烧水时去玩手机，偶尔看一眼；AIO 是用响水壶烧水，水开了壶会响", "以上比喻都不完全准确，但能反映核心差异"]',
  'B',
  '### 深度解析

#### 选项 B 解析（烧水模型）
1.  **BIO (Blocking IO) - 同步阻塞**：
    *   你（线程）烧水（IO操作），必须**一直盯着**（阻塞），直到水开（IO完成）才能做别的事。
    *   *特点*：一个连接一个线程，并发量低。
2.  **NIO (Non-blocking IO) - 同步非阻塞**：
    *   你烧水，但你可以去玩手机（非阻塞），每隔一会儿**来看一眼**水开了没（轮询/Selector）。
    *   *特点*：多路复用，一个线程管理多个连接（Selector），适合高并发。
3.  **AIO (Asynchronous IO) - 异步非阻塞**：
    *   你用响水壶烧水，设置好后就去睡觉了。水开了，壶**自动响**（回调/通知），你再去处理。
    *   *特点*：操作系统完成后通知应用程序，性能最高，但 Linux 下实现尚不完美（Epoll 本质还是同步非阻塞，Java AIO 在 Linux 常退化为 NIO）。

#### 选项 A 解析（点餐模型）
*   NIO 应该是：你点完餐在柜台等着，厨师每做好一个菜就问“谁点的宫保鸡丁”，你一直轮询或者被 Selector 通知。
*   AIO 确实像包厢服务，点完餐你玩你的，菜好了直接端到你面前（Buffer 填满了通知你）。',
  'medium',
  (SELECT id FROM categories WHERE name = 'IO流'),
  ARRAY['IO', 'Netty', '高并发'],
  true
),

-- 5. JVM: Metaspace
(
  'JVM 方法区：PermGen vs Metaspace', 
  '在 JDK 8 中，永久代（PermGen）被元空间（Metaspace）取代。关于元空间，主要区别是什么？',
  'single', 
  '["元空间使用堆内存（Heap），受 -Xmx 限制", "元空间使用本地内存（Native Memory），不受 JVM 堆大小限制", "元空间不再存储类元数据（Class Metadata）", "元空间会导致 Full GC 更加频繁"]',
  'B',
  '### 深度解析

#### 核心区别
*   **JDK 7 及之前**：方法区实现为**永久代（PermGen）**。它在 **JVM 堆内存**中。
    *   *缺点*：大小难以调整，容易出现 `java.lang.OutOfMemoryError: PermGen space`。加载的类太多（如 JSP, 动态代理）就会爆。
*   **JDK 8 及之后**：方法区实现为**元空间（Metaspace）**。它使用 **本地内存（Native Memory）**，即操作系统内存，不再在 JVM 堆中。

#### 为什么这样做？
1.  **不再受限于 Heap 大小**：默认情况下，Metaspace 的大小仅受限于操作系统的可用物理内存。这大大减少了 OOM 的风险。
2.  **融合 HotSpot 与 JRockit**：JRockit 虚拟机本身就没有永久代，为了合并，HotSpot 去掉了 PermGen。

#### 注意事项
虽然不容易 OOM，但如果无限制使用，可能会耗尽服务器物理内存，导致操作系统杀掉进程。因此生产环境通常还是会设置 `-XX:MaxMetaspaceSize`。',
  'medium',
  (SELECT id FROM categories WHERE name = 'JVM'),
  ARRAY['JVM', '内存模型', 'JDK8'],
  true
),

-- 6. Algorithm: QuickSort
(
  '快速排序 (QuickSort) 的时间复杂度', 
  '快速排序在平均情况和最坏情况下的时间复杂度分别是多少？',
  'single', 
  '["O(n log n), O(n log n)", "O(n log n), O(n^2)", "O(n^2), O(n^2)", "O(n), O(n log n)"]',
  'B',
  '### 深度解析

#### 复杂度分析
*   **平均情况：O(n log n)**
    *   每次划分（Partition）都能将数组大致平分，递归树的深度为 log n，每层需要遍历 n 个元素。
*   **最坏情况：O(n^2)**
    *   当数组**已经有序**（正序或逆序），且每次选择**第一个元素**作为基准（Pivot）时。
    *   此时每次划分只能减少一个元素，递归树退化为链表，深度为 n。

#### 如何优化最坏情况？
1.  **随机选择 Pivot**：随机选一个数作为基准，从概率上避免最坏情况。
2.  **三数取中法**：取头、中、尾三个数的中位数作为 Pivot。

#### 空间复杂度
*   O(log n)：递归调用的栈空间。',
  'easy',
  (SELECT id FROM categories WHERE name = 'Java基础语法'), -- Algorithm
  ARRAY['算法', '排序', '数据结构'],
  true
);
