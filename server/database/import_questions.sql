-- Insert more high-quality questions with deep analysis

-- Helper function to get category ID (to make the script portable)
-- We'll just use subqueries in the INSERT statement

INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active) 
VALUES 
-- 1. JVM: GC Roots
(
  'JVM 中哪些对象可以作为 GC Roots？', 
  '在 Java 的垃圾回收机制（可达性分析算法）中，哪些对象可以作为 GC Roots？请选择所有正确的选项。',
  'multiple', 
  '["虚拟机栈（栈帧中的本地变量表）中引用的对象", "方法区中类静态属性引用的对象", "方法区中常量引用的对象", "本地方法栈中 JNI（即一般说的 Native 方法）引用的对象", "所有被 WeakReference 引用的对象"]',
  'A,B,C,D',
  '### 深度解析

在 Java GC 的**可达性分析算法（Reachability Analysis）**中，为了判断对象是否存活，JVM 会从一系列称为 **GC Roots** 的对象作为起始点，从这些节点开始向下搜索。

#### 可以作为 GC Roots 的对象包括：

1.  **虚拟机栈（栈帧中的本地变量表）中引用的对象**
    *   例如：正在执行的方法中的局部变量、参数等。这是最常见的 GC Root。
2.  **方法区中类静态属性引用的对象**
    *   例如：`static` 关键字修饰的引用类型变量。
3.  **方法区中常量引用的对象**
    *   例如：`static final` 修饰的引用类型变量，或者字符串常量池（String Table）里的引用。
4.  **本地方法栈中 JNI（Native 方法）引用的对象**
    *   当调用 C/C++ 本地库时，Native 代码持有的 Java 对象引用。
5.  **Java 虚拟机内部的引用**
    *   如基本数据类型对应的 Class 对象，一些常驻的异常对象（NullPointerException 等），以及系统类加载器。
6.  **所有被同步锁（synchronized 关键字）持有的对象**

#### 错误选项分析：
*   **E 选项**：被 `WeakReference`（弱引用）引用的对象**不能**作为 GC Roots。相反，如果一个对象只被弱引用引用，那么在下一次 GC 时它**一定**会被回收。

### 扩展知识
*   **软引用（SoftReference）**：内存不足时回收。
*   **弱引用（WeakReference）**：发现即回收。
*   **虚引用（PhantomReference）**：无法通过它获取对象实例，唯一作用是对象被回收时收到通知（用于管理堆外内存等）。',
  'hard',
  (SELECT id FROM categories WHERE name = 'JVM'),
  ARRAY['JVM', 'GC', '面试高频'],
  true
),

-- 2. Collections: HashMap Implementation
(
  'Java 8 中 HashMap 的扩容机制与红黑树转换', 
  '关于 Java 8 中 HashMap 的实现，以下说法错误的是？',
  'single', 
  '["默认初始容量是 16，默认加载因子是 0.75", "当链表长度超过 8 时，一定会转换为红黑树", "HashMap 允许 null 键和 null 值", "扩容时，元素的新位置要么在原位置，要么在原位置 + 旧数组长度"]',
  'B',
  '### 深度解析

#### 选项 B 错误分析
**"当链表长度超过 8 时，一定会转换为红黑树"** 这句话是不严谨的。

在 Java 8 的 `HashMap` 源码中，链表转换为红黑树需要满足**两个条件**：
1.  链表长度达到阈值（`TREEIFY_THRESHOLD`，默认为 8）。
2.  **且** 数组（Bucket）的长度达到最小树化容量（`MIN_TREEIFY_CAPACITY`，默认为 64）。

**如果链表长度超过 8，但数组长度小于 64，HashMap 会优先选择扩容（resize）数组，而不是转换为红黑树。** 这样做是为了避免在哈希表建立初期，由于数组过小导致的哈希冲突过多，此时扩容能更有效地分散哈希冲突。

#### 其他选项正确性分析
*   **A 正确**：`DEFAULT_INITIAL_CAPACITY = 16`, `DEFAULT_LOAD_FACTOR = 0.75`。
*   **C 正确**：`HashMap` 允许一个 `null` 键和多个 `null` 值。`null` 键会被放在下标 0 的位置。
*   **D 正确**：这是 Java 8 的优化。扩容时，数组长度变为原来的 2 倍。计算索引的逻辑是 `(n - 1) & hash`。由于 n 变为 2n，二进制表示中最高位多了一个 1。因此，元素的位置要么不变（最高位是 0），要么变成 `原索引 + oldCap`（最高位是 1）。这避免了重新计算 Hash 值。

### 源码参考 (Java 8)
```java
final void treeifyBin(Node<K,V>[] tab, int hash) {
    int n, index; Node<K,V> e;
    // 检查数组长度是否小于 64
    if (tab == null || (n = tab.length) < MIN_TREEIFY_CAPACITY)
        resize(); // 优先扩容
    else if ((e = tab[index = (n - 1) & hash]) != null) {
        // 转换为红黑树逻辑
        // ...
    }
}
```',
  'medium',
  (SELECT id FROM categories WHERE name = '集合框架'),
  ARRAY['HashMap', '源码分析', 'Java8'],
  true
),

