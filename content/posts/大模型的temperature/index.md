---
title: "大模型的Temperature"
date: 2026-07-11T15:58:20+08:00
draft: false
---

## 🌡️ 什么是 Temperature？

Temperature（温度）是大语言模型中的一个重要超参数，它控制着模型输出文本的**随机性**和**创造性**。

## 🎯 Temperature 的作用

### 工作原理

在语言模型中，模型会为每个可能的输出 token 计算一个概率分布。Temperature 通过以下方式影响这个分布：

```python
import numpy as np

def apply_temperature(logits, temperature):
    # 应用温度缩放
    scaled_logits = logits / temperature

    # 应用 softmax 得到概率分布
    probabilities = np.exp(scaled_logits) / np.sum(np.exp(scaled_logits))
    return probabilities
```
