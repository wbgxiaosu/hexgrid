///|
/// A hex-addressed map: values stored per cell over a fixed region
/// shape.
///
/// The map is sparse-friendly: `HexMap::set` may store values for any
/// coordinate, while `HexMap::contains` reports whether the cell
/// belongs to the map's backing region. Iteration order is
/// deterministic (sorted by increasing `q`, then `r`), so programs
/// built on top of it stay reproducible.
pub struct HexMap[T] {
  priv cells : Map[@hex.Hex, T]
  priv region : Region
}

///|
/// The region shape of `self`.
pub fn[T] HexMap::region(self : HexMap[T]) -> Region {
  self.region
}

///|
/// Creates a map covering `region`, filling every cell with `default`.
pub fn[T] HexMap::make(region : Region, default : T) -> HexMap[T] {
  let cells : Map[@hex.Hex, T] = Map([])
  for c in region.cells() {
    cells[c] = default
  }
  { cells, region, }
}

///|
/// Creates an empty map with the given region but no stored values.
pub fn[T] HexMap::make_empty(region : Region) -> HexMap[T] {
  { cells: Map([]), region, }
}

///|
/// The number of stored values.
pub fn[T] HexMap::length(self : HexMap[T]) -> Int32 {
  self.cells.length()
}

///|
/// Whether `self` stores a value at `cell`. A cell inside the region
/// that was never written (or was removed) returns `false`; use
/// `HexMap::in_region` for the shape check.
pub fn[T] HexMap::contains(self : HexMap[T], cell : @hex.Hex) -> Bool {
  self.cells.contains(cell)
}

///|
/// Whether `cell` belongs to the map's region shape.
pub fn[T] HexMap::in_region(self : HexMap[T], cell : @hex.Hex) -> Bool {
  for c in self.region.cells() {
    if c == cell {
      return true
    }
  }
  false
}

///|
/// The stored value at `cell`, if any.
pub fn[T] HexMap::get(self : HexMap[T], cell : @hex.Hex) -> T? {
  self.cells.get(cell)
}

///|
/// The stored value at `cell`, or `default` when absent.
pub fn[T] HexMap::get_or(self : HexMap[T], cell : @hex.Hex, default : T) -> T {
  self.cells.get(cell).unwrap_or(default)
}

///|
/// Stores `value` at `cell`, overwriting any previous value.
pub fn[T] HexMap::set(self : HexMap[T], cell : @hex.Hex, value : T) -> Unit {
  self.cells[cell] = value
}

///|
/// Removes the value at `cell`, returning it if present.
pub fn[T] HexMap::remove(self : HexMap[T], cell : @hex.Hex) -> T? {
  match self.cells.get(cell) {
    Some(v) => {
      self.cells.remove(cell)
      Some(v)
    }
    None => None
  }
}

///|
/// All cells that currently hold a value, sorted by increasing `q`
/// then `r`.
pub fn[T] HexMap::occupied(self : HexMap[T]) -> Array[@hex.Hex] {
  let acc : Array[@hex.Hex] = []
  for k, _ in self.cells {
    acc.push(k)
  }
  acc.sort_by(fn(a, b) { if a.q != b.q { a.q - b.q } else { a.r - b.r } })
  acc
}

///|
/// All stored values, in the deterministic order of `HexMap::occupied`.
pub fn[T] HexMap::values(self : HexMap[T]) -> Array[T] {
  let acc : Array[T] = []
  for c in self.occupied() {
    match self.cells.get(c) {
      Some(v) => acc.push(v)
      None => ()
    }
  }
  acc
}
