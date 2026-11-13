# hexgrid 项目申报书

## 基本信息

- 项目名称：hexgrid：MoonBit 六角格网格几何基础库
- 参赛者：苏春昊（wbgxiaosu）
- 联系方式：1684128842@qq.com
- GitHub 仓库链接：https://github.com/wbgxiaosu/hexgrid
- 项目方向：MoonBit 游戏工具基建 / 网格几何基础库
- 是否为移植项目：否（原创项目，参考公开技术资料，见文末说明）

## 项目简介

hexgrid 为 MoonBit 生态补齐平面六角格网格这一通用基础设施，为战棋/SLG、Roguelike、六角地图编辑器、算法可视化等场景的库作者与应用开发者提供可复用的坐标系统、寻路、视野与地图存储引擎。功能范围对标 rust 生态成熟库 `hexx` 的功能版图（仅作范围参照，未复用其代码），分四个独立成包的层次交付：

- `hex` 包——坐标系统与网格几何：axial/cube 坐标、offset 四种布局（OddR/EvenR/OddQ/EvenQ）、doubled 两种模式（DoubleWidth/DoubleHeight，含奇偶校验）、像素布局（pointy/flat）双向转换与像素拾取、距离（网格步数与欧氏）、直线/环/螺旋/范围/旋转/镜像、主方向判定、HexBounds 边界判定与枚举；
- `path` 包——寻路：二叉堆 Dijkstra 代价泛洪（单源/多源、自定义步长代价、max_cost 截断）与 A* 最短路，路径可回溯至最近源；
- `fov` 包——视野：单向与对称两种直线视野模型，附带**形式化定义的可见性语义**（见下）；
- `hexmap` 包——地图存储：稀疏 `HexMap[T]` 与**密集 `DenseHexMap[T]`**（数组密集存储、cell↔index 双向索引映射），支持平行四边形、odd-r 矩形、六边形、三角形四种区域形状（闭合公式格数），含 ASCII 渲染。

**对称 FOV 的具体算法与可见性语义**（形式化定义，见 fov 包头文档与 docs/RULES_REFERENCES.md）：视线取 `Hex::line`（cube 插值取整）的直线格序列；单向可见性定义为"线段内部格（不含两端点）全部满足透明谓词"，由此得出：观察者自身透明性无影响、不透明目标本身可见但阻挡其后、相邻格恒可见；对称可见性在此之上要求双向视线均畅通（Bergström 式对称 shadowcasting 纪律在六角直线模型上的适配），其结果恒为单向结果的子集，并有 20 张确定性随机地图上的成对对称性、子集与镜像规则性质测试钉住。

通用性说明：网格几何与具体玩法解耦——本库不含任何回合、单位或胜负概念；通行判定、步长代价、透明度、渲染函数等语义全部由调用方以回调和泛型注入；不绑定 UI 框架或运行时，零第三方依赖（仅用 moonbitlang/core），wasm/wasm-gc/native 三后端零警告。与 Uber H3 等球面测地六角索引（地理编码领域）无关，本库专注平面游戏网格。

## 预期使用场景

1. **战棋/策略游戏的移动与索敌**：以每格地形代价与剩余移动力（max_cost）一次泛洪出可移动范围；多单位时用 `compute_multi` 得到"到最近单位的代价场"做 AI 索敌与威胁范围；`find_path` 规划绕障移动路径；UI 层用 `OffsetCoord` 或 `DenseHexMap` 的索引映射对接矩形数组存储。
2. **Roguelike 视野与光照**：玩家移动后调用 `compute_symmetric`，双向视线保证"我能看见你，你也能看见我"的对称可见性；墙体本身可见但阻挡其后方（端点豁免语义由形式化定义保证）；配合 `Hex::range`/`Hex::distance`/`euclidean_distance` 组装光照半径与衰减。
3. **六角地图编辑器与数据管道**：`Layout::axial_to_pixel` 按 pointy/flat 渲染网格，`Hex::from_pixel_round` 把鼠标点击像素精确拾取回格子；`DenseHexMap[T]`/`HexMap[T]` 读写格子数据并 ASCII 预览；`HexBounds` 做视口裁剪，doubled 坐标对接行主序存档格式。
4. **算法教学与可视化**：Dijkstra 波前扩张、六角旋转/镜像、直线生成均为纯函数、确定性输出，适合做交互式教学演示的计算核。

## 核心功能范围

- 坐标系统：axial/cube/offset×4/doubled×2 五套坐标互转（roundtrip 有全格测试钉住）、像素布局双向转换与拾取取整；
- 网格几何：六向邻接、网格距离、欧氏距离、直线、环、螺旋、填充范围、60° 旋转、镜像、主方向、HexBounds 边界；
- 寻路：单源/多源 Dijkstra 与 A*，自定义步长代价、通行判定、max_cost，路径回溯至最近源；
- 视野：单向 FOV 与对称 FOV（双向视线），形式化可见性语义 + 边界遮挡/透明度/对称性测试组；
- 存储与索引：四种区域形状（闭合公式格数）、稀疏 HexMap[T]、密集 DenseHexMap[T]（cell↔index 双向映射）、ASCII 渲染；
- 质量基建：66 个白盒测试（参考值断言、往返一致性、公理与性质测试、确定性随机地图穷举对称性，外加大规模参数压力组与退化输入保证：radius-100 枚举、百万级坐标、50 源泛洪、NaN/负/零步长代价快速失败）；CI 四 job：三后端 `moon check --deny-warn` + `moon build` + `moon test --deny-warn`、`moon fmt --check`、moonc ≥ 0.10.19 断言、独立消费者工程每次 push 验证可安装可用；
- 发布 mooncakes.io（wbgxiaosu/hexgrid，当前 0.3.1），README 示例覆盖坐标、寻路、视野、地图存储主线。

## 原创性说明

- 本项目性质：原创项目，全部代码从零编写，未移植、未复制任何现有实现；
- 参考资料：Red Blob Games《Hexagonal Grids》（免费公开网页，坐标/地图形状/直线算法思想）；对称视野参考 RogueBasin 公开的对称 shadowcasting 思想并适配到六角直线模型；doubled 坐标转换公式出自 Red Blob Games；rust `hexx`（MIT/Apache-2.0 双许可）仅用作功能范围参照清单，未读取、未复制、未移植其任何代码；出处、参考范围与许可逐条记录在 docs/RULES_REFERENCES.md；
- 查重说明：与 Uber H3（测地六角索引）领域不同、无代码关联；与生态内方格寻路库（moonpath、moonnavkit、moonbit-pathfinding）互补不重叠，对比结论存档于 README "Ecosystem positioning" 一节；
- 本项目许可证：Apache License 2.0；仓库含 19 个有效功能提交与全绿 CI，mooncakes 已发布 0.1.0–0.3.1 四个版本。
