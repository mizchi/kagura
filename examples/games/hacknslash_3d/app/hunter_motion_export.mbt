///|
/// Sample the actual player rig, including upper-body masking and release keys.
/// The viewer and combat share the same weapon profile measured in 60 Hz frames.
pub fn export_hunter_motion_asset() -> String {
  let actor = CharacterModel::new()
  let skeleton : Array[Json] = actor.skeleton.bones.map(bone => {
    let p = bone.local_transform
    {
      "name": Json(bone.name),
      "parent": Json(bone.parent),
      "position": Json([p.position.x, p.position.y, p.position.z]),
      "rotation": Json([p.rotation.x, p.rotation.y, p.rotation.z, p.rotation.w]),
      "scale": Json([p.scale.x, p.scale.y, p.scale.z]),
    }
  })
  let models : Array[Json] = [
    {
      "id": "hunter",
      "name": "Hunter",
      "parts": Json(
        export_hunter_parts(character_outfit_parts(Human, actor.outfit)),
      ),
    },
  ]
  for species in [Goblin, Kobold, Skeleton] {
    models.push({
      "id": Json("hunter_" + species.id()),
      "name": Json(species.id()),
      "parts": Json(
        export_hunter_parts(
          character_outfit_parts(species, CharacterOutfit::starter()),
        ),
      ),
    })
  }
  for
    (id, style) in [
      ("bare", None),
      ("leather", Some(Leather)),
      ("plate", Some(Plate)),
      ("occult", Some(Occult)),
    ] {
    models.push({
      "id": Json("hunter_" + id),
      "name": Json("Human / " + id),
      "parts": Json(
        export_hunter_parts(
          character_outfit_parts(Human, character_outfit_preset(style)),
        ),
      ),
    })
  }
  let weapons : Array[Json] = []
  let clips : Array[Json] = []
  for weapon in shared_hunter_weapon_sets {
    let profile = weapon.kind.profile()
    let id = profile.id + "_attack"
    let clip_ids = [id]
    if weapon.kind == @game.Cleaver {
      clip_ids.append([id + "_2", id + "_3"])
    }
    clip_ids.append([
      "charge", "whirlwind", "lightning_cast", "flame_cast", "astral_cast", "dash_strike",
      "raise_zombie", "flaming_skull",
    ])
    weapons.push({
      "id": Json(weapon.id),
      "name": Json(profile.name),
      "parts": Json(export_hunter_parts(weapon.parts)),
      "clips": Json(clip_ids),
      "defaultClip": Json(id),
    })
    let steps = if weapon.kind == @game.Cleaver {
      [@game.Opening, @game.Return, @game.Finisher]
    } else {
      [@game.Opening]
    }
    for step in steps {
      let profile = if weapon.kind == @game.Cleaver {
        step.profile()
      } else {
        profile
      }
      let id = if step == @game.Opening {
        id
      } else if step == @game.Return {
        id + "_2"
      } else {
        id + "_3"
      }
      actor.equip_weapon(weapon.kind)
      actor.trigger_attack(combo=step)
      let count = profile.windup + profile.recovery + 1
      let times = Array::makei(count, i => i.to_double() / 60.0)
      let rotations : Array[Array[Double]] = Array::makei(char_num_bones, _ => {
        []
      })
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
            "joint": Json(i),
            "target": Json(target),
            "interpolation": Json(
              if target == "scale" {
                "step"
              } else {
                "linear"
              },
            ),
            "times": Json(times),
            "values": Json(values),
          })
        }
      }
      let events : Array[Json] = [
        {
          "name": Json(
            if weapon.kind == @game.Bow || weapon.kind == @game.Focus {
              "Release"
            } else {
              "Impact"
            },
          ),
          "time": Json(profile.windup.to_double() / 60.0),
        },
      ]
      clips.push({
        "id": Json(id),
        "name": Json(profile.action),
        "duration": Json(actor.attack_duration()),
        "fps": 60,
        "channels": Json(channels),
        "events": Json(events),
      })
    }
  }

  clips.push(
    export_charge_clip(shared_hunter_charge_clip, @game.player_charge_profile),
  )
  weapons.push({
    "id": "shield_guard",
    "name": "狩人の盾 / ガード",
    "parts": Json(export_hunter_parts(hunter_guard_parts)),
    "clips": Json(["guard"]),
    "defaultClip": "guard",
  })
  for
    (id, name, state, contact) in [
      ("guard", "盾ガード", Guarding, 5),
      (
        "whirlwind",
        "ワールウィンド / ループ",
        Whirling,
        @game.whirlwind_contact_frame,
      ),
      ("lightning_cast", "連鎖雷撃", Casting(@game.LightningArt), 10),
      ("flame_cast", "炎弾の詠唱", Casting(@game.FlameArt), 14),
      ("astral_cast", "星落とし", Casting(@game.AstralArt), 30),
      ("dash_strike", "突進斬り", Casting(@game.DashArt), 16),
      ("raise_zombie", "ゾンビ召喚", Casting(@game.RaiseZombieArt), 18),
      ("flaming_skull", "炎の頭蓋", Casting(@game.FlamingSkullArt), 18),
    ] {
    clips.push(export_hunter_art_clip(id, name, state, contact))
  }
  (
    {
      "format": "kagura.motion",
      "version": 2,
      "name": "ASHEN REALMS / Hunter",
      "skeleton": Json(skeleton),
      "models": Json(models),
      "weapons": Json(weapons),
      "clips": Json(clips),
    } : Json).stringify()
}

///|
fn export_hunter_parts(parts : Array[CharacterPart]) -> Array[Json] {
  parts.map(part => {
    "name": Json(part.name),
    "color": Json([part.color.x, part.color.y, part.color.z, part.color.w]),
    "vertices": Json(part.mesh.vertex_data),
    "indices": Json(part.mesh.indices),
    "joints": Json(part.skin.joint_indices),
    "weights": Json(part.skin.weights),
  })
}

///|
fn export_hunter_art_clip(
  id : String,
  name : String,
  state : CharAnimState,
  contact : Int32,
) -> Json {
  let actor = CharacterModel::new()
  let count = if state == Whirling {
    @game.whirlwind_cycle_frames + 1
  } else if state == Guarding {
    61
  } else {
    37
  }
  let times = Array::makei(count, i => i.to_double() / 60.0)
  let rotations : Array[Array[Double]] = Array::makei(char_num_bones, _ => [])
  let translations : Array[Array[Double]] = Array::makei(char_num_bones, _ => [])
  let scales : Array[Array[Double]] = Array::makei(char_num_bones, _ => [])
  for frame in 0..<count {
    actor.anim_state = if frame == count - 1 && state != Whirling {
      Idle
    } else {
      state
    }
    actor.action_time = times[frame]
    actor.skinning_cache_dirty = true
    ignore(actor.compute_skinning())
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
        "joint": Json(i),
        "target": Json(target),
        "interpolation": "linear",
        "times": Json(times),
        "values": Json(values),
      })
    }
  }
  {
    "id": Json(id),
    "name": Json(name),
    "duration": Json(times[count - 1]),
    "fps": 60,
    "channels": Json(channels),
    "events": Json(
      (
        [{ "name": "Contact", "time": Json(contact.to_double() / 60.0) }] :
        Array[Json]),
    ),
  }
}
