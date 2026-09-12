// Hunter rig contract: metres, Y up, +Z forward. Rigid joints, parent before child.
// Geometry and palette live in hunter_model.mbt; motion never edits the bind mesh.

///|
let char_num_bones : Int = 14

///|
let hunter_head_height : Double = 0.7

///|
let run_anim_duration : Double = 0.48

///|
let attack_anim_duration : Double = 0.32

///|
enum CharAnimState {
  Idle
  Attacking
  Running
  Hurt
  Dodging
} derive(Eq, Debug)

///|
struct PlayerCharacter {
  skeleton : @skeleton3d.Skeleton
  parts : Array[HunterPart]
  // Combined mesh is kept for geometry inspection and existing tooling.
  bind_mesh : @mesh3d.Mesh3D
  skin_data : @skeleton3d.SkinData
  packed_vertex_data : Array[Double]
  mut anim_state : CharAnimState
  mut moving : Bool
  mut time : Double
  mut action_time : Double
  mut attack_count : Int
  mut dodge_count : Int
  mut attack_side : Double
  local_poses : Array[@transform3d.Transform3D]
  mut cached_skinning_matrices : Array[@math3d.Mat4]
  mut skinning_cache_dirty : Bool
  mut skinning_cache_builds : Int
}

///|
fn build_character_skeleton() -> @skeleton3d.Skeleton {
  // World-space rest anchors: root, chest, R arm/forearm/weapon, head,
  // L arm/forearm, L thigh/shin, R thigh/shin, coat tails L/R.
  let anchors = [
    ("root", -1, 0.0, 0.0, 0.0),
    ("torso", 0, 0.0, 0.55, 0.0),
    ("r_upper_arm", 1, 0.24, 0.63, 0.0),
    ("r_forearm", 2, 0.30, 0.46, 0.02),
    ("sword", 3, 0.33, 0.33, 0.08),
    ("head", 1, 0.0, 0.70, 0.0),
    ("l_upper_arm", 1, -0.24, 0.63, 0.0),
    ("l_forearm", 6, -0.30, 0.46, 0.02),
    ("l_thigh", 0, -0.115, 0.38, 0.0),
    ("l_shin", 8, -0.115, 0.20, 0.0),
    ("r_thigh", 0, 0.115, 0.38, 0.0),
    ("r_shin", 10, 0.115, 0.20, 0.0),
    ("coat_l", 1, -0.12, 0.46, -0.14),
    ("coat_r", 1, 0.12, 0.46, -0.14),
  ]
  let bones : Array[@skeleton3d.Bone] = []
  let ibms : Array[@math3d.Mat4] = []
  for (name, parent, x, y, z) in anchors {
    let pos = @math3d.Vec3::new(x, y, z)
    let parent_pos = if parent < 0 {
      @math3d.Vec3::zero()
    } else {
      let (_, _, px, py, pz) = anchors[parent]
      @math3d.Vec3::new(px, py, pz)
    }
    bones.push({
      name,
      parent,
      local_transform: @transform3d.Transform3D::from_position(
        pos.sub(parent_pos),
      ),
    })
    ibms.push(@math3d.Mat4::translation(-x, -y, -z))
  }
  @skeleton3d.Skeleton::new(bones, ibms)
}

///|
fn PlayerCharacter::new() -> PlayerCharacter {
  let skeleton = build_character_skeleton()
  let parts = build_hunter_parts()
  let (bind_mesh, skin_data) = combine_hunter_parts(parts)
  {
    skeleton,
    parts,
    bind_mesh,
    skin_data,
    packed_vertex_data: @skeleton3d.build_skinned_vertex_data(
      bind_mesh, skin_data,
    ),
    anim_state: Idle,
    moving: false,
    time: 0.0,
    action_time: 0.0,
    attack_side: 1.0,
    attack_count: 0,
    dodge_count: 0,
    local_poses: skeleton.bones.map(fn(b) { b.local_transform }),
    cached_skinning_matrices: [],
    skinning_cache_dirty: true,
    skinning_cache_builds: 0,
  }
}

///|
fn PlayerCharacter::trigger_attack(self : PlayerCharacter) -> Unit {
  if self.anim_state == Dodging {
    return
  }
  self.attack_count += 1
  self.attack_side = -self.attack_side
  self.anim_state = Attacking
  self.action_time = 0.0
  self.skinning_cache_dirty = true
}

///|
fn PlayerCharacter::trigger_hurt(self : PlayerCharacter) -> Unit {
  if self.anim_state == Dodging || self.anim_state == Attacking {
    return
  }
  self.anim_state = Hurt
  self.action_time = 0.0
  self.skinning_cache_dirty = true
}

///|
fn PlayerCharacter::trigger_dodge(self : PlayerCharacter) -> Unit {
  self.dodge_count += 1
  self.anim_state = Dodging
  self.action_time = 0.0
  self.skinning_cache_dirty = true
}

