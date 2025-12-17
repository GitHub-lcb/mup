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
