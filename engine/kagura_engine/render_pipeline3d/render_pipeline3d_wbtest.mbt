///|
test "camera depth is produced only while SSAO consumes it" {
  let pipeline = RenderPipeline3D::new(300, 640, 480, PostFXConfig::default())
  let dst = @gfx.new_image_handle(1, 640, 480)
  let identity = @math3d.Mat4::identity()
  let casters = [
    @shadow3d.ShadowCaster::new(@mesh3d.Mesh3D::cube(1.0), identity),
  ]
  let disabled = pipeline.compose_postfx(dst, casters, identity, 640, 480)
  assert_false(
    disabled.any(cmd => cmd.dst.id == pipeline.camera_depth_target.id),
  )
  assert_true(disabled.any(cmd => cmd.dst.id == dst.id))
  pipeline.config = {
    ..pipeline.config,
    ssao_config: SSAOConfig::enabled_default(),
  }
  let enabled = pipeline.compose_postfx(dst, casters, identity, 640, 480)
  assert_eq(enabled[0].dst.id, pipeline.camera_depth_target.id)
  assert_eq(enabled[1].src_image_ids[1], pipeline.camera_depth_target.id)
  let direct = pipeline.compose_postfx(
    dst,
    casters,
    identity,
    640,
    480,
    cache_resources=false,
  )
  assert_eq(direct[0].resource_cache_key, 0)
  assert_eq(direct[0].uniform_dwords, enabled[0].uniform_dwords)
  pipeline.config = {
    ..pipeline.config,
    ssao_config: SSAOConfig::disabled_default(),
  }
  let toggled = pipeline.compose_postfx(dst, casters, identity, 640, 480)
  assert_false(
    toggled.any(cmd => cmd.dst.id == pipeline.camera_depth_target.id),
  )
}