-- 3. Concurrency: volatile
(
  'volatile 关键字的作用', 
  '关于 `volatile` 关键字，以下描述正确的是（多选）？',
  'multiple', 
  '["保证了变量的可见性（Visibility）", "保证了变量操作的原子性（Atomicity）", "禁止指令重排序（Ordering）", "可以替代 synchronized 实现所有同步场景"]',
  'A,C',
  '### 深度解析

`volatile` 是 Java 虚拟机提供的轻量级同步机制。

#### 正确选项分析：
1.  **A 正确（可见性）**：当一个线程修改了 `volatile` 变量的值，新值会立即被刷新到主内存（Main Memory），且其他线程读取该变量时，会被强制从主内存重新加载。这保证了多线程环境下变量修改的实时可见性。
2.  **C 正确（禁止指令重排序）**：`volatile` 通过插入**内存屏障（Memory Barrier）**来禁止特定类型的处理器重排序和编译器重排序。
    *   例如：在单例模式的**双重检查锁定（DCL）**实现中，`instance` 必须声明为 `volatile`，就是为了防止对象初始化时的指令重排序导致其他线程获取到未完全初始化的对象。

#### 错误选项分析：
*   **B 错误（原子性）**：`volatile` **不能**保证复合操作的原子性。
    *   例如：`volatile int i = 0; i++;`。`i++` 包含读、改、写三个步骤，`volatile` 无法保证这三个步骤作为一个原子整体执行。多线程下 `i++` 仍然是不安全的。要保证原子性需要使用 `synchronized`、`Lock` 或 `AtomicInteger`。
*   **D 错误**：由于无法保证原子性，它不能完全替代 `synchronized`。它适用于状态标记量（flag）、双重检查锁定等特定场景。

### 扩展：JMM（Java 内存模型）
`volatile` 的语义是基于 JMM 的 happen-before 原则建立的。',
  'medium',
  (SELECT id FROM categories WHERE name = '多线程'),
  ARRAY['并发编程', 'JMM', 'volatile'],
  true
),

-- 4. Thread Pool
(
  '线程池 ThreadPoolExecutor 参数解析', 
  '当向一个 ThreadPoolExecutor 提交任务时，线程池的处理流程是怎样的？请按正确顺序排序：\n1. 存入工作队列 \n2. 创建核心线程执行 \n3. 执行拒绝策略 \n4. 创建非核心线程执行',
  'single', 
  '["2 -> 1 -> 4 -> 3", "2 -> 4 -> 1 -> 3", "1 -> 2 -> 4 -> 3", "2 -> 1 -> 3 -> 4"]',
  'A',
  '### 深度解析

Java 线程池 `ThreadPoolExecutor` 的任务提交逻辑是面试中的超高频考点。

#### 正确流程（2 -> 1 -> 4 -> 3）：

1.  **判断核心线程数（corePoolSize）**：
    *   如果当前运行的线程数 < `corePoolSize`，则**创建新线程（核心线程）**来执行任务。（即使有空闲的核心线程，也可能创建新线程，取决于具体实现，但通常优先创建直到满）。
2.  **判断工作队列（BlockingQueue）**：
    *   如果当前运行的线程数 >= `corePoolSize`，则将任务**加入工作队列**等待执行。
3.  **判断最大线程数（maximumPoolSize）**：
    *   如果工作队列已满，且当前运行的线程数 < `maximumPoolSize`，则**创建新线程（非核心线程）**来执行任务。
4.  **执行拒绝策略（RejectedExecutionHandler）**：
    *   如果工作队列已满，且当前运行的线程数 >= `maximumPoolSize`，则调用**拒绝策略**处理该任务。

#### 常见陷阱
*   很多人误以为是先把线程创建到 `maximumPoolSize` 再放队列，其实是**先放队列，队列满了才继续创建线程**。
*   **特殊的队列**：如果是 `SynchronousQueue`（容量为 0），则第 2 步直接失败（相当于队列满），会直接触发第 3 步（创建非核心线程）。这是 `Executors.newCachedThreadPool()` 的工作模式。

#### 默认拒绝策略
*   `AbortPolicy`：抛出 `RejectedExecutionException` 异常（默认）。
*   `CallerRunsPolicy`：由调用线程（提交任务的线程）直接运行该任务。
*   `DiscardPolicy`：默默丢弃，不抛异常。
*   `DiscardOldestPolicy`：丢弃队列中最老的任务，重新尝试提交。',
  'hard',
  (SELECT id FROM categories WHERE name = '多线程'),
  ARRAY['线程池', '源码分析'],
  true
),

