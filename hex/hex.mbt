///|
/// A hexagonal grid cell in **axial coordinates** (q, r).
///
/// Axial coordinates are the canonical representation used throughout
/// hexgrid: every algorithm (distance, lines, rings, rotation, field of
/// view, pathfinding) operates on `Hex` values. The implicit third cube
/// coordinate is `s = -q - r`.
///
/// Conventions follow Red Blob Games, "Hexagonal Grids"
/// (<https://www.red-bean.com/robert/publications/hex-grids/>), whose
/// treatment of axial/cube/offset systems is the de-facto industry
/// reference. See docs/RULES_REFERENCES.md for details.
pub struct Hex {
  q : Int32
  r : Int32
} derive(Eq, Debug, Hash)

///|
pub extend Hex with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Hex with Hash::{hash, hash_combine}

///|
/// Constructs a cell in axial coordinates. Hexagons are plain
/// immutable values; this is the public constructor.
pub fn Hex::make(q : Int32, r : Int32) -> Hex {
  { q, r, }
}

///|
/// The third cube coordinate, derived from axial coordinates.
pub fn Hex::s(self : Hex) -> Int32 {
  -self.q - self.r
}

///|
/// Formats the cell as `q;r` (the compact label used by many hex tools).
pub fn Hex::label(self : Hex) -> String {
  "\{self.q};\{self.r}"
}

///|
/// Vector addition.
pub fn Hex::op_add(self : Hex, other : Hex) -> Hex {
  { q: self.q + other.q, r: self.r + other.r, }
}

///|
/// Vector subtraction.
pub fn Hex::op_sub(self : Hex, other : Hex) -> Hex {
  { q: self.q - other.q, r: self.r - other.r, }
}

///|
/// Scalar multiplication.
pub fn Hex::op_mul(self : Hex, k : Int32) -> Hex {
  { q: self.q * k, r: self.r * k, }
}

///|
/// The six axial direction vectors, ordered counter-clockwise starting
/// from east: E, NE, NW, W, SW, SE (pointy-top orientation).
pub let directions : Array[Hex] = [
  { q: 1, r: 0, },
  { q: 1, r: -1, },
  { q: 0, r: -1, },
  { q: -1, r: 0, },
  { q: -1, r: 1, },
  { q: 0, r: 1, },
]

///|
/// The neighbour of `self` in the given `direction` (0..=5, see
/// `directions`). Direction indices wrap around modulo 6.
pub fn Hex::neighbor(self : Hex, direction : Int32) -> Hex {
  let d = directions[(direction % 6 + 6) % 6]
  self.op_add(d)
}

///|
/// All six neighbours of `self`, in the same order as `directions`
/// (counter-clockwise starting from east).
pub fn Hex::neighbors(self : Hex) -> Array[Hex] {
  let out = []
  for i in 0..<6 {
    out.push(self.neighbor(i))
  }
  out
}

///|
/// Manhattan-style hex distance: the minimum number of steps between
/// two cells on the grid.
pub fn Hex::distance(self : Hex, other : Hex) -> Int32 {
  let d = self.op_sub(other)
  let dq = if d.q < 0 { -d.q } else { d.q }
  let dr = if d.r < 0 { -d.r } else { d.r }
  let ds = if d.s() < 0 { -d.s() } else { d.s() }
  (dq + dr + ds) / 2
}

///|
/// All cells exactly `radius` steps from `center`. Radius 0 yields the
/// centre itself; negative radii yield an empty array.
pub fn Hex::ring(center : Hex, radius : Int32) -> Array[Hex] {
  let acc : Array[Hex] = []
  if radius <= 0 {
    if radius == 0 {
      acc.push(center)
    }
    return acc
  }
  let mut cell = center.op_add(directions[4].op_mul(radius))
  for d in 0..<6 {
    for _ in 0..<radius {
      acc.push(cell)
      cell = cell.neighbor(d)
    }
  }
  acc
}

