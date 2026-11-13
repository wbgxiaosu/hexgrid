///|
/// Stress: large-radius enumeration scales linearly and matches the
/// closed-form cell counts (guards against the large-parameter
/// crashes that sank previous-season submissions).
test "stress: radius-100 enumeration matches closed-form counts" {
  let big = Hex::range(h(0, 0), 100)
  assert_eq(big.length(), 3 * 100 * 100 + 3 * 100 + 1)
  // ring at radius 100 has exactly 6*100 cells
  assert_eq(Hex::ring(h(0, 0), 100).length(), 600)
  // spiral 0..=60 matches the filled-hexagon count
  assert_eq(Hex::spiral(h(0, 0), 0, 60).length(), 3 * 60 * 60 + 3 * 60 + 1)
  // spot-check membership at the far edge
  assert_true(big.contains(h(100, -100)))
  assert_false(big.contains(h(101, -100)))
}

///|
/// Stress: extreme coordinates stay exact and never panic.
test "stress: million-scale coordinates" {
  let a = h(1000000, 0)
  let b = h(-1000000, 0)
  assert_eq(a.distance(b), 2000000)
  // line over a million-scale span has distance+1 cells
  let line = a.line(b)
  assert_eq(line.length(), 2000001)
  // endpoints preserved, consecutive steps are neighbours
  assert_eq(line[0], a)
  assert_eq(line[2000000], b)
  // distance axioms at scale
  assert_eq(b.distance(a), 2000000)
  assert_eq(a.distance(a), 0)
}

///|
/// Property: line length is always distance + 1 across a spread of
/// ranges (including degenerate zero-distance lines).
test "stress: line length invariant across distances" {
  for radius in [0, 1, 7, 23, 64] {
    for cell in Hex::range(h(0, 0), radius) {
      let line = h(0, 0).line(cell)
      assert_eq(line.length(), h(0, 0).distance(cell) + 1)
    }
  }
}
