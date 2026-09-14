///|
/// An unarmed zombie exports the exact poses used for simulation and rendering.
pub fn export_zombie_motion_asset() -> String {
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
  let clips : Array[Json] = []
  for i, clip in zombie_clips {
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
          "time": (@game.Pounce.melee_profile().unwrap().windup.to_double() /
          60.0).to_json(),
        },
      ]
    } else {
      []
    }
    clips.push({
      "id": clip.name.to_json(),
      "name": [
        "項垂れる / Idle", "足を引きずる / Shamble", "飛びかかる / Pounce",
      ][i].to_json(),
      "duration": clip.duration.to_json(),
      "fps": 60,
      "events": events.to_json(),
      "channels": channels.to_json(),
    })
  }
  let models : Array[Json] = [
    {
      "id": "zombie",
      "name": "屍人 / Zombie",
      "parts": export_motion_parts(zombie_mesh.parts).to_json(),
    },
  ]
  let weapons : Array[Json] = [
    {
      "id": "natural",
      "name": "素手",
      "parts": ([] : Array[Json]).to_json(),
      "clips": ["zombie_idle", "zombie_shamble", "zombie_pounce"].to_json(),
      "defaultClip": "zombie_idle",
    },
  ]
  (
    {
      "format": "kagura.motion",
      "version": 2,
      "name": "ASHEN REALMS — 屍人",
      "skeleton": skeleton.to_json(),
      "models": models.to_json(),
      "clips": clips.to_json(),
      "weapons": weapons.to_json(),
    } : Json).stringify()
}
