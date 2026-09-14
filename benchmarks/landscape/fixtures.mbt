///|
/// Consumer fixtures call the shipping APIs; no alternative implementations.
fn fixture_mask() -> @draw3d.CameraOcclusion {
  {
    eye: @math3d.Vec3::new(3.5, 3.0, 7.5),
    target: @math3d.Vec3::new(3.5, 1.0, 3.0),
    enabled: true,
    eye_radius: 1.25,
    target_radius: 0.85,
    softness: 0.55,
    end_fraction: 0.97,
  }
}

///|
fn fixture_models(count : Int) -> Array[@math3d.Mat4] {
  Array::makei(count, i => {
    @math3d.Mat4::translation((i % 8).to_double(), 0.25, (i / 8).to_double())
  })
}

///|
fn fixture_skeleton() -> @skeleton3d.Skeleton {
  @skeleton3d.Skeleton::new(
    Array::makei(18, i => {
      name: "joint_\{i}",
      parent: if i == 0 {
        -1
      } else {
        0
      },
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, i.to_double() * 0.04, 0.0),
      ),
    }),
    Array::makei(18, i => {
      @math3d.Mat4::translation(0.0, -i.to_double() * 0.04, 0.0)
    }),
  )
}

///|
fn fixture_bake(skeleton : @skeleton3d.Skeleton) -> @scene3d.BakedSkinningClip {
  @scene3d.BakedSkinningClip::from_pose_sampler(skeleton, 48, i => {
    let poses = skeleton.bones.map(b => b.local_transform)
    poses[0] = poses[0].with_position(
      @math3d.Vec3::new(i.to_double() * 0.002, 0.0, 0.0),
    )
    poses
  })
}

///|
fn fixture_skin_vertices(mesh : @mesh3d.Mesh3D) -> Array[Double] {
  let vertices : Array[Double] = []
  for i in 0..<mesh.vertex_count() {
    for j in 0..<8 {
      vertices.push(mesh.vertex_data[i * 8 + j])
    }
    vertices.append([0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0])
  }
  vertices
}

///|
fn fixture_scenery_uniforms(
  models : Array[@math3d.Mat4],
  vp : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  mask : @draw3d.CameraOcclusion,
) -> Array[Array[Int]] {
  models.map(model => {
    let words = @draw3d.lit_colored_uniform_dwords(
      model,
      vp,
      lighting,
      @math3d.Vec4::new(3.5, 98.0, 3.0, 0.0),
    )
    mask.append_uniform_dwords(words)
    words
  })
}

///|
fn fixture_scatter(width : Int, height : Int) -> Array[Bool] {
  let density : @terrain3d.WarpedDensityField = {
    frequency_x: 0.16,
    frequency_z: 0.19,
    warp_x: 5.0,
    warp_z: 6.0,
    warp_frequency_x: 0.11,
    warp_frequency_z: 0.13,
  }
  Array::makei(width * height, i => {
    let x = i % width
    let z = i / width
    @terrain3d.priority_scatter_cell(
      x,
      z,
      42,
      probability=0.025 +
        density.sample(x.to_double(), z.to_double(), phase=42.0 * 0.013) * 0.20,
      radius=1,
    )
  })
}
