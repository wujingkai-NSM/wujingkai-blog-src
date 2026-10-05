---
title: "Softmax是什么？大模型利用softmax做了什么"
date: 2026-10-05T10:00:00+08:00
draft: false
---

## 什么是 Softmax？


Softmax（软最大化）是一个把**任意实数向量**转换成**概率分布**的函数。对于一组分数（logits）z₁, z₂, …, zₙ：

```
softmax(z_i) = exp(z_i) / Σ_j exp(z_j)
```

输出的每个值都满足两条概率公理：

1. **非负**：`exp` 永远大于 0
2. **归一**：所有输出加起来等于 1

名字可以拆成 **soft + max**：它像 max 一样把最大的分数排在前面，但是"软的"——不会像 argmax 那样只选一个、其余全归零，而是给每个候选都留一份概率，分数越高概率越大。

### 一个手算的例子

```python
import numpy as np

def softmax(z):
    # 减去最大值防止 exp 溢出，结果不变
    e = np.exp(z - np.max(z))
    return e / e.sum()

logits = np.array([3.0, 1.0, 0.2])
print(softmax(logits))
# [0.844 0.114 0.042]
```

分数 3.0 拿到约 84% 的概率，但它不会把另外两个完全压死——这正是"软"的含义。如果换成 hard max，结果是 `[1, 0, 0]`。

### 两个关键性质

- **平移不变**：给所有 logits 加同一个常数，softmax 结果不变。所以上面的代码先减去最大值来防止 `exp` 溢出，数学上完全等价。
- **放大差距**：softmax 是指数函数，分数差会被指数放大。差 2 分的两个候选，概率差约 e² ≈ 7.4 倍。这个性质是 [大模型的 Temperature]({{< ref "/posts/大模型的temperature" >}}) 里 Temperature 能"捏"分布形状的根本原因——`logits / T` 就是在调节这个放大倍数。

## 大模型利用 Softmax 做了什么

### 1. 输出层：把打分变成"下一个词的概率"

语言模型的本质任务是：给定前文，预测下一个 token。模型的最后一层对词表里每个 token（通常几万到十几万个）输出一个 logit，再经过 softmax 变成整个词表上的概率分布：

```
输入 "世界上最高的山是" → 模型输出 15 万个 logits → softmax → 15 万个概率，加起来 = 1

"珠穆朗玛峰" → 0.92
"乔戈里峰"   → 0.05
"富士山"     → 0.001
...
```

采样时就是按这个分布抽签——概率高的词更容易被选中，但概率低的词也可能出现。生成的每一个字都来自这样一次 softmax + 采样。

### 2. 训练：交叉熵损失的底层就是 softmax

训练时模型要学习"给正确 token 分配高概率"。衡量指标交叉熵损失：

```
loss = -log(softmax(z)的正确token概率)
```

它和 softmax 的组合有一个极其干净的梯度：**预测概率 − one-hot 标签**。如果模型以 0.3 的概率预测了正确答案，梯度就把这个 0.3 往 1 推、其余概率相应往下压。softmax 处处可导，梯度才能一路回传——这是它能成为语言模型标配的数学前提。

工程上两者合并成 `log_softmax + NLLLoss`（如 PyTorch 的 `CrossEntropyLoss`），用 log-sum-exp 技巧避免数值问题。

### 3. 采样策略：在 softmax 分布之后做文章

拿到 softmax 概率分布后，还有各种"怎么抽"的策略：

- **Temperature**：在 softmax 之前缩放 logits（详见 [大模型的 Temperature]({{< ref "/posts/大模型的temperature" >}})）
- **Top-k**：只保留概率最高的 k 个候选，重新归一化后采样
- **Top-p（nucleus）**：保留累计概率刚超过 p（如 0.9）的最小候选集

它们共同的目的都是砍掉长尾里那些"基本是胡说"的低概率候选。

### 4. Attention：权重也由 Softmax 生成

Transformer 的注意力机制里同样有 softmax：

```
Attention(Q, K, V) = softmax(QK^T / √d) · V
```

Q 和 K 的点积衡量"这个 query 该多关注那个 key"，softmax 把这组打分变成一组和为 1 的权重，再对 V 加权求和。也就是说，模型不仅**输出词**靠 softmax，**决定看哪里**也靠 softmax。

## Softmax 与 Temperature 的关系

一句话总结：**Softmax 负责"生成"概率分布，Temperature 负责"重塑"这个分布。**

| | Softmax | Temperature |
|---|---|---|
| 角色 | 打分 → 概率 | 调节概率分布的尖锐程度 |
| 位置 | 模型输出层（必须有） | 推理时参数（可选） |
| 去掉会怎样 | 拿不到概率，无法采样 | 默认 T=1，照常工作 |

Temperature 正是插在 softmax 之前的那一步除法（`logits / T`），因为它借助了 softmax 指数放大差距的性质才能生效。这两篇文章配套阅读效果更好。

## 小结

- Softmax 把任意实数向量变成和为 1 的概率分布，是 argmax 的"软化"版本
- 平移不变 + 指数放大差距，是它最重要的两条性质
- 大模型用它做三件事：输出词表概率、配合交叉熵训练、给 attention 算权重
- Temperature、Top-k、Top-p 都是在 softmax 分布之上做的采样控制
