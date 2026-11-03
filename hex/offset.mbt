///|
/// Which offset layout to use when mapping between axial and
/// row/column coordinates. Four variants cover all conventions named
/// by Red Blob Games ("Offset coordinates").
#derive(Eq, Debug)
pub enum OffsetLayout {
  /// Odd rows shifted right ("odd-r", pointy-top).
  OddR
  /// Even rows shifted right ("even-r", pointy-top).
  EvenR
  /// Odd columns shifted down ("odd-q", flat-top).
  OddQ
  /// Even columns shifted down ("even-q", flat-top).
  EvenQ
}

///|
/// A cell addressed in offset coordinates: a plain `col`/`row` pair as
/// used by rectangular storage and most tile maps.
#derive(Eq, Debug)
pub struct OffsetCoord {
  col : Int32
  row : Int32
}

///|
/// Converts axial coordinates to offset coordinates under `layout`.
pub fn OffsetCoord::from_axial(hex : Hex, layout : OffsetLayout) -> OffsetCoord {
  let q = hex.q
  let r = hex.r
  match layout {
    OddR => {
      let col = q + (r - (r & 1)) / 2
      { col, row: r, }
    }
    EvenR => {
      let col = q + (r + (r & 1)) / 2
      { col, row: r, }
    }
    OddQ => {
      let row = r + (q - (q & 1)) / 2
      { col: q, row, }
    }
    EvenQ => {
      let row = r + (q + (q & 1)) / 2
      { col: q, row, }
    }
  }
}

///|
/// Converts offset coordinates back to axial coordinates under
/// `layout`. The pair must satisfy `col`/`row` >= 0 for the shift
/// arithmetic to match the standard definitions.
pub fn OffsetCoord::to_axial(self : OffsetCoord, layout : OffsetLayout) -> Hex {
  let col = self.col
  let row = self.row
  match layout {
    OddR => {
      let q = col - (row - (row & 1)) / 2
      { q, r: row, }
    }
    EvenR => {
      let q = col - (row + (row & 1)) / 2
      { q, r: row, }
    }
    OddQ => {
      let r = row - (col - (col & 1)) / 2
      { q: col, r, }
    }
    EvenQ => {
      let r = row - (col + (col & 1)) / 2
      { q: col, r, }
    }
  }
}

///|
pub extend OffsetCoord with Eq::{equal, not_equal}

///|
pub extend OffsetCoord with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// All four offset layouts, for exhaustive roundtrip testing.
pub let offset_layouts : Array[OffsetLayout] = [OddR, EvenR, OddQ, EvenQ]

///|
pub extend Hex with Eq::{equal, not_equal}

///|
pub extend OffsetLayout with Eq::{equal, not_equal}

///|
pub extend OffsetLayout with @moonbitlang/core/debug.Debug::{to_repr}
