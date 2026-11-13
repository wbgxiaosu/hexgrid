///|
/// Stress: field of view at radius 100 over an open field covers the
/// full hexagon; the symmetric variant matches it exactly.
test "stress: fov at radius 100" {
  fn clear(_c : @hex.Hex) -> Bool {
    true
  }
  let full = compute(h(0, 0), 100, clear)
  assert_eq(full.length(), 3 * 100 * 100 + 3 * 100 + 1)
  assert_eq(compute_symmetric(h(0, 0), 100, clear), full)
  // the viewer is always first-class present
  assert_true(full.contains(h(0, 0)))
}

///|
/// Stress: 20 radius-30 random wall maps keep all three FOV invariants
/// at scale (pairwise symmetry, subset, mirror rule).
test "stress: fov invariants over 20 large random maps" {
  let mut seed : UInt32 = 20261113
  fn next_random() -> UInt32 {
    seed = seed ^ (seed << 13)
    seed = seed ^ (seed >> 17)
    seed = seed ^ (seed << 5)
    seed
  }
  let field = @hex.Hex::range(h(0, 0), 30)
  for _map in 0..<20 {
    let walls : Map[@hex.Hex, Bool] = Map([])
    for c in field {
      if next_random() % 9 == 0 && c != h(0, 0) {
        walls[c] = true
      }
    }
    fn terrain(c : @hex.Hex) -> Bool {
      !walls.contains(c)
    }
    let one_way = compute(h(0, 0), 30, terrain)
    let symmetric = compute_symmetric(h(0, 0), 30, terrain)
    for c in symmetric {
      assert_true(one_way.contains(c))
    }
    for c in field {
      assert_eq(
        symmetric.contains(c),
        visible(h(0, 0), c, terrain) && visible(c, h(0, 0), terrain),
      )
    }
  }
}
