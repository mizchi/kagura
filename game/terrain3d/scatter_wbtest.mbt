///|
test "coordinate rolls stay half-open and scatter has no query-order or chunk dependency" {
  for seed in [42, -19] {
    let whole : Array[(Int, Int)] = []
    let chunks : Array[(Int, Int)] = []
    for x in -20..<20 {
      for z in -20..<20 {
        let roll = coordinate_random(x, z, seed)
        assert_true(roll >= 0.0 && roll < 1.0)
        if priority_scatter_cell(x, z, seed, probability=0.4, radius=2) {
          whole.push((x, z))
          for dz in -2..<=2 {
            for dx in -2..<=2 {
              if dx != 0 || dz != 0 {
                assert_false(
                  priority_scatter_cell(
                    x + dx,
                    z + dz,
                    seed,
                    probability=0.4,
                    radius=2,
                  ),
                )
              }
            }
          }
        }
      }
    }
    for cx in [1, 0] {
      for x in (cx * 20 - 20)..<(cx * 20) {
        for z in -20..<20 {
          if priority_scatter_cell(x, z, seed, probability=0.4, radius=2) {
            chunks.push((x, z))
          }
        }
      }
    }
    assert_true(whole.length() > 20)
    assert_eq(whole.length(), chunks.length())
    assert_true(whole.all(p => chunks.contains(p)))
  }
  assert_false(priority_scatter_cell(0, 0, 0, probability=0.0))
  assert_true(priority_scatter_cell(0, 0, 0, probability=1.0, radius=0))
}

///|
test "warped density exposes independent scale and deformation without mutable random state" {
  let field : WarpedDensityField = {
    frequency_x: 0.16,
    frequency_z: 0.19,
    warp_x: 5.0,
    warp_z: 6.0,
    warp_frequency_x: 0.11,
    warp_frequency_z: 0.13,
  }
  let straight = { ..field, warp_x: 0.0, warp_z: 0.0, }
  let mut different = 0
  for z in -20..<20 {
    for x in -20..<20 {
      let value = field.sample(x.to_double(), z.to_double(), phase=0.42)
      assert_true(value >= 0.0 && value <= 1.0)
      assert_eq(field.sample(x.to_double(), z.to_double(), phase=0.42), value)
      assert_true(
        (field.sample(x.to_double() + 0.001, z.to_double(), phase=0.42) - value).abs() <
        0.001,
      )
      if (value - straight.sample(x.to_double(), z.to_double(), phase=0.42)).abs() >
        0.01 {
        different += 1
      }
    }
  }
  assert_true(different > 1000)
}
