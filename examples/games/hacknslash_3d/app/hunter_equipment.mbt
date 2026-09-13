///|
/// The body remains immutable. Each equipment combination is composed once.
struct CharacterEquippedMesh {
  parts : Array[CharacterPart]
  mesh : @mesh3d.Mesh3D
  skin : @skeleton3d.SkinData
  packed : Array[Double]
}

///|
let shared_hunter_weapon_sets : Array[HunterWeaponSet] = [
  build_hunter_weapon_set(),
  build_hunter_motion_weapon(@game.Spear, 1, build_hunter_spear_thrust_clip()),
  build_hunter_motion_weapon(@game.Knuckles, 0, build_hunter_punch_clip()),
  build_hunter_motion_weapon(@game.Focus, 2, build_hunter_cast_spell_clip()),
  build_hunter_motion_weapon(@game.Bow, 3, build_hunter_bow_shot_clip()),
]

///|
fn build_hunter_motion_weapon(
  kind : @game.PlayerWeaponKind,
  source_index : Int,
  clip : @animation3d.AnimationClip,
) -> HunterWeaponSet {
  let source = shared_enemy_skeleton
  let target = build_character_skeleton()
  let source_world = source.compute_world_transforms(
    source.bones.map(b => b.local_transform),
  )
  let target_world = target.compute_world_transforms(
    target.bones.map(b => b.local_transform),
  )
  // Shared biped -> hunter joints. The enemy tail is not used by equipment.
  let joints = [0, 1, 5, 6, 7, 2, 3, 8, 9, 10, 11, 0, 4, 14, 15, 16]
  let parts = shared_enemy_weapons[source_index].mesh.parts.map(part => {
    let data = @procedural3d.RigidGeometry::new()
    let mesh = part.geometry.bind_mesh
    let skin = part.geometry.skin_data
    data.vertices.append(mesh.vertex_data)
    data.indices.append(mesh.indices)
    data.weights.append(skin.weights)
    for i in 0..<skin.vertex_count {
      let mut dx = 0.0
      let mut dy = 0.0
      let mut dz = 0.0
      for j in 0..<4 {
        let old = skin.joint_indices[i * 4 + j]
        let next = joints[old]
        data.joints.push(next)
        let a = source_world[old].mul_vec4(
          @math3d.Vec4::new(0.0, 0.0, 0.0, 1.0),
        )
        let b = target_world[next].mul_vec4(
          @math3d.Vec4::new(0.0, 0.0, 0.0, 1.0),
        )
        let weight = skin.weights[i * 4 + j]
        dx += (b.x - a.x) * weight
        dy += (b.y - a.y) * weight
        dz += (b.z - a.z) * weight
      }
      data.vertices[i * 8] += dx
      data.vertices[i * 8 + 1] += dy
      data.vertices[i * 8 + 2] += dz
    }
    let mesh = data.build_mesh()
    let skin = data.build_skin()
    {
      name: part.name,
      color: part.color,
      mesh,
      skin,
      packed: @skeleton3d.build_skinned_vertex_data(mesh, skin),
    }
  })
  let profile = kind.profile()
  {
    kind,
    id: profile.id,
    parts,
    clip: Some(clip),
    attack_duration: (profile.windup + profile.recovery).to_double() / 60.0,
    sample_attack: fn(_, _) { [] },
  }
}

///|
fn CharacterModel::equip_weapon(
  self : CharacterModel,
  kind : @game.PlayerWeaponKind,
) -> Unit {
  if self.weapon.kind == kind {
    return
  }
  let weapon = shared_hunter_weapon_sets[kind.index()]
  self.weapon = weapon
  self.refresh_equipped_mesh()
  self.attack_player = weapon.clip.map(clip => {
    let player = @animation3d.AnimationPlayer::new(clip)
    player.set_looping(false)
    player
  })
  self.anim_state = if self.moving { Running } else { Idle }
  self.action_time = 0.0
  self.skinning_cache_dirty = true
}

///|
fn CharacterModel::sample_weapon_attack(self : CharacterModel) -> Unit {
  match self.attack_player {
    Some(player) => {
      let contact = self.weapon.kind.profile().windup.to_double() / 60.0
      let phase = if self.action_time <= contact {
        self.action_time / contact * 0.5
      } else {
        0.5 +
        (self.action_time - contact) /
        (self.weapon.attack_duration - contact) *
        0.5
      }
      player.set_time(phase.max(0.0).min(1.0))
      // Keep the player's running legs and coat; the weapon animates the upper body.
      @animation3d.apply_node_poses(
        self.local_poses,
        player
        .sample()
        .filter(p => {
          (p.node_index > 0 && p.node_index < 8) || p.node_index >= 14
        }),
      )
    }
    None =>
      for
        (bone, x, y, z) in (self.weapon.sample_attack)(
          self.action_time / self.weapon.attack_duration,
          self.attack_side,
        ) {
        self.rotate_bone(bone, x, y, z)
      }
  }
}
