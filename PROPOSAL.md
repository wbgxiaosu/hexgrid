# hexgrid 项目申报书

## 基本信息

- 项目名称：hexgrid：MoonBit 六角格网格几何基础库
- 参赛者：苏春昊（wbgxiaosu）
- 联系方式：1684128842@qq.com
- GitHub 仓库链接：https://github.com/wbgxiaosu/hexgrid
- 项目方向：MoonBit 游戏工具基建 / 网格几何基础库
- 是否为移植项目：否（原创项目，参考公开技术资料，见文末说明）

## 项目简介

hexgrid 为 MoonBit 生态补齐平面六角格网格这一通用基础设施，为战棋/SLG、Roguelike、六角地图编辑器、算法可视化等场景的库作者与应用开发者提供可复用的坐标系统、寻路、视野与地图存储引擎。项目提供四个独立成包的层次：`hex` 包提供轴向/立方/偏移三套坐标系统与网格几何运算，`path` 包提供 Dijkstra 代价泛洪（单源/多源）与 A* 寻路，`fov` 包提供单向与对称两种直线视野模型，`hexmap` 包提供区域形状地图容器。

通用性说明：六角格是与方格并列的经典网格范式，网格几何本身与具体玩法解耦——本库不含任何回合、单位或胜负概念；通行判定、步长代价、透明度、渲染函数等语义全部由调用方以回调和泛型注入；不绑定 UI 框架或运行时，零第三方依赖（仅用 moonbitlang/core），wasm/wasm-gc/native 三后端零警告。与 Uber H3 等球面测地六角索引（地理编码领域）无关，本库专注平面游戏网格。

## 预期使用场景

1. **战棋/策略游戏的移动与索敌**：以每格地形代价与剩余移动力（max_cost）一次泛洪出可移动范围；多单位时用 `compute_multi` 得到"到最近单位的代价场"做 AI 索敌与威胁范围；`find_path` 规划绕障移动路径；UI 层用 `OffsetCoord` 映射到矩形数组存储。
2. **Roguelike 视野与光照**：玩家移动后调用 `compute_symmetric`，双向视线保证"我能看见你，你也能看见我"的对称可见性，消除单向视野的穿帮；墙体本身可见但阻挡其后方；配合 `Hex::range`/`Hex::distance` 组装光照半径与衰减。
3. **六角地图编辑器与数据管道**：`Layout::axial_to_pixel` 按 pointy/flat 渲染网格，`Hex::from_pixel_round` 把鼠标点击像素精确拾取回格子；`HexMap[T]` 读写格子数据并 ASCII 预览；`OffsetCoord` 四种布局与矩形行存储格式安全互转（roundtrip 有全格测试钉住）。
4. **算法教学与可视化**：Dijkstra 波前扩张、六角旋转/镜像、直线生成均为纯函数、确定性输出，适合做交互式教学演示的计算核。

## 核心功能范围

- 提供 axial 立方坐标系：距离、直线绘制、环、螺旋、填充范围、六方向、60° 旋转、镜像与 cube 互转；
- 提供 offset 坐标四种布局（OddR/EvenR/OddQ/EvenQ）与像素布局（pointy/flat）双向转换及像素拾取取整；
- 提供 A* 寻路与 Dijkstra 代价泛洪（单源/多源），支持自定义步长代价、通行判定与 max_cost，路径可回溯至最近源；
- 提供单向与对称（双向视线）两种视野模型，支持透明度回调与墙体遮挡语义；
- 提供 hexmap 包：平行四边形、odd-r 矩形、六边形、三角形四种区域形状（闭合公式格数）与泛型稀疏 HexMap[T] 容器，含 ASCII 渲染；
- 提供 ≥40 个白盒测试，覆盖几何不变量（往返一致性、距离公理、对称性、多源-单源等价）等性质；
- 提供独立消费者示例工程与可运行演示程序，CI 对三后端执行 --deny-warn 硬门禁并发布 mooncakes.io（当前 0.2.0）。

## 原创性说明

- 本项目性质：原创项目，全部代码从零编写，未移植、未复制任何现有实现；
- 参考资料：Red Blob Games《Hexagonal Grids》（免费公开网页，仅参考公开算法思想）；对称视野参考 RogueBasin 公开的对称 shadowcasting 思想并适配到六角直线模型；Dijkstra/A* 为经典算法文献；出处、参考范围与许可逐条记录在 docs/RULES_REFERENCES.md；
- 查重说明：与 Uber H3（测地六角索引）领域不同、无代码关联；与生态内方格寻路库（moonpath、moonnavkit、moonbit-pathfinding）互补不重叠，对比结论存档于 README "Ecosystem positioning" 一节；
- 本项目许可证：Apache License 2.0；仓库含 12 个有效功能提交与全绿 CI。
