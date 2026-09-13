///|
/// A shared authored action: crouch, drive through two strides, plant and recover.
/// Root X/Z stays zero; collision-aware gameplay owns travel on both rigs.
fn build_charge_clip(hunter : Bool) -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = []
  let head = if hunter { 5 } else { 2 }
  let left_arm = if hunter { 6 } else { 3 }
  let left_hand = if hunter { 7 } else { 4 }
  let right_arm = if hunter { 2 } else { 5 }
  let right_hand = if hunter { 3 } else { 6 }
  let left_leg = if hunter { 8 } else { 7 }
  let left_knee = if hunter { 9 } else { 8 }
  let right_leg = if hunter { 10 } else { 9 }
  let right_knee = if hunter { 11 } else { 10 }
  let times = Array::makei(101, i => i.to_double() / 100.0)
  let joints = [
    1, head, left_arm, left_hand, right_arm, right_hand, left_leg, left_knee, right_leg,
    right_knee,
  ]
  if hunter {
    joints.append([12, 13])
  } else {
    joints.push(11)
  }
  for joint in joints {
    let values : Array[Double] = []
    for t in times {
      let strength = if t < 0.3 {
        t / 0.3
      } else if t > 0.7 {
        (1.0 - t) / 0.3
      } else {
        1.0
      }
      let stride = if t >= 0.3 && t <= 0.7 {
        @math.sin((t - 0.3) / 0.4 * @math.PI * 4.0)
      } else {
        0.0
      }
      let (x, y, z) = if (hunter && joint >= 12) || (!hunter && joint == 11) {
        (-0.55 * strength, 0.0, 0.0)
      } else if joint == 1 {
        (0.38 * strength, -0.12 * strength, 0.0)
      } else if joint == head {
        (-0.16 * strength, 0.0, 0.0)
      } else if joint == right_arm {
        (-1.05 * strength - stride * 0.12, 0.0, -0.22 * strength)
      } else if joint == left_arm {
        (-0.72 * strength + stride * 0.12, 0.0, 0.22 * strength)
      } else if joint == left_hand || joint == right_hand {
        (-0.8 * strength, 0.0, 0.0)
      } else if joint == left_leg {
        (-0.35 * strength + stride * 0.65, 0.0, 0.0)
      } else if joint == right_leg {
        (-0.35 * strength - stride * 0.65, 0.0, 0.0)
      } else {
        (0.7 * strength + stride.abs() * 0.25, 0.0, 0.0)
      }
      let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), y)
        .multiply(
          @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), x),
        )
        .multiply(
          @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), z),
        )
      values.append([q.x, q.y, q.z, q.w])
    }
    channels.push({
      node_index: joint,
      target: @animation3d.Rotation,
      interpolation: @animation3d.Linear,
      times,
      values,
    })
  }
  channels.push({
    node_index: 0,
    target: @animation3d.Translation,
    interpolation: @animation3d.Linear,
    times: [0.0, 0.3, 0.7, 1.0],
    values: [0.0, 0.0, 0.0, 0.0, -0.018, 0.0, 0.0, -0.018, 0.0, 0.0, 0.0, 0.0],
  })
  channels.push({
    node_index: if hunter {
      16
    } else {
      15
    },
    target: @animation3d.Scale,
    interpolation: @animation3d.Step,
    times: [0.0],
    values: [0.0, 0.0, 0.0],
  })
  { name: "charge", channels, duration: 1.0, }
}

///|
let shared_hunter_charge_clip : @animation3d.AnimationClip = build_charge_clip(
  true,
)

///|
let shared_enemy_charge_clip : @animation3d.AnimationClip = build_charge_clip(
  false,
)

///|
fn PlayerCharacter::sample_charge(self : PlayerCharacter) -> Unit {
  let frame = (self.action_time * 60.0).round().to_int()
  self.charge_player.set_time(@game.player_charge_profile.phase(frame))
  @animation3d.apply_node_poses(self.local_poses, self.charge_player.sample())
}

///|
/// Convert the normalized shared action to real gameplay seconds for Studio.
fn export_charge_clip(
  clip : @animation3d.AnimationClip,
  profile : @game.ChargeProfile,
) -> Json {
  let channels : Array[Json] = clip.channels.map(channel => {
    let times = channel.times.map(t => {
      let frame = if t <= 0.3 {
        t / 0.3 * profile.windup.to_double()
      } else if t <= 0.7 {
        profile.windup.to_double() +
        (t - 0.3) / 0.4 * profile.active.to_double()
      } else {
        (profile.windup + profile.active).to_double() +
        (t - 0.7) / 0.3 * profile.recovery.to_double()
      }
      frame / 60.0
    })
    {
      "joint": channel.node_index.to_json(),
      "target": (match channel.target {
        @animation3d.Translation => "translation"
        @animation3d.Rotation => "rotation"
        @animation3d.Scale => "scale"
      }).to_json(),
      "interpolation": (if channel.interpolation is @animation3d.Step {
        "step"
      } else {
        "linear"
      }).to_json(),
      "times": times.to_json(),
      "values": channel.values.to_json(),
    }
  })
  let events : Array[Json] = [
    { "name": "Launch", "time": (profile.windup.to_double() / 60.0).to_json() },
    {
      "name": "Brake",
      "time": ((profile.windup + profile.active).to_double() / 60.0).to_json(),
    },
  ]
  {
    "id": "charge",
    "name": "突進",
    "duration": (profile.duration().to_double() / 60.0).to_json(),
    "fps": 60,
    "channels": channels.to_json(),
    "events": events.to_json(),
  }
}
