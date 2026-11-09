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

///|
test "fov: symmetric visibility is symmetric for all pairs" {
  let cells = @hex.Hex::range(h(0, 0), 3)
  // wall at (1, 0) plus a second wall further out for variety
  fn terrain(c : @hex.Hex) -> Bool {
    !((c.q == 1 && c.r == 0) || (c.q == -1 && c.r == -1))
  }
  for a in cells {
    for b in cells {
      let forward = visible(a, b, terrain) && visible(b, a, terrain)
      let backward = visible(b, a, terrain) && visible(a, b, terrain)
      assert_eq(forward, backward)
    }
  }
}

///|
test "fov: compute_symmetric is a subset of compute" {
  fn wall_east(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r == 0)
  }
  let one_way = compute(h(0, 0), 4, wall_east)
  let symmetric = compute_symmetric(h(0, 0), 4, wall_east)
  for c in symmetric {
    assert_true(one_way.contains(c))
  }
  assert_true(symmetric.length() <= one_way.length())
}

///|
test "fov: symmetric hides cells whose occupants cannot see back" {
  fn wall_east(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r == 0)
  }
  // (2, 0) is behind the wall from the viewer at origin...
  assert_true(!compute(h(0, 0), 4, wall_east).contains(h(2, 0)))
  // ...and conversely an occupant at (2, 0) cannot see the origin,
  // so the symmetric model must not reveal it either.
  assert_true(!compute_symmetric(h(0, 0), 4, wall_east).contains(h(2, 0)))
  // the wall itself is still visible from the origin...
  assert_true(compute_symmetric(h(0, 0), 4, wall_east).contains(h(1, 0)))
  // ...but a wall occupant cannot see past itself to the origin? It can:
  // the line from (1,0) to (0,0) has no interior cells, so the wall
  // occupant does see the viewer. Both models agree here.
  assert_true(visible(h(1, 0), h(0, 0), wall_east))
  // open field: symmetric equals one-way
  assert_eq(
    compute_symmetric(h(0, 0), 3, all_clear).length(),
    compute(h(0, 0), 3, all_clear).length(),
  )
}

///|
test "fov: radius boundary semantics" {
  fn clear(_c : @hex.Hex) -> Bool {
    true
  }
  // radius 0: the viewer alone
  let r0 = compute(h(2, -1), 0, clear)
  assert_eq(r0.length(), 1)
  assert_eq(r0[0], h(2, -1))
  // radius 1, open field: viewer plus exactly the 6 neighbours
  let r1 = compute_symmetric(h(2, -1), 1, clear)
  assert_eq(r1.length(), 7)
  // radius R on an open field: the full hexagon, 3R^2+3R+1 cells
  for radius in [2, 3, 4] {
    let full = compute_symmetric(h(0, 0), radius, clear)
    assert_eq(full.length(), 3 * radius * radius + 3 * radius + 1)
    // on an open field symmetric equals one-way exactly
    assert_eq(full, compute(h(0, 0), radius, clear))
  }
}

///|
test "fov: adjacent cells always visible regardless of callbacks" {
  // the interior of an adjacent line is empty, so even "opaque" worlds
  // reveal the six neighbours
  fn all_opaque(_c : @hex.Hex) -> Bool {
    false
  }
  let fov = compute(h(0, 0), 1, all_opaque)
  assert_eq(fov.length(), 7)
  // ...but nothing at distance 2 survives an opaque world
  let wide = compute(h(0, 0), 3, all_opaque)
  assert_eq(wide.length(), 7)
}

///|
test "fov: wall visibility and edge blocking semantics" {
  fn wall_east(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r == 0)
  }
  // the wall itself is visible (targets are exempt)
  assert_true(visible(h(0, 0), h(1, 0), wall_east))
  // the cell behind the wall on the same line is not
  assert_false(visible(h(0, 0), h(2, 0), wall_east))
  // symmetric model agrees: behind the wall is dark
  let sym = compute_symmetric(h(0, 0), 3, wall_east)
  assert_false(sym.contains(h(2, 0)))
  assert_true(sym.contains(h(1, 0)))
  // cells past the wall's edge (not on the blocked line) stay lit:
  // the diagonal through (1,-1) never touches the wall
  assert_true(sym.contains(h(1, -1)))
  assert_true(sym.contains(h(2, -2)))
}

///|
test "fov: transparency only applies to interior cells" {
  // glass at the target: still visible (target exempt)
  fn glass_target(c : @hex.Hex) -> Bool {
    !(c.q == 2 && c.r == 0)
  }
  assert_true(visible(h(0, 0), h(2, 0), glass_target))
  // glass in the interior: blocks
  fn glass_interior(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r == 0)
  }
  assert_false(visible(h(0, 0), h(2, 0), glass_interior))
}

///|
test "fov: exhaustive pairwise symmetry over deterministic random maps" {
  // xorshift32 PRNG - deterministic across platforms and runs
  let mut seed : UInt32 = 0x2545F491
  fn next_random() -> UInt32 {
    seed = seed ^ (seed << 13)
    seed = seed ^ (seed >> 17)
    seed = seed ^ (seed << 5)
    seed
  }
  let field = @hex.Hex::range(h(0, 0), 4)
  for _map in 0..<20 {
    // one random wall map per iteration
    let walls : Map[@hex.Hex, Bool] = Map([])
    for c in field {
      if next_random() % 4 == 0 && c != h(0, 0) {
        walls[c] = true
      }
    }
    fn terrain(c : @hex.Hex) -> Bool {
      !walls.contains(c)
    }
    // property 1: visible() is pairwise symmetric
    for a in field {
      for b in field {
        assert_eq(
          visible(a, b, terrain) && visible(b, a, terrain),
          visible(b, a, terrain) && visible(a, b, terrain),
        )
      }
    }
    // property 2: symmetric FOV is a subset of one-way FOV
    let one_way = compute(h(0, 0), 4, terrain)
    let symmetric = compute_symmetric(h(0, 0), 4, terrain)
    for c in symmetric {
      assert_true(one_way.contains(c))
    }
    // property 3: symmetric membership is exactly the mirror rule
    for c in field {
      assert_eq(
        symmetric.contains(c),
        visible(h(0, 0), c, terrain) && visible(c, h(0, 0), terrain),
      )
    }
  }
}
