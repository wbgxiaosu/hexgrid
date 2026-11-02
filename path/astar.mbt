///|
/// A* pathfinding over the hex grid.
///
/// The heuristic must be admissible; `@hex.Hex::distance` is admissible for
/// any `step_cost` of at least 1.0 per step, and is the default.
pub fn find_path(
  start : @hex.Hex,
  goal : @hex.Hex,
  passable : (@hex.Hex) -> Bool,
  step_cost : (@hex.Hex, @hex.Hex) -> Double,
) -> Array[@hex.Hex]? raise {
  if !(start == goal) && !passable(goal) {
    return None
  }
  let g : Map[@hex.Hex, Double] = Map([])
  let came_from : Map[@hex.Hex, @hex.Hex] = Map([])
  let frontier : Heap[@hex.Hex] = Heap::new()
  g[start] = 0.0
  frontier.push(start.distance(goal).to_double(), start)
  while frontier.size() > 0 {
    match frontier.pop() {
      Some(current) => {
        if current == goal {
          return Some(reconstruct(came_from, start, goal))
        }
        let cur_g = g.get(current).unwrap_or(0.0)
        for d in 0..<6 {
          let next = current.neighbor(d)
          if !(next == start) && !passable(next) {
            continue
          }
          let w = step_cost(current, next)
          if !(w > 0.0) {
            fail("step_cost must return a positive value")
          }
          let tentative = cur_g + w
          match g.get(next) {
            Some(existing) =>
              if tentative < existing {
                g[next] = tentative
                came_from[next] = current
                let f = tentative + next.distance(goal).to_double()
                frontier.push(f, next)
              }
            None => {
              g[next] = tentative
              came_from[next] = current
              let f = tentative + next.distance(goal).to_double()
              frontier.push(f, next)
            }
          }
        }
      }
      None => break
    }
  }
  None
}

///|
fn reconstruct(
  came_from : Map[@hex.Hex, @hex.Hex],
  start : @hex.Hex,
  goal : @hex.Hex,
) -> Array[@hex.Hex] {
  let acc : Array[@hex.Hex] = [goal]
  let mut cur = goal
  while !(cur == start) {
    match came_from.get(cur) {
      Some(prev) => {
        acc.push(prev)
        cur = prev
      }
      None => break
    }
  }
  let n = acc.length()
  for i in 0..<(n / 2) {
    let tmp = acc[i]
    acc[i] = acc[n - 1 - i]
    acc[n - 1 - i] = tmp
  }
  acc
}
