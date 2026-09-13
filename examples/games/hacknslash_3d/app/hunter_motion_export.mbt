///|
/// Sample the actual player rig, including upper-body masking and release keys.
/// The viewer and combat share the same weapon profile measured in 60 Hz frames.
pub fn export_hunter_motion_asset() -> String {
  let actor = PlayerCharacter::new()
  let skeleton : Array[Json] = actor.skeleton.bones.map(bone => {
    let p = bone.local_transform
    {
      "name": bone.name.to_json(),
      "parent": bone.parent.to_json(),
      "position": [p.position.x, p.position.y, p.position.z].to_json(),
      "rotation": [p.rotation.x, p.rotation.y, p.rotation.z, p.rotation.w].to_json(),
      "scale": [p.scale.x, p.scale.y, p.scale.z].to_json(),
    }
  })
  let models : Array[Json] = [
    {
      "id": "hunter",
      "name": "Hunter",
      "parts": export_hunter_parts(actor.body_parts).to_json(),
    },
  ]
  let weapons : Array[Json] = []
  let clips : Array[Json] = []
  for weapon in shared_hunter_weapon_sets {
    let profile = weapon.kind.profile()
    let id = profile.id + "_attack"
    weapons.push({
      "id": weapon.id.to_json(),
      "name": profile.name.to_json(),
      "parts": export_hunter_parts(weapon.parts).to_json(),
      "clips": [id, "charge"].to_json(),
      "defaultClip": id.to_json(),
    })
    actor.equip_weapon(weapon.kind)
    actor.trigger_attack()
    let count = profile.windup + profile.recovery + 1
    let times = Array::makei(count, i => i.to_double() / 60.0)
    let rotations : Array[Array[Double]] = Array::makei(char_num_bones, _ => [])
    let translations : Array[Array[Double]] = Array::makei(char_num_bones, _ => {
      []
    })
    let scales : Array[Array[Double]] = Array::makei(char_num_bones, _ => [])
    for frame in 0..<count {
      actor.action_time = times[frame]
      actor.anim_state = if frame == count - 1 { Idle } else { Attacking }
      actor.skinning_cache_dirty = true
      let _ = actor.compute_skinning()
      for i in 0..<char_num_bones {
        let p = actor.local_poses[i]
        rotations[i].append([
          p.rotation.x,
          p.rotation.y,
          p.rotation.z,
          p.rotation.w,
        ])
        translations[i].append([p.position.x, p.position.y, p.position.z])
        scales[i].append([p.scale.x, p.scale.y, p.scale.z])
      }
    }
    let channels : Array[Json] = []
    for i in 0..<char_num_bones {
      for
        (target, values) in [
          ("rotation", rotations[i]),
          ("translation", translations[i]),
          ("scale", scales[i]),
        ] {
        channels.push({
          "joint": i.to_json(),
          "target": target.to_json(),
          "interpolation": (if target == "scale" { "step" } else { "linear" }).to_json(),
          "times": times.to_json(),
          "values": values.to_json(),
        })
      }
    }
    let events : Array[Json] = [
      {
        "name": (if weapon.kind == @game.Bow || weapon.kind == @game.Focus {
          "Release"
        } else {
          "Impact"
        }).to_json(),
        "time": (profile.windup.to_double() / 60.0).to_json(),
      },
    ]
    clips.push({
      "id": id.to_json(),
      "name": profile.action.to_json(),
      "duration": weapon.attack_duration.to_json(),
      "fps": 60,
      "channels": channels.to_json(),
      "events": events.to_json(),
    })
  }
  clips.push(
    export_charge_clip(shared_hunter_charge_clip, @game.player_charge_profile),
  )
  (
    {
      "format": "kagura.motion",
      "version": 2,
      "name": "ASHEN HUNT / Hunter",
      "skeleton": skeleton.to_json(),
      "models": models.to_json(),
      "weapons": weapons.to_json(),
      "clips": clips.to_json(),
    } : Json).stringify()
}

///|
fn export_hunter_parts(parts : Array[HunterPart]) -> Array[Json] {
  parts.map(part => {
    "name": part.name.to_json(),
    "color": [part.color.x, part.color.y, part.color.z, part.color.w].to_json(),
    "vertices": part.mesh.vertex_data.to_json(),
    "indices": part.mesh.indices.to_json(),
    "joints": part.skin.joint_indices.to_json(),
    "weights": part.skin.weights.to_json(),
  })
}
