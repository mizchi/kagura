///|
fn vec4_to_color(color : @math3d.Vec4) -> @gfx.Color {
  @gfx.new_color(color.x, color.y, color.z, color.w)
}

///|
fn make_hud_ctx(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> @hud.HudContext {
  {
    dst,
    shader,
    screen_w: screen_w.to_double(),
    screen_h: screen_h.to_double(),
    text_renderer: None,
  }
}

///|
fn append_particle_geometry(
  vertex_data : Array[Double],
  indices : Array[Int],
  appended_vertex_data : Array[Double],
  appended_indices : Array[Int],
) -> Unit {
  let base_vertex = vertex_data.length() / 8
  for value in appended_vertex_data {
    vertex_data.push(value)
  }
  for index in appended_indices {
    indices.push(base_vertex + index)
  }
}

///|
fn draw_preview_scene(
  state : EffectStudioState,
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  camera : @camera3d.Camera3D,
) -> Unit {
  let vp = camera.view_projection_matrix()
  let floor_region = @gfx.new_dst_region(
    0,
    0,
    ctx.screen_w,
    ctx.screen_h,
    state.floor_mesh.indices.length(),
  )
  let floor_model = @math3d.Mat4::translation(0.0, -0.06, 0.0).multiply(
    @math3d.Mat4::scaling(6.0, 0.12, 6.0),
  )
  cmds.push(
    @draw3d.new_lit_colored_mesh_draw_command(
      ctx.dst,
      state.lit_colored_shader,
      floor_region,
      0,
      state.lit_colored_shader.id,
      100 + state.frame_count,
      @gfx.BlendMode::from_int(1),
      state.floor_mesh,
      floor_model,
      vp,
      state.lighting,
      @math3d.Vec4::new(0.12, 0.13, 0.16, 1.0),
      [],
    ),
  )
  let pedestal_region = @gfx.new_dst_region(
    0,
    0,
    ctx.screen_w,
    ctx.screen_h,
    state.pedestal_mesh.indices.length(),
  )
  let pedestal_model = @math3d.Mat4::translation(0.0, 0.08, 0.0).multiply(
    @math3d.Mat4::scaling(0.9, 0.16, 0.9),
  )
  cmds.push(
    @draw3d.new_lit_colored_mesh_draw_command(
      ctx.dst,
      state.lit_colored_shader,
      pedestal_region,
      0,
      state.lit_colored_shader.id,
      200 + state.frame_count,
      @gfx.BlendMode::from_int(1),
      state.pedestal_mesh,
      pedestal_model,
      vp,
      state.lighting,
      @math3d.Vec4::new(0.18, 0.22, 0.28, 1.0),
      [],
    ),
  )
}

///|
fn append_effect_particles(
  state : EffectStudioState,
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
  camera : @camera3d.Camera3D,
) -> Unit {
  let runtime = @effect.build_effect_runtime_plan(state.doc, state.preview_time)
  let view = camera.view_matrix()
  let cam_right = @math3d.Vec3::new(
    view.elements[0],
    view.elements[4],
    view.elements[8],
  )
  let cam_up = @math3d.Vec3::new(
    view.elements[1],
    view.elements[5],
    view.elements[9],
  )
  let vertex_data : Array[Double] = []
  let indices : Array[Int] = []
  for burst in runtime.scheduled_bursts {
    let emitter = @particle3d.ParticleEmitter::new(burst.config)
    emitter.update(1.0)
    if burst.age > 0.0 {
      emitter.update_physics_only(burst.age)
    }
    let (burst_vertex_data, burst_indices) = emitter.build_billboard_vertices(
      cam_right, cam_up,
    )
    append_particle_geometry(
      vertex_data, indices, burst_vertex_data, burst_indices,
    )
  }
  if indices.is_empty() {
    return
  }
  let region = @gfx.new_dst_region(
    0,
    0,
    ctx.screen_w,
    ctx.screen_h,
    indices.length(),
  )
  cmds.push(
    @draw3d.new_particle_draw_command(
      ctx.dst,
      state.particle_shader,
      region,
      0,
      state.particle_shader.id,
      state.frame_count,
      @gfx.BlendMode::from_int(2),
      vertex_data,
      indices,
      camera.view_projection_matrix(),
      [],
    ),
  )
}

///|
fn draw_timeline_overlay(
  state : EffectStudioState,
  cmds : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
) -> Unit {
  let hud_ctx = make_hud_ctx(ctx.dst, ctx.shader)
  let timeline = @effect.build_timeline_view(state.doc, state.preview_time)
  let overlay = build_effect_studio_overlay_model(
    state.doc,
    state.preview_time,
    state.playing,
  )
  let panel_y = screen_h.to_double() - timeline_height
  hud_ctx.draw_rect(
    cmds,
    0.0,
    panel_y,
    screen_w.to_double(),
    timeline_height,
    @hud.hex_color(0x08101A, alpha=0.92),
  )
  hud_ctx.draw_text(cmds, "EFFECT STUDIO", 20.0, 20.0, panel_y + 12.0, 0xD9E6FF)
  hud_ctx.draw_text(
    cmds,
    state.doc.name + " / " + overlay.status_label,
    16.0,
    20.0,
    panel_y + 40.0,
    0x86B7FF,
  )
  hud_ctx.draw_text(
    cmds,
    "AI edits the effect_doc; J downloads bundle, L downloads review prompt.",
    14.0,
    20.0,
    panel_y + 62.0,
    0x7A8CA5,
  )
  hud_ctx.draw_text(
    cmds,
    "bursts " +
    overlay.scheduled_burst_count.to_string() +
    " / particles " +
    overlay.scheduled_particle_count.to_string(),
    14.0,
    screen_w.to_double() - 270.0,
    panel_y + 18.0,
    0xFFD27A,
  )
  let timeline_left = 180.0
  let timeline_top = panel_y + 92.0
  let timeline_w = screen_w.to_double() - timeline_left - 24.0
  let lane_h = 22.0
  hud_ctx.draw_rect(
    cmds,
    timeline_left,
    timeline_top - 10.0,
    timeline_w,
    timeline.lanes.length().to_double() * lane_h + 20.0,
    @hud.hex_color(0x101722, alpha=0.96),
  )
  for i in 0..<5 {
    let ratio = i.to_double() / 4.0
    let x = timeline_left + timeline_w * ratio
    hud_ctx.draw_rect(
      cmds,
      x,
      timeline_top - 10.0,
      1.0,
      timeline.lanes.length().to_double() * lane_h + 20.0,
      @hud.hex_color(0x263241, alpha=0.9),
    )
  }
  for i in 0..<timeline.lanes.length() {
    let lane = timeline.lanes[i]
    let y = timeline_top + i.to_double() * lane_h
    hud_ctx.draw_text(cmds, lane.label, 14.0, 20.0, y + 2.0, 0xCFD8E3)
    hud_ctx.draw_rect(
      cmds,
      timeline_left,
      y,
      timeline_w,
      16.0,
      @hud.hex_color(0x15202B, alpha=0.92),
    )
    hud_ctx.draw_rect(
      cmds,
      timeline_left + timeline_w * lane.start_ratio,
      y,
      timeline_w * lane.duration_ratio,
      16.0,
      vec4_to_color(
        if lane.active {
          lane.accent_color
        } else {
          @math3d.Vec4::new(
            lane.accent_color.x * 0.35,
            lane.accent_color.y * 0.35,
            lane.accent_color.z * 0.35,
            0.85,
          )
        },
      ),
    )
    for marker in lane.marker_ratios {
      hud_ctx.draw_rect(
        cmds,
        timeline_left + timeline_w * marker,
        y - 2.0,
        2.0,
        20.0,
        @hud.hex_color(0xF4F7FB, alpha=0.85),
      )
    }
  }
  let playhead_x = timeline_left + timeline_w * timeline.playhead_ratio
  hud_ctx.draw_rect(
    cmds,
    playhead_x,
    timeline_top - 14.0,
    2.0,
    timeline.lanes.length().to_double() * lane_h + 28.0,
    @hud.hex_color(0xFF5D5D, alpha=0.96),
  )
}

///|
fn EffectStudioState::draw(
  self : EffectStudioState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let camera = self.camera.to_camera3d()
  draw_preview_scene(self, cmds, ctx, camera)
  append_effect_particles(self, cmds, ctx, camera)
  draw_timeline_overlay(self, cmds, ctx)
  cmds
}
