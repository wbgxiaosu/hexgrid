///|
/// Stress: dense storage at radius 40 (4921 slots) — full index
/// roundtrip, full readback, no degradation.
test "stress: dense map over radius-40 hexagon" {
  let m : DenseHexMap[Int32] = DenseHexMap::make(Region::hexagon(40), -1)
  assert_eq(m.length(), 3 * 40 * 40 + 3 * 40 + 1)
  // write every slot through its index, then read back
  for i, c in m.cells {
    m.set(c, i % 977)
  }
  for i, c in m.cells {
    assert_eq(m.get(c), Some(i % 977))
    assert_eq(m.index_of(c), Some(i))
    assert_eq(m.cell_at(i), Some(c))
  }
}

///|
/// Stress: ASCII render of a 40x40 rectangle produces the exact row
/// structure (guards the large-format rendering crash class).
test "stress: render a 40x40 rectangle" {
  let m : HexMap[Int32] = HexMap::make(Region::rectangle(40, 40), 0)
  let out = m.render(fn(_v) { "x" })
  let lines = out.split("\n").collect()
  assert_eq(lines.length(), 40)
  // even row: 40 tokens with 39 separators; odd row: 1 indent + same
  assert_eq(lines[0].length(), 79)
  assert_eq(lines[1].length(), 80)
}
