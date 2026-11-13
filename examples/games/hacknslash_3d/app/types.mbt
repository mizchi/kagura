// Rendering-only types (stay in )

///|
struct Meshes3D {
  item : @mesh3d.Mesh3D
  projectile : @mesh3d.Mesh3D
  arrow : @mesh3d.Mesh3D
  floor_tile : @mesh3d.Mesh3D
  wall : @mesh3d.Mesh3D
  wall_low : @mesh3d.Mesh3D
  wall_tall : @mesh3d.Mesh3D
  ledge : @mesh3d.Mesh3D
  pillar : @mesh3d.Mesh3D
  debris : @mesh3d.Mesh3D
  crate : @mesh3d.Mesh3D
  loot_beam : @mesh3d.Mesh3D
  telegraph_disc : @mesh3d.Mesh3D
}

///|
#derive(Eq, Debug)
enum DungeonSurfaceKind {
  Floor
  Corridor
  Door
  Wall
  Pillar
}

///|
pub impl Show for DungeonSurfaceKind with fn output(self, logger) {
  logger.write_object(Repr(self))
}

// Combined mesh with a single color for batched shadow-lit rendering

///|
struct DungeonMeshGroup {
  mesh : @mesh3d.Mesh3D
  color : @math3d.Vec4
  surface_kind : DungeonSurfaceKind
  index_offset : Int32
  dst_region : @gfx.DstRegion
}

///|
struct VisibleDungeonMeshCache {
  depth_meshes : Array[@mesh3d.Mesh3D]
  groups : Array[DungeonMeshGroup]
  all_mesh : @mesh3d.Mesh3D
}

///|
struct GeneratedPropAsset {
  scene_graph : @scene3d.SceneGraph
  source_path : String
}

///|
type GeneratedPropAnchor = @interactable2d.InteractableAnchor

///|
type GeneratedPropRole = @interactable2d.InteractableRole

///|
type GeneratedPropPickupEffect = @interactable2d.InteractablePickupEffect

///|
struct GeneratedPropPlacement {
  source_path : String
  floor : Int32
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
struct DamagePopup {
  x : Double
  y : Double
  amount : Int32
  color_hex : Int32
  mut ttl : Int32
  mut rise : Double
}

///|
// Input replacement is used by JS inspection; native retains the same helper.
#warnings("-unused_mut")
struct GameState {
  inspection : @inspection.FieldControl
  hud_publisher : @ui.JsonObjectPublisher
  mut world : @game.GameWorld
  mut active_save_slot : Int32
  mut save_slots : Array[SaveSlotView]
  mut save_notice : String
  mut pending_save_deletion : SaveDeletion?
  aim : HunterAimState
  combat_feedback : CombatFeedbackState
  mut input : @inpututil.InputHelper
  // Profiler
  mut show_profiler : Bool
  mut profile : @engine.FrameProfile
  // 3D-specific
  mut camera : @camera3d.OrbitCamera
  camera_settings : HunterCameraSettings
  mut expedition_map : ExpeditionMapView?
  mut scenery : SceneryCache?
  scenery_shader : @gfx.ShaderHandle
  sky_mesh : @mesh3d.Mesh3D
  sky_shader : @gfx.ShaderHandle
  terrain_lab : TerrainLabState
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
  character : CharacterModel
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
  mut visible_chunk_cache_player_tile_x : Int32
  mut visible_chunk_cache_player_tile_z : Int32
  mut visible_chunk_cache_builds : Int32
  mut visible_dungeon_mesh_cache : VisibleDungeonMeshCache
  mut visible_dungeon_mesh_cache_player_tile_x : Int32
  mut visible_dungeon_mesh_cache_player_tile_z : Int32
  mut visible_dungeon_mesh_cache_builds : Int32
  mut generated_props : Array[GeneratedPropState]
  mut active_effects : Array[ActiveEffectInstance]
  mut damage_popups : Array[DamagePopup]
  audio_ctx : @audio.MixerAudioContext
  audio_bank : @audio.SoundBank[GameSoundCue]
  audio_failed_paths : Array[String]
  mut audio_last_played_cue : String
  mut audio_last_played_state : String
  mut dungeon_floor_texture_image_id : Int32?
  mut dungeon_wall_texture_image_id : Int32?
  // PostFX pipeline
  mut pipeline : @render_pipeline3d.RenderPipeline3D
  fog_sh : @gfx.ShaderHandle
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
  mut minimap_cache_player_tile_x : Int32
  mut minimap_cache_player_tile_y : Int32
  mut minimap_cache_floor : Int32
  mut minimap_cache_dst_id : Int32
  mut minimap_cache_shader_id : Int32
  mut minimap_cache_discovery_version : Int32
  mut minimap_cache_builds : Int32
  // HUD static text cache
  mut hud_static_cmds : Array[@gfx.DrawTrianglesCommand]
  mut hud_static_cache_floor : Int32
  mut hud_static_cache_dst_id : Int32
  mut hud_static_cache_shader_id : Int32
  mut hud_static_cache_text_mode : Int32
  mut hud_static_cache_builds : Int32
  mut pause_return_ui : @game.UIMode
  mut pause_return_cursor : Int32
  region_meshes : Array[RegionMeshCache?]
  mut region_mesh_stamp : Int32
  mut region_prepare_max_ms : Double
  mut region_chunk_max_ms : Double
  mut region_batch_max_ms : Double
  initial_map_ms : Double
  mut region_chunks_built : Int32
  mut inventory_notice : String
  mut paused : Bool
  mut ground_targeting : Bool
  mut ground_target_x : Double
  mut ground_target_y : Double
  mut combat_visuals : Array[CombatVisual]
  mut motion_preview : Bool
}

///|
pub extend DungeonSurfaceKind with Eq::{not_equal, equal}

///|
pub extend DungeonSurfaceKind with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DungeonSurfaceKind with Show::{to_string, output}
