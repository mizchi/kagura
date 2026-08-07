///|
fn surface_samples_include(
  samples : Array[@modeling3d.BakedSurfaceSample],
  position : @math3d.Vec3,
  normal : @math3d.Vec3,
) -> Bool {
  for sample in samples {
    if sample.position.approx_eq(position, 1.0e-6) &&
      sample.normal.approx_eq(normal, 1.0e-6) {
      return true
    }
  }
  false
}

///|
test "sculpt_layer_baked_surface_samples exposes six faces for a single filled voxel" {
  let layer : @modeling3d.SculptLayer = {
    id: "single_voxel",
    voxel_size: 0.2,
    half_extent: 1,
    color_hex: 0xFFAA88,
    muted_stamp_ids: [],
    stamps: [
      {
        id: "core",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::zero(),
        radius: 0.05,
      },
    ],
  }
  let samples = @modeling3d.sculpt_layer_baked_surface_samples(layer)
  assert_eq(samples.length(), 6)
  assert_true(
    surface_samples_include(
      samples,
      @math3d.Vec3::new(0.0, 0.0, 0.1),
      @math3d.Vec3::unit_z(),
    ),
  )
  assert_true(
    surface_samples_include(
      samples,
      @math3d.Vec3::new(0.1, 0.0, 0.0),
      @math3d.Vec3::unit_x(),
    ),
  )
}

///|
test "sculpt_layer_baked_surface_samples ignores internal shared faces" {
  let layer : @modeling3d.SculptLayer = {
    id: "two_voxels",
    voxel_size: 0.2,
    half_extent: 1,
    color_hex: 0xFFAA88,
    muted_stamp_ids: [],
    stamps: [
      {
        id: "left",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::new(-0.2, 0.0, 0.0),
        radius: 0.05,
      },
      {
        id: "right",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::zero(),
        radius: 0.05,
      },
    ],
  }
  let samples = @modeling3d.sculpt_layer_baked_surface_samples(layer)
  assert_eq(samples.length(), 10)
  assert_false(
    surface_samples_include(
      samples,
      @math3d.Vec3::zero(),
      @math3d.Vec3::unit_x(),
    ),
  )
}

///|
test "sculpt_layer_density accumulates overlapping add stamps" {
  let single : @modeling3d.SculptLayer = {
    id: "single",
    voxel_size: 0.2,
    half_extent: 1,
    color_hex: 0xFFAA88,
    muted_stamp_ids: [],
    stamps: [
      {
        id: "a",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::zero(),
        radius: 0.2,
      },
    ],
  }
  let stacked : @modeling3d.SculptLayer = {
    ..single,
    id: "stacked",
    stamps: [
      {
        id: "a",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::zero(),
        radius: 0.2,
      },
      {
        id: "b",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::zero(),
        radius: 0.2,
      },
    ],
  }
  assert_true(
    @modeling3d.sculpt_layer_density(stacked, @math3d.Vec3::zero()) >
    @modeling3d.sculpt_layer_density(single, @math3d.Vec3::zero()),
  )
}

///|
test "sculpt_layer_baked_mesh emits a continuous surface for a single add stamp" {
  let layer : @modeling3d.SculptLayer = {
    id: "single_stamp",
    voxel_size: 0.2,
    half_extent: 1,
    color_hex: 0xFFAA88,
    muted_stamp_ids: [],
    stamps: [
      {
        id: "core",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::zero(),
        radius: 0.18,
      },
    ],
  }
  let mesh = @modeling3d.sculpt_layer_baked_mesh(layer)
  let bounds = mesh.bounds()
  assert_true(mesh.triangle_count() > 0)
  assert_true(mesh.vertex_count() > 0)
  assert_true(bounds.max_x > 0.05)
  assert_true(bounds.max_x < 0.25)
  assert_true(bounds.min_x < -0.05)
  assert_true(bounds.min_x > -0.25)
}
