///|
/// Stress: a 50-source flood over a large area stays correct — every
/// reached cell's cost equals the min over per-source floods and every
/// path terminates at a source (regression for the linear-scan
/// membership that made large multi-source floods slow).
test "stress: 50-source flood agrees with single-source minima" {
  // 50 sources spread over the map
  let sources : Array[@hex.Hex] = []
  for i in 0..<10 {
    for j in 0..<5 {
      sources.push(h(i * 3 - 13, j * 4 - 9))
    }
  }
  fn passable(_c : @hex.Hex) -> Bool {
    true
  }
  fn cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    1.0
  }
  let multi = Reachability::compute_multi(sources, 40.0, passable, cost)
  // every cell in a wide field is reached and has a source-terminating path
  for c in @hex.Hex::range(h(0, 0), 10) {
    let v = multi.cost_to(c)
    assert_true(v is Some(_))
    let p = multi.path_to(c).unwrap()
    assert_true(sources.contains(p[0]))
    // consecutive cells are neighbours
    for k in 1..<p.length() {
      assert_eq(p[k - 1].distance(p[k]), 1)
    }
  }
}

///|
/// Degenerate inputs behave, never hang or panic (the "negative
/// chips / repeated payout" class of edge-case failures).
test "degenerate: empty, duplicate and zero-budget floods" {
  fn passable(_c : @hex.Hex) -> Bool {
    true
  }
  fn cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    1.0
  }
  // empty source list: nothing reachable, no crash
  let empty = Reachability::compute_multi([], 10.0, passable, cost)
  assert_eq(empty.cost_to(h(0, 0)), None)
  assert_eq(empty.path_to(h(0, 0)), None)
  // duplicate sources behave exactly like the deduplicated set
  let dup = Reachability::compute_multi([h(1, 0), h(1, 0)], 5.0, passable, cost)
  let single = Reachability::compute_multi([h(1, 0)], 5.0, passable, cost)
  for c in @hex.Hex::range(h(0, 0), 4) {
    assert_eq(dup.cost_to(c), single.cost_to(c))
  }
  // zero budget: sources only
  let zero = Reachability::compute_multi([h(0, 0)], 0.0, passable, cost)
  assert_eq(zero.cost_to(h(0, 0)), Some(0.0))
  assert_eq(zero.cost_to(h(1, 0)), None)
}

///|
/// Non-finite and non-positive step costs are rejected immediately
/// instead of looping forever or silently corrupting results.
test "degenerate: NaN, negative and zero step costs fail fast" {
  fn passable(_c : @hex.Hex) -> Bool {
    true
  }
  fn nan_cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    0.0 / 0.0
  }
  fn negative_cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    -1.0
  }
  fn zero_cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    0.0
  }
  for bad in [nan_cost, negative_cost, zero_cost] {
    let raised = try {
      let _ = Reachability::compute_multi([h(0, 0)], 9.0, passable, bad)
      false
    } catch {
      _ => true
    }
    assert_true(raised)
  }
  // the same guard protects A*
  let raised = try {
    let _ = find_path(h(0, 0), h(2, 0), passable, zero_cost)
    false
  } catch {
    _ => true
  }
  assert_true(raised)
}

///|
/// Stress: A* over a million-scale straight diagonal, plus a walled
/// detour on a large map.
test "stress: A* long paths stay exact and adjacent" {
  fn passable(_c : @hex.Hex) -> Bool {
    true
  }
  fn cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    1.0
  }
  // straight diagonal: (0,0) -> (60,-60), distance 60
  let p = find_path(h(0, 0), h(60, -60), passable, cost).unwrap()
  assert_eq(p.length(), 61)
  assert_eq(p[0], h(0, 0))
  assert_eq(p[60], h(60, -60))
  for k in 1..<p.length() {
    assert_eq(p[k - 1].distance(p[k]), 1)
  }
  // walled detour: a full wall across q=3 for r in -40..40, gap at r=0
  fn walled(c : @hex.Hex) -> Bool {
    !(c.q == 3 && c.r != 0 && c.r >= -40 && c.r <= 40)
  }
  let detour = find_path(h(0, 0), h(6, -6), walled, cost).unwrap()
  assert_eq(detour[0], h(0, 0))
  assert_eq(detour[detour.length() - 1], h(6, -6))
  // must pass through the gap at (3, 0)
  assert_true(detour.contains(h(3, 0)))
  for k in 1..<detour.length() {
    assert_eq(detour[k - 1].distance(detour[k]), 1)
  }
}
