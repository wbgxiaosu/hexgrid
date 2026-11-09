///|
/// A hexagonal grid cell in **doubled coordinates** (col, row).
///
/// Doubled coordinates store one axis doubled so that every neighbour
/// differs by an even step, which makes row-major storage layouts
/// (arrays of arrays with gaps) trivially correct. See Red Blob Games,
/// "Hexagonal Grids" (doubled coordinates section) for the full
/// treatment; conversions are exact integer arithmetic for coordinates
/// of matching parity.
#derive(Eq, Debug)
pub struct Doubled {
  col : Int32
  row : Int32
}

///|
pub extend Doubled with Eq::{equal, not_equal}

///|
pub extend Doubled with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// The two doubled-coordinate conventions.
#derive(Eq, Debug)
pub enum DoubledMode {
  /// Doubled width: `col = 2q + r`, `row = r` (columns step by 2).
  DoubleWidth
  /// Doubled height: `col = q`, `row = q + 2r` (rows step by 2).
  DoubleHeight
}

///|
pub extend DoubledMode with Eq::{equal, not_equal}

///|
pub extend DoubledMode with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Every doubled-coordinate convention, for exhaustive tests.
pub let doubled_modes : Array[DoubledMode] = [DoubleWidth, DoubleHeight]

///|
/// Public constructor for a doubled coordinate.
pub fn Doubled::make(col : Int32, row : Int32) -> Doubled {
  { col, row, }
}

///|
/// Converts axial coordinates to doubled coordinates under `mode`.
pub fn Hex::to_doubled(self : Hex, mode : DoubledMode) -> Doubled {
  match mode {
    DoubleWidth => Doubled::make(2 * self.q + self.r, self.r)
    DoubleHeight => Doubled::make(self.q, self.q + 2 * self.r)
  }
}

///|
/// Converts doubled coordinates back to axial coordinates under
/// `mode`. The caller must guarantee the doubled coordinate has the
/// parity required by `mode` (col and row of the same parity for
/// `DoubleWidth`); conversions of valid coordinates are exact.
pub fn Doubled::to_hex(self : Doubled, mode : DoubledMode) -> Hex raise {
  match mode {
    DoubleWidth => {
      if (self.col - self.row) % 2 != 0 {
        fail(
          "doubled-width coordinates must have col and row of the same parity",
        )
      }
      Hex::make((self.col - self.row) / 2, self.row)
    }
    DoubleHeight => {
      if (self.row - self.col) % 2 != 0 {
        fail(
          "doubled-height coordinates must have col and row of the same parity",
        )
      }
      Hex::make(self.col, (self.row - self.col) / 2)
    }
  }
}

///|
/// The **euclidean distance** between two cells, in units of the hex
/// edge length, using the pointy-top pixel mapping (any rotation gives
/// the same norm). This is the straight-line distance between cell
/// centres — distinct from `Hex::distance`, which counts grid steps.
pub fn Hex::euclidean_distance(self : Hex, other : Hex) -> Double {
  let dq = (self.q - other.q).to_double()
  let dr = (self.r - other.r).to_double()
  let dx = 1.7320508075688772 * dq + 0.8660254037844386 * dr
  let dy = 1.5 * dr
  (dx * dx + dy * dy).sqrt()
}

///|
/// The index of the neighbour direction (0..5, matching
/// `Hex::directions`) that most reduces the grid distance to `target`.
/// Ties pick the smallest index, making the result deterministic.
pub fn Hex::main_direction_to(self : Hex, target : Hex) -> Int32 {
  let mut best = 0
  let mut best_dist = self.distance(target)
  for d in 0..<6 {
    let dist = self.neighbor(d).distance(target)
    if dist < best_dist {
      best = d
      best_dist = dist
    }
  }
  best
}
