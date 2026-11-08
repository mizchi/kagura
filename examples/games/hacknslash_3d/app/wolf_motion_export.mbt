///|
/// A quadruped asset carries its own rig and needs no weapon attachment.
pub fn export_wolf_motion_asset() -> String {
  let skeleton : Array[Json] = wolf_skeleton.bones.map(bone => {
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
  for i, clip in wolf_clips {
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
            @game.Bite.melee_profile().unwrap().windup.to_double() / 60.0,
          ),
        },
      ]
    } else {
      []
    }
    clips.push({
      "id": Json(clip.name),
      "name": Json(["歩く / Walk", "走る / Run", "噛み付く / Bite"][i]),
      "duration": Json(clip.duration),
      "fps": 60,
      "events": Json(events),
      "channels": Json(channels),
    })
  }
  let models : Array[Json] = [
    {
      "id": "wolf",
      "name": "灰狼 / Ash wolf",
      "parts": Json(export_motion_parts(wolf_mesh.parts)),
    },
  ]
  let weapons : Array[Json] = [
    {
      "id": "natural",
      "name": "牙・四肢",
      "parts": Json(([] : Array[Json])),
      "clips": Json(["wolf_walk", "wolf_run", "wolf_bite"]),
      "defaultClip": "wolf_walk",
    },
  ]
  (
    {
      "format": "kagura.motion",
      "version": 2,
      "name": "ASHEN REALMS — 灰狼",
      "skeleton": Json(skeleton),
      "models": Json(models),
      "clips": Json(clips),
      "weapons": Json(weapons),
    } : Json).stringify()
}
