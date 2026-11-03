///|
fn h(q : Int32, r : Int32) -> @hex.Hex {
  @hex.Hex::make(q, r)
}

///|
fn all_pass(_c : @hex.Hex) -> Bool {
  true
}

///|
fn unit_cost(_from : @hex.Hex, _to : @hex.Hex) -> Double {
  1.0
}

///|
test "dijkstra: uniform cost field equals hex distance" {
  let r = Reachability::compute(h(0, 0), 5.0, all_pass, unit_cost)
  assert_eq(r.sources, [h(0, 0)])
  // every cell within max_cost is reachable at exactly the hex distance
  for cell in @hex.Hex::range(h(0, 0), 5) {
    assert_eq(r.cost_to(cell), Some(cell.distance(h(0, 0)).to_double()))
  }
  // nothing beyond max_cost is reachable
  assert_eq(r.cost_to(h(6, -6)), None)
  assert_eq(r.reached().length(), @hex.Hex::range(h(0, 0), 5).length())
}

///|
test "dijkstra: max_cost bounds the flood" {
  let r = Reachability::compute(h(0, 0), 2.5, all_pass, unit_cost)
  assert_eq(r.reached().length(), @hex.Hex::range(h(0, 0), 2).length())
  assert_eq(r.cost_to(h(3, 0)), None)
}

///|
test "dijkstra: walls force detours and paths stay legal" {
  // a vertical wall on the column q = 1, with a gap at r = -1
  fn passable(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r != -1)
  }
  let r = Reachability::compute(h(0, 0), 10.0, passable, unit_cost)
  // cells behind the wall cost more than their hex distance
  let behind = h(3, 0)
  assert_true(
    r.cost_to(behind).unwrap_or(99.0) > behind.distance(h(0, 0)).to_double(),
  )
  // every returned path is legal: consecutive cells adjacent, costs consistent
  for cell in r.reached() {
    match r.path_to(cell) {
      Some(path) => {
        assert_eq(path[0], h(0, 0))
        assert_eq(path[path.length() - 1], cell)
        for k in 0..<(path.length() - 1) {
          assert_eq(path[k].distance(path[k + 1]), 1)
        }
        assert_eq(path.length() - 1, r.cost_to(cell).unwrap_or(-1.0).to_int())
      }
      None => fail("every reached cell must have a path")
    }
  }
}

///|
test "dijkstra: variable terrain costs are honoured" {
  // entering row r = 1 costs 5, everywhere else 1
  fn cost(_from : @hex.Hex, to : @hex.Hex) -> Double {
    if to.r == 1 {
      5.0
    } else {
      1.0
    }
  }
  let r = Reachability::compute(h(0, 0), 20.0, all_pass, cost)
  // entering (1,1) costs 5 and every approach enters the row once,
  // so the optimum is 1 (steps before) + 5 (entering the row)
  assert_eq(r.cost_to(h(1, 1)), Some(6.0))
  // staying on cheap ground is unaffected
  assert_eq(r.cost_to(h(2, -1)), Some(2.0))
}

///|
test "astar: straight lines, detours, unreachable goals" {
  // straight line in the open field
  match find_path(h(0, 0), h(3, -3), all_pass, unit_cost) {
    Some(path) => {
      assert_eq(path.length(), 4)
      assert_eq(path[0], h(0, 0))
      assert_eq(path[3], h(3, -3))
    }
    None => fail("open field must be connected")
  }
  // detour around a wall is longer than the hex distance
  fn passable(c : @hex.Hex) -> Bool {
    !(c.q == 1 && c.r != -1)
  }
  match find_path(h(0, 0), h(3, 0), passable, unit_cost) {
    Some(path) => {
      assert_true(path.length() - 1 > h(3, 0).distance(h(0, 0)))
      // path legality
      for k in 0..<(path.length() - 1) {
        assert_eq(path[k].distance(path[k + 1]), 1)
        assert_true(passable(path[k + 1]) || path[k + 1] == h(0, 0))
      }
    }
    None => fail("the gap makes the goal reachable")
  }
  // fully walled-off goal is unreachable
  fn walled_off(c : @hex.Hex) -> Bool {
    c.q < 2
  }
  assert_eq(find_path(h(0, 0), h(3, 0), walled_off, unit_cost), None)
  // start == goal
  assert_eq(find_path(h(2, 2), h(2, 2), all_pass, unit_cost), Some([h(2, 2)]))
}

///|
test "astar agrees with dijkstra on path cost across the field" {
  for goal in @hex.Hex::range(h(0, 0), 3) {
    let dijkstra = Reachability::compute(h(0, 0), 20.0, all_pass, unit_cost)
    match find_path(h(0, 0), goal, all_pass, unit_cost) {
      Some(path) => {
        let steps = (path.length() - 1).to_double()
        assert_eq(dijkstra.cost_to(goal), Some(steps))
      }
      None => fail("open field")
    }
  }
}

///|
test "dijkstra: multi-source agrees with single-source floods" {
  let field = @hex.Hex::range(h(0, 0), 3)
  fn passable(_c : @hex.Hex) -> Bool {
    true
  }
  fn cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    1.0
  }
  // each single-source flood equals the multi-source flood with one source
  for s in [h(-2, 1), h(0, 0), h(2, -2)] {
    let single = Reachability::compute(s, 10.0, passable, cost)
    let multi = Reachability::compute_multi([s], 10.0, passable, cost)
    for c in field {
      assert_eq(single.cost_to(c), multi.cost_to(c))
    }
  }
}

///|
test "dijkstra: multi-source cost is the min over sources" {
  fn passable(_c : @hex.Hex) -> Bool {
    true
  }
  fn cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    1.0
  }
  let a = h(-3, 0)
  let b = h(3, -3)
  let multi = Reachability::compute_multi([a, b], 10.0, passable, cost)
  let from_a = Reachability::compute(a, 10.0, passable, cost)
  let from_b = Reachability::compute(b, 10.0, passable, cost)
  for c in @hex.Hex::range(h(0, 0), 4) {
    let lo = match (from_a.cost_to(c), from_b.cost_to(c)) {
      (Some(x), Some(y)) => if x < y { x } else { y }
      (Some(x), None) => x
      (None, Some(y)) => y
      (None, None) => continue
    }
    assert_eq(multi.cost_to(c), Some(lo))
  }
  // the origin is 3 steps from either source here
  assert_eq(multi.cost_to(h(0, 0)), Some(3.0))
  // a path home terminates at some source
  let p = multi.path_to(h(0, 0)).unwrap()
  assert_true(p[0] == a || p[0] == b)
}

///|
test "dijkstra: multi-source seeds survive impassable terrain" {
  fn all_walls(_c : @hex.Hex) -> Bool {
    false
  }
  fn cost(_a : @hex.Hex, _b : @hex.Hex) -> Double {
    1.0
  }
  let multi = Reachability::compute_multi(
    [h(-1, 0), h(1, 0)],
    5.0,
    all_walls,
    cost,
  )
  // sources are exempt from the passable check, so both exist at cost 0
  assert_eq(multi.cost_to(h(-1, 0)), Some(0.0))
  assert_eq(multi.cost_to(h(1, 0)), Some(0.0))
  // any other cell requires entering an impassable cell -> unreachable
  assert_eq(multi.cost_to(h(0, 0)), None)
  assert_eq(multi.cost_to(h(2, 0)), None)
}
