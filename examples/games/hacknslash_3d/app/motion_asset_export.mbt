///|
/// Portable authoring data, exported from the same meshes and clips as the game.
/// The offline motion_api entry does not initialize the browser or run gameplay.
pub fn export_enemy_motion_asset() -> String {
  let models = EnemyModels::new()
  let skeleton : Array[Json] = shared_enemy_skeleton.bones.map(bone => {
    let pose = bone.local_transform
    {
      "name": Json(bone.name),
      "parent": Json(bone.parent),
      "position": Json([pose.position.x, pose.position.y, pose.position.z]),
      "rotation": Json([
        pose.rotation.x,
        pose.rotation.y,
        pose.rotation.z,
        pose.rotation.w,
      ]),
      "scale": Json([pose.scale.x, pose.scale.y, pose.scale.z]),
    }
  })
  let characters : Array[Json] = []
  for
    (id, name, data) in [
      ("goblin", "Goblin", models.basic),
      ("kobold", "Kobold", models.fast),
      ("skeleton", "Skeleton", models.caster),
      ("tank", "Armored goblin", models.tank),
      ("boss", "Skeleton lord", models.boss),
    ] {
    characters.push({
      "id": Json(id),
      "name": Json(name),
      "parts": Json(export_motion_parts(data.parts)),
    })
  }
  let clips : Array[Json] = []
  let weapons : Array[Json] = []
  for weapon in models.weapons {
    let id = weapon.clip_id
    let name = weapon.clip_name
    let clip = weapon.clip
    let windup = weapon.windup
    let recovery = weapon.recovery
    weapons.push({
      "id": Json(weapon.id),
      "name": Json(weapon.name),
      "parts": Json(export_motion_parts(weapon.mesh.parts)),
      "clips": Json([id, "charge"]),
      "defaultClip": Json(id),
    })
    let contact = windup.to_double() / 60.0
    let duration = (windup + recovery).to_double() / 60.0
    let channels : Array[Json] = clip.channels.map(channel => {
      let times = channel.times.map(time => {
        if time <= 0.5 {
          time * 2.0 * contact
        } else {
          contact + (time - 0.5) * 2.0 * recovery.to_double() / 60.0
        }
      })
      let target = match channel.target {
        @animation3d.Translation => "translation"
        @animation3d.Rotation => "rotation"
        @animation3d.Scale => "scale"
      }
      let interpolation = match channel.interpolation {
        @animation3d.Step => "step"
        _ => "linear"
      }
      {
        "joint": Json(channel.node_index),
        "target": Json(target),
        "interpolation": Json(interpolation),
        "times": Json(times),
        "values": Json(channel.values),
      }
    })
    let events : Array[Json] = [
      {
        "name": Json(
          if id == "bow_shot" || id == "cast_spell" {
            "Release"
          } else {
            "Impact"
          },
        ),
        "time": Json(contact),
      },
    ]
    clips.push({
      "id": Json(id),
      "name": Json(name),
      "duration": Json(duration),
      "fps": 60,
      "events": Json(events),
      "channels": Json(channels),
    })
  }
  clips.push(
    export_charge_clip(shared_enemy_charge_clip, @game.enemy_charge_profile),
  )
  (
    {
      "format": "kagura.motion",
      "version": 2,
      "name": "ASHEN REALMS",
      "skeleton": Json(skeleton),
      "models": Json(characters),
      "weapons": Json(weapons),
      "clips": Json(clips),
    } : Json).stringify()
}

///|
fn export_motion_parts(parts : Array[EnemyMaterialPart]) -> Array[Json] {
  parts.map(part => {
    "name": Json(part.name),
    "color": Json([part.color.x, part.color.y, part.color.z, part.color.w]),
    "vertices": Json(part.geometry.bind_mesh.vertex_data),
    "indices": Json(part.geometry.bind_mesh.indices),
    "joints": Json(part.geometry.skin_data.joint_indices),
    "weights": Json(part.geometry.skin_data.weights),
  })
}
