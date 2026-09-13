///|
/// A reusable equipment asset: geometry, attack clip and preview contact timing.
/// All parts bind to the shared biped's hand/prop sockets, never a species mesh.
struct EnemyWeaponSet {
  id : String
  name : String
  mesh : EnemyMeshData
  motion : @game.EnemyAttackMotion
  clip_id : String
  clip_name : String
  clip : @animation3d.AnimationClip
  windup : Int
  recovery : Int
  bake_frames : Int
}

///|
let shared_enemy_weapons : Array[EnemyWeaponSet] = [
  {
    id: "knuckles",
    name: "Iron knuckles",
    mesh: build_knuckles_weapon(),
    motion: @game.Punch,
    clip_id: "punch",
    clip_name: "Punch",
    clip: build_punch_clip(),
    windup: 18,
    recovery: 22,
    bake_frames: 49,
  },
  {
    id: "spear",
    name: "Hunting spear",
    mesh: build_spear_weapon(),
    motion: @game.SpearThrust,
    clip_id: "spear_thrust",
    clip_name: "Spear thrust",
    clip: build_spear_thrust_clip(),
    windup: 24,
    recovery: 24,
    bake_frames: 49,
  },
  {
    id: "focus",
    name: "Arcane focus",
    mesh: build_focus_weapon(),
    motion: @game.CastSpell,
    clip_id: "cast_spell",
    clip_name: "Cast spell",
    clip: build_cast_spell_clip(),
    windup: @game.meteor_cast_frames,
    recovery: 24,
    bake_frames: 241,
  },
  {
    id: "bow",
    name: "Bone bow",
    mesh: build_bow_weapon(),
    motion: @game.BowShot,
    clip_id: "bow_shot",
    clip_name: "Bow shot",
    clip: build_bow_shot_clip(),
    windup: @game.enemy_bow_draw_frames,
    recovery: 22,
    bake_frames: 97,
  },
]

///|
fn default_enemy_weapon_index(kind : @game.EnemyKind) -> Int {
  match kind {
    @game.Fast | @game.Exploder | @game.Teleporter => 1
    @game.Ranged => 3
    @game.Summoner | @game.Caster | @game.Boss => 2
    _ => 0
  }
}

///|
fn append_enemy_part(
  dst : @procedural3d.RigidGeometry,
  part : EnemyMaterialPart,
) -> Unit {
  let mesh = part.geometry.bind_mesh
  let skin = part.geometry.skin_data
  let base = dst.vertices.length() / 8
  dst.vertices.append(mesh.vertex_data)
  for index in mesh.indices {
    dst.indices.push(base + index)
  }
  dst.joints.append(skin.joint_indices)
  dst.weights.append(skin.weights)
}

///|
/// Merge equal materials once when equipping, retaining the original instanced
/// crowd batches. Authoring meshes remain immutable and independently reusable.
fn combine_enemy_parts(parts : Array[EnemyMaterialPart]) -> EnemyMeshData {
  let merged : Array[EnemyMaterialPart] = []
  let batches : Array[@procedural3d.RigidGeometry] = []
  for part in parts {
    let mut found = -1
    for i in 0..<merged.length() {
      let color = merged[i].color
      if color.x == part.color.x &&
        color.y == part.color.y &&
        color.z == part.color.z &&
        color.w == part.color.w {
        found = i
        break
      }
    }
    if found < 0 {
      found = merged.length()
      merged.push(part)
      batches.push(@procedural3d.RigidGeometry::new())
    }
    append_enemy_part(batches[found], part)
  }
  let combined = @procedural3d.RigidGeometry::new()
  for i in 0..<merged.length() {
    let source = merged[i]
    let geometry = batches[i]
    combined.append(geometry)
    merged[i] = {
      name: source.name,
      color: source.color,
      geometry: @scene3d.SkinnedMeshAsset::new(
        geometry.build_mesh(),
        geometry.build_skin(),
      ),
    }
  }
  {
    parts: merged,
    geometry: @scene3d.SkinnedMeshAsset::new(
      combined.build_mesh(),
      combined.build_skin(),
    ),
  }
}

///|
fn EnemyModels::get_equipped_mesh_data(
  self : EnemyModels,
  kind : @game.EnemyKind,
  weapon_index? : Int = default_enemy_weapon_index(kind),
) -> EnemyMeshData {
  if kind == @game.Zombie {
    return zombie_mesh
  }
  if kind == @game.Wolf {
    return wolf_mesh
  }
  let body_index = match kind {
    @game.Fast | @game.Exploder | @game.Teleporter => 1
    @game.Tank | @game.Berserker => 2
    @game.Ranged | @game.Summoner | @game.Caster => 3
    @game.Boss => 4
    _ => 0
  }
  let key = body_index * self.weapons.length() + weapon_index
  match self.equipped_meshes.get(key) {
    Some(mesh) => mesh
    None => {
      let parts = self.get_mesh_data(kind).parts.copy()
      parts.append(self.weapons[weapon_index].mesh.parts)
      let mesh = combine_enemy_parts(parts)
      self.equipped_meshes[key] = mesh
      mesh
    }
  }
}
