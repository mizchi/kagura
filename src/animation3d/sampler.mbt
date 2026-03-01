///|
/// Find the keyframe index for the given time using binary search.
/// Returns the index of the last keyframe <= time.
fn find_keyframe(times : Array[Double], time : Double) -> Int {
  let len = times.length()
  if len == 0 {
    return 0
  }
  if time <= times[0] {
    return 0
  }
  if time >= times[len - 1] {
    return len - 1
  }
  // Binary search for the interval
  let mut lo = 0
  let mut hi = len - 1
  while lo < hi - 1 {
    let mid = (lo + hi) / 2
    if times[mid] <= time {
      lo = mid
    } else {
      hi = mid
    }
  }
  lo
}

///|
/// Sample a Vec3 channel at the given time.
pub fn sample_vec3(channel : AnimChannel, time : Double) -> @math3d.Vec3 {
  let len = channel.times.length()
  if len == 0 {
    return @math3d.Vec3::zero()
  }
  // Clamp to range
  if time <= channel.times[0] {
    return @math3d.Vec3::new(
      channel.values[0],
      channel.values[1],
      channel.values[2],
    )
  }
  if time >= channel.times[len - 1] {
    let i = (len - 1) * 3
    return @math3d.Vec3::new(
      channel.values[i],
      channel.values[i + 1],
      channel.values[i + 2],
    )
  }
  let idx = find_keyframe(channel.times, time)
  let v0 = @math3d.Vec3::new(
    channel.values[idx * 3],
    channel.values[idx * 3 + 1],
    channel.values[idx * 3 + 2],
  )
  match channel.interpolation {
    Step => v0
    Linear => {
      let next = idx + 1
      if next >= len {
        return v0
      }
      let t0 = channel.times[idx]
      let t1 = channel.times[next]
      let dt = t1 - t0
      let t = if dt > 1.0e-10 { (time - t0) / dt } else { 0.0 }
      let v1 = @math3d.Vec3::new(
        channel.values[next * 3],
        channel.values[next * 3 + 1],
        channel.values[next * 3 + 2],
      )
      v0.lerp(v1, t)
    }
  }
}

///|
/// Sample a Quaternion channel at the given time.
pub fn sample_quat(channel : AnimChannel, time : Double) -> @math3d.Quaternion {
  let len = channel.times.length()
  if len == 0 {
    return @math3d.Quaternion::identity()
  }
  // Clamp to range
  if time <= channel.times[0] {
    return @math3d.Quaternion::new(
      channel.values[0],
      channel.values[1],
      channel.values[2],
      channel.values[3],
    )
  }
  if time >= channel.times[len - 1] {
    let i = (len - 1) * 4
    return @math3d.Quaternion::new(
      channel.values[i],
      channel.values[i + 1],
      channel.values[i + 2],
      channel.values[i + 3],
    )
  }
  let idx = find_keyframe(channel.times, time)
  let q0 = @math3d.Quaternion::new(
    channel.values[idx * 4],
    channel.values[idx * 4 + 1],
    channel.values[idx * 4 + 2],
    channel.values[idx * 4 + 3],
  )
  match channel.interpolation {
    Step => q0
    Linear => {
      let next = idx + 1
      if next >= len {
        return q0
      }
      let t0 = channel.times[idx]
      let t1 = channel.times[next]
      let dt = t1 - t0
      let t = if dt > 1.0e-10 { (time - t0) / dt } else { 0.0 }
      let q1 = @math3d.Quaternion::new(
        channel.values[next * 4],
        channel.values[next * 4 + 1],
        channel.values[next * 4 + 2],
        channel.values[next * 4 + 3],
      )
      q0.slerp(q1, t)
    }
  }
}
