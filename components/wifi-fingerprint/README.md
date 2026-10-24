# Wi-Fi 指纹定位与课程定位仿真归档

这是 **40 条训练、16 条测试、3 维 WiFi RSSI 特征**的历史课程实验，使用 LMS、RLS、FrLMS、FrRLS 名称下的线性实现分别预测 x/y 坐标。与仓库根目录五类核滤波 **70/20** 实验不同，参数和成绩分别解释。

**实测 RSSI 数据由任课教师提供并预处理，不是本人在本项目中现场采集。** 公开副本不包含教师工作簿、MAT 数据、课件、报告原件、名单或学号。算法属于课程复现与学习整理，不宣称原创或独立编写全部历史代码。

## 包含什么

| 目录 | 内容与运行边界 |
| --- | --- |
| `matlab/fingerprint/` | 原文保留的六个坐标实验脚本/类；原入口需要自备合法私有工作簿 |
| `matlab/run_fingerprint_csv.m` | 新增便携入口，读取私有 CSV，使用原类返回有效长度 MSE 和配对预测 |
| `matlab/series-benchmark/` | 七个原始 Mackey-Glass/alpha-stable 基准与辅助函数；不附 MAT，完整 MAIN 未运行 |
| `matlab/geometry/` | 十四个原始质心、最小二乘、RSSI、AOA、TDOA 教学仿真文件 |
| `tests/` | 无课程数据的小型合成检查 |
| `tools/inspect_fingerprint_csv.py` | 标准库 CSV 检查工具，自检不需要真实数据 |
| `docs/` | 数据格式、历史结果、实现问题、来源、文件摘要与验证边界 |

27 个历史 MATLAB 文件逐字节复制，未修正历史方程、默认参数或绘图。几何仿真和时间序列基准仅作为独立学习材料保留，其误差不能移作 WiFi 定位成绩。

## 小型验证

MATLAB 当前目录切到本组件，避免其他项目的同名类干扰：

```matlab
addpath('tests');
test_micro_synthetic;
```

```sh
python tools/inspect_fingerprint_csv.py --self-test
python tools/inspect_fingerprint_csv.py --train /private/train.csv --test /private/test.csv
```

自备有权使用的 CSV（字段见 [数据格式](docs/data-format.md)）：

```matlab
addpath('matlab');
result = run_fingerprint_csv('private-train.csv', 'private-test.csv');
```

便携入口保留历史的随机种子与坐标训练顺序：x 不重排但消耗 `randperm(16)`，y 以种子 5 重排。原脚本的 1000 行补零及整列绘图由入口替换为实际训练长度；不自动调参、不导出数据、不绘图。模型仍有历史数值限制，详见 [实现审计](docs/implementation-audit.md)。

## 阅读顺序

- [实现审计与已知问题](docs/implementation-audit.md)：FrRLS alpha=1、初始化和训练顺序不匹配、未使用的数组槽位。
- [历史指标与证据边界](docs/historical-results.md)：4.2→1.8 m、57% 等仅是旧材料中的未复核说法。
- [来源与公开范围](docs/provenance.md)、[源文件映射](docs/source-map.json)：作者归属未充分确认；无宽泛再授权。
- [本次验证](docs/validation.md)：MATLAB 微型测试与静态分析范围，未运行项明确列出。

不能从现有每轴 dB 曲线直接获得二维 RMSE，也不能将样本行号解释为时间轴或证明 NLOS/多径机制。没有硬件部署或跨场景精度承诺。