///|
fn PlayerCharacter::set_moving(self : PlayerCharacter, moving : Bool) -> Unit {
  self.moving = moving
  if self.anim_state == Idle || self.anim_state == Running {
    self.anim_state = if moving { Running } else { Idle }
  }
  self.skinning_cache_dirty = true
}

///|
fn PlayerCharacter::update(self : PlayerCharacter, dt : Double) -> Unit {
  self.time += dt
  self.action_time += dt
  let duration = match self.anim_state {
    Attacking => attack_anim_duration
    Hurt => 0.24
    Dodging => 0.24
    _ => -1.0
  }
  if duration > 0.0 && self.action_time >= duration {
    self.anim_state = if self.moving { Running } else { Idle }
  }
  self.skinning_cache_dirty = true
}

///|
fn PlayerCharacter::rotate_bone(
  self : PlayerCharacter,
  index : Int,
  x : Double,
  y : Double,
  z : Double,
) -> Unit {
  let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), y)
    .multiply(@math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), x))
    .multiply(@math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), z))
  self.local_poses[index] = self.local_poses[index].with_rotation(q)
}

///|
fn PlayerCharacter::compute_skinning(
  self : PlayerCharacter,
) -> Array[@math3d.Mat4] {
  if !self.skinning_cache_dirty {
    return self.cached_skinning_matrices
  }
  for i in 0..<char_num_bones {
    self.local_poses[i] = self.skeleton.bones[i].local_transform
  }
  let phase = self.time * 2.0 * @math.PI / run_anim_duration
  let stride = if self.moving { @math.sin(phase) } else { 0.0 }
  let bob = if self.moving { @math.sin(phase).abs() * 0.035 } else { 0.0 }
  self.local_poses[0] = self.local_poses[0].with_position(
    @math3d.Vec3::new(0.0, bob, 0.0),
  )
  self.rotate_bone(8, stride * 0.65, 0.0, -0.035)
  self.rotate_bone(10, -stride * 0.65, 0.0, 0.035)
  self.rotate_bone(9, @cmp.maximum(0.0, -stride) * 0.65, 0.0, 0.0)
  self.rotate_bone(11, @cmp.maximum(0.0, stride) * 0.65, 0.0, 0.0)
  self.rotate_bone(2, -stride * 0.32 - 0.15, 0.0, -0.12)
  self.rotate_bone(6, stride * 0.4 - 0.2, 0.0, 0.12)
  self.rotate_bone(
    1,
    if self.moving {
      0.10
    } else {
      @math.sin(self.time * 2.8) * 0.018
    },
    0.0,
    stride * 0.035,
  )
  self.rotate_bone(
    5,
    -0.035,
    @math.sin(self.time * 1.7) * 0.035,
    -stride * 0.045,
  )
  self.rotate_bone(12, -0.18 - stride.abs() * 0.25, 0.0, stride * 0.12)
  self.rotate_bone(13, -0.18 - stride.abs() * 0.25, 0.0, -stride * 0.12)
  match self.anim_state {
    Attacking => {
      let t = self.action_time / attack_anim_duration
      // Anticipation -> fast cross-body sweep -> recovery to ready stance.
      let swing = if t < 0.24 {
        t / 0.24 * -0.65
      } else if t < 0.62 {
        -0.65 + (t - 0.24) / 0.38 * 2.1
      } else {
        1.45 * (1.0 - (t - 0.62) / 0.38)
      }
      self.rotate_bone(1, 0.08, swing * self.attack_side * 0.45, 0.0)
      self.rotate_bone(2, -1.0, swing * self.attack_side, -0.35)
      self.rotate_bone(3, -0.35, 0.0, -0.3)
      self.rotate_bone(5, 0.0, -swing * self.attack_side * 0.2, 0.0)
    }
    Hurt =>
      self.rotate_bone(
        1,
        -@math.sin(self.action_time / 0.24 * @math.PI) * 0.35,
        0.0,
        0.12,
      )
    Dodging => {
      let t = self.action_time / 0.24
      self.local_poses[0] = self.local_poses[0].with_position(
        @math3d.Vec3::new(0.0, -0.1 * @math.sin(t * @math.PI), 0.0),
      )
      self.rotate_bone(1, 0.7 * @math.sin(t * @math.PI), 0.0, -0.2)
      self.rotate_bone(2, -0.65, 0.0, -0.3)
      self.rotate_bone(6, 0.7, 0.0, 0.3)
      self.rotate_bone(12, -0.9, 0.0, -0.2)
      self.rotate_bone(13, -0.9, 0.0, 0.2)
    }
    _ => ()
  }
  let world = self.skeleton.compute_world_transforms(self.local_poses)
  self.cached_skinning_matrices = self.skeleton.compute_skinning_matrices(world)
  self.skinning_cache_dirty = false
  self.skinning_cache_builds += 1
  self.cached_skinning_matrices
}

///|
pub extend CharAnimState with Eq::{not_equal, equal}
