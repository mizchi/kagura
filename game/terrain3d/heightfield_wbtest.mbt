///|
test "height generators are deterministic, bounded and distinct" {
  let fields : Array[HeightField] = []
  for pattern in [Perlin, DiamondSquare, Voronoi, Hybrid] {
    let config = TerrainConfig::{
      ..TerrainConfig::default(),
      pattern,
      seed: 42,
      amplitude: 4.0,
    }
    let a = generate_height_field(40, 32, config)
    let b = generate_height_field(40, 32, config)
    let c = generate_height_field(40, 32, { ..config, seed: 43, })
    assert_eq(a.values, b.values)
    assert_true(a.values != c.values)
    assert_eq(a.values.length(), 41 * 33)
    let stats = a.statistics()
    assert_true(stats.minimum >= 0.0)
    assert_true(stats.maximum <= 4.0)
    assert_true(stats.maximum - stats.minimum > 0.5)
    for previous in fields {
      assert_true(a.values != previous.values)
    }
    fields.push(a)
  }
}

///|
test "surface sampling matches each rendered triangle and shared crop edges" {
  let field = HeightField::new(1, 1, [0.0, 1.0, 2.0, 5.0])
  assert_eq(field.sample(0.25, 0.75), 2.25)
  assert_eq(field.sample(0.75, 0.25), 1.75)
  assert_eq(field.sample(1.0, 1.0), 5.0)
  let source = generate_height_field(40, 30, TerrainConfig::default())
  let left = source.crop(0, 0, 20, 30)
  let right = source.crop(20, 0, 20, 30)
  for z in 0..<=30 {
    assert_eq(
      left.sample(20.0, z.to_double()),
      right.sample(0.0, z.to_double()),
    )
  }
}

///|
test "slope limiter preserves flat pads while bounding triangle slope" {
  let field = generate_height_field(50, 40, {
    ..TerrainConfig::default(),
    pattern: Voronoi,
    amplitude: 12.0,
    scale: 6.0,
  })
  for z in 15..<25 {
    for x in 15..<25 {
      field.set(x, z, 0.0)
    }
  }
  field.limit_slope(0.4)
  for z in 15..<25 {
    for x in 15..<25 {
      assert_eq(field.at(x, z), 0.0)
    }
  }
  assert_true(field.statistics().max_slope <= 0.4 * 2.0.sqrt() + 0.00001)
}

///|
test "zero amplitude is flat, and generation is bounded for invalid dimensions and parameters" {
  for pattern in [Flat, Perlin, DiamondSquare, Voronoi, Hybrid] {
    let field = generate_height_field(8, 8, {
      ..TerrainConfig::default(),
      pattern,
      amplitude: 0.0,
    })
    assert_true(field.values.all(h => h == 0.0))
  }
  let small = generate_height_field(0, -1, {
    ..TerrainConfig::default(),
    scale: 0.0,
    roughness: 4.0,
  })
  assert_eq(small.values.length(), 4)
  assert_true(small.values.all(h => !h.is_nan()))
}

///|
test "heightfield raycast hits rendered triangles from above and outside, and misses sky" {
  let field = HeightField::new(1, 1, [0.0, 1.0, 2.0, 4.0])
  let hit = field.raycast(0.25, 6.0, 0.75, 0.0, -1.0, 0.0).unwrap()
  assert_true((hit.1 - field.sample(hit.0, hit.2)).abs() < 0.00001)
  assert_eq(hit.1, 2.0)
  let hit = field.raycast(-2.0, 3.0, 0.5, 1.0, -0.5, 0.0).unwrap()
  assert_true((hit.1 - field.sample(hit.0, hit.2)).abs() < 0.00001)
  assert_true(field.raycast(0.5, 6.0, 0.5, 0.0, 1.0, 0.0) is None)
  assert_true(field.raycast(-1.0, 6.0, 0.5, 0.0, -1.0, 0.0) is None)
  assert_true(
    field.raycast(0.5, 6.0, 0.5, 0.0, -1.0, 0.0, max_distance=1.0) is None,
  )
}

///|
test "ground overlays split at terrain edges so their interiors cannot sink below ridges" {
  let field = HeightField::new(2, 2, [
    0.0, 2.0, 0.0, 2.0, 0.0, 2.0, 0.0, 2.0, 0.0,
  ])
  let mesh = field.project_polygon(
    [(0.2, 0.3), (1.8, 0.3), (1.8, 1.7), (0.2, 1.7)],
    lift=0.01,
  )
  assert_true(mesh.indices.length() > 6)
  for i = 0; i < mesh.indices.length(); i = i + 3 {
    let mut x = 0.0
    let mut y = 0.0
    let mut z = 0.0
    for j in 0..<3 {
      let k = mesh.indices[i + j] * 8
      x += mesh.vertex_data[k] / 3.0
      y += mesh.vertex_data[k + 1] / 3.0
      z += mesh.vertex_data[k + 2] / 3.0
      assert_true(mesh.vertex_data[k + 4] > 0.0)
    }
    assert_true((y - field.sample(x, z) - 0.01).abs() < 0.000001)
  }
  assert_eq(
    field.project_polygon([(-3.0, -3.0), (-2.0, -3.0), (-2.0, -2.0)]).indices.length(),
    0,
  )
}

///|
test "ray traverses multiple cells and near-vertical rays do not stall on grid edges" {
  let field = HeightField::new(
    6,
    6,
    Array::makei(49, i => (i % 7).to_double() * 0.2 + (i / 7).to_double() * 0.3),
  )
  let hit = field.raycast(-3.0, 8.0, 7.0, 0.4, -0.5, -0.2).unwrap()
  assert_true((hit.0 - 2.0).abs() < 0.00001)
  assert_true((hit.1 - 1.75).abs() < 0.00001)
  assert_true((hit.2 - 4.5).abs() < 0.00001)
  let hit = field.raycast(3.0, 8.0, 4.5, -1.0e-9, -1.0, 0.0).unwrap()
  assert_true((hit.1 - field.sample(hit.0, hit.2)).abs() < 0.00001)
}
