///|
/// An unarmed zombie exports the exact poses used for simulation and rendering.
pub fn export_zombie_motion_asset() -> String {
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
  let clips : Array[Json] = []
  for i, clip in zombie_clips {
    let channels : Array[Json] = clip.channels.map(channel => {
      let target = match channel.target {
        @animation3d.Translation => "translation"
        @animation3d.Rotation => "rotation"
        @animation3d.Scale => "scale"
      }
      {
        "joint": Json(channel.node_index),
        "target": Json(target),
        "interpolation": "linear",
        "times": Json(channel.times),
        "values": Json(channel.values),
      }
    })
    let events : Array[Json] = if i == 2 {
      [
        {
          "name": "Impact",
          "time": Json(
            @game.Pounce.melee_profile().unwrap().windup.to_double() / 60.0,
          ),
        },
      ]
    } else {
      []
    }
    clips.push({
      "id": Json(clip.name),
      "name": Json(
        [
          "項垂れる / Idle", "足を引きずる / Shamble", "飛びかかる / Pounce",
        ][i],
      ),
      "duration": Json(clip.duration),
      "fps": 60,
      "events": Json(events),
      "channels": Json(channels),
    })
  }
  let models : Array[Json] = [
    {
      "id": "zombie",
      "name": "屍人 / Zombie",
      "parts": Json(export_motion_parts(zombie_mesh.parts)),
    },
  ]
  let weapons : Array[Json] = [
    {
      "id": "natural",
      "name": "素手",
      "parts": Json(([] : Array[Json])),
      "clips": Json(["zombie_idle", "zombie_shamble", "zombie_pounce"]),
      "defaultClip": "zombie_idle",
    },
  ]
  (
    {
      "format": "kagura.motion",
      "version": 2,
      "name": "ASHEN REALMS — 屍人",
      "skeleton": Json(skeleton),
      "models": Json(models),
      "clips": Json(clips),
      "weapons": Json(weapons),
    } : Json).stringify()
}
