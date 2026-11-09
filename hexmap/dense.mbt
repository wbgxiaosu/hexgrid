///|
/// **Dense** region-shaped storage for per-cell values.
///
/// Where `HexMap[T]` is sparse (a hash map holding only written cells),
/// `DenseHexMap[T]` pre-allocates one slot per cell of its region in
/// deterministic enumeration order and keeps a bidirectional
/// cell-to-index mapping, giving O(1) indexed access with no hashing
/// on the hot path. This mirrors the "dense storage" collections of
/// mature hex libraries (e.g. rust `hexx`'s `HexagonalMap`).
#derive(Debug)
pub struct DenseHexMap[T] {
  region : Region
  /// Index-to-cell table: `cells[i]` is the cell of slot `i`, in
  /// region enumeration order.
  cells : Array[@hex.Hex]
  /// Cell-to-index table: `index[cell]` is the slot of `cell`.
  index : Map[@hex.Hex, Int32]
  /// Dense slot storage, same length as `cells`.
  data : Array[T]
  default : T
}

///|
pub extend DenseHexMap with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Creates a dense map over `region`, filling every slot with
/// `default`.
pub fn[T] DenseHexMap::make(region : Region, default : T) -> DenseHexMap[T] {
  let cells : Array[@hex.Hex] = []
  let index : Map[@hex.Hex, Int32] = Map([])
  for c in region.cells() {
    index[c] = cells.length()
    cells.push(c)
  }
  let data : Array[T] = []
  for _ in 0..<cells.length() {
    data.push(default)
  }
  { region, cells, index, data, default, }
}

///|
/// The number of slots (exactly the cell count of the region).
pub fn[T] DenseHexMap::length(self : DenseHexMap[T]) -> Int32 {
  self.data.length()
}

///|
/// Whether `cell` belongs to the region and therefore has a slot.
pub fn[T] DenseHexMap::contains(self : DenseHexMap[T], cell : @hex.Hex) -> Bool {
  self.index.get(cell) is Some(_)
}

///|
/// The slot index of `cell`, or `None` if it is outside the region.
pub fn[T] DenseHexMap::index_of(
  self : DenseHexMap[T],
  cell : @hex.Hex,
) -> Int32? {
  match self.index.get(cell) {
    Some(i) => Some(i)
    None => None
  }
}

///|
/// The cell occupying slot `i`, or `None` when `i` is out of range.
pub fn[T] DenseHexMap::cell_at(self : DenseHexMap[T], i : Int32) -> @hex.Hex? {
  self.cells.get(i)
}

///|
/// The value at `cell`, or `None` when `cell` is outside the region.
pub fn[T] DenseHexMap::get(self : DenseHexMap[T], cell : @hex.Hex) -> T? {
  match self.index.get(cell) {
    Some(i) => self.data.get(i)
    None => None
  }
}

///|
/// The value at `cell`, falling back to the map default outside the
/// region (which is where the default lives anyway).
pub fn[T] DenseHexMap::get_or(self : DenseHexMap[T], cell : @hex.Hex) -> T {
  match self.get(cell) {
    Some(v) => v
    None => self.default
  }
}

///|
/// Writes `value` into the slot of `cell`. Raises when `cell` is
/// outside the region — dense storage has no room for unlisted cells.
pub fn[T] DenseHexMap::set(
  self : DenseHexMap[T],
  cell : @hex.Hex,
  value : T,
) -> Unit raise {
  match self.index.get(cell) {
    Some(i) => self.data[i] = value
    None => fail("DenseHexMap::set: cell is outside the region")
  }
}

///|
/// Iterates every `(cell, value)` pair in region enumeration order.
pub fn[T] DenseHexMap::iter(
  self : DenseHexMap[T],
  f : (@hex.Hex, T) -> Unit,
) -> Unit {
  for i, v in self.data {
    f(self.cells[i], v)
  }
}
