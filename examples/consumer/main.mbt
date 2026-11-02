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
  println("consumer example OK")
}
