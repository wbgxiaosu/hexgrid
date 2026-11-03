///|
/// A map region shape: which cells of the hex grid belong to the map.
///
/// All four shapes enumerate cells deterministically (sorted by
/// increasing `q`, then `r`) and have closed-form cell counts, which
/// the test suite pins against the formulas.
#derive(Eq, Debug)
pub enum Region {
  /// Parallelogram: `q` in `0..<w` and `r` in `0..<h`; exactly
  /// `w * h` cells.
  Parallelogram(Int32, Int32)
  /// Rectangle in odd-r offset space: column `0..<w`, row `0..<h`;
  /// exactly `w * h` cells. Rows of even length produce the classic
  /// staggered hex rectangle.
  Rectangle(Int32, Int32)
  /// Filled hexagon of radius `n` around the origin; exactly
  /// `3n^2 + 3n + 1` cells for `n >= 0`.
  Hexagon(Int32)
  /// Triangle with `n` cells on each side: `q >= 1`, `r >= 1` and
  /// `q + r <= n + 1`; exactly `n * (n + 1) / 2` cells for `n >= 1`.
  Triangle(Int32)
}

///|
pub extend Region with Eq::{equal, not_equal}

///|
pub extend Region with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// One sample region of every shape, in the order of the variants —
/// handy for tests and consumers that want to exercise all shapes.
pub let region_shapes : Array[Region] = [
  Parallelogram(3, 3),
  Rectangle(4, 3),
  Hexagon(2),
  Triangle(3),
]

///|
/// Enumerates every cell of `self`, sorted by increasing `q` then `r`.
pub fn Region::cells(self : Region) -> Array[@hex.Hex] {
  let acc : Array[@hex.Hex] = []
  match self {
    Parallelogram(w, h) =>
      for q in 0..<w {
        for r in 0..<h {
          acc.push(@hex.Hex::make(q, r))
        }
      }
    Rectangle(w, h) =>
      for row in 0..<h {
        for col in 0..<w {
          // odd-r: odd rows shifted right
          let q = col - (row - (row & 1)) / 2
          acc.push(@hex.Hex::make(q, row))
        }
      }
    Hexagon(n) =>
      for c in @hex.Hex::range(@hex.Hex::make(0, 0), n) {
        acc.push(c)
      }
    Triangle(n) =>
      for q in 1..<=n {
        for r in 1..<=(n + 1 - q) {
          acc.push(@hex.Hex::make(q, r))
        }
      }
  }
  // sort for a deterministic order regardless of enumeration order
  acc.sort_by(fn(a, b) { if a.q != b.q { a.q - b.q } else { a.r - b.r } })
  acc
}

///|
/// Number of cells in `self`, computed from the shape parameters in
/// closed form (matches `Region::cells(self).length()`).
pub fn Region::size(self : Region) -> Int32 {
  match self {
    Parallelogram(w, h) | Rectangle(w, h) => w * h
    Hexagon(n) => 3 * n * n + 3 * n + 1
    Triangle(n) => n * (n + 1) / 2
  }
}
