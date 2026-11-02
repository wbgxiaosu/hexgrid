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
}
