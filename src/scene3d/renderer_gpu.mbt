// ============================================================
// GPU Z-buffer 3D rendering (per-object draw commands)
// ============================================================
// Unlike the CPU painter's algorithm renderer (renderer.mbt),
// this emits one DrawTrianglesCommand per object and relies on
// the GPU depth buffer for correct depth ordering.

///|
/// Render a SceneGraph using GPU Z-buffer depth testing.
/// Each visible mesh becomes a single draw command with lit shader uniforms.
/// No CPU-side depth sorting is needed — the GPU handles it via Z-buffer.
/// Optional shader parameters enable automatic shader selection based on material properties.
pub fn render_scene3d_graph_gpu(
  graph : SceneGraph,
  camera : @camera3d.Camera3D,
  lighting? : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  shader3d_textured? : @gfx.ShaderHandle? = None,
  shader3d_pbr? : @gfx.ShaderHandle? = None,
  shader3d_pbr_textured? : @gfx.ShaderHandle? = None,
  shader3d_skinned? : @gfx.ShaderHandle? = None,
) -> Array[@gfx.DrawTrianglesCommand] {
  let vp = camera.view_projection_matrix()
  let frustum = Frustum::from_vp(vp)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let identity = @math3d.Mat4::identity()
  for i in 0..<graph.roots.length() {
    traverse_node_gpu(
      graph,
      graph.roots[i],
      identity,
      vp,
      frustum,
      lighting,
      dst,
      shader3d,
      screen_w,
      screen_h,
      cmds,
      shader3d_textured~,
      shader3d_pbr~,
      shader3d_pbr_textured~,
      shader3d_skinned~,
      camera_pos=camera.position,
    )
  }
  cmds
}

///|
fn traverse_node_gpu(
  graph : SceneGraph,
  node_id : Int,
  parent_world : @math3d.Mat4,
  vp : @math3d.Mat4,
  frustum : Frustum,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
  shader3d_textured? : @gfx.ShaderHandle? = None,
  shader3d_pbr? : @gfx.ShaderHandle? = None,
  shader3d_pbr_textured? : @gfx.ShaderHandle? = None,
  shader3d_skinned? : @gfx.ShaderHandle? = None,
  camera_pos? : @math3d.Vec3 = @math3d.Vec3::new(0.0, 0.0, 0.0),
) -> Unit {
  match graph.nodes.get(node_id) {
    None => ()
    Some(node) => {
      let world = parent_world.multiply(node.transform.to_mat4())
      match node.mesh {
        Some(mesh) =>
          render_object_gpu(
            mesh,
            world,
            node.color,
            node.material,
            node.skinning,
            vp,
            frustum,
            lighting,
            dst,
            shader3d,
            screen_w,
            screen_h,
            cmds,
            shader3d_textured~,
            shader3d_pbr~,
            shader3d_pbr_textured~,
            shader3d_skinned~,
            camera_pos~,
          )
        None => ()
      }
      for i in 0..<node.children.length() {
        traverse_node_gpu(
          graph,
          node.children[i],
          world,
          vp,
          frustum,
          lighting,
          dst,
          shader3d,
          screen_w,
          screen_h,
          cmds,
          shader3d_textured~,
          shader3d_pbr~,
          shader3d_pbr_textured~,
          shader3d_skinned~,
          camera_pos~,
        )
      }
    }
  }
}

///|
/// Render a flat Scene3D (Object3D array) using GPU Z-buffer depth testing.
/// Each visible mesh becomes a single draw command with lit shader uniforms.
/// No CPU-side depth sorting is needed — the GPU handles it via Z-buffer.
pub fn render_scene3d_gpu(
  scene : Scene3D,
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  shader3d_textured? : @gfx.ShaderHandle? = None,
  shader3d_pbr? : @gfx.ShaderHandle? = None,
  shader3d_pbr_textured? : @gfx.ShaderHandle? = None,
  shader3d_skinned? : @gfx.ShaderHandle? = None,
) -> Array[@gfx.DrawTrianglesCommand] {
  let vp = scene.camera.view_projection_matrix()
  let frustum = Frustum::from_vp(vp)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let objects = sort_objects_for_gpu(scene.objects)
  for i in 0..<objects.length() {
    let obj = objects[i]
    let model = obj.transform.to_mat4()
    render_object_gpu(
      obj.mesh,
      model,
      obj.color,
      obj.material,
      obj.skinning,
      vp,
      frustum,
      scene.lighting,
      dst,
      shader3d,
      screen_w,
      screen_h,
      cmds,
      shader3d_textured~,
      shader3d_pbr~,
      shader3d_pbr_textured~,
      shader3d_skinned~,
      camera_pos=scene.camera.position,
    )
  }
  cmds
}

///|
fn sort_objects_for_gpu(objects : Array[Object3D]) -> Array[Object3D] {
  let ordered : Array[(Int, Object3D)] = []
  for i in 0..<objects.length() {
    ordered.push((i, objects[i]))
  }
  ordered.sort_by(fn(a, b) {
    let bias_a = a.1.sort_bias
    let bias_b = b.1.sort_bias
    if bias_a > bias_b {
      -1
    } else if bias_a < bias_b {
      1
    } else {
      a.0 - b.0
    }
  })
  let sorted : Array[Object3D] = []
  for entry in ordered {
    sorted.push(entry.1)
  }
  sorted
}

