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
  let light_dwords = @light3d.light_uniform_dwords(lighting)
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
      light_dwords,
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
  light_dwords : Array[Int],
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
            light_dwords,
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
          light_dwords,
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
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_scene3d_gpu_commands(
    scene.objects,
    scene.camera,
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
  )
  cmds
}

///|
pub fn push_scene3d_gpu_commands(
  objects : Array[Object3D],
  camera : @camera3d.Camera3D,
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
) -> Unit {
  let vp = camera.view_projection_matrix()
  let frustum = Frustum::from_vp(vp)
  let camera_pos = camera.position
  let light_dwords = @light3d.light_uniform_dwords(lighting)
  if has_nonzero_sort_bias_gpu(objects) {
    let ordered_indices = sort_object_indices_for_gpu(objects)
    for index in ordered_indices {
      let obj = objects[index]
      let model = obj.transform.to_mat4()
      render_object_gpu(
        obj.mesh,
        model,
        obj.color,
        obj.material,
        obj.skinning,
        vp,
        frustum,
        lighting,
        light_dwords,
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
  } else {
    for obj in objects {
      let model = obj.transform.to_mat4()
      render_object_gpu(
        obj.mesh,
        model,
        obj.color,
        obj.material,
        obj.skinning,
        vp,
        frustum,
        lighting,
        light_dwords,
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

///|
pub fn push_object3d_gpu_commands(
  obj : Object3D,
  camera : @camera3d.Camera3D,
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
) -> Unit {
  push_scene3d_gpu_commands(
    [obj],
    camera,
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
  )
}

///|
pub fn push_skinned_mesh_gpu_commands(
  mesh : @mesh3d.Mesh3D,
  instance_transforms : Array[@transform3d.Transform3D],
  instance_colors : Array[@math3d.Vec4],
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  camera : @camera3d.Camera3D,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  shader3d_skinned_instanced : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let count = if instance_transforms.length() < instance_colors.length() {
    instance_transforms.length()
  } else {
    instance_colors.length()
  }
  if count == 0 {
    return
  }
  let vp = camera.view_projection_matrix()
  push_skinned_mesh_gpu_commands_with_view_projection(
    mesh, instance_transforms, instance_colors, packed_vertex_data, skinning_matrices,
    vp, lighting, dst, shader3d_skinned, shader3d_skinned_instanced, screen_w, screen_h,
    cmds,
  )
}

///|
pub fn push_skinned_mesh_gpu_commands_with_view_projection(
  mesh : @mesh3d.Mesh3D,
  instance_transforms : Array[@transform3d.Transform3D],
  instance_colors : Array[@math3d.Vec4],
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  shader3d_skinned_instanced : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let count = if instance_transforms.length() < instance_colors.length() {
    instance_transforms.length()
  } else {
    instance_colors.length()
  }
  if count == 0 {
    return
  }
  let instance_matrices : Array[@math3d.Mat4] = []
  for i in 0..<count {
    instance_matrices.push(instance_transforms[i].to_mat4())
  }
  push_skinned_mesh_gpu_commands_from_matrices_with_view_projection(
    mesh, instance_matrices, instance_colors, packed_vertex_data, skinning_matrices,
    view_projection, lighting, dst, shader3d_skinned, shader3d_skinned_instanced,
    screen_w, screen_h, cmds,
  )
}

///|
pub fn push_skinned_mesh_gpu_commands_from_matrices_with_view_projection(
  mesh : @mesh3d.Mesh3D,
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  shader3d_skinned_instanced : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let frustum = Frustum::from_vp(view_projection)
  push_skinned_mesh_gpu_commands_from_matrices_with_frustum(
    mesh, instance_matrices, instance_colors, packed_vertex_data, skinning_matrices,
    view_projection, frustum, lighting, dst, shader3d_skinned, shader3d_skinned_instanced,
    screen_w, screen_h, cmds,
  )
}

///|
pub fn push_skinned_mesh_gpu_commands_from_matrices_with_uniform_color_and_view_projection(
  mesh : @mesh3d.Mesh3D,
  instance_matrices : Array[@math3d.Mat4],
  base_color : @math3d.Vec4,
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  _shader3d_skinned_instanced : @gfx.ShaderHandle,
  shader3d_skinned_instanced_monochrome : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let frustum = Frustum::from_vp(view_projection)
  let count = instance_matrices.length()
  if count == 0 {
    return
  }
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(mesh)
  let visible_instance_matrices : Array[@math3d.Mat4] = []
  let dst_region = @gfx.new_dst_region(
    0,
    0,
    screen_w,
    screen_h,
    mesh.indices.length(),
  )
  for i in 0..<count {
    let model = instance_matrices[i]
    let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
      omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model,
    )
    if frustum_cull_aabb(
        frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z,
      ) {
      continue
    }
    visible_instance_matrices.push(model)
  }
  if visible_instance_matrices.is_empty() {
    return
  }
  if visible_instance_matrices.length() == 1 {
    push_single_skinned_mesh_gpu_command_from_matrix_with_frustum(
      mesh,
      visible_instance_matrices[0],
      base_color,
      packed_vertex_data,
      skinning_matrices,
      view_projection,
      frustum,
      lighting,
      dst,
      shader3d_skinned,
      screen_w,
      screen_h,
      cmds,
    )
    return
  }
  let chunk_size = @draw3d.skinned_instanced_max_instances()
  let mut start = 0
  while start < visible_instance_matrices.length() {
    let end = if start + chunk_size < visible_instance_matrices.length() {
      start + chunk_size
    } else {
      visible_instance_matrices.length()
    }
    let chunk_len = end - start
    if chunk_len == 1 {
      push_single_skinned_mesh_gpu_command_from_matrix_with_frustum(
        mesh,
        visible_instance_matrices[start],
        base_color,
        packed_vertex_data,
        skinning_matrices,
        view_projection,
        frustum,
        lighting,
        dst,
        shader3d_skinned,
        screen_w,
        screen_h,
        cmds,
      )
    } else {
      let chunk_matrices : Array[@math3d.Mat4] = []
      for i in start..<end {
        chunk_matrices.push(visible_instance_matrices[i])
      }
      cmds.push(
        @draw3d.new_skinned_instanced_monochrome_lit_mesh_draw_command(
          dst,
          shader3d_skinned_instanced_monochrome,
          dst_region,
          @gfx.BlendMode::from_int(1),
          packed_vertex_data,
          mesh.indices,
          view_projection,
          lighting,
          skinning_matrices,
          chunk_matrices,
          base_color,
        ),
      )
    }
    start = end
  }
}

///|
pub fn uniform_instance_color(
  instance_colors : Array[@math3d.Vec4],
) -> @math3d.Vec4? {
  if instance_colors.is_empty() {
    return None
  }
  let first = instance_colors[0]
  for i in 1..<instance_colors.length() {
    let color = instance_colors[i]
    if color.x != first.x ||
      color.y != first.y ||
      color.z != first.z ||
      color.w != first.w {
      return None
    }
  }
  Some(first)
}

///|
pub fn push_skinned_mesh_gpu_commands_with_color_optimization_and_view_projection(
  mesh : @mesh3d.Mesh3D,
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  shader3d_skinned_instanced : @gfx.ShaderHandle,
  shader3d_skinned_instanced_monochrome : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  match uniform_instance_color(instance_colors) {
    Some(base_color) =>
      push_skinned_mesh_gpu_commands_from_matrices_with_uniform_color_and_view_projection(
        mesh, instance_matrices, base_color, packed_vertex_data, skinning_matrices,
        view_projection, lighting, dst, shader3d_skinned, shader3d_skinned_instanced,
        shader3d_skinned_instanced_monochrome, screen_w, screen_h, cmds,
      )
    None =>
      push_skinned_mesh_gpu_commands_from_matrices_with_view_projection(
        mesh, instance_matrices, instance_colors, packed_vertex_data, skinning_matrices,
        view_projection, lighting, dst, shader3d_skinned, shader3d_skinned_instanced,
        screen_w, screen_h, cmds,
      )
  }
}

///|
fn push_instanced_mesh_gpu_commands_from_matrices_with_colors_and_view_projection(
  mesh : @mesh3d.Mesh3D,
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_colored : @gfx.ShaderHandle,
  shader3d_instanced : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let count = if instance_matrices.length() < instance_colors.length() {
    instance_matrices.length()
  } else {
    instance_colors.length()
  }
  if count == 0 {
    return
  }
  let frustum = Frustum::from_vp(view_projection)
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(mesh)
  let visible_instance_matrices : Array[@math3d.Mat4] = []
  let visible_instance_colors : Array[@math3d.Vec4] = []
  let dst_region = @gfx.new_dst_region(
    0,
    0,
    screen_w,
    screen_h,
    mesh.indices.length(),
  )
  for i in 0..<count {
    let model = instance_matrices[i]
    let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
      omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model,
    )
    if frustum_cull_aabb(
        frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z,
      ) {
      continue
    }
    visible_instance_matrices.push(model)
    visible_instance_colors.push(instance_colors[i])
  }
  if visible_instance_matrices.is_empty() {
    return
  }
  if visible_instance_matrices.length() == 1 {
    cmds.push(
      @draw3d.new_lit_colored_mesh_draw_command(
        dst,
        shader3d_colored,
        dst_region,
        0,
        0,
        0,
        @gfx.BlendMode::from_int(1),
        mesh,
        visible_instance_matrices[0],
        view_projection,
        lighting,
        visible_instance_colors[0],
        [],
      ),
    )
    return
  }
  cmds.push(
    @draw3d.new_instanced_lit_mesh_draw_command(
      dst,
      shader3d_instanced,
      dst_region,
      @gfx.BlendMode::from_int(1),
      mesh,
      view_projection,
      lighting,
      visible_instance_matrices,
      visible_instance_colors,
    ),
  )
}

///|
pub fn push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(
  mesh : @mesh3d.Mesh3D,
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_colored : @gfx.ShaderHandle,
  shader3d_instanced : @gfx.ShaderHandle,
  shader3d_instanced_monochrome : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  match uniform_instance_color(instance_colors) {
    Some(base_color) =>
      push_instanced_mesh_gpu_commands_from_matrices_with_uniform_color_and_view_projection(
        mesh, instance_matrices, base_color, view_projection, lighting, dst, shader3d_colored,
        shader3d_instanced_monochrome, screen_w, screen_h, cmds,
      )
    None =>
      push_instanced_mesh_gpu_commands_from_matrices_with_colors_and_view_projection(
        mesh, instance_matrices, instance_colors, view_projection, lighting, dst,
        shader3d_colored, shader3d_instanced, screen_w, screen_h, cmds,
      )
  }
}

///|
pub fn push_instanced_instance_data_gpu_commands_with_color_optimization_and_view_projection(
  mesh : @mesh3d.Mesh3D,
  instances : Array[InstanceData],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_colored : @gfx.ShaderHandle,
  shader3d_instanced : @gfx.ShaderHandle,
  shader3d_instanced_monochrome : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  if instances.is_empty() {
    return
  }
  let instance_matrices : Array[@math3d.Mat4] = []
  let instance_colors : Array[@math3d.Vec4] = []
  for inst in instances {
    instance_matrices.push(inst.transform.to_mat4())
    instance_colors.push(inst.color)
  }
  push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(
    mesh, instance_matrices, instance_colors, view_projection, lighting, dst, shader3d_colored,
    shader3d_instanced, shader3d_instanced_monochrome, screen_w, screen_h, cmds,
  )
}

///|
pub fn push_instanced_mesh_gpu_commands_from_matrices_with_uniform_color_and_view_projection(
  mesh : @mesh3d.Mesh3D,
  instance_matrices : Array[@math3d.Mat4],
  base_color : @math3d.Vec4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_colored : @gfx.ShaderHandle,
  shader3d_instanced_monochrome : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let frustum = Frustum::from_vp(view_projection)
  let count = instance_matrices.length()
  if count == 0 {
    return
  }
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(mesh)
  let visible_instance_matrices : Array[@math3d.Mat4] = []
  let dst_region = @gfx.new_dst_region(
    0,
    0,
    screen_w,
    screen_h,
    mesh.indices.length(),
  )
  for i in 0..<count {
    let model = instance_matrices[i]
    let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
      omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model,
    )
    if frustum_cull_aabb(
        frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z,
      ) {
      continue
    }
    visible_instance_matrices.push(model)
  }
  if visible_instance_matrices.is_empty() {
    return
  }
  if visible_instance_matrices.length() == 1 {
    cmds.push(
      @draw3d.new_lit_colored_mesh_draw_command(
        dst,
        shader3d_colored,
        dst_region,
        0,
        0,
        0,
        @gfx.BlendMode::from_int(1),
        mesh,
        visible_instance_matrices[0],
        view_projection,
        lighting,
        base_color,
        [],
      ),
    )
    return
  }
  let chunk_size = @draw3d.instanced_monochrome_max_instances()
  let mut start = 0
  while start < visible_instance_matrices.length() {
    let end = if start + chunk_size < visible_instance_matrices.length() {
      start + chunk_size
    } else {
      visible_instance_matrices.length()
    }
    let chunk_len = end - start
    if chunk_len == 1 {
      cmds.push(
        @draw3d.new_lit_colored_mesh_draw_command(
          dst,
          shader3d_colored,
          dst_region,
          0,
          0,
          0,
          @gfx.BlendMode::from_int(1),
          mesh,
          visible_instance_matrices[start],
          view_projection,
          lighting,
          base_color,
          [],
        ),
      )
    } else {
      let chunk_matrices : Array[@math3d.Mat4] = []
      for i in start..<end {
        chunk_matrices.push(visible_instance_matrices[i])
      }
      cmds.push(
        @draw3d.new_instanced_monochrome_lit_mesh_draw_command(
          dst,
          shader3d_instanced_monochrome,
          dst_region,
          @gfx.BlendMode::from_int(1),
          mesh,
          view_projection,
          lighting,
          chunk_matrices,
          base_color,
        ),
      )
    }
    start = end
  }
}

///|
fn push_skinned_mesh_gpu_commands_from_matrices_with_frustum(
  mesh : @mesh3d.Mesh3D,
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  frustum : Frustum,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  shader3d_skinned_instanced : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let count = if instance_matrices.length() < instance_colors.length() {
    instance_matrices.length()
  } else {
    instance_colors.length()
  }
  if count == 0 {
    return
  }
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(mesh)
  let visible_instance_matrices : Array[@math3d.Mat4] = []
  let visible_instance_colors : Array[@math3d.Vec4] = []
  let dst_region = @gfx.new_dst_region(
    0,
    0,
    screen_w,
    screen_h,
    mesh.indices.length(),
  )
  for i in 0..<count {
    let model = instance_matrices[i]
    let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
      omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model,
    )
    if frustum_cull_aabb(
        frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z,
      ) {
      continue
    }
    visible_instance_matrices.push(model)
    visible_instance_colors.push(instance_colors[i])
  }
  if visible_instance_matrices.is_empty() {
    return
  }
  if visible_instance_matrices.length() == 1 {
    push_single_skinned_mesh_gpu_command_from_matrix_with_frustum(
      mesh,
      visible_instance_matrices[0],
      visible_instance_colors[0],
      packed_vertex_data,
      skinning_matrices,
      view_projection,
      frustum,
      lighting,
      dst,
      shader3d_skinned,
      screen_w,
      screen_h,
      cmds,
    )
    return
  }
  let chunk_size = @draw3d.skinned_instanced_max_instances()
  let mut start = 0
  while start < visible_instance_matrices.length() {
    let end = if start + chunk_size < visible_instance_matrices.length() {
      start + chunk_size
    } else {
      visible_instance_matrices.length()
    }
    let chunk_len = end - start
    if chunk_len == 1 {
      push_single_skinned_mesh_gpu_command_from_matrix_with_frustum(
        mesh,
        visible_instance_matrices[start],
        visible_instance_colors[start],
        packed_vertex_data,
        skinning_matrices,
        view_projection,
        frustum,
        lighting,
        dst,
        shader3d_skinned,
        screen_w,
        screen_h,
        cmds,
      )
    } else {
      let chunk_matrices : Array[@math3d.Mat4] = []
      let chunk_colors : Array[@math3d.Vec4] = []
      for i in start..<end {
        chunk_matrices.push(visible_instance_matrices[i])
        chunk_colors.push(visible_instance_colors[i])
      }
      cmds.push(
        @draw3d.new_skinned_instanced_lit_mesh_draw_command(
          dst,
          shader3d_skinned_instanced,
          dst_region,
          @gfx.BlendMode::from_int(1),
          packed_vertex_data,
          mesh.indices,
          view_projection,
          lighting,
          skinning_matrices,
          chunk_matrices,
          chunk_colors,
        ),
      )
    }
    start = end
  }
}

///|
fn push_single_skinned_mesh_gpu_command_from_matrix_with_frustum(
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  _color : @math3d.Vec4,
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  frustum : Frustum,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(mesh)
  let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
    omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model,
  )
  if frustum_cull_aabb(frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) {
    return
  }
  cmds.push(
    @draw3d.new_skinned_lit_mesh_draw_command(
      dst,
      shader3d_skinned,
      @gfx.new_dst_region(0, 0, screen_w, screen_h, mesh.indices.length()),
      0,
      0,
      0,
      @gfx.BlendMode::from_int(1),
      packed_vertex_data,
      mesh.indices,
      model,
      view_projection,
      lighting,
      skinning_matrices,
      [],
    ),
  )
}

///|
pub fn push_single_skinned_mesh_gpu_command(
  mesh : @mesh3d.Mesh3D,
  transform : @transform3d.Transform3D,
  color : @math3d.Vec4,
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  camera : @camera3d.Camera3D,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let vp = camera.view_projection_matrix()
  push_single_skinned_mesh_gpu_command_with_view_projection(
    mesh, transform, color, packed_vertex_data, skinning_matrices, vp, lighting,
    dst, shader3d_skinned, screen_w, screen_h, cmds,
  )
}

///|
pub fn push_single_skinned_mesh_gpu_command_with_view_projection(
  mesh : @mesh3d.Mesh3D,
  transform : @transform3d.Transform3D,
  color : @math3d.Vec4,
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let frustum = Frustum::from_vp(view_projection)
  push_single_skinned_mesh_gpu_command_with_frustum(
    mesh, transform, color, packed_vertex_data, skinning_matrices, view_projection,
    frustum, lighting, dst, shader3d_skinned, screen_w, screen_h, cmds,
  )
}

///|
fn push_single_skinned_mesh_gpu_command_with_frustum(
  mesh : @mesh3d.Mesh3D,
  transform : @transform3d.Transform3D,
  color : @math3d.Vec4,
  packed_vertex_data : Array[Double],
  skinning_matrices : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  frustum : Frustum,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_skinned : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let model = transform.to_mat4()
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(mesh)
  let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
    omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model,
  )
  if frustum_cull_aabb(frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) {
    return
  }
  let tinted_lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      lighting.directional.direction,
      @math3d.Vec3::new(
        lighting.directional.color.x * color.x,
        lighting.directional.color.y * color.y,
        lighting.directional.color.z * color.z,
      ),
      lighting.directional.intensity,
    ),
    @light3d.AmbientLight::new(
      @math3d.Vec3::new(
        lighting.ambient.color.x * color.x,
        lighting.ambient.color.y * color.y,
        lighting.ambient.color.z * color.z,
      ),
      lighting.ambient.intensity,
    ),
  )
  let dst_region = @gfx.new_dst_region(
    0,
    0,
    screen_w,
    screen_h,
    mesh.indices.length(),
  )
  cmds.push(
    @draw3d.new_skinned_lit_mesh_draw_command(
      dst,
      shader3d_skinned,
      dst_region,
      0,
      0,
      0,
      @gfx.BlendMode::from_int(1),
      packed_vertex_data,
      mesh.indices,
      model,
      view_projection,
      tinted_lighting,
      skinning_matrices,
      [],
    ),
  )
}

