# hexgrid 申报书（2026 MoonBit 黑客松 · 十一月赛）

- 项目名称：hexgrid —— MoonBit 六角格网格几何基础库
- GitHub 仓库链接：https://github.com/wbgxiaosu/hexgrid
- 参赛者：wbgxiaosu（个人参赛）
- 主要实现语言：MoonBit（100%，零第三方包依赖，仅用 moonbitlang/core 标准库）

## 1. 一句话目标

为 MoonBit 生态补齐六角格网格这一游戏与空间计算的基础设施：提供轴向/立方/偏移三套坐标系统、网格几何运算、A* 寻路与视野判定，全部为纯函数、确定性、零依赖 API——它不是游戏或演示，而是策略游戏、战棋、Roguelike 与地图工具可以直接依赖的地基。

## 2. 已有基础与本期新增

本项目为十一月球赛季全新立项，全部开发在本赛期内完成：

- 新建仓库、CI（三后端 + moonc ≥ 0.10.19 断言 + fmt 门禁 + 独立消费者验证）与全套文档；
- `hex` 包：axial/cube/offset 坐标互转、距离、直线（lerp+立方取整）、环、螺旋、填充范围、60° 旋转、镜像、像素布局（pointy/flat）双向转换；
- `path` 包：自研二叉堆 + Dijkstra 代价泛洪（自定义地形代价与 max_cost 截断）+ A* 寻路与路径回溯；
- `fov` 包：视线遮挡语义的六角格视野判定；
- 发布 mooncakes.io（wbgxiaosu/hexgrid）。

## 3. 技术路径与选题依据

- **查重**：立项前对 mooncakes 全库 11 批 100+ 关键词逐一查重（regex/lunar/toml/YAML/SVG/字体/tokenizer 等全被占用），确认"平面六角格网格几何"为真实空白（Uber H3 是地理测地网格，属不同领域，README 中已显式区分）。
- **权威参考**：坐标系与算法严格对照 Red Blob Games《Hexagonal Grids》（业界事实标准）与经典 Dijkstra/A* 文献，参考来源、范围与许可逐条记录在 docs/RULES_REFERENCES.md，无任何代码复制。
- **架构**：三个单一职责包（hex/path/fov），纯函数、调用方注入通行性/代价/透明度语义，库不夹带游戏规则。

## 4. 预期功能与完成度

见 README 功能表：三套坐标系统互转、九类网格几何运算、两种像素布局、Dijkstra/A* 寻路、视线 FOV。M0 目标（本期承诺）全部为可用代码并有测试钉住；扩展项（地图容器、对称 shadowcasting、多源 Dijkstra）列入 Roadmap 不作为本期承诺。

## 5. 测试与质量基建

- 21 个白盒测试覆盖核心路径：参考值断言（Red Blob Games 案例）、往返一致性（offset 四布局 × 全格、像素双向全格）、公理式性质（距离对称性、相邻性、路径合法性）与经典局面（绕墙、封死、变代价地形）；
- CI 四 job：wasm/wasm-gc/native 三后端 `moon check --deny-warn` + `moon build` + `moon test --deny-warn`，`moon fmt --check` 格式门禁，moonc ≥ 0.10.19 硬断言，外加独立消费者工程（examples/consumer）每次 push 验证"可安装可用"。

## 6. 开源合规

Apache-2.0（LICENSE 附仓库根目录）。零第三方包依赖；参考的 Red Blob Games / RogueBasin 为免费公开资料，仅参考数学定义、未复制代码或文本，出处与参考范围在 docs/RULES_REFERENCES.md 逐条可查。

## 7. AI 辅助说明

AI 辅助代码实现与文档草拟；项目选题与查重结论、坐标系与算法取舍、质量门禁定义、参考来源核验与开源合规由参赛者确定和把控，详见 docs/AI_COLLABORATION.md。
