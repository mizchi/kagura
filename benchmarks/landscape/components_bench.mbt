///|
test "phase camera sweep 64 clear rays" (b : @bench.T) {
  let start = @math3d.Vec3::new(3.5, 2.0, 3.0)
  let ends = Array::makei(64, i => {
    @math3d.Vec3::new(4.0 + i.to_double() * 0.01, 3.0, 8.0)
  })
  b.bench(name="landscape/phase_camera_clear_64", fn() {
    b.keep(
      ends.map(end => @camera3d.sweep_camera_boom(start, end, p => p.y < 0.18)),
    )
  })
}

///|
test "phase camera sweep 64 obstructed rays" (b : @bench.T) {
  let start = @math3d.Vec3::new(3.5, 2.0, 3.0)
  let ends = Array::makei(64, i => {
    @math3d.Vec3::new(4.0 + i.to_double() * 0.01, 3.0, 8.0)
  })
  b.bench(name="landscape/phase_camera_blocked_64", fn() {
    b.keep(
      ends.map(end => @camera3d.sweep_camera_boom(start, end, p => p.z >= 6.0)),
    )
  })
}

///|
test "build visibility uniform tails 128" (b : @bench.T) {
  let mask = fixture_mask()
  b.bench(name="landscape/build_visibility_tails_128", fn() {
    let words : Array[Int] = []
    for _ in 0..<128 {
      mask.append_uniform_dwords(words)
    }
    b.keep(words)
  })
}

///|
test "build lit scenery uniforms 128" (b : @bench.T) {
  let models = fixture_models(128)
  let vp = @math3d.Mat4::perspective(0.7, 1.4, 0.1, 700.0)
  let lighting = @light3d.LightingEnvironment::default()
  let mask = fixture_mask()
  b.bench(name="landscape/build_scenery_uniforms_128", fn() {
    b.keep(fixture_scenery_uniforms(models, vp, lighting, mask))
  })
}

///|
test "build skinned draws 64 actors 18 bones" (b : @bench.T) {
  let models = fixture_models(64)
  let vp = @math3d.Mat4::perspective(0.7, 1.4, 0.1, 700.0)
  let lighting = @light3d.LightingEnvironment::default()
  let clip = fixture_bake(fixture_skeleton())
  let dst = @gfx.new_image_handle(1, 1280, 900)
  let shader = @gfx.new_shader_handle(1, "fixture")
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let vertices = fixture_skin_vertices(mesh)
  let region = @gfx.new_dst_region(0, 0, 1280, 900, mesh.indices.length())
  b.bench(name="landscape/build_skinned_draws_64", fn() {
    let commands = Array::makei(64, i => {
      @draw3d.new_skinned_lit_mesh_draw_command(
        dst,
        shader,
        region,
        0,
        0,
        0,
        @gfx.BlendMode::from_int(0),
        vertices,
        mesh.indices,
        models[i],
        vp,
        lighting,
        clip.matrices(i % 48),
        [],
      )
    })
    b.keep(commands)
  })
}

///|
test "build monochrome skinning uniforms 8 groups of 8 actors" (b : @bench.T) {
  let models = fixture_models(8)
  let vp = @math3d.Mat4::perspective(0.7, 1.4, 0.1, 700.0)
  let lighting = @light3d.LightingEnvironment::default()
  let clip = fixture_bake(fixture_skeleton())
  let color = @math3d.Vec4::new(0.3, 0.4, 0.2, 1.0)
  b.bench(name="landscape/build_skinned_groups_8x8", fn() {
    b.keep(
      Array::makei(8, i => {
        @draw3d.skinned_instanced_monochrome_lit_uniform_dwords(
          vp,
          lighting,
          clip.matrices(i * 6),
          models,
          color,
        )
      }),
    )
  })
}

///|
test "build procedural pose bank 48 by 18 bones" (b : @bench.T) {
  let skeleton = fixture_skeleton()
  b.bench(name="landscape/build_pose_bank_48x18", fn() {
    b.keep(fixture_bake(skeleton))
  })
}

///|
test "phase cached pose lookup for 64 actors" (b : @bench.T) {
  let clip = fixture_bake(fixture_skeleton())
  b.bench(name="landscape/phase_cached_poses_64", fn() {
    for i in 0..<64 {
      b.keep(clip.matrices(i % 48))
    }
  })
}

///|
test "build scatter for a 100 by 80 region" (b : @bench.T) {
  b.bench(name="landscape/build_scatter_100x80", fn() {
    b.keep(fixture_scatter(100, 80))
  })
}

///|
test "build scatter for a 20 by 20 chunk" (b : @bench.T) {
  b.bench(name="landscape/build_scatter_20x20", fn() {
    b.keep(fixture_scatter(20, 20))
  })
}
