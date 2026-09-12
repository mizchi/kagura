// Procedural enemy models with skeletal animation
// Shared 12-joint biped with articulated arms, legs and tail.
// Each enemy kind gets a different mesh with unique proportions and decorations.

///|
let enemy_bone_count : Int = 12

///|
let enemy_walk_duration : Double = 0.72

///|
let enemy_walk_keyframes : Int = 18

// Per-kind mesh data (pre-built, shared across instances)

///|
struct EnemyMeshData {
  bind_mesh : @mesh3d.Mesh3D
  skin_data : @skeleton3d.SkinData
  packed_vertex_data : Array[Double]
  parts : Array[EnemyMaterialPart]
  mut material_pose_generation : Int
}

// All enemy models

///|
struct EnemyModels {
  skeleton : @skeleton3d.Skeleton
  walk_player : @animation3d.AnimationPlayer
  local_poses : Array[@transform3d.Transform3D]
  mut cached_skinning_matrices : Array[@math3d.Mat4]
  mut skinning_cache_dirty : Bool
  mut skinning_cache_builds : Int
  mut pose_generation : Int
  mut cached_skinned_basic : @mesh3d.Mesh3D
  mut cached_skinned_fast : @mesh3d.Mesh3D
  mut cached_skinned_tank : @mesh3d.Mesh3D
  mut cached_skinned_ranged : @mesh3d.Mesh3D
  mut cached_skinned_boss : @mesh3d.Mesh3D
  cached_skinned_basic_data : Array[Double]
  cached_skinned_fast_data : Array[Double]
  cached_skinned_tank_data : Array[Double]
  cached_skinned_ranged_data : Array[Double]
  cached_skinned_boss_data : Array[Double]
  mut skinned_mesh_cache_dirty : Bool
  mut skinned_mesh_cache_builds : Int
  basic : EnemyMeshData
  fast : EnemyMeshData
  tank : EnemyMeshData
  ranged : EnemyMeshData
  boss : EnemyMeshData
}

///|
fn clone_vertex_data(data : Array[Double]) -> Array[Double] {
  let cloned : Array[Double] = Array::make(data.length(), 0.0)
  for i in 0..<data.length() {
    cloned[i] = data[i]
  }
  cloned
}

// A shared gait keeps material batches instanced while articulating every limb.

///|
fn build_enemy_walk_animation() -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = []
  for joint in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] {
    let times : Array[Double] = []
    let values : Array[Double] = []
    for k in 0..<enemy_walk_keyframes {
      let t = k.to_double() /
        (enemy_walk_keyframes - 1).to_double() *
        enemy_walk_duration
      let wave = @math.sin(t * 2.0 * @math.PI / enemy_walk_duration)
      let angle = match joint {
        1 => 0.06 * wave
        2 => -0.06 * wave
        3 => -0.24 * wave
        4 => -0.18 - 0.09 * wave
        5 => 0.24 * wave
        6 => -0.18 + 0.09 * wave
        7 => 0.36 * wave
        8 => 0.18 + 0.22 * @cmp.maximum(0.0, -wave)
        9 => -0.36 * wave
        10 => 0.18 + 0.22 * @cmp.maximum(0.0, wave)
        _ => 0.28 * wave
      }
      let axis = if joint == 1 || joint == 2 || joint == 11 {
        @math3d.Vec3::unit_y()
      } else {
        @math3d.Vec3::unit_x()
      }
      let q = @math3d.Quaternion::from_axis_angle(axis, angle)
      times.push(t)
      values.append([q.x, q.y, q.z, q.w])
    }
    channels.push({
      node_index: joint,
      target: @animation3d.Rotation,
      interpolation: @animation3d.Linear,
      times,
      values,
    })
  }
  { name: "biped_walk", channels, duration: enemy_walk_duration, }
}

///|
fn EnemyModels::new() -> EnemyModels {
  let skeleton = @procedural3d.build_biped_skeleton(
    @procedural3d.default_biped_proportions(),
  )
  let walk_clip = build_enemy_walk_animation()
  let walk_player = @animation3d.AnimationPlayer::new(walk_clip)
  walk_player.set_looping(true)
  walk_player.play()
  let local_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<enemy_bone_count {
    local_poses.push(skeleton.bones[i].local_transform)
  }
  let basic = build_monster_mesh_data(@game.Goblin)
  let basic_mesh = basic.bind_mesh
  let fast = build_monster_mesh_data(@game.Kobold)
  let fast_mesh = fast.bind_mesh
  let tank = build_monster_mesh_data(@game.Goblin, armor=1)
  let tank_mesh = tank.bind_mesh
  let ranged = build_monster_mesh_data(@game.Skeleton)
  let ranged_mesh = ranged.bind_mesh
  let boss = build_monster_mesh_data(@game.Skeleton, armor=2)
  let boss_mesh = boss.bind_mesh
  {
    skeleton,
    walk_player,
    local_poses,
    cached_skinning_matrices: [],
    skinning_cache_dirty: true,
    skinning_cache_builds: 0,
    pose_generation: 0,
    cached_skinned_basic: basic_mesh,
    cached_skinned_fast: fast_mesh,
    cached_skinned_tank: tank_mesh,
    cached_skinned_ranged: ranged_mesh,
    cached_skinned_boss: boss_mesh,
    cached_skinned_basic_data: clone_vertex_data(basic_mesh.vertex_data),
    cached_skinned_fast_data: clone_vertex_data(fast_mesh.vertex_data),
    cached_skinned_tank_data: clone_vertex_data(tank_mesh.vertex_data),
    cached_skinned_ranged_data: clone_vertex_data(ranged_mesh.vertex_data),
    cached_skinned_boss_data: clone_vertex_data(boss_mesh.vertex_data),
    skinned_mesh_cache_dirty: true,
    skinned_mesh_cache_builds: 0,
    basic,
    fast,
    tank,
    ranged,
    boss,
  }
}

