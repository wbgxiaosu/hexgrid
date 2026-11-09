# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.3.0] - 2026-11-09

### Added

- `hex` package: doubled-coordinate conversions (`Doubled`, double-
  width and double-height modes with parity validation),
  `Hex::euclidean_distance`, `Hex::main_direction_to`, and
  `HexBounds` (containment, closed-form cell count, spiral
  enumeration). Functional scope benchmarked against the rust
  `hexx` crate (feature map only, no code reused).
- `hexmap` package: `DenseHexMap[T]` — dense array-backed region
  storage with a bidirectional cell-to-index mapping (`index_of`,
  `cell_at`), O(1) indexed access and ordered iteration.
- `fov` package: formal package-level visibility semantics (one-way
  interior-transparency rule with endpoint exemptions; symmetric
  bidirectional rule) and a boundary test suite: radius 0/1 and
  open-field counts, opaque-world adjacency, wall/edge blocking,
  interior-vs-target transparency, and 20 deterministic random wall
  maps with pairwise-symmetry, subset and mirror-rule properties.

## [0.2.0] - 2026-11-03

### Added

- `hexmap` package: region-shaped map storage — `Region` shapes
  (parallelogram, odd-r rectangle, filled hexagon, triangle) with
  closed-form cell counts and deterministic cell enumeration, and a
  generic sparse `HexMap[T]` (`make`, `make_empty`, `get`, `get_or`,
  `set`, `remove`, `contains`, `in_region`, `occupied`, `values`).
- `fov::visible` and `fov::compute_symmetric`: symmetric
  line-of-sight FOV — a cell is visible only when the line of sight is
  clear in both directions (always a subset of `compute`).
- `Reachability::compute_multi`: multi-source Dijkstra flood; each
  reached cell records the cheapest cost over all sources with
  back-pointers towards the nearest source. The single-source
  `compute` now delegates to it (`Reachability.sources` replaces the
  former `source` field).
- Independent consumer example exercises the three new APIs.

### Documentation

- README feature table and roadmap updated; provenance for the
  symmetric FOV, multi-source Dijkstra and region-shaped maps added to
  `docs/RULES_REFERENCES.md`; acceptance evidence map added in
  `ACCEPTANCE.md`.

## [0.1.2] - 2026-11-03

### Changed

- Migrated all `derive(...)` clauses to the new `#derive(...)`
  attribute syntax (moonc >= 0.10.19), as required by the latest
  MoonBit toolchain where the trailing form is deprecated. The CI
  toolchain assertion now enforces moonc >= 0.10.19 accordingly.

## [0.1.1] - 2026-11-03

### Added

- `Hex::neighbors(self) -> Array[Hex]`: all six neighbours of a cell,
  in the same counter-clockwise order as `directions`, with tests
  covering the distance-1 / distinctness / direction-order invariants.

### Documentation

- README: new "Ecosystem positioning" section recording the November
  2026 mooncakes.io survey that confirms the flat hexagonal-grid niche
  is unoccupied, and the boundary with adjacent square-grid
  pathfinding, terrain-generation and map-codec libraries.

## [0.1.0] - 2026-11-02

### Added

- Initial release: axial/cube/offset coordinate systems, distance,
  lines, rings, spirals, range, rotation, reflection, pixel rounding;
  Dijkstra reachability maps and A* pathfinding; line-based
  field-of-view; pointy/flat pixel layouts; independent consumer
  example verified in CI on wasm, wasm-gc and native backends.
