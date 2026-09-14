///|
test "woodland clusters break rows while retaining clearance and a bounded obstacle count" {
  for seed in [42, 43, -19] {
    let rows = Array::make(3, 0)
    let columns = Array::make(3, 0)
    let mut count = 0
    for z in 3..<77 {
      for x in 3..<97 {
        if woodland_tree_cell(x, z, seed) {
          count += 1
          rows[z % 3] += 1
          columns[x % 3] += 1
          for dz in -1..<=1 {
            for dx in -1..<=1 {
              if dx != 0 || dz != 0 {
                assert_false(woodland_tree_cell(x + dx, z + dz, seed))
              }
            }
          }
        }
      }
    }
    assert_true(count > 180 && count < 650)
    assert_true(rows.all(n => n > 40) && columns.all(n => n > 40))
  }
}
