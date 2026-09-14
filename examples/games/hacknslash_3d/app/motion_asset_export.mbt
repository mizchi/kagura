///|
/// Portable authoring data, exported from the same meshes and clips as the game.
/// The offline motion_api entry does not initialize the browser or run gameplay.
pub fn export_enemy_motion_asset() -> String {
  let models = EnemyModels::new()
  let skeleton : Array[Json] = shared_enemy_skeleton.bones.map(bone => {
    let pose = bone.local_transform
    {
      "name": bone.name.to_json(),
      "parent": bone.parent.to_json(),
      "position": [pose.position.x, pose.position.y, pose.position.z].to_json(),
      "rotation": [
        pose.rotation.x,
        pose.rotation.y,
        pose.rotation.z,
        pose.rotation.w,
      ].to_json(),
      "scale": [pose.scale.x, pose.scale.y, pose.scale.z].to_json(),
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
      "id": id.to_json(),
      "name": name.to_json(),
      "parts": export_motion_parts(data.parts).to_json(),
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
      "id": weapon.id.to_json(),
      "name": weapon.name.to_json(),
      "parts": export_motion_parts(weapon.mesh.parts).to_json(),
      "clips": [id, "charge"].to_json(),
      "defaultClip": id.to_json(),
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
        "joint": channel.node_index.to_json(),
        "target": target.to_json(),
        "interpolation": interpolation.to_json(),
        "times": times.to_json(),
        "values": channel.values.to_json(),
      }
    })
    let events : Array[Json] = [
      {
        "name": (if id == "bow_shot" || id == "cast_spell" {
          "Release"
        } else {
          "Impact"
        }).to_json(),
        "time": contact.to_json(),
      },
    ]
    clips.push({
      "id": id.to_json(),
      "name": name.to_json(),
      "duration": duration.to_json(),
      "fps": 60,
      "events": events.to_json(),
      "channels": channels.to_json(),
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
      "skeleton": skeleton.to_json(),
      "models": characters.to_json(),
      "weapons": weapons.to_json(),
      "clips": clips.to_json(),
    } : Json).stringify()
}

///|
fn export_motion_parts(parts : Array[EnemyMaterialPart]) -> Array[Json] {
  parts.map(part => {
    "name": part.name.to_json(),
    "color": [part.color.x, part.color.y, part.color.z, part.color.w].to_json(),
    "vertices": part.geometry.bind_mesh.vertex_data.to_json(),
    "indices": part.geometry.bind_mesh.indices.to_json(),
    "joints": part.geometry.skin_data.joint_indices.to_json(),
    "weights": part.geometry.skin_data.weights.to_json(),
  })
}
