///|
fn main raise {
  let start = @hex.Hex::make(0, 0)
  let goal = @hex.Hex::make(2, 2)
  match @path.find_path(start, goal, fn(_c) { true }, fn(_f, _t) { 1.0 }) {
    Some(path) => println("consumer A* steps: \{path.length() - 1}")
    None => println("consumer A* failed")
  }
  let seen = @fov.compute(start, 2, fn(_c) { true })
  println("consumer fov cells: \{seen.length()}")
  // symmetric FOV: subset discipline on an open field
  let sym = @fov.compute_symmetric(start, 2, fn(_c) { true })
  println("consumer symmetric fov cells: \{sym.length()}")
  // multi-source Dijkstra: two sources meet in the middle
  let multi = @path.Reachability::compute_multi(
    [@hex.Hex::make(-2, 1), @hex.Hex::make(2, -1)],
    10.0,
    fn(_c) { true },
    fn(_f, _t) { 1.0 },
  )
  match multi.cost_to(start) {
    Some(c) => println("consumer multi-source cost to origin: \{c}")
    None => println("consumer multi-source failed")
  }
  // region-shaped hex map over a 3x3 odd-r rectangle
  let m : @hexmap.HexMap[Int32] = @hexmap.HexMap::make(
    @hexmap.Region::rectangle(3, 3),
    0,
  )
  println(
    "consumer hexmap cells: \{m.length()} (region size \{@hexmap.Region::rectangle(3, 3).size()})",
  )
  println("consumer example OK")
}
