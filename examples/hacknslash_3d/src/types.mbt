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

///|
enum DungeonSurfaceKind {
  Floor
  Corridor
  Door
  Wall
  Pillar
} derive(Eq, Show)

// Combined mesh with a single color for batched shadow-lit rendering

///|
struct DungeonMeshGroup {
  mesh : @mesh3d.Mesh3D
  color : @math3d.Vec4
  surface_kind : DungeonSurfaceKind
  dst_region : @gfx.DstRegion
}

///|
struct VisibleDungeonMeshCache {
  groups : Array[DungeonMeshGroup]
  all_mesh : @mesh3d.Mesh3D
}

///|
struct GeneratedPropAsset {
  scene_graph : @scene3d.SceneGraph
  source_path : String
}

///|
enum GeneratedPropAnchor {
  StartRoomCenter
  LargestNonStartRoomCenter
  BossRoomCenter
  TreasureRoomCenter
} derive(Eq, Show)

///|
enum GeneratedPropRole {
  Decoration
  Blocking
  Pickup
} derive(Eq, Show)

///|
enum GeneratedPropPickupEffect {
  ScorePickup
  HealthPickup
  EquipmentPickup
} derive(Eq, Show)

///|
struct GeneratedPropPlacement {
  source_path : String
  floor : Int
  anchor : GeneratedPropAnchor
  role : GeneratedPropRole
  pickup_effect : GeneratedPropPickupEffect
  pickup_rarity : @game.ItemRarity?
  pickup_slot : @game.EquipSlot?
  scale : Double
  yaw_degrees : Double
  x_offset_tiles : Double
  z_offset_tiles : Double
}

///|
struct GeneratedPropState {
  base_scene_graph : @scene3d.SceneGraph
  scene_graph : @scene3d.SceneGraph
  placement : GeneratedPropPlacement
}

///|
struct ActiveEffectInstance {
  label : String
  doc : @effect.EffectDocument
  placement : @effect.EffectPlacement
  mut elapsed : Double
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
  shader3d_textured : @gfx.ShaderHandle
  shader3d_pbr : @gfx.ShaderHandle
  shader3d_pbr_textured : @gfx.ShaderHandle
  shader3d_colored : @gfx.ShaderHandle
  shader3d_instanced : @gfx.ShaderHandle
  shader3d_instanced_monochrome : @gfx.ShaderHandle
  shader3d_skinned : @gfx.ShaderHandle
  shader3d_skinned_instanced : @gfx.ShaderHandle
  shader3d_skinned_instanced_monochrome : @gfx.ShaderHandle
  meshes : Meshes3D
  character : PlayerCharacter
  enemy_models : EnemyModels
  enemy_render_buckets : EnemyRenderBuckets
  // Shadow mapping
  shadow_map : @gfx.ImageHandle
  shadow_depth_shader : @gfx.ShaderHandle
  shadow_lit_shader : @gfx.ShaderHandle
  shadow_lit_textured_shader : @gfx.ShaderHandle
  mut shadows_enabled : Bool
  shadow_config : @shadow3d.ShadowConfig
  mut dungeon_chunks : Array[DungeonChunk]
  mut dungeon_tinted_lighting_cache : Array[@light3d.LightingEnvironment]
  mut visible_chunks_cache : Array[DungeonChunk]
  mut visible_chunk_cache_player_tile_x : Int
  mut visible_chunk_cache_player_tile_z : Int
  mut visible_chunk_cache_builds : Int
  mut visible_dungeon_mesh_cache : VisibleDungeonMeshCache
  mut visible_dungeon_mesh_cache_player_tile_x : Int
  mut visible_dungeon_mesh_cache_player_tile_z : Int
  mut visible_dungeon_mesh_cache_builds : Int
  mut generated_props : Array[GeneratedPropState]
  mut active_effects : Array[ActiveEffectInstance]
  audio_ctx : @audio.MixerAudioContext
  audio_players : GameAudioPlayers
  mut dungeon_floor_texture_image_id : Int?
  mut dungeon_wall_texture_image_id : Int?
  // PostFX
  scene_target : @gfx.ImageHandle
  bloom_a : @gfx.ImageHandle
  bloom_b : @gfx.ImageHandle
  post_target : @gfx.ImageHandle
  bloom_threshold_sh : @gfx.ShaderHandle
  bloom_hblur_sh : @gfx.ShaderHandle
  bloom_vblur_sh : @gfx.ShaderHandle
  bloom_composite_sh : @gfx.ShaderHandle
  mut fxaa_enabled : Bool
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
  // Entity instancing scratch
  entity_instance_scratch : EntityInstanceScratch
  // HUD minimap cache
  mut minimap_static_cmds : Array[@gfx.DrawTrianglesCommand]
  mut minimap_cache_player_tile_x : Int
  mut minimap_cache_player_tile_y : Int
  mut minimap_cache_floor : Int
  mut minimap_cache_dst_id : Int
  mut minimap_cache_shader_id : Int
  mut minimap_cache_discovery_version : Int
  mut minimap_cache_builds : Int
  // HUD static text cache
  mut hud_static_cmds : Array[@gfx.DrawTrianglesCommand]
  mut hud_static_cache_floor : Int
  mut hud_static_cache_dst_id : Int
  mut hud_static_cache_shader_id : Int
  mut hud_static_cache_text_mode : Int
  mut hud_static_cache_builds : Int
}