-- 5. Basic: String
(
  'String, StringBuilder, StringBuffer 的区别', 
  '以下关于字符串类的描述，错误的是？',
  'single', 
  '["String 是不可变类（Immutable），每次修改都会生成新的对象", "StringBuilder 是可变的，线程不安全，但性能最高", "StringBuffer 是可变的，线程安全，适合多线程环境", "String s = new String(\"abc\") 只创建了一个对象"]',
  'D',
  '### 深度解析

#### 选项 D 错误分析
语句 `String s = new String("abc");` 通常会创建**两个对象**（假设 "abc" 之前未在常量池中）：
1.  **字符串常量池中的对象**：字面量 `"abc"` 会先在常量池中创建一个 String 对象。
2.  **堆内存中的对象**：`new String(...)` 会在堆（Heap）中创建一个新的 String 对象，该对象的内容引用常量池中的 "abc"。
3.  变量 `s` 引用堆中的这个对象。

*注：如果常量池中已经存在 "abc"，则只创建一个堆对象。但无论如何，绝对不仅仅是“一个对象”那么简单，因为它涉及到了常量池机制。严格来说，如果是首次执行，是2个。*

#### 其他选项正确性分析
*   **A 正确**：`String` 类被 `final` 修饰，底层 `char[]` (Java 9+ 是 `byte[]`) 也是 `final` 的。不可变性带来了安全性（HashKey）、线程安全等好处。
*   **B 正确**：`StringBuilder` 继承自 `AbstractStringBuilder`，没有同步锁，效率最高，适合单线程大量字符串拼接。
*   **C 正确**：`StringBuffer` 的方法大多由 `synchronized` 修饰，线程安全，但因为锁竞争，性能略低于 `StringBuilder`。

### 性能排序
`StringBuilder` > `StringBuffer` > `String` (在大量拼接场景下)',
  'easy',
  (SELECT id FROM categories WHERE name = 'Java基础语法'),
  ARRAY['String', '基础'],
  true
),

-- 6. Redis (Adding a question even if category might not strictly exist, mapped to IO or similar, or create category if needed. Let's map to IO for now or skip. Actually let's do a Lock question for Multi-threading)
(
  'synchronized 与 ReentrantLock 的区别', 
  '对比 synchronized 关键字和 ReentrantLock 类，以下说法错误的是？',
  'single', 
  '["synchronized 是 JVM 层面的实现，ReentrantLock 是 API 层面的实现", "synchronized 会自动释放锁，ReentrantLock 需要在 finally 中手动释放", "synchronized 只能是非公平锁，ReentrantLock 可以指定为公平锁", "ReentrantLock 无法响应中断，一旦等待锁就必须一直等下去"]',
  'D',
  '### 深度解析

#### 选项 D 错误分析
**ReentrantLock 是可以响应中断的。**
*   `synchronized`：一旦进入阻塞等待锁的状态，是**不可中断**的（uninterruptible）。
*   `ReentrantLock`：
    *   `lock()`：不可中断。
    *   `lockInterruptibly()`：**可中断**。如果线程在等待锁的过程中被中断，会抛出 `InterruptedException`。
    *   `tryLock()`：尝试获取锁，不等待或等待一段时间，也是灵活的锁定方式。

#### 其他选项正确性分析
*   **A 正确**：`synchronized` 是关键字，基于 Monitor 对象，字节码层面的 `monitorenter/monitorexit`；`ReentrantLock` 是 JDK 提供的类，基于 AQS（AbstractQueuedSynchronizer）实现。
*   **B 正确**：`synchronized` 代码块执行完或抛异常会自动释放；`ReentrantLock` 必须在 `finally` 块中调用 `unlock()`，否则可能导致死锁。
*   **C 正确**：`synchronized` 早期是重量级锁，后来引入偏向锁、轻量级锁，但始终是非公平的。`ReentrantLock` 构造函数可以传入 `true` 实现公平锁（FairSync），遵循先来后到，但性能会下降。',
  'medium',
  (SELECT id FROM categories WHERE name = '多线程'),
  ARRAY['锁', '并发编程', '对比'],
  true
),

