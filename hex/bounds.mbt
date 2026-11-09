///|
/// A **hexagonal bounding region**: a center cell plus a radius.
///
/// Bounds answer "is this coordinate inside the map?" without touching
/// any storage, and enumerate their cells in the same deterministic
/// order as `Hex::spiral`. Useful for world maps, chunk clipping and
/// as the backing region for dense storage (see `@hexmap.DenseHexMap`).
#derive(Eq, Debug)
pub struct HexBounds {
  center : Hex
  radius : Int32
}

///|
pub extend HexBounds with Eq::{equal, not_equal}

///|
pub extend HexBounds with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Public constructor for hexagonal bounds.
pub fn HexBounds::make(center : Hex, radius : Int32) -> HexBounds {
  { center, radius, }
}

///|
/// Whether `cell` lies within the bounds (grid distance to the center
/// is at most the radius).
pub fn HexBounds::is_in_bounds(self : HexBounds, cell : Hex) -> Bool {
  self.center.distance(cell) <= self.radius
}

///|
/// Every cell within the bounds, in deterministic spiral order. The
/// count is exactly `3 * radius^2 + 3 * radius + 1`.
pub fn HexBounds::all_cells(self : HexBounds) -> Array[Hex] {
  Hex::spiral(self.center, 0, self.radius)
}

///|
/// The number of cells within the bounds: `3 * radius^2 + 3 * radius
/// + 1` (a filled hexagon of cells).
pub fn HexBounds::length(self : HexBounds) -> Int32 {
  3 * self.radius * self.radius + 3 * self.radius + 1
}