///|
/// All cells within `radius` steps of `center` (a filled hexagonal
/// area), ordered by increasing `q`. Contains exactly `3r^2+3r+1`
/// cells when `radius >= 0`.
pub fn Hex::range(center : Hex, radius : Int32) -> Array[Hex] {
  let acc : Array[Hex] = []
  if radius < 0 {
    return acc
  }
  for dq in -radius..<=radius {
    let lo = if -radius > -dq - radius { -radius } else { -dq - radius }
    let hi = if radius < -dq + radius { radius } else { -dq + radius }
    for dr in lo..<=hi {
      acc.push({ q: center.q + dq, r: center.r + dr, })
    }
  }
  acc
}

///|
/// The concentric rings around `center` from `min_radius` up to and
/// including `max_radius`.
pub fn Hex::spiral(
  center : Hex,
  min_radius : Int32,
  max_radius : Int32,
) -> Array[Hex] {
  let acc : Array[Hex] = []
  for radius in min_radius..<=max_radius {
    for cell in Hex::ring(center, radius) {
      acc.push(cell)
    }
  }
  acc
}

///|
/// The straight grid line from `self` to `target`, inclusive of both
/// endpoints, computed with floating-point linear interpolation and
/// cube rounding (Red Blob Games, "Line drawing").
pub fn Hex::line(self : Hex, target : Hex) -> Array[Hex] {
  let n = self.distance(target)
  if n == 0 {
    return [self]
  }
  let acc : Array[Hex] = []
  for i in 0..<=n {
    let t = i.to_double() / n.to_double()
    acc.push(Hex::cube_round(self.lerp(target, t)))
  }
  acc
}

///|
/// Component-wise linear interpolation towards `other` by factor `t`.
pub fn Hex::lerp(
  self : Hex,
  other : Hex,
  t : Double,
) -> (Double, Double, Double) {
  let a = self.q.to_double() + (other.q - self.q).to_double() * t
  let b = self.r.to_double() + (other.r - self.r).to_double() * t
  (a, b, -a - b)
}

///|
/// Rounds fractional cube coordinates to the nearest cell. Ties are
/// broken by repairing the component with the largest rounding error,
/// exactly as prescribed by Red Blob Games.
pub fn Hex::cube_round(frac : (Double, Double, Double)) -> Hex {
  let (fx, fy, fz) = frac
  let mut rx = fx.round()
  let mut ry = fy.round()
  let mut rz = fz.round()
  let dx = (rx - fx).abs()
  let dy = (ry - fy).abs()
  let dz = (rz - fz).abs()
  if dx > dy && dx > dz {
    rx = -ry - rz
  } else if dy > dz {
    ry = -rx - rz
  } else {
    rz = -rx - ry
  }
  { q: rx.to_int(), r: ry.to_int(), }
}

///|
/// Rotates `self` around the origin by `steps` sixtieths of a full
/// turn (each step is 60°, counter-clockwise). Negative steps rotate
/// clockwise.
pub fn Hex::rotate(self : Hex, steps : Int32) -> Hex {
  let k = (steps % 6 + 6) % 6
  let mut q = self.q
  let mut r = self.r
  for _ in 0..<k {
    let nq = -r
    let nr = q + r
    q = nq
    r = nr
  }
  { q, r, }
}

///|
/// Reflects `self` across the axis that passes through direction 0
/// (the E–W axis for pointy-top orientation).
pub fn Hex::reflect(self : Hex) -> Hex {
  { q: -self.r, r: -self.q, }
}

///|
/// Rounds fractional axial coordinates (already divided through a
/// layout) to the nearest cell, via cube rounding.
pub fn Hex::from_pixel_round(x : Double, y : Double, layout : Layout) -> Hex {
  let (q, r) = layout.pixel_to_axial(x, y)
  Hex::cube_round((q, r, -q - r))
}
