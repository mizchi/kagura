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
    (id, name, data, clip) in [
      ("goblin", "Goblin", models.basic, "punch"),
      ("kobold", "Kobold", models.fast, "spear_thrust"),
      ("archer", "Skeleton archer", models.ranged, "bow_shot"),
      ("caster", "Skeleton mage", models.caster, "cast_spell"),
      ("tank", "Armored goblin", models.tank, "punch"),
      ("boss", "Skeleton lord", models.boss, "cast_spell"),
    ] {
    let parts : Array[Json] = data.parts.map(part => {
      "name": part.name.to_json(),
      "color": [part.color.x, part.color.y, part.color.z, part.color.w].to_json(),
      "vertices": part.geometry.bind_mesh.vertex_data.to_json(),
      "indices": part.geometry.bind_mesh.indices.to_json(),
      "joints": part.geometry.skin_data.joint_indices.to_json(),
      "weights": part.geometry.skin_data.weights.to_json(),
    })
    characters.push({
      "id": id.to_json(),
      "name": name.to_json(),
      "defaultClip": clip.to_json(),
      "parts": parts.to_json(),
    })
  }
  let clips : Array[Json] = []
  for
    (id, name, clip, windup, recovery) in [
      ("punch", "Punch", build_punch_clip(), 18, 22),
      ("spear_thrust", "Spear thrust", build_spear_thrust_clip(), 24, 24),
      (
        "cast_spell",
        "Cast spell",
        build_cast_spell_clip(),
        @game.meteor_cast_frames,
        24,
      ),
      (
        "bow_shot",
        "Bow shot",
        build_bow_shot_clip(),
        @game.enemy_bow_draw_frames,
        22,
      ),
    ] {
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
  (
    {
      "format": "kagura.motion",
      "version": 1,
      "name": "ASHEN HUNT",
      "skeleton": skeleton.to_json(),
      "models": characters.to_json(),
      "clips": clips.to_json(),
    } : Json).stringify()
}
