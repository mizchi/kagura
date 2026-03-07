// Data structures (same as 2D version + 3D extensions)

struct Player {
  mut x : Double
  mut y : Double
  mut hp : Int
  max_hp : Int
  size : Double
  mut damage_timer : Int
  mut iframe_timer : Int
  mut facing_angle : Double
  mut dash_timer : Int
  mut dash_cooldown_timer : Int
  mut dash_vx : Double
  mut dash_vy : Double
}

struct ItemDrop {
  x : Double
  y : Double
  kind : Int
  mut alive : Bool
  spawn_frame : Int
}

struct Projectile {
  mut x : Double
  mut y : Double
  vx : Double
  vy : Double
  mut alive : Bool
  damage : Int
}

struct Enemy {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  mut hp : Int
  max_hp : Int
  speed : Double
  size : Double
  mut alive : Bool
  mut damage_timer : Int
  kind : Int
  mut path_cache : Array[@terrain.Point]
  mut path_index : Int
  mut path_timer : Int
  mut shoot_cooldown : Int
  mut charge_timer : Int
  mut charge_cooldown : Int
}

struct Meshes3D {
  item : @mesh3d.Mesh3D
  projectile : @mesh3d.Mesh3D
  floor_tile : @mesh3d.Mesh3D
  wall : @mesh3d.Mesh3D
}

// Combined mesh with a single color for batched shadow-lit rendering
struct DungeonMeshGroup {
  mesh : @mesh3d.Mesh3D
  color : @math3d.Vec4
}

struct GameState {
  mut mode : Int
  mut frame_count : Int
  mut seed : Int
  mut floor : Int
  mut score : Int
  player : Player
  mut enemies : Array[Enemy]
  mut items : Array[ItemDrop]
  mut projectiles : Array[Projectile]
  dungeon : DungeonData
  input : @inpututil.InputHelper
  mut attack_timer : Int
  mut screen_flash : Int
  mut floor_announce_timer : Int
  // RPG systems
  inventory : Inventory
  equipment : Equipment
  skills : SkillTree
  mut player_stats : PlayerStats
  mut ui_mode : Int // 0=none, 1=inventory, 2=skill tree
  mut ui_cursor : Int // selected slot index in UI
  // Profiler
  mut show_profiler : Bool
  mut profile : @debugutil.FrameProfile
  // 3D-specific
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  shader3d : @gfx.ShaderHandle
  shader3d_skinned : @gfx.ShaderHandle
  meshes : Meshes3D
  mut dungeon_graph : @scene3d.SceneGraph
  character : PlayerCharacter
  enemy_models : EnemyModels
  // Shadow mapping
  shadow_map : @gfx.ImageHandle
  shadow_depth_shader : @gfx.ShaderHandle
  shadow_lit_shader : @gfx.ShaderHandle
  shadow_config : @shadow3d.ShadowConfig
  mut dungeon_mesh_groups : Array[DungeonMeshGroup]
  mut dungeon_wall_mesh : @mesh3d.Mesh3D
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
  // SSAO
  ssao_sh : @gfx.ShaderHandle
  ssao_target : @gfx.ImageHandle
  // Particles
  particle_manager : @particle3d.ParticleManager
  // Text
  text_renderer : @text.TextRenderer?
}