///|
fn has_nonzero_sort_bias_gpu(objects : Array[Object3D]) -> Bool {
  for obj in objects {
    if obj.sort_bias != 0.0 {
      return true
    }
  }
  false
}

///|
fn sort_object_indices_for_gpu(objects : Array[Object3D]) -> Array[Int] {
  let ordered : Array[Int] = []
  for i in 0..<objects.length() {
    ordered.push(i)
  }
  ordered.sort_by(fn(a, b) {
    let bias_a = objects[a].sort_bias
    let bias_b = objects[b].sort_bias
    if bias_a > bias_b {
      -1
    } else if bias_a < bias_b {
      1
    } else {
      a - b
    }
  })
  ordered
}

///|
fn has_identity_tint(color : @math3d.Vec4) -> Bool {
  color.x == 1.0 && color.y == 1.0 && color.z == 1.0
}

///|
let scene3d_alpha_blend_mode : @gfx.BlendMode = @gfx.BlendMode::from_int(1)

///|
let scene3d_empty_src_image_ids : Array[Int] = []

///|
fn can_use_simple_untextured_gpu_path(
  material : Material?,
  skinning : SkinningState?,
) -> Bool {
  match (material, skinning) {
    (None, None) => true
    _ => false
  }
}

///|
fn tint_lighting_for_object(
  lighting : @light3d.LightingEnvironment,
  color : @math3d.Vec4,
) -> @light3d.LightingEnvironment {
  if has_identity_tint(color) {
    lighting
  } else {
    @light3d.LightingEnvironment::new(
      @light3d.DirectionalLight::new(
        lighting.directional.direction,
        @math3d.Vec3::new(
          lighting.directional.color.x * color.x,
          lighting.directional.color.y * color.y,
          lighting.directional.color.z * color.z,
        ),
        lighting.directional.intensity,
      ),
      @light3d.AmbientLight::new(
        @math3d.Vec3::new(
          lighting.ambient.color.x * color.x,
          lighting.ambient.color.y * color.y,
          lighting.ambient.color.z * color.z,
        ),
        lighting.ambient.intensity,
      ),
      point_lights=lighting.point_lights,
      spot_lights=lighting.spot_lights,
    )
  }
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
  light_dwords : Array[Int],
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
  let index_count = mesh.indices.length()
  let dst_region = @gfx.new_dst_region(0, 0, screen_w, screen_h, index_count)
  if can_use_simple_untextured_gpu_path(material, skinning) {
    if has_identity_tint(color) {
      cmds.push(
        @draw3d.new_lit_mesh_draw_command_with_light_dwords(
          dst, shader3d, dst_region, 0, 0, 0, scene3d_alpha_blend_mode, mesh, model,
          vp, light_dwords, scene3d_empty_src_image_ids,
        ),
      )
    } else {
      let object_lighting = tint_lighting_for_object(lighting, color)
      cmds.push(
        @draw3d.new_lit_mesh_draw_command(
          dst, shader3d, dst_region, 0, 0, 0, scene3d_alpha_blend_mode, mesh, model,
          vp, object_lighting, scene3d_empty_src_image_ids,
        ),
      )
    }
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
  let src_image_ids : Array[Int] = if has_texture {
    [src_image_id]
  } else {
    scene3d_empty_src_image_ids
  }
  // Select shader and build draw command based on material properties
  if is_pbr {
    let tinted_lighting = tint_lighting_for_object(lighting, col)
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
      dst, shader, dst_region, 0, 0, 0, scene3d_alpha_blend_mode, mesh, model, vp,
      tinted_lighting, metallic, roughness, col, emissive, camera_pos, src_image_ids,
    )
    cmds.push(cmd)
  } else {
    match (skinning, shader3d_skinned) {
      (Some(sk), Some(skinned_shader)) => {
        let tinted_lighting = tint_lighting_for_object(lighting, col)
        let cmd = match sk.packed_vertex_data {
          Some(packed_vertex_data) =>
            @draw3d.new_skinned_lit_mesh_draw_command(
              dst,
              skinned_shader,
              dst_region,
              0,
              0,
              0,
              scene3d_alpha_blend_mode,
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
              scene3d_alpha_blend_mode,
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
        let cmd = if has_identity_tint(col) {
          @draw3d.new_lit_mesh_draw_command_with_light_dwords(
            dst, shader, dst_region, 0, 0, 0, scene3d_alpha_blend_mode, mesh, model,
            vp, light_dwords, src_image_ids,
          )
        } else {
          let tinted_lighting = tint_lighting_for_object(lighting, col)
          @draw3d.new_lit_mesh_draw_command(
            dst, shader, dst_region, 0, 0, 0, scene3d_alpha_blend_mode, mesh, model,
            vp, tinted_lighting, src_image_ids,
          )
        }
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
  render_instanced_gpu_with_view_projection(
    mesh, instances, vp, lighting, dst, shader3d_instanced, screen_w, screen_h,
  )
}

///|
pub fn render_instanced_gpu_with_view_projection(
  mesh : @mesh3d.Mesh3D,
  instances : Array[InstanceData],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d_instanced : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
) -> @gfx.DrawTrianglesCommand {
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
    @gfx.BlendMode::from_int(1),
    mesh,
    view_projection,
    lighting,
    instance_matrices,
    instance_colors,
  )
}