///|
fn render_object_gpu(
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  color : @math3d.Vec4,
  material : Material?,
  skinning : SkinningState?,
  vp : @math3d.Mat4,
  frustum : Frustum,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
  shader3d_textured? : @gfx.ShaderHandle? = None,
  shader3d_pbr? : @gfx.ShaderHandle? = None,
  shader3d_pbr_textured? : @gfx.ShaderHandle? = None,
  shader3d_skinned? : @gfx.ShaderHandle? = None,
  camera_pos? : @math3d.Vec3 = @math3d.Vec3::new(0.0, 0.0, 0.0),
) -> Unit {
  // Frustum culling
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(mesh)
  let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
    omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model,
  )
  if frustum_cull_aabb(frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) {
    return
  }
  // Resolve color and texture from material
  let (col, src_image_id, metallic, roughness, emissive) = match material {
    Some(mat) =>
      (mat.color, mat.src_image_id, mat.metallic, mat.roughness, mat.emissive)
    None => (color, -1, 0.0, 0.5, @math3d.Vec3::new(0.0, 0.0, 0.0))
  }
  let has_texture = src_image_id >= 0
  let is_pbr = metallic > 0.0 || roughness != 0.5
  // Build per-object lighting with object color baked into ambient/diffuse
  let tinted_lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      lighting.directional.direction,
      @math3d.Vec3::new(
        lighting.directional.color.x * col.x,
        lighting.directional.color.y * col.y,
        lighting.directional.color.z * col.z,
      ),
      lighting.directional.intensity,
    ),
    @light3d.AmbientLight::new(
      @math3d.Vec3::new(
        lighting.ambient.color.x * col.x,
        lighting.ambient.color.y * col.y,
        lighting.ambient.color.z * col.z,
      ),
      lighting.ambient.intensity,
    ),
  )
  let index_count = mesh.indices.length()
  let dst_region = @gfx.new_dst_region(0, 0, screen_w, screen_h, index_count)
  let src_image_ids : Array[Int] = if has_texture { [src_image_id] } else { [] }
  // Select shader and build draw command based on material properties
  if is_pbr {
    let shader = if has_texture {
      match shader3d_pbr_textured {
        Some(s) => s
        None =>
          match shader3d_pbr {
            Some(s) => s
            None => shader3d
          }
      }
    } else {
      match shader3d_pbr {
        Some(s) => s
        None => shader3d
      }
    }
    let cmd = @draw3d.new_pbr_mesh_draw_command(
      dst,
      shader,
      dst_region,
      0,
      0,
      0,
      @gfx.blend_mode_from_int(1),
      mesh,
      model,
      vp,
      tinted_lighting,
      metallic,
      roughness,
      col,
      emissive,
      camera_pos,
      src_image_ids,
    )
    cmds.push(cmd)
  } else {
    match (skinning, shader3d_skinned) {
      (Some(sk), Some(skinned_shader)) => {
        let cmd = match sk.packed_vertex_data {
          Some(packed_vertex_data) =>
            @draw3d.new_skinned_lit_mesh_draw_command(
              dst,
              skinned_shader,
              dst_region,
              0,
              0,
              0,
              @gfx.blend_mode_from_int(1),
              packed_vertex_data,
              mesh.indices,
              model,
              vp,
              tinted_lighting,
              sk.skinning_matrices,
              src_image_ids,
            )
          None =>
            @draw3d.new_skinned_lit_mesh_draw_command_from_skin(
              dst,
              skinned_shader,
              dst_region,
              0,
              0,
              0,
              @gfx.blend_mode_from_int(1),
              mesh,
              sk.skin,
              model,
              vp,
              tinted_lighting,
              sk.skinning_matrices,
              src_image_ids,
            )
        }
        cmds.push(cmd)
      }
      _ => {
        let shader = if has_texture {
          match shader3d_textured {
            Some(s) => s
            None => shader3d
          }
        } else {
          shader3d
        }
        let cmd = @draw3d.new_lit_mesh_draw_command(
          dst,
          shader,
          dst_region,
          0,
          0,
          0,
          @gfx.blend_mode_from_int(1),
          mesh,
          model,
          vp,
          tinted_lighting,
          src_image_ids,
        )
        cmds.push(cmd)
      }
    }
  }
}

///|
/// Render multiple instances of the same mesh in a single draw call.
pub fn render_instanced_gpu(
  mesh : @mesh3d.Mesh3D,
  instances : Array[InstanceData],
  camera : @camera3d.Camera3D,
  lighting? : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
  dst : @gfx.ImageHandle,
  shader3d_instanced : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
) -> @gfx.DrawTrianglesCommand {
  let vp = camera.view_projection_matrix()
  let instance_matrices : Array[@math3d.Mat4] = []
  let instance_colors : Array[@math3d.Vec4] = []
  for inst in instances {
    instance_matrices.push(inst.transform.to_mat4())
    instance_colors.push(inst.color)
  }
  let index_count = mesh.indices.length()
  let dst_region = @gfx.new_dst_region(0, 0, screen_w, screen_h, index_count)
  @draw3d.new_instanced_lit_mesh_draw_command(
    dst,
    shader3d_instanced,
    dst_region,
    @gfx.blend_mode_from_int(1),
    mesh,
    vp,
    lighting,
    instance_matrices,
    instance_colors,
  )
}
