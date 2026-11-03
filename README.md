# hexgrid

**Reusable hexagonal-grid geometry infrastructure for MoonBit** — not a
game, not a demo. hexgrid provides the coordinate systems, grid
mathematics and search algorithms that strategy games, wargames,
roguelikes and map tools build on, behind pure, deterministic,
dependency-free APIs.

## Game coverage

| Area | Capabilities |
|---|---|
| Coordinate systems | axial `Hex`, cube coordinates, `OddR`/`EvenR`/`OddQ`/`EvenQ` offset layouts, round-trip conversion |
| Grid mathematics | hex distance, 6-direction neighbours, straight lines (lerp + cube rounding), rings, spirals, filled ranges, 60° rotation, reflection |
| Pixel layouts | pointy-top and flat-top layouts, pixel ↔ axial conversion, bounds-driven sizing |
| Pathfinding | Dijkstra cost flood with custom step costs and `max_cost` bounds, A* with admissible heuristics, path reconstruction |
| Field of view | line-of-sight FOV with transparency callbacks, wall-blocking semantics |

## Shared design principles

- **Pure and deterministic** — every function is a mathematical
  operation on the grid: no I/O, no global state, no randomness. The
  same inputs always produce the same outputs on every backend.
- **Zero dependencies** — only `moonbitlang/core`; the binary heap and
  all algorithms are implemented from scratch.
- **Caller-owned semantics** — passability, terrain costs and
  transparency are caller-supplied functions; hexgrid imposes no game
  rules.

## Installation

Requires the MoonBit toolchain (moonc ≥ 0.10.19). Install the library
from [mooncakes.io](https://mooncakes.io/docs/#/wbgxiaosu/hexgrid):

```bash
moon add wbgxiaosu/hexgrid
```

then declare the packages you need in the consuming package's
`moon.pkg`:

```
import {
  "wbgxiaosu/hexgrid/hex",
  "wbgxiaosu/hexgrid/path",
  "wbgxiaosu/hexgrid/fov",
}
```

(this import configuration is verified by the consumer example below).

## Usage

```mbt
///|
fn main raise {
  let start = @hex.Hex::make(0, 0)
  let goal = @hex.Hex::make(4, -2)
  // straight-line geometry
  println("distance: \{start.distance(goal)}") // 4
  // pathfinding around a wall on column q = 1
  fn passable(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r != -1)
  }
  match @path.find_path(start, goal, passable, fn(_f, _t) { 1.0 }) {
    Some(steps) => println("detour: \{steps.length() - 1} steps") // 4
    None => println("unreachable")
  }
}
```

Running the full demo:

```console
$ moon run cmd/main
distance 0;0 -> 4;-2 = 4
line 0;0 -> 4;-2: 0;0 1;0 2;-1 3;-1 4;-2
range 2 has 19 cells; ring 2 has 12
A* path (4 steps, detouring the wall): 0;0 -> 1;-1 -> 2;-1 -> 3;-1 -> 4;-2
visible cells (16): -2;0, -2;1, -2;2, -1;-1, -1;0, -1;1, -1;2, 0;-2, 0;-1, 0;0, 0;1, 0;2, 1;-2, 1;-1, 1;0, 2;-2
```

## Independent consumer example

[examples/consumer](examples/consumer) is a separate module importing
the published package name exactly the way an external user would;
`moon.work` redirects the dependency to the local source tree, so CI
runs it on every push to continuously prove the library is consumable
from outside:

```console
$ cd examples/consumer && moon run .
consumer A* steps: 4
consumer fov cells: 19
consumer example OK
```

## Building and testing

```bash
moon check --deny-warn
moon test --deny-warn
moon run cmd/main
cd examples/consumer && moon run .
```

CI runs `moon check --deny-warn` and `moon test --deny-warn` on the
wasm, wasm-gc and native backends, asserts moonc ≥ 0.10.19, checks
formatting with `moon fmt --check`, and executes the consumer example
on every push.

## Scope statement

hexgrid is an original MoonBit codebase. The coordinate mathematics
and algorithms follow the published, freely readable treatments of Red
Blob Games ("Hexagonal Grids") and the classical Dijkstra/A*
literature; every line is implemented from those descriptions, not
copied. The exact sources and scopes are recorded in
[docs/RULES_REFERENCES.md](docs/RULES_REFERENCES.md). hexgrid is
unrelated to Uber's H3 geodesic hexagonal indexing.

## Ecosystem positioning

A survey of mooncakes.io (November 2026) shows hexgrid occupies an
unoccupied niche: **flat hexagonal-grid geometry**. Adjacent libraries
do not overlap:

- Square-grid / general-graph pathfinding toolkits (e.g. `moonpath`,
  `moonnavkit`, `moonbit-pathfinding`) operate on 2D grids or abstract
  graphs; none provide axial/cube coordinates, ring/spiral generation,
  hex rotations or hex-specific line-of-sight.
- Procedural content generators (e.g. `terrain`) produce maps but
  define no grid topology.
- Tiled-map codecs (e.g. `moonbit-pixelkit`) parse map files without
  hex geometry math.

hexgrid composes naturally with such libraries: its `Hex` values can
feed any pathfinding or map-representation layer, while the six-way
topology, offset-layout conversions and FOV live only here.

## Roadmap

- hex-map storage container with rectangle/hexagon/parallelogram
  region shapes;
- symmetric shadowcasting FOV as an alternative to the line-based
  model;
- Dijkstra maps with multiple sources and falloff functions.

## Acceptance

The acceptance criteria are mapped to concrete, verifiable evidence in
[ACCEPTANCE.md](ACCEPTANCE.md). AI-assisted development and the
participant's ownership of goals, technical path and quality boundaries
are documented in [docs/AI_COLLABORATION.md](docs/AI_COLLABORATION.md).

## License

Apache-2.0 — see [LICENSE](LICENSE).
