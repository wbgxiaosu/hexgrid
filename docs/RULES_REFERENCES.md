# Rules, Algorithms and Reference Provenance

hexgrid is an original MoonBit codebase. Every algorithm is implemented
from the published descriptions below; no third-party source code is
copied or translated. Each reference names its concrete source, scope
and licence.

## Coordinate systems and grid algorithms

- **Axial / cube / offset coordinate systems, distance, lines, rings,
  spirals, rounding, rotation, pixel (layout) conversion** — Red Blob
  Games, *"Hexagonal Grids"* by Robert W. Hearn (published at
  <https://www.red-bean.com/robert/publications/hex-grids/>), the
  de-facto industry reference for hexagonal grid mathematics.
  Referenced scope: the coordinate-system definitions, the cube
  distance formula `(|dq|+|dr|+|ds|)/2`, lerp + cube rounding for line
  drawing, the ring/spiral walks, the four offset-layout conversion
  formulas and the pointy/flat layout matrices. The site text is
  freely readable; hexgrid implements the mathematics as original
  MoonBit code.

- **Field of view** — line-of-sight semantics: a cell is visible when
  the straight grid line from the viewer to it passes only through
  transparent cells, with viewer and target exempt (walls are visible
  but block). This "line-of-sight through every candidate" approach is
  the standard baseline described in the roguelike development
  community, e.g. RogueBasin, *"Field of View"*,
  <https://www.roguebasin.com/index.php/Field_of_View>. The
  implementation composes hexgrid's own `Hex::line`; no external code
  is used.

- **Dijkstra flood and A\*** — the classical algorithms as presented
  in Amit Patel, *"Introduction to A\*"*
  (<https://theory.stanford.edu/~amitp/GameProgramming/>, same author
  as Red Blob Games) and the open textbook *Dijsktra/A\** chapters of
  <https://www.redblobgames.com/pathfinding/a-star/introduction.html>.
  Referenced scope: frontier priority queue, g-score bookkeeping and
  back-pointer path reconstruction. The binary heap is written from
  scratch in MoonBit.

## Dependency licences

hexgrid currently has **zero third-party package dependencies** — only
`moonbitlang/core` (the standard library, Apache-2.0, used unmodified)
is required.

## What hexgrid is not

- hexgrid is not related to Uber's H3 geospatial hexagonal indexing
  (geodesic icosahedron grids); it addresses flat 2D game grids.
- hexgrid is not a game, a renderer or a map editor; it is the
  reusable geometric foundation those tools build on.
