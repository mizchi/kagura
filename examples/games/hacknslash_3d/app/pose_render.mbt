///|
struct PoseRenderBucket {
  matrices : Array[@math3d.Mat4]
  colors : Array[@math3d.Vec4]
}

///|
struct PoseRenderState {
  buckets : Map[Int, PoseRenderBucket]
  active_keys : Array[Int]
}

///|
fn PoseRenderState::clear(self : PoseRenderState) -> Unit {
  for key in self.active_keys {
    self.buckets[key].matrices.clear()
    self.buckets[key].colors.clear()
  }
  self.active_keys.clear()
}

///|
fn PoseRenderState::add(
  self : PoseRenderState,
  key : Int,
  model : @math3d.Mat4,
  color : @math3d.Vec4,
) -> Unit {
  let bucket = match self.buckets.get(key) {
    Some(bucket) => bucket
    None => {
      let bucket : PoseRenderBucket = { matrices: [], colors: [], }
      self.buckets[key] = bucket
      bucket
    }
  }
  if bucket.matrices.is_empty() {
    self.active_keys.push(key)
  }
  bucket.matrices.push(model)
  bucket.colors.push(color)
}

///|
// Reuse bind geometry and baked palettes; only instance transforms change.
fn GameState::push_baked_enemy_commands(
  self : GameState,
  poses : PoseRenderState,
  mesh : EnemyMeshData,
  skinning_for_key : (Int) -> Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  for key in poses.active_keys {
    let bucket = poses.buckets[key]
    let skinning = skinning_for_key(key)
    for part in mesh.parts {
      let colors = bucket.colors.map(tint => {
        @math3d.Vec4::new(
          part.color.x * tint.x,
          part.color.y * tint.y,
          part.color.z * tint.z,
          part.color.w,
        )
      })
      @web_hooks.register_static_geometry(
        part.geometry.packed_vertex_data,
        part.geometry.bind_mesh.indices,
      )
      @scene3d.push_skinned_mesh_gpu_commands_with_color_optimization_and_view_projection(
        part.geometry.bind_mesh,
        bucket.matrices,
        colors,
        part.geometry.packed_vertex_data,
        skinning,
        view_projection,
        self.lighting,
        dst,
        self.shader3d_skinned,
        self.shader3d_skinned_instanced,
        self.shader3d_skinned_instanced_monochrome,
        screen_w,
        screen_h,
        cmds,
      )
    }
  }
}
