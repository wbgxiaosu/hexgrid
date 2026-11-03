///|
fn main raise {
  // 1. core geometry
  let a = @hex.Hex::make(0, 0)
  let b = @hex.Hex::make(4, -2)
  println("distance \{a.label()} -> \{b.label()} = \{a.distance(b)}")
  let lb = StringBuilder()
  for i, c in a.line(b) {
    if i > 0 {
      lb.write_string(" ")
    }
    lb.write_string(c.label())
  }
  println("line \{a.label()} -> \{b.label()}: \{lb}")
  println(
    "range 2 has \{@hex.Hex::range(a, 2).length()} cells; ring 2 has \{@hex.Hex::ring(a, 2).length()}",
  )

  // 2. pathfinding around a wall on column q = 1
  fn passable(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r != -1)
  }
  match @path.find_path(a, b, passable, fn(_f, _t) { 1.0 }) {
    Some(steps) => {
      let buf = StringBuilder()
      for i, c in steps {
        if i > 0 {
          buf.write_string(" -> ")
        }
        buf.write_string(c.label())
      }
      println(
        "A* path (\{steps.length() - 1} steps, detouring the wall): \{buf}",
      )
    }
    None => println("no path")
  }

  // 3. field of view with a blocking wall at (1, 0)
  fn transparent(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r == 0)
  }
  let seen = @fov.compute(a, 2, transparent)
  let sb = StringBuilder()
  for i, c in seen {
    if i > 0 {
      sb.write_string(", ")
    }
    sb.write_string(c.label())
  }
  println("visible cells (\{seen.length()}): \{sb}")

  // 4. symmetric FOV: bidirectional line of sight
  let sym = @fov.compute_symmetric(a, 2, transparent)
  println("symmetric fov: \{sym.length()} cells (one-way saw \{seen.length()})")

  // 5. multi-source Dijkstra: two friendly cities, nearest-source map
  let multi = @path.Reachability::compute_multi(
    [@hex.Hex::make(-2, 1), @hex.Hex::make(2, -1)],
    10.0,
    fn(_c) { true },
    fn(_f, _t) { 1.0 },
  )
  match multi.cost_to(a) {
    Some(c) =>
      println("multi-source: origin is \{c} steps from the nearest city")
    None => println("multi-source: origin unreachable")
  }

  // 6. region-shaped hex map with ASCII rendering
  let terrain : @hexmap.HexMap[String] = @hexmap.HexMap::make(
    @hexmap.Region::rectangle(4, 3),
    ".",
  )
  terrain.set(@hex.Hex::make(0, 0), "X")
  terrain.set(@hex.Hex::make(2, 1), "~")
  println("hexmap 4x3 rectangle (X you, ~ water):")
  println(terrain.render(fn(v) { v }))
}
