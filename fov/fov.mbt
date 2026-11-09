/// # Visibility semantics (formal definition)
///
/// Let `line(a, b)` be the straight grid line of `@hex.Hex::line`
/// (cube interpolation with rounding), inclusive of both endpoints,
/// and `interior(line(a, b))` be that line without its endpoints.
///
/// **One-way visibility** `visible(viewer, target)` holds if and only
/// if every cell of `interior(line(viewer, target))` satisfies
/// `transparent`. Consequences of this definition:
///
/// - the viewer's own transparency never matters (it is not interior);
/// - an opaque **target is still visible** — walls can be seen even
///   though they block everything behind them;
/// - a cell adjacent to the viewer has an empty interior, so it is
///   always visible regardless of the callbacks;
/// - only cells within grid distance `radius` are enumerated, and the
///   viewer itself is always part of the result.
///
/// **Symmetric visibility** additionally requires the mirror check:
/// `visible(viewer, target)` **and** `visible(target, viewer)`. This
/// is the hexagonal adaptation of the symmetric-visibility discipline
/// of Bjorn Bergstrom's symmetric shadowcasting (RogueBasin, "Better
/// FOV", https://www.roguebasin.com/index.php/Better_FOV — freely
/// readable); the composition with hex line drawing and the
/// implementation are original. Symmetric results are always a subset
/// of the one-way results on the same inputs.

///|
/// Whether `target` is visible from `viewer` under the one-way
/// line-of-sight rule defined in the package header.
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
