# 并行 K-Means 聚类算法设计与实现

基于 MPI 的并行 K-Means 聚类算法课程设计，使用 PCAM 方法学进行并行设计，并在本地 MacBook 上完成实验。

## 项目结构

```
.
├── data_generator.hpp      # 合成高斯分布数据生成器
├── kmeans_serial.cpp       # 串行基线版本
├── kmeans_mpi.cpp          # MPI 并行版本
├── run_experiments.sh      # 批量实验脚本
├── results/                # 实验结果目录
└── README.md               # 本文件
```

## 环境要求

- macOS（或 Linux）
- C++17 编译器（Apple Clang / GCC）
- OpenMPI
- `bc` 命令行计算器（实验脚本用）

## 安装 OpenMPI

```bash
brew install open-mpi
```

## 编译

```bash
# 串行版本
mpicxx -O2 -std=c++17 -o kmeans_serial kmeans_serial.cpp

# MPI 并行版本
mpicxx -O2 -std=c++17 -o kmeans_mpi kmeans_mpi.cpp
```

## 运行

### 串行版本
```bash
./kmeans_serial <N> <d> <K> <max_iter>
# 示例
./kmeans_serial 100000 16 8 20
```

### MPI 并行版本
```bash
mpirun --oversubscribe -np <P> ./kmeans_mpi <N> <d> <K> <max_iter>
# 示例：4 进程
mpirun --oversubscribe -np 4 ./kmeans_mpi 100000 16 8 20
```

> `--oversubscribe` 允许在 MacBook 上启动超过物理核心数的进程，便于测试扩展性。

## 批量实验

```bash
bash run_experiments.sh
```

脚本会自动运行不同数据规模（N）和进程数（P）的组合，计算加速比、效率和成本，结果保存在 `results/experiment_results.csv` 中。

## PCAM 设计概要

| 阶段 | 设计内容 |
|------|----------|
| **划分 (Partitioning)** | 域分解：将 N 个样本均匀划分为 P 个子集，每个子集分配到一个进程 |
| **通讯 (Communication)** | 每轮迭代使用 `MPI_Allreduce` 全局归约局部簇内和与计数，更新全局聚类中心 |
| **组合 (Agglomeration)** | 将单个样本的计算组合为进程级粗粒度任务，提升计算/通讯比 |
| **映射 (Mapping)** | 静态映射：进程 rank i 处理连续的样本块，负载均衡 |

## 评估指标

| 指标 | 说明 |
|------|------|
| 运行时间 Tp | MPI 并行版本的 wall-clock 时间（毫秒） |
| 加速比 Sp | Sp = Ts / Tp |
| 效率 E | E = Sp / P |
| 成本 C | C = Tp × P |
