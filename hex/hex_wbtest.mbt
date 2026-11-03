///|
fn h(q : Int32, r : Int32) -> Hex {
  { q, r, }
}

///|
test "distance: known values and symmetry" {
  // Red Blob Games reference cases
  assert_eq(h(1, -1).distance(h(0, 0)), 1)
  assert_eq(h(2, -1).distance(h(0, 0)), 2)
  assert_eq(h(3, -7).distance(h(0, 0)), 7)
  assert_eq(h(-3, 7).distance(h(0, 0)), 7)
  // symmetry across a wide neighbourhood
  for a in Hex::range(h(0, 0), 4) {
    for b in Hex::range(h(0, 0), 4) {
      assert_eq(a.distance(b), b.distance(a))
      assert_eq(a.distance(b), a.op_sub(b).distance(h(0, 0)))
    }
  }
}

///|
test "neighbors: every direction is exactly one step away" {
  for cell in Hex::range(h(0, 0), 3) {
    for d in 0..<6 {
      let n = cell.neighbor(d)
      assert_eq(cell.distance(n), 1)
    }
    // direction indices wrap around
    assert_eq(cell.neighbor(-1), cell.neighbor(5))
    assert_eq(cell.neighbor(7), cell.neighbor(1))
  }
}

///|
test "ring: sizes and distances" {
  assert_eq(Hex::ring(h(0, 0), 0), [h(0, 0)])
  assert_eq(Hex::ring(h(0, 0), -1).length(), 0)
  // ring N has 6*N cells, each exactly N steps away
  for radius in 1..<=5 {
    let cells = Hex::ring(h(2, -1), radius)
    assert_eq(cells.length(), 6 * radius)
    for c in cells {
      assert_eq(h(2, -1).distance(c), radius)
    }
  }
}

///|
test "range: hexagonal area sizes 3r^2+3r+1" {
  assert_eq(Hex::range(h(0, 0), 0).length(), 1)
  assert_eq(Hex::range(h(0, 0), 1).length(), 7)
  assert_eq(Hex::range(h(0, 0), 2).length(), 19)
  assert_eq(Hex::range(h(0, 0), 3).length(), 37)
  assert_eq(Hex::range(h(0, 0), 4).length(), 61)
  for radius in 1..<=5 {
    let cells = Hex::range(h(1, 1), radius)
    assert_eq(cells.length(), 3 * radius * radius + 3 * radius + 1)
    for c in cells {
      assert_true(h(1, 1).distance(c) <= radius)
    }
  }
  // no duplicates
  let cells = Hex::range(h(0, 0), 3)
  for i in 0..<cells.length() {
    for j in (i + 1)..<cells.length() {
      assert_true(!(cells[i] == cells[j]))
    }
  }
}

///|
test "spiral: concatenates rings in order" {
  let s = Hex::spiral(h(0, 0), 0, 2)
  assert_eq(s.length(), 1 + 6 + 12)
  assert_eq(Hex::spiral(h(0, 0), 2, 2).length(), 12)
  assert_eq(Hex::spiral(h(0, 0), 3, 2).length(), 0)
}

///|
test "line: straight east is straight, endpoints included" {
  let l = h(0, 0).line(h(5, 0))
  assert_eq(l.length(), 6)
  assert_eq(l[0], h(0, 0))
  assert_eq(l[5], h(5, 0))
  // consecutive cells on any line are exactly one step apart
  for a in Hex::range(h(0, 0), 3) {
    for b in Hex::range(h(0, 0), 3) {
      let l = a.line(b)
      assert_eq(l.length(), a.distance(b) + 1)
      assert_eq(l[0], a)
      assert_eq(l[l.length() - 1], b)
      for k in 0..<(l.length() - 1) {
        assert_eq(l[k].distance(l[k + 1]), 1)
      }
    }
  }
}

///|
test "rotate: 60-degree steps, identity at 6, distance preserved" {
  let origin = h(0, 0)
  assert_eq(h(4, -2).rotate(0), h(4, -2))
  assert_eq(h(4, -2).rotate(6), h(4, -2))
  assert_eq(h(4, -2).rotate(-6), h(4, -2))
  // rotating (1,-2) twice yields (1,1)
  assert_eq(h(1, -2).rotate(2), h(1, 1))
  for cell in Hex::range(origin, 3) {
    for steps in 0..<6 {
      let rot = cell.rotate(steps)
      assert_eq(origin.distance(rot), origin.distance(cell))
    }
    // six rotations orbit back to the start
    let mut cur = cell
    for _ in 0..<6 {
      cur = cur.rotate(1)
    }
    assert_eq(cur, cell)
  }
}

///|
test "reflect: involution and axis fixing" {
  for cell in Hex::range(h(0, 0), 3) {
    assert_eq(cell.reflect().reflect(), cell)
  }
  // cells on the E-W axis stay put: q = -r means the cell lies on the axis
  assert_eq(h(3, -3).reflect(), h(3, -3))
  assert_eq(h(0, 0).reflect(), h(0, 0))
}

///|
test "offset: roundtrip in all four layouts" {
  let layouts = [OddR, EvenR, OddQ, EvenQ]
  for layout in layouts {
    for cell in Hex::range(h(0, 0), 4) {
      let oc = OffsetCoord::from_axial(cell, layout)
      assert_eq(oc.to_axial(layout), cell)
    }
  }
  // the four layouts disagree on most cells (so they are real layouts)
  let cell = h(2, 3)
  let a = OffsetCoord::from_axial(cell, OddR)
  let b = OffsetCoord::from_axial(cell, EvenR)
  assert_true(!(a == b))
}

///|
test "pixel: from_pixel_round recovers every cell in both orientations" {
  for layout in [pointy_layout, flat_layout] {
    for cell in Hex::range(h(0, 0), 4) {
      let (x, y) = layout.axial_to_pixel(cell)
      assert_eq(Hex::from_pixel_round(x, y, layout), cell)
    }
  }
}

///|
test "lerp: endpoints are exact" {
  let (q0, r0, _) = h(2, -3).lerp(h(2, -3), 0.5)
  assert_eq(q0.round().to_int(), 2)
  assert_eq(r0.round().to_int(), -3)
  let (q1, r1, _) = h(1, 1).lerp(h(4, -2), 1.0)
  assert_eq(q1, 4.0)
  assert_eq(r1, -2.0)
}

///|
test "neighbors: exactly six distinct distance-1 cells" {
  for cell in Hex::range(h(0, 0), 3) {
    let ns = cell.neighbors()
    assert_eq(ns.length(), 6)
    for n in ns {
      assert_eq(cell.distance(n), 1)
    }
    // all distinct
    for i in 0..<6 {
      for j in (i + 1)..<6 {
        assert_false(ns[i] == ns[j])
      }
    }
  }
}

///|
test "neighbors: matches direction order" {
  let c = h(3, -1)
  for i in 0..<6 {
    assert_eq(c.neighbors()[i], c.neighbor(i))
  }
}
