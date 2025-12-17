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
