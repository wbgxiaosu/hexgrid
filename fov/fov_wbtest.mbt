///|
fn h(q : Int32, r : Int32) -> @hex.Hex {
  @hex.Hex::make(q, r)
}

///|
fn all_clear(_c : @hex.Hex) -> Bool {
  true
}

///|
test "fov: open field sees everything within radius" {
  let seen = compute(h(0, 0), 3, all_clear)
  assert_eq(seen.length(), @hex.Hex::range(h(0, 0), 3).length())
  assert_true(seen.contains(h(2, -2)))
}

///|
test "fov: the viewer always sees itself" {
  let seen = compute(h(4, -2), 0, fn(_c) { false })
  assert_eq(seen, [h(4, -2)])
}

///|
test "fov: a wall blocks the cells directly behind it" {
  // wall one step east of the viewer
  fn wall_east(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r == 0)
  }
  let seen = compute(h(0, 0), 4, wall_east)
  // the wall itself is visible (targets are exempt from the check)
  assert_true(seen.contains(h(1, 0)))
  // cells on the same straight line behind the wall are not
  assert_true(!seen.contains(h(2, 0)))
  assert_true(!seen.contains(h(3, 0)))
  // cells on lines that miss the wall remain visible
  assert_true(seen.contains(h(1, -1)))
  assert_true(seen.contains(h(0, -2)))
}

///|
test "fov: every visible non-viewer cell has a clear line of sight" {
  // invariant: visible iff the grid line to the target is clear
  fn transparent(c : @hex.Hex) -> Bool {
    !(c.q == 2 && c.r == -1)
  }
  let viewer = h(0, 0)
  let seen = compute(viewer, 4, transparent)
  let expected : Array[@hex.Hex] = []
  for candidate in @hex.Hex::range(viewer, 4) {
    if candidate == viewer {
      expected.push(candidate)
      continue
    }
    let line = viewer.line(candidate)
    let mut clear = true
    for k in 1..<(line.length() - 1) {
      if !transparent(line[k]) {
        clear = false
        break
      }
    }
    if clear {
      expected.push(candidate)
    }
  }
  assert_eq(seen.length(), expected.length())
  for c in expected {
    assert_true(seen.contains(c))
  }
}
