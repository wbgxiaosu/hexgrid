///|
/// Whether `target` is visible from `viewer` under the one-way
/// line-of-sight rule: the straight grid line from the viewer to the
/// target (see `@hex.Hex::line`) passes only through transparent
/// cells. Both endpoints are exempt from the transparency check, so
/// walls are visible even though they block the light behind them.
pub fn visible(
  viewer : @hex.Hex,
  target : @hex.Hex,
  transparent : (@hex.Hex) -> Bool,
) -> Bool {
  if viewer == target {
    return true
  }
  let line = viewer.line(target)
  for k in 1..<(line.length() - 1) {
    if !transparent(line[k]) {
      return false
    }
  }
  true
}

///|
/// Line-of-sight field of view over the hex grid.
///
/// A cell is visible from `viewer` when `visible(viewer, cell)`
/// holds. For a symmetric variant see `compute_symmetric`.
pub fn compute(
  viewer : @hex.Hex,
  radius : Int32,
  transparent : (@hex.Hex) -> Bool,
) -> Array[@hex.Hex] {
  let acc : Array[@hex.Hex] = []
  for candidate in @hex.Hex::range(viewer, radius) {
    if visible(viewer, candidate, transparent) {
      acc.push(candidate)
    }
  }
  acc
}

///|
/// Symmetric line-of-sight field of view over the hex grid.
///
/// A cell is visible when the line of sight is clear in **both**
/// directions (`viewer` to `cell` and `cell` to `viewer`). This is
/// the symmetric-visibility discipline for grids (Bjorn Bergstrom's
/// symmetric shadowcasting adapted to hex line drawing): it removes
/// the asymmetric artefacts of the one-way model, where a viewer can
/// sometimes see a cell whose occupant cannot see the viewer back.
/// The result is always a subset of `compute` on the same inputs.
pub fn compute_symmetric(
  viewer : @hex.Hex,
  radius : Int32,
  transparent : (@hex.Hex) -> Bool,
) -> Array[@hex.Hex] {
  let acc : Array[@hex.Hex] = []
  for candidate in @hex.Hex::range(viewer, radius) {
    if visible(viewer, candidate, transparent) &&
      visible(candidate, viewer, transparent) {
      acc.push(candidate)
    }
  }
  acc
}
