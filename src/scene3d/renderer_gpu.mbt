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
pub fn render_scene3d_graph_gpu(
  graph : SceneGraph,
  camera : @camera3d.Camera3D,
  lighting~ : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
) -> Array[@gfx.DrawTrianglesCommand] {
  let vp = camera.view_projection_matrix()
  let frustum = Frustum::from_vp(vp)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let identity = @math3d.Mat4::identity()
  for i in 0..<graph.roots.length() {
    traverse_node_gpu(
      graph, graph.roots[i], identity, vp, frustum, lighting, dst, shader3d,
      screen_w, screen_h, cmds,
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
) -> Unit {
  match graph.nodes.get(node_id) {
    None => ()
    Some(node) => {
      let world = parent_world.multiply(node.transform.to_mat4())
      match node.mesh {
        Some(mesh) =>
          render_object_gpu(
            mesh, world, node.color, node.material, vp, frustum, lighting,
            dst, shader3d, screen_w, screen_h, cmds,
          )
        None => ()
      }
      for i in 0..<node.children.length() {
        traverse_node_gpu(
          graph, node.children[i], world, vp, frustum, lighting, dst,
          shader3d, screen_w, screen_h, cmds,
        )
      }
    }
  }
}

///|
fn render_object_gpu(
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  color : @math3d.Vec4,
  material : Material?,
  vp : @math3d.Mat4,
  frustum : Frustum,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  // Frustum culling
  let (omin_x, omin_y, omin_z, omax_x, omax_y, omax_z) = compute_mesh_aabb(
    mesh,
  )
  let (wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) = transform_aabb(
    omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model,
  )
  if frustum_cull_aabb(frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z) {
    return
  }
  // Resolve color and texture from material
  let (col, src_image_id) = match material {
    Some(mat) => (mat.color, mat.src_image_id)
    None => (color, -1)
  }
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
  let src_image_ids : Array[Int] = if src_image_id >= 0 {
    [src_image_id]
  } else {
    []
  }
  let cmd = @draw3d.new_lit_mesh_draw_command(
    dst,
    shader3d,
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
