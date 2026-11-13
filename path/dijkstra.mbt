///|
/// A minimal binary min-heap over (priority, payload) pairs.
priv struct Heap[T] {
  items : Array[(Double, T)]
}

///|
fn[T] Heap::new() -> Heap[T] {
  { items: [], }
}

///|
fn[T] Heap::size(self : Heap[T]) -> Int32 {
  self.items.length()
}

///|
fn[T] Heap::push(self : Heap[T], priority : Double, value : T) -> Unit {
  self.items.push((priority, value))
  let mut i = self.items.length() - 1
  while i > 0 {
    let parent = (i - 1) / 2
    if self.items[i].0 < self.items[parent].0 {
      let tmp = self.items[i]
      self.items[i] = self.items[parent]
      self.items[parent] = tmp
      i = parent
    } else {
      break
    }
  }
}

///|
fn[T] Heap::pop(self : Heap[T]) -> T? {
  if self.items.is_empty() {
    return None
  }
  let top = self.items[0].1
  let last = match self.items.pop() {
    Some(x) => x
    None => return None
  }
  if self.items.length() > 0 {
    self.items[0] = last
    let n = self.items.length()
    let mut i = 0
    while true {
      let l = 2 * i + 1
      let r = 2 * i + 2
      let mut smallest = i
      if l < n && self.items[l].0 < self.items[smallest].0 {
        smallest = l
      }
      if r < n && self.items[r].0 < self.items[smallest].0 {
        smallest = r
      }
      if smallest == i {
        break
      }
      let tmp = self.items[i]
      self.items[i] = self.items[smallest]
      self.items[smallest] = tmp
      i = smallest
    }
  }
  Some(top)
}

///|
/// The result of a breadth/cost-first flood from a source cell:
/// the cheapest known cost per reachable cell plus a back-pointer to
/// the previous cell on a cheapest path.
#derive(Eq, Debug)
pub struct Reachability {
  /// Cost from the source to each reachable cell (source itself has
  /// cost 0). Cells not reachable within `max_cost` are absent.
  cost : Map[@hex.Hex, Double]
  /// Back-pointers: `came_from[cell]` is the previous cell on a
  /// cheapest path from the nearest source.
  came_from : Map[@hex.Hex, @hex.Hex]
  /// The source cells the flood started from (exactly one for a
  /// single-source flood).
  sources : Array[@hex.Hex]
  /// Membership index over `sources` for O(1) lookups; kept in sync
  /// with `sources` at construction time.
  source_set : Map[@hex.Hex, Bool]
}

///|
pub extend Reachability with Eq::{equal, not_equal}

///|
pub extend Reachability with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Reconstructs one cheapest path from the source to `target`
/// (inclusive of both ends). Returns `None` if `target` was not
/// reached.
pub fn Reachability::path_to(
  self : Reachability,
  target : @hex.Hex,
) -> Array[@hex.Hex]? {
  if !self.cost.contains(target) {
    return None
  }
  let acc : Array[@hex.Hex] = [target]
  let mut cur = target
  while !self.source_set.contains(cur) {
    match self.came_from.get(cur) {
      Some(prev) => {
        acc.push(prev)
        cur = prev
      }
      None => return None
    }
  }
  // reverse in place
  let n = acc.length()
  for i in 0..<(n / 2) {
    let tmp = acc[i]
    acc[i] = acc[n - 1 - i]
    acc[n - 1 - i] = tmp
  }
  Some(acc)
}

///|
/// Dijkstra flood over the hex grid from a single `source`.
///
/// - `passable(cell)` decides whether a cell may be entered at all
///   (the source is exempt from this check).
/// - `step_cost(from, to)` is the movement cost of entering `to`
///   from `from`; it should return a positive value. For uniform
///   movement pass a constant cost of `1.0`.
/// - `max_cost` bounds the search; unreachable or too-expensive cells
///   are omitted from the result.
pub fn Reachability::compute(
  source : @hex.Hex,
  max_cost : Double,
  passable : (@hex.Hex) -> Bool,
  step_cost : (@hex.Hex, @hex.Hex) -> Double,
) -> Reachability raise {
  Reachability::compute_multi([source], max_cost, passable, step_cost)
}

///|
/// Dijkstra flood over the hex grid from **several** sources at once.
///
/// Every source starts at cost 0.0; each reached cell records the
/// cheapest cost over all sources and a back-pointer path towards the
/// nearest source (the first one a cheapest path reaches). Sources are
/// exempt from the `passable` check, exactly like the single-source
/// `compute`. Typical uses: distance-to-nearest-city maps, threat
/// radii of several units, or multi-exit escape analysis.
pub fn Reachability::compute_multi(
  sources : Array[@hex.Hex],
  max_cost : Double,
  passable : (@hex.Hex) -> Bool,
  step_cost : (@hex.Hex, @hex.Hex) -> Double,
) -> Reachability raise {
  let cost : Map[@hex.Hex, Double] = Map([])
  let came_from : Map[@hex.Hex, @hex.Hex] = Map([])
  let frontier : Heap[@hex.Hex] = Heap::new()
  let source_set : Map[@hex.Hex, Bool] = Map([])
  for source in sources {
    cost[source] = 0.0
    source_set[source] = true
    frontier.push(0.0, source)
  }
  while frontier.size() > 0 {
    match frontier.pop() {
      Some(current) => {
        let cur_cost = cost.get(current).unwrap_or(0.0)
        for d in 0..<6 {
          let next = current.neighbor(d)
          if !source_set.contains(next) && !passable(next) {
            continue
          }
          let w = step_cost(current, next)
          if !(w > 0.0) {
            fail("step_cost must return a positive value")
          }
          let new_cost = cur_cost + w
          if new_cost <= max_cost {
            match cost.get(next) {
              Some(existing) =>
                if new_cost < existing {
                  cost[next] = new_cost
                  came_from[next] = current
                  frontier.push(new_cost, next)
                }
              None => {
                cost[next] = new_cost
                came_from[next] = current
                frontier.push(new_cost, next)
              }
            }
          }
        }
      }
      None => break
    }
  }
  { cost, came_from, sources, source_set, }
}

///|
/// The cheapest cost from the nearest source to `cell`, or `None` if the cell
/// was not reached within `max_cost`.
pub fn Reachability::cost_to(self : Reachability, cell : @hex.Hex) -> Double? {
  self.cost.get(cell)
}

///|
/// All cells reached by the flood, as an array.
pub fn Reachability::reached(self : Reachability) -> Array[@hex.Hex] {
  let acc : Array[@hex.Hex] = []
  for k, _ in self.cost {
    acc.push(k)
  }
  acc
}
