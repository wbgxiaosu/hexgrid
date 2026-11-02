///|
/// Line-of-sight field of view over the hex grid.
///
/// A cell is visible from `viewer` when the straight grid line from
/// the viewer to the cell (see `@hex.Hex::line`) passes only through
/// transparent cells; the viewer itself and the target cell are exempt
/// from the transparency check (walls are visible even though they
/// block the light behind them).
pub fn compute(
  viewer : @hex.Hex,
  radius : Int32,
  transparent : (@hex.Hex) -> Bool,
) -> Array[@hex.Hex] {
  let acc : Array[@hex.Hex] = []
  for candidate in @hex.Hex::range(viewer, radius) {
    if candidate == viewer {
      acc.push(candidate)
      continue
    }
    let line = viewer.line(candidate)
    let mut blocked = false
    for k in 1..<(line.length() - 1) {
      if !transparent(line[k]) {
        blocked = true
        break
      }
    }
    if !blocked {
      acc.push(candidate)
    }
  }
  acc
}
