# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and the project adheres to [Semantic Versioning](https://semver.org/).

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
