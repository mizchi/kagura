///|
/// A quadruped asset carries its own rig and needs no weapon attachment.
pub fn export_wolf_motion_asset() -> String {
  let skeleton : Array[Json] = wolf_skeleton.bones.map(bone => {
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
  let clips : Array[Json] = []
  for i, clip in wolf_clips {
    let channels : Array[Json] = clip.channels.map(channel => {
      let target = match channel.target {
        @animation3d.Translation => "translation"
        @animation3d.Rotation => "rotation"
        @animation3d.Scale => "scale"
      }
      {
        "joint": channel.node_index.to_json(),
        "target": target.to_json(),
        "interpolation": "linear",
        "times": channel.times.to_json(),
        "values": channel.values.to_json(),
      }
    })
    let events : Array[Json] = if i == 2 {
      [
        {
          "name": "Impact",
          "time": (@game.Bite.melee_profile().unwrap().windup.to_double() / 60.0).to_json(),
        },
      ]
    } else {
      []
    }
    clips.push({
      "id": clip.name.to_json(),
      "name": ["歩く / Walk", "走る / Run", "噛み付く / Bite"][i].to_json(),
      "duration": clip.duration.to_json(),
      "fps": 60,
      "events": events.to_json(),
      "channels": channels.to_json(),
    })
  }
  let models : Array[Json] = [
    {
      "id": "wolf",
      "name": "灰狼 / Ash wolf",
      "parts": export_motion_parts(wolf_mesh.parts).to_json(),
    },
  ]
  let weapons : Array[Json] = [
    {
      "id": "natural",
      "name": "牙・四肢",
      "parts": ([] : Array[Json]).to_json(),
      "clips": ["wolf_walk", "wolf_run", "wolf_bite"].to_json(),
      "defaultClip": "wolf_walk",
    },
  ]
  (
    {
      "format": "kagura.motion",
      "version": 2,
      "name": "ASHEN HUNT — 灰狼",
      "skeleton": skeleton.to_json(),
      "models": models.to_json(),
      "clips": clips.to_json(),
      "weapons": weapons.to_json(),
    } : Json).stringify()
}
