# Transformer 与室内定位：从“查、比、取”到 AaT

## 这份材料讲什么

这是一份面向 Transformer 初学者的阅读和分享材料。主线只有一个：把课堂中学到的 Attention 放到 Wi-Fi 指纹定位问题里，再用 Anchor-agnostic Transformers（AaT）说明论文如何把这个直觉变成模型设计。

这里的“查、比、取”是教学类比，不是论文原文术语：

- **查**：当前问题要找什么，对应 Query。
- **比**：当前 Query 与候选 Key 的相关程度。
- **取**：按相关程度汇总 Value。

## 1. 从课堂里的 Transformer 开始

Transformer 先把输入组织成一组 token。Attention 让一个 token 直接查看其他 token，并按相关性汇总信息；完整的 Transformer 还包括多头注意力、残差连接、LayerNorm、前馈网络、位置或身份信息，以及最后的任务输出层。

因此，Attention 不能直接等同于 Transformer。Attention 是信息交换模块，Transformer 是围绕它组织起来的完整网络架构。

## 2. 把问题换成 Wi-Fi 指纹定位

在室内不同位置，手机看到的接入点（AP）及其 RSS 信号强度组合会变化。把一组 AP 信号看作地点的“信号身份证”，就得到 Wi-Fi fingerprint。传统指纹定位通常先在已知位置采集指纹，再把一次新的扫描与历史记录进行比较。

为了建立直觉，可以暂时这样对应：

| 定位里的对象 | Attention 类比 |
| --- | --- |
| 当前手机扫描 | Query |
| 历史指纹记录的匹配特征 | Key |
| 历史记录对应的位置 | Value |
| 定位输出 | 按相似度加权汇总的位置 |

这个对应关系只是在解释“加权查库”的计算骨架。它还不是 AaT 的真实 Self-Attention。

## 3. 为什么要区分类比和真正的 Transformer

教学算例使用固定的距离和权重规则：距离越近，位置贡献越大。这能把“查、比、取”讲清楚，但“怎样算相似”是人提前写好的。

真正的 Transformer 会把输入映射成 token，并在训练中学习 Q、K、V 的投影和信息组合方式。多头注意力可以从不同角度观察关系。因此，Transformer 的增量不只是“也会加权”，而是把比较方式、信息组合方式和任务输出一起交给数据学习。

## 4. AaT 论文的关键思路

AaT 关注一个实际困难：同一次 RSS 扫描里，可靠信号和环境噪声混在一起。RSS 数组中编号相邻的 AP，也不代表它们在物理空间中相邻，因此直接套用 CNN 的局部邻域假设并不自然；逐项处理的 RNN 也不容易一次观察整次扫描的关系。

论文的思路可以按四步理解：

1. **Anchor2Vec：先翻译输入。** 原始 RSS 指纹是一串离散 anchor 数值，而 Transformer 接收 token embedding。Anchor2Vec 把输入整理成固定数量的高维表示，再加入 `[CLS]` 和位置/身份信息。
2. **Encoder：让 token 互相交流。** Self-Attention 在一次扫描内部比较 token 之间的关系，而不是拿当前扫描去历史指纹库查位置。
3. **“查、比、取”发生在扫描内部。** 某个 token 生成 Query，与同一次扫描中的所有 Key 比较，再按权重汇总 Value；较能区分位置的信号可以贡献更多，噪声信号贡献更少。
4. **`[CLS]` 汇总任务信息。** 编码器处理后，`[CLS]` 可用于楼层分类和二维坐标回归。

最容易混淆的地方是：前面的近邻类比是“当前扫描查询历史记录”；AaT 的 Self-Attention 是“同一次扫描内部的 token 互相查询”。两者都有加权汇总，但查询对象不同。

## 5. 结果应该怎样读

当前源材料记录了一个 UJIIndoorLoc 教学算例：在已知建筑和楼层的条件下，选取一条验证记录，并用同层训练记录做四近邻加权，得到单样本误差约 3.19 m。这个数字只说明计算过程，不能当作数据集整体性能，也不能直接和论文平均误差比较。

源材料还记录了论文增强版 eAaT 的结果：UJIIndoorLoc、UTSIndoorLoc 和 TampereIndoorLoc 的精细定位 MAE 分别为 8.40 m、6.86 m 和 8.52 m；UJI 的楼层准确率记录为 94.69%。这些是论文/本地讲稿中已有的记录，本次整理没有重新训练或复现实验。源材料同时指出同一结果表中 CNNLoc 的楼层准确率为 96.03%，因此不能笼统地说 eAaT 在所有指标上都最好。

## 6. 读者需要记住的边界

- 这是技术阅读和课堂分享材料，不是可运行的 Transformer 定位实现。
- “查、比、取”是帮助入门的语言；正式实现仍应回到矩阵化的 Q/K/V、softmax、多头注意力和 Transformer Encoder。
- 3.19 m 是有条件的单样本教学计算；8.40 m 是论文记录的整体 MAE，评价范围不同，不能直接比较。
- 论文结果是否能迁移到新的楼宇、设备和环境，需要新的数据划分、基线和实验验证；不能从架构名称直接推出鲁棒性。

## 引用

1. Vaswani et al. (2017), [Attention Is All You Need](https://arxiv.org/abs/1706.03762).
2. Torres-Sospedra et al. (2014), [UJIIndoorLoc](https://archive.ics.uci.edu/dataset/310/ujiindoorloc), DOI [10.24432/C5MS59](https://doi.org/10.24432/C5MS59).
3. Nguyen, Le & Havinga (2023), [Anchor-agnostic Transformers for Fingerprint-based Indoor Localization](https://doi.org/10.1109/PERCOM56429.2023.10099376).