-- 7. Spring Bean Scope (Mapping to Object Oriented or Reflect, let's put in Object Oriented as it relates to instances)
(
  'Spring Bean 的作用域（Scope）', 
  'Spring 框架中 Bean 的默认作用域是什么？还有哪些常见作用域？',
  'single', 
  '["Prototype (原型)", "Singleton (单例)", "Request (请求)", "Session (会话)"]',
  'B',
  '### 深度解析

#### 正确答案：Singleton (单例)
在 Spring 容器中，Bean 的默认作用域是 **Singleton**。
这意味着在整个 Spring IoC 容器中，该 Bean 只有一个实例。每次注入或获取该 Bean，得到的都是同一个对象。

#### 其他作用域解析
*   **Prototype (原型)**：每次通过容器获取 Bean 时（例如 `context.getBean()`），都会创建一个**新的实例**。
    *   *注意：Spring 不负责管理 Prototype Bean 的完整生命周期（只负责创建，不负责销毁），开发者需要自己管理销毁。*
*   **Request** (Web 环境)：每次 HTTP 请求都会创建一个新的 Bean，仅在当前 Request 内有效。
*   **Session** (Web 环境)：同一个 HTTP Session 共享一个 Bean。
*   **Application** (Web 环境)：整个 ServletContext 生命周期内有效。

#### 线程安全问题
由于默认是单例，如果 Bean 中有成员变量（即有状态的 Bean），在多线程环境下是不安全的。因此，通常建议 Spring Bean 是无状态的（Service, Dao），或者使用 ThreadLocal 处理状态，或者改为 Prototype。',
  'medium',
  (SELECT id FROM categories WHERE name = '面向对象'),
  ARRAY['Spring', '设计模式', 'Bean'],
  true
),

-- 8. Database/IO: ACID
(
  '数据库事务的 ACID 特性', 
  '数据库事务必须具备的四个特性是 ACID，其中 I 代表什么？',
  'single', 
  '["Identity (标识性)", "Isolation (隔离性)", "Integrity (完整性)", "Immutability (不可变性)"]',
  'B',
  '### 深度解析

ACID 是数据库事务正确执行的四个基本要素：

1.  **A (Atomicity) 原子性**：
    *   事务是一个不可分割的工作单位，事务中的操作要么都发生，要么都不发生。
    *   *实现原理*：Undo Log。
2.  **C (Consistency) 一致性**：
    *   事务前后，数据库的完整性约束没有被破坏。
    *   *这是最终目标*。
3.  **I (Isolation) 隔离性**：
    *   多个事务并发执行时，一个事务的执行不应影响其他事务的执行。
    *   *实现原理*：MVCC（多版本并发控制）和 锁（Lock）。
    *   *隔离级别*：Read Uncommitted, Read Committed, Repeatable Read, Serializable。
4.  **D (Durability) 持久性**：
    *   事务一旦提交，其对数据库的改变就是永久性的，即使数据库崩溃也能恢复。
    *   *实现原理*：Redo Log。

#### 面试高频点
面试官经常问：**"MySQL 的 InnoDB 引擎是如何保证 Atomicity 和 Durability 的？"**
*   原子性靠 Undo Log（回滚日志）。
*   持久性靠 Redo Log（重做日志）。',
  'easy',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Mapping DB to IO category roughly
  ARRAY['数据库', '事务', 'MySQL'],
  true
);
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
-- Insert more questions: Microservices, Docker, Git, Linux, MyBatis

INSERT INTO questions (title, content, type, options, correct_answer, explanation, difficulty, category_id, tags, is_active) 
VALUES 
-- 1. Microservices: Hystrix/Sentinel
(
  '微服务中的熔断与降级', 
  '在微服务架构中，关于服务熔断（Circuit Breaking）和服务降级（Degradation）的区别，以下描述最准确的是？',
  'single', 
  '["熔断是消费端的主动保护机制，降级是服务端的被动补救措施", "熔断是因外部故障（如下游服务超时）而切断请求，降级是因系统整体负荷过高而暂时屏蔽非核心业务", "熔断会导致请求直接失败，降级会尝试返回缓存数据，两者不能同时使用", "熔断是临时的，降级是永久的"]',
  'B',
  '### 深度解析

#### 选项 B 正确分析
*   **服务熔断 (Circuit Breaking)**：
    *   **类比**：家里的保险丝。
    *   **场景**：当下游服务出现故障（响应慢、报错率高）时，为了防止拖垮当前服务（雪崩效应），**主动切断**对下游的调用。
    *   **状态**：关闭 -> 打开（熔断） -> 半打开（尝试恢复） -> 关闭。
    *   **侧重点**：保护调用方，防止故障扩散。

*   **服务降级 (Degradation)**：
    *   **类比**：电力公司在高峰期限制工业用电，保障民用电。
    *   **场景**：当系统整体负载过高（CPU/内存飙升），或者非核心服务故障时，为了保证**核心业务**（如支付、下单）的可用性，暂时**牺牲非核心业务**（如评论、推荐），返回默认值或空值。
    *   **侧重点**：保证核心业务的高可用。

#### 关系
熔断通常会触发降级（熔断后执行 fallback 逻辑返回兜底数据），但降级不一定是因为熔断（可能是手动开关控制）。',
  'hard',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Mapping Distributed to IO
  ARRAY['微服务', 'Spring Cloud', '高可用'],
  true
),

-- 2. Docker: Image Layers
(
  'Docker 镜像分层原理', 
  'Docker 镜像采用分层结构（Layered File System），以下关于分层的优势，错误的是？',
  'single', 
  '["共享资源：多个镜像可以共享底层的 Base Image（如 Ubuntu），节省磁盘空间", "加速分发：Push/Pull 时只需传输缺失的层", "容器启动快：容器启动时只需加载只读镜像层，无需复制文件", "写时复制（CoW）：修改文件时会直接在只读层上进行修改，效率极高"]',
  'D',
  '### 深度解析

#### 选项 D 错误分析
**Docker 不会直接在只读层上修改文件。**
Docker 使用 **Copy-on-Write (CoW, 写时复制)** 策略：
1.  所有的镜像层（Image Layers）都是**只读**（Read-Only）的。
2.  当容器启动时，Docker 会在镜像层之上添加一个**可写容器层**（Writable Container Layer）。
3.  如果要修改某个文件，Docker 会先将该文件从只读层**复制**到可写层，然后对副本进行修改。
4.  只读层的文件依然存在，只是被可写层的文件**遮挡**（Hidden）了。
5.  *缺点*：如果是大文件的第一次修改，CoW 会带来明显的 I/O 延迟（因为要复制）。

#### 其他选项正确性
*   **A, B**：利用联合文件系统（UnionFS），不同镜像复用相同层，极大节省空间和带宽。
*   **C**：启动极快，因为不需要拷贝整个操作系统，只是挂载文件系统。',
  'medium',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Mapping DevOps to IO/Tools
  ARRAY['Docker', '容器化', 'DevOps'],
  true
),

-- 3. Linux: Load Average
(
  'Linux Load Average (平均负载)', 
  '在 Linux 中执行 `uptime` 命令看到 `load average: 0.8, 1.2, 2.5`。假设这是一台单核 CPU 的机器，这说明什么？',
  'single', 
  '["系统当前非常空闲", "系统在过去 15 分钟内负载较高，很多进程在排队", "系统在过去 1 分钟内负载最高", "CPU 使用率一定是 100%"]',
  'B',
  '### 深度解析

#### Load Average 定义
平均负载是指单位时间内，系统处于**可运行状态**（Running/Runnable）和**不可中断状态**（Uninterruptible sleep, 通常是 IO 等待）的进程数平均值。

#### 数据解读
`0.8, 1.2, 2.5` 分别代表过去 **1分钟**、**5分钟**、**15分钟** 的平均负载。

#### 结合 CPU 核数分析
*   **单核 CPU**：Load < 1.0 表示系统良好；Load > 1.0 表示有进程在排队等待 CPU。
*   **题目情景**：
    *   1分钟 (0.8)：当前负载已下降，系统可以处理过来。
    *   15分钟 (2.5)：过去很长一段时间负载高达 2.5，意味着有 `2.5 - 1 = 1.5` 个进程在排队，系统**严重过载**。
    *   **结论**：系统之前的压力很大，最近刚缓过来。

#### 误区
Load 高不代表 CPU 使用率一定高。
*   **CPU 密集型**：Load 高 ≈ CPU 使用率高。
*   **IO 密集型**：大量进程在等待磁盘 I/O（D状态），Load 会很高，但 CPU 使用率可能很低。',
  'hard',
  (SELECT id FROM categories WHERE name = '多线程'), -- Mapping OS to Thread
  ARRAY['Linux', '运维', '性能调优'],
  true
),

-- 4. MyBatis: #{} vs ${}
(
  'MyBatis 中 #{} 和 ${} 的区别', 
  '在 MyBatis 的 Mapper XML 文件中，关于 `#{}` 和 `${}` 的区别，以下描述正确的是？',
  'single', 
  '["#{} 是字符串替换，${} 是预编译处理", "#{} 可以防止 SQL 注入，${} 不能防止", "#{} 性能比 ${} 差，因为要进行反射", "表名和字段名作为参数时，必须使用 #{}"]',
  'B',
  '### 深度解析

#### 正确答案 B
*   **`#{}` (预编译)**：
    *   MyBatis 会将其解析为 JDBC 的占位符 **`?`**。
    *   执行时，通过 `PreparedStatement` 的 `setObject()` 方法设置参数。
    *   **优势**：有效防止 **SQL 注入**攻击，不需要手动转义特殊字符。
*   **`${}` (字符串拼接)**：
    *   MyBatis 会直接将变量的值**拼接**在 SQL 语句中。
    *   **风险**：存在 SQL 注入风险（例如传入 `1 OR 1=1`）。
    *   **场景**：只能用于**表名**、**列名**、**排序字段**（ORDER BY）等无法使用 `?` 占位符的地方。

#### 错误选项分析
*   **A 反了**：`#{}` 是预编译，`${}` 是替换。
*   **D 错误**：表名（Table Name）作为参数时，JDBC 不支持用 `?` 占位，**必须**使用 `${}`（但要注意安全检查）。',
  'easy',
  (SELECT id FROM categories WHERE name = 'IO流'), -- Mapping Framework to IO/DB
  ARRAY['MyBatis', 'ORM', 'SQL注入'],
  true
),

-- 5. Git: Rebase vs Merge
(
  'Git: Merge vs Rebase', 
  '在合并分支时，git merge 和 git rebase 的主要区别是什么？',
  'single', 
  '["merge 会修改提交历史，rebase 会保留原始提交记录", "rebase 会将当前分支的提交应用到目标分支之后，形成线性的提交历史，看起来更整洁", "merge 只有在冲突时才生成新的 Commit，rebase 永远不生成新 Commit", "rebase 比 merge 更安全，适合在公共分支（如 master）上随意使用"]',
  'B',
  '### 深度解析

#### Merge (合并)
*   **行为**：将两个分支的最新快照合并，生成一个新的 **Merge Commit**。
*   **特点**：保留了完整的分支结构（分叉和汇合），真实记录了开发过程。
*   **缺点**：提交历史可能变得错综复杂（尤其是多人协作时）。

#### Rebase (变基)
*   **行为**：将当前分支的 commit 临时保存，将当前分支的基底移动到目标分支的最新 commit，然后将保存的 commit **逐个应用**（Re-play）上去。
*   **特点**：**线性历史**（Linear History），没有分叉，看起来像是一直在最新代码上开发。
*   **缺点**：**修改了历史**（改变了 commit 的 hash）。

#### 黄金法则
**绝对不要在公共分支（Public Branch）上使用 Rebase！**
如果在 master 上 rebase，会改变别人的提交历史，导致其他人的本地仓库无法同步（Push Rejected）。Rebase 仅限用于**本地个人开发分支**整理提交记录。',
  'medium',
  (SELECT id FROM categories WHERE name = 'Java基础语法'), -- Mapping Tools
  ARRAY['Git', '版本控制', '团队协作'],
  true
);
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
