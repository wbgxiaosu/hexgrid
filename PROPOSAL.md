# hexgrid 项目申报书

## 基本信息

- 项目名称：hexgrid：MoonBit 六角格网格几何基础库
- 参赛者：苏春昊
- 联系方式：1684128842@qq.com
- GitHub 仓库链接：https://github.com/wbgxiaosu/hexgrid
- 项目方向：MoonBit 游戏与空间计算领域基础库 / 空间基础设施
- 是否为移植项目：否，原创项目（参考公开技术资料，详见文末说明）

## 项目简介（项目方向与通用性说明）

hexgrid 为 MoonBit 生态补齐**平面六角格网格**这一游戏与空间计算的基础设施，为战棋/SLG、Roguelike、六角地图编辑器、可视化分析工具提供可复用的坐标系统、寻路与视野判定引擎。它不是游戏或演示，而是可直接依赖的库：`hex` 包提供轴向/立方/偏移三套坐标系统与网格几何运算，`path` 包提供 Dijkstra 代价泛洪与 A* 寻路，`fov` 包提供视线遮挡语义的六角格视野判定。通用性体现在三处：坐标系统与算法对一切六角拓扑应用通用，不预设任何具体游戏；通行性、步代价、透明度等语义全部由调用方注入，库不夹带游戏规则；不绑定 UI 框架、运行时或网络栈，零第三方依赖（仅用 moonbitlang/core），wasm / wasm-gc / native 三后端零警告。面向需要在 MoonBit 中构建六角网格应用的库作者、工具开发者和应用开发者。

## 预期使用场景

**场景一：战棋/SLG 的移动范围与索敌。** 回合制战棋中，用 `Reachability::compute` 以每格地形代价（森林 2、山地 3）与剩余移动力（max_cost）一次泛洪出单位的可移动范围及最廉到达代价；用 `find_path` 计算向敌单位移动的路径；用 `Hex::neighbors` 判定近战攻击范围；UI 层用 `OffsetCoord` 将六角格映射到矩形数组存储。

**场景二：Roguelike 的视野与光照系统。** 玩家移动后调用 `fov::compute`，以透明度谓词（墙、门由调用方定义）判定可见格：直线穿过透明格可见，墙体本身可见但阻挡其后；配合 `Hex::range` 做光照半径、`Hex::distance` 做光照衰减，组装完整的地牢视野方案，无需引入游戏引擎。

**场景三：六角地图编辑器与地图数据管道。** 编辑器用 `Layout::axial_to_pixel` 按 pointy/flat 两种布局渲染网格，用 `Hex::from_pixel_round` 把鼠标点击像素精确拾取回格子；地图存档用 `OffsetCoord` 四种布局（OddR/EvenR/OddQ/EvenQ）与 Tiled 等矩形行存储格式互转，roundtrip 安全有全格测试钉住。

**场景四：空间算法教学与可视化。** Dijkstra 泛洪、六角旋转/镜像、直线生成均为纯函数、确定性输出，适合作为算法教学动画与交互式演示的计算核；距离公理、往返一致性等性质测试可直接作为教学内容引用。

## 拟实现的核心功能

- 坐标系统：axial/cube 互转（含隐式第三坐标 s）、offset 四布局（OddR/EvenR/OddQ/EvenQ）双向转换，roundtrip 安全；
- 网格几何：六向邻接（directions/neighbor/neighbors）、六角距离、直线（lerp + 立方取整）、环、螺旋、填充范围、60° 旋转、镜像；
- 像素层：pointy/flat 两种布局的 axial↔pixel 双向转换与像素拾取取整；
- 寻路：二叉堆 + Dijkstra 代价泛洪（自定义步代价、max_cost 截断、cost_to/path_to/reached 查询）+ A* 最短路；
- 视野：直线视线遮挡语义的六角格 FOV（墙可见、墙后不可见）；
- 质量基建：白盒测试覆盖参考值断言、四布局×全格往返一致性、距离/相邻性公理与经典局面；CI 四 job：三后端 `moon check --deny-warn` + `moon build` + `moon test --deny-warn`、`moon fmt --check`、moonc ≥ 0.10.19 断言、独立消费者工程每次 push 验证可安装可用；
- 发布 mooncakes.io（wbgxiaosu/hexgrid），提供 README 使用示例覆盖坐标、寻路、视野三条主线。

## 原创性说明（参考已有公开资料）

- 本项目性质：原创项目，全部代码从零编写，未移植、未复制任何现有实现；
- 参考资料：Red Blob Games《Hexagonal Grids》（https://www.redblobgames.com/grids/hexagons/ ，免费公开的业界事实标准）；Dijkstra / A* 经典算法文献；出处、参考范围与许可逐条记录在 docs/RULES_REFERENCES.md；
- 与 Uber H3（地理测地六角索引）领域不同、无代码关联；与生态内方格寻路库（moonpath、moonnavkit、moonbit-pathfinding）互补不重叠，查重对比结论存档于 README "Ecosystem positioning" 一节；
- 本项目许可证：Apache License 2.0。