///|
fn EnemyModels::update(self : EnemyModels, dt : Double) -> Unit {
  self.walk_player.update(dt)
  self.pose_generation += 1
  self.skinning_cache_dirty = true
  self.skinned_mesh_cache_dirty = true
}

///|
fn EnemyModels::get_mesh_data(
  self : EnemyModels,
  kind : @game.EnemyKind,
) -> EnemyMeshData {
  match kind {
    @game.Fast | @game.Exploder | @game.Teleporter => self.fast
    @game.Tank | @game.Berserker => self.tank
    @game.Ranged | @game.Summoner | @game.Caster => self.ranged
    @game.Boss => self.boss
    @game.Basic | @game.Swarm => self.basic
  }
}

///|
fn EnemyModels::compute_skinning(self : EnemyModels) -> Array[@math3d.Mat4] {
  if !self.skinning_cache_dirty {
    return self.cached_skinning_matrices
  }
  for i in 0..<enemy_bone_count {
    self.local_poses[i] = self.skeleton.bones[i].local_transform
  }
  let poses = self.walk_player.sample()
  for pose in poses {
    let idx = pose.node_index
    if idx >= 0 && idx < enemy_bone_count {
      match pose.rotation {
        Some(q) =>
          self.local_poses[idx] = self.local_poses[idx].with_rotation(q)
        None => ()
      }
      match pose.translation {
        Some(v) =>
          self.local_poses[idx] = self.local_poses[idx].with_position(v)
        None => ()
      }
    }
  }
  let world_transforms = self.skeleton.compute_world_transforms(
    self.local_poses,
  )
  self.cached_skinning_matrices = self.skeleton.compute_skinning_matrices(
    world_transforms,
  )
  self.skinning_cache_dirty = false
  self.skinning_cache_builds = self.skinning_cache_builds + 1
  self.cached_skinning_matrices
}

///|
fn EnemyModels::rebuild_skinned_mesh_cache(self : EnemyModels) -> Unit {
  if !self.skinned_mesh_cache_dirty {
    return
  }
  let skinning = self.compute_skinning()
  @skeleton3d.apply_skin_into(
    self.basic.bind_mesh,
    self.basic.skin_data,
    skinning,
    self.cached_skinned_basic_data,
  )
  self.cached_skinned_basic = @mesh3d.Mesh3D::new(
    self.cached_skinned_basic_data,
    self.basic.bind_mesh.indices,
  )
  @skeleton3d.apply_skin_into(
    self.fast.bind_mesh,
    self.fast.skin_data,
    skinning,
    self.cached_skinned_fast_data,
  )
  self.cached_skinned_fast = @mesh3d.Mesh3D::new(
    self.cached_skinned_fast_data,
    self.fast.bind_mesh.indices,
  )
  @skeleton3d.apply_skin_into(
    self.tank.bind_mesh,
    self.tank.skin_data,
    skinning,
    self.cached_skinned_tank_data,
  )
  self.cached_skinned_tank = @mesh3d.Mesh3D::new(
    self.cached_skinned_tank_data,
    self.tank.bind_mesh.indices,
  )
  @skeleton3d.apply_skin_into(
    self.ranged.bind_mesh,
    self.ranged.skin_data,
    skinning,
    self.cached_skinned_ranged_data,
  )
  self.cached_skinned_ranged = @mesh3d.Mesh3D::new(
    self.cached_skinned_ranged_data,
    self.ranged.bind_mesh.indices,
  )
  @skeleton3d.apply_skin_into(
    self.boss.bind_mesh,
    self.boss.skin_data,
    skinning,
    self.cached_skinned_boss_data,
  )
  self.cached_skinned_boss = @mesh3d.Mesh3D::new(
    self.cached_skinned_boss_data,
    self.boss.bind_mesh.indices,
  )
  self.skinned_mesh_cache_dirty = false
  self.skinned_mesh_cache_builds = self.skinned_mesh_cache_builds + 1
}

///|
// Only displayed species need their material geometry. Combined meshes are
// independently lazy for inspection/capture and never built by this draw path.
fn EnemyModels::prepare_materials(
  self : EnemyModels,
  model : EnemyMeshData,
) -> Unit {
  if model.material_pose_generation == self.pose_generation {
    return
  }
  let skinning = self.compute_skinning()
  for part in model.parts {
    @skeleton3d.apply_skin_into(
      part.mesh,
      part.skin,
      skinning,
      part.skinned_data,
    )
    part.skinned_mesh = @mesh3d.Mesh3D::new(
      part.skinned_data,
      part.mesh.indices,
    )
  }
  model.material_pose_generation = self.pose_generation
}

///|
fn EnemyModels::get_skinned_mesh(
  self : EnemyModels,
  kind : @game.EnemyKind,
) -> @mesh3d.Mesh3D {
  self.rebuild_skinned_mesh_cache()
  match kind {
    @game.Fast | @game.Exploder | @game.Teleporter => self.cached_skinned_fast
    @game.Tank | @game.Berserker => self.cached_skinned_tank
    @game.Ranged | @game.Summoner | @game.Caster => self.cached_skinned_ranged
    @game.Boss => self.cached_skinned_boss
    @game.Basic | @game.Swarm => self.cached_skinned_basic
  }
}
