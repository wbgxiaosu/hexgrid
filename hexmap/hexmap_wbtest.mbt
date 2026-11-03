///|
test "region: closed-form sizes match enumeration" {
  let regions = [
    Parallelogram(3, 4),
    Parallelogram(1, 1),
    Rectangle(5, 3),
    Rectangle(4, 4),
    Hexagon(0),
    Hexagon(2),
    Hexagon(4),
    Triangle(1),
    Triangle(5),
  ]
  for r in regions {
    let cs = r.cells()
    assert_eq(cs.length(), r.size())
    // all cells distinct
    for i in 0..<cs.length() {
      for j in (i + 1)..<cs.length() {
        assert_false(cs[i] == cs[j])
      }
    }
    // deterministic order: sorted by q then r
    for i in 0..<(cs.length() - 1) {
      let a = cs[i]
      let b = cs[i + 1]
      assert_true(a.q < b.q || (a.q == b.q && a.r < b.r))
    }
  }
}

///|
test "region: hexagon counts follow 3n^2+3n+1" {
  for n in 0..<=5 {
    assert_eq(Hexagon(n).cells().length(), 3 * n * n + 3 * n + 1)
  }
}

///|
test "rectangle: cells invert odd-r offset coordinates" {
  let w = 4
  let h = 3
  let cs = Rectangle(w, h).cells()
  assert_eq(cs.length(), w * h)
  // reconstruct (col, row) from each axial cell via the odd-r inverse
  for c in cs {
    let col = c.q + (c.r - (c.r & 1)) / 2
    assert_true(col >= 0 && col < w)
    assert_true(c.r >= 0 && c.r < h)
  }
}

///|
test "hexmap: make fills exactly the region" {
  let region : Region = Rectangle(3, 3)
  let m : HexMap[Int32] = HexMap::make(region, 0)
  assert_eq(m.length(), region.size())
  for c in region.cells() {
    assert_eq(m.get_or(c, -1), 0)
    assert_true(m.contains(c))
    assert_true(m.in_region(c))
  }
}

///|
test "hexmap: set, get, overwrite and remove" {
  let region : Region = Parallelogram(3, 3)
  let m : HexMap[String] = HexMap::make(region, ".")
  let c = @hex.Hex::make(1, 1)
  assert_eq(m.get_or(c, "?"), ".")
  m.set(c, "X")
  assert_eq(m.get_or(c, "?"), "X")
  assert_eq(m.get(c), Some("X"))
  assert_eq(m.remove(c), Some("X"))
  assert_false(m.contains(c))
  assert_eq(m.remove(c), None)
  // set outside the region is allowed (sparse semantics), in_region stays false
  let outside = @hex.Hex::make(50, 50)
  assert_false(m.in_region(outside))
  m.set(outside, "o")
  assert_true(m.contains(outside))
  assert_false(m.in_region(outside))
}

///|
test "hexmap: deterministic iteration order" {
  let m : HexMap[Int32] = HexMap::make_empty(Rectangle(3, 3))
  // insert in reverse order
  for c in Rectangle(3, 3).cells() {
    m.set(c, c.r * 10 + c.q)
  }
  let occ = m.occupied()
  assert_eq(occ.length(), 9)
  for i in 0..<(occ.length() - 1) {
    let a = occ[i]
    let b = occ[i + 1]
    assert_true(a.q < b.q || (a.q == b.q && a.r < b.r))
  }
  // values follow the same order as occupied cells
  let vals = m.values()
  assert_eq(vals.length(), 9)
  for i in 0..<vals.length() {
    assert_eq(vals[i], occ[i].r * 10 + occ[i].q)
  }
}

///|
test "hexmap: make_empty starts with no stored values" {
  let m : HexMap[Int32] = HexMap::make_empty(Hexagon(2))
  assert_eq(m.length(), 0)
  assert_eq(m.region(), Hexagon(2))
  assert_eq(m.get(@hex.Hex::make(0, 0)), None)
}
