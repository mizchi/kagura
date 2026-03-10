// Rendering-only types (stay in src/)

///|
struct Meshes3D {
  item : @mesh3d.Mesh3D
  projectile : @mesh3d.Mesh3D
  arrow : @mesh3d.Mesh3D
  floor_tile : @mesh3d.Mesh3D
  wall : @mesh3d.Mesh3D
  ledge : @mesh3d.Mesh3D
  pillar : @mesh3d.Mesh3D
}

// Combined mesh with a single color for batched shadow-lit rendering

///|
struct DungeonMeshGroup {
  mesh : @mesh3d.Mesh3D
  color : @math3d.Vec4
}

///|
struct GameState {
  world : @game.GameWorld
  input : @inpututil.InputHelper
  // Profiler
  mut show_profiler : Bool
  mut profile : @debugutil.FrameProfile
  // 3D-specific
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  shader3d : @gfx.ShaderHandle
  shader3d_skinned : @gfx.ShaderHandle
  meshes : Meshes3D
  character : PlayerCharacter
  enemy_models : EnemyModels
  // Shadow mapping
  shadow_map : @gfx.ImageHandle
  shadow_depth_shader : @gfx.ShaderHandle
  shadow_lit_shader : @gfx.ShaderHandle
  shadow_config : @shadow3d.ShadowConfig
  mut dungeon_chunks : Array[DungeonChunk]
  // PostFX
  scene_target : @gfx.ImageHandle
  bloom_a : @gfx.ImageHandle
  bloom_b : @gfx.ImageHandle
  post_target : @gfx.ImageHandle
  bloom_threshold_sh : @gfx.ShaderHandle
  bloom_hblur_sh : @gfx.ShaderHandle
  bloom_vblur_sh : @gfx.ShaderHandle
  bloom_composite_sh : @gfx.ShaderHandle
  fxaa_sh : @gfx.ShaderHandle
  tonemap_sh : @gfx.ShaderHandle
  // Camera depth (for SSAO)
  camera_depth_target : @gfx.ImageHandle
  camera_depth_shader : @gfx.ShaderHandle
  // SSAO
  ssao_config : SSAOConfig
  ssao_sh : @gfx.ShaderHandle
  ssao_target : @gfx.ImageHandle
  // Particles
  particle_manager : @particle3d.ParticleManager
  // UI icons
  icon_atlas : IconAtlas
  // Text
  text_renderer : @text.TextRenderer?
}
