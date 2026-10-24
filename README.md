# 五类核自适应滤波的室内定位课程复现

MATLAB 课程复现工程：用三维测量特征分别回归 X、Y 坐标，比较 **KRLS、KLMS、FrKLMS、FrKRLS、KRGMC** 的测试集学习曲线。

本项目保留教学示例的组织方式：两个坐标主函数、五个独立 `handle` 算法类、一个公共高斯核函数。贡献在于实现整理、接口统一、数值保护和验证；不把已有算法称为原创，也不把课程提供的定位数据称为本人采集。

**数据不随仓库分发。** 需要自行取得有权使用的数据，按 [字段说明](辅助文件/README.md) 放置后，才能运行完整定位实验。默认测试提供微型合成数值检查，它不能替代真实定位实验。公开副本于 **2026-10-25** 通过 MATLAB R2022a 静态检查和内置微型合成数值测试；没有重跑课程数据实验、历史基线或设备采集。

## 代码结构

```text
MAIN_x.m                    X 坐标主函数
MAIN_y.m                    Y 坐标主函数
KRLS.m / KLMS.m             独立核滤波算法类
FrKLMS.m / FrKRLS.m         教学示例的分数阶实现
KRGMC.m                    广义最大相关熵递推实现
kernel.m                   公共高斯核函数
MAIN_compare_xy.m          两坐标组合运行与导出
plot_results.m             组合图和单坐标图
save_results.m             MAT、CSV、PNG、PDF、FIG 导出
tests/                     静态检查、合成数值检查、可选私有数据回归
辅助文件/README.md         数据格式与放置说明；不含原始数据
results/                   历史汇总数值与结果索引；不含模型或逐点预测
docs/                      中文原理、架构、运行、贡献与限制说明
```

各算法使用相同接口：

```matlab
kaf = KRLS(struct('M',Inf,'kerneltype','gauss','sigma',22,'gam',0.01));
kaf.initial_p(X_train(1,:),y_train(1));
kaf.train(X_train(2,:),y_train(2));
y_est = kaf.evaluate(X_test);
[dict,weight] = kaf.model;
```

`X_train` 每行一个样本；两个坐标使用独立模型和独立参数。图中一次迭代表示学习一个训练样本后，重新评估固定测试集，不是一次完整 epoch。

## 运行

原工程记录的运行环境为 MATLAB R2022a；公开副本本次也使用该版本完成静态分析与微型合成数值测试。请先将 MATLAB 当前文件夹切换到仓库根目录，避免其他目录中的同名类或 `kernel.m` 覆盖本工程。

不需要数据、不训练的静态检查：

```matlab
addpath('tests');
report = check_static;
```

合成数据的微型数值测试（会执行少量算法更新，2026-10-25 已运行通过）：

```matlab
addpath('tests');
test_xy_learning_curves;
```

自行放置课程格式数据后运行：

```matlab
xResult = MAIN_x;                  % 单独显示 X 坐标学习曲线
yResult = MAIN_y;                  % 单独显示 Y 坐标学习曲线
results = MAIN_compare_xy;         % 组合图并保存本机结果
```

完整实验固定要求 70 条训练数据、20 条测试数据、三维输入及固定排列。代码不会自动下载数据、补造数据或训练参数。完整测试、可选基线和截图核对见 [运行与验证](docs/运行与验证.md)。

## 历史结果与当前验证

原工程的记录日期为 **2026-09-30**，包含一次完整定位复现及类结构回归。公开索引仅保留十个最终误差值和历史验证摘要，见 [结果索引](results/README.md)。这些历史指标来自课程数据和给定参数，不代表跨场景性能、独立新测试或普适算法排名。

2026-10-25 的检查范围是文件选择、源码一致性、MATLAB 静态分析、类接口、微型合成数值测试、文档链接与公开内容扫描。课程数据训练、完整图形导出、历史基线与截图对照、硬件采集均未重新执行。详细状态见 [验证记录](docs/验证记录.md)。

## 阅读与贡献边界

- [架构与代码导读](docs/架构与代码导读.md)：从入口读到算法状态与结果数组。
- [算法与参数](docs/算法与参数.md)：五种更新、核宽度与误差尺度的区别。
- [贡献与来源](docs/贡献与来源.md)：实现整理、教学来源、AI 辅助和未确认的作者归属。
- [限制与数据边界](docs/限制与数据边界.md)：固定数据规模、模型增长与验证局限。
- [Transformer 与室内定位读书分享](docs/transformer-notes/README.md)：Attention、Wi-Fi 指纹与 AaT 的教学说明；不包含 Transformer 定位实现，其论文/教学指标与本项目核滤波误差分别解释。
- [第三方声明](THIRD_PARTY_NOTICES.md)、[许可状态](LICENSE_STATUS.md)：课程材料及相关上游权利不被本仓库重新授权。

公开归档未附 MIT、Apache 等宽泛许可。原教学材料与相关实现的权利范围仍有未确认项；这里只整理可审阅的实现和说明，不宣称完成上游授权审查。

## 历史 Wi-Fi 指纹定位与定位仿真组件

[components/wifi-fingerprint](components/wifi-fingerprint/README.md) 保留 27 个历史 MATLAB 源文件、独立定位仿真、CSV 便携入口和微型合成检查。该组件使用教师提供并预处理的 **40/16** 实测 RSSI 指纹表，数据不公开，也不是本人采集。它与本页 **70/20** 五类核滤波的参数、成绩和验证历史分别解释；历史算法不宣称原创。

2026-10-25 的新增组件验证在 MATLAB R2022a `-nojvm -batch` 下退出码 0；30 文件静态分析保留 92 条历史消息，新增 3 文件无消息。首次普通 batch 的退出异常与后续排查详见 [组件验证记录](components/wifi-fingerprint/docs/validation.md)。没有重跑教师数据或硬件实验。
