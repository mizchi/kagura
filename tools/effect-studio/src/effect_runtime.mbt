///|
pub struct ScheduledEffectBurst {
  track_id : String
  track_label : String
  spawn_time : Double
  age : Double
  config : @particle3d.EmitterConfig
}

///|
pub struct EffectRuntimePlan {
  preview_time : Double
  normalized_time : Double
  active_track_ids : Array[String]
  total_particles : Int
  scheduled_bursts : Array[ScheduledEffectBurst]
}

///|
pub struct EffectPlacement {
  origin : @math3d.Vec3
  target : @math3d.Vec3?
  scale : Double
}

///|
pub fn new_effect_placement(
  origin : @math3d.Vec3,
  target : @math3d.Vec3?,
  scale : Double,
) -> EffectPlacement {
  { origin, target, scale }
}

///|
fn hash_u32(seed : Int) -> Int {
  let mut h = seed
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h & 0x7FFFFFFF
}

///|
fn hash_to_double(seed : Int) -> Double {
  hash_u32(seed).to_double() / 2147483647.0
}

///|
fn hash_lerp(seed : Int, min : Double, max : Double) -> Double {
  min + hash_to_double(seed) * (max - min)
}

///|
fn max_double(a : Double, b : Double) -> Double {
  if a > b { a } else { b }
}

///|
fn line_burst_ratio(track : EffectTrack, burst_index : Int) -> Double {
  let interval = max_double(track.burst_interval, 0.000001)
  let burst_count = @cmp.maximum(1, (track.duration / interval).to_int() + 1)
  if burst_count <= 1 {
    0.0
  } else {
    burst_index.to_double() / (burst_count - 1).to_double()
  }
}

///|
fn burst_origin(track : EffectTrack, burst_index : Int) -> @math3d.Vec3 {
  match track.pattern {
    Point => track.origin
    Ring => {
      let angle = burst_index.to_double() * 2.399963229728653
      let dx = @math.cos(angle) * track.spread_radius
      let dz = @math.sin(angle) * track.spread_radius
      track.origin.add(@math3d.Vec3::new(dx, 0.0, dz))
    }
    Column => {
      let dx = hash_lerp(
        burst_index * 17 + 1,
        -track.spread_radius,
        track.spread_radius,
      )
      let dz = hash_lerp(
        burst_index * 17 + 2,
        -track.spread_radius,
        track.spread_radius,
      )
      track.origin.add(@math3d.Vec3::new(dx, 0.0, dz))
    }
    Line => {
      let ratio = line_burst_ratio(track, burst_index)
      let line_origin = track.origin.scale(1.0 - ratio)
      let line_target = track.secondary_origin.scale(ratio)
      let offset = @math3d.Vec3::new(
        hash_lerp(burst_index * 31 + 1, -track.spread_radius, track.spread_radius),
        0.0,
        hash_lerp(burst_index * 31 + 2, -track.spread_radius, track.spread_radius),
      )
      line_origin.add(line_target).add(offset)
    }
  }
}

///|
fn emitter_velocity_min(track : EffectTrack, burst_index : Int) -> @math3d.Vec3 {
  match track.pattern {
    Ring => {
      let angle = burst_index.to_double() * 2.399963229728653
      let outward = @math3d.Vec3::new(@math.cos(angle), 0.15, @math.sin(angle))
      track.initial_velocity_min.add(outward.scale(0.4))
    }
    _ => track.initial_velocity_min
  }
}

///|
fn emitter_velocity_max(track : EffectTrack, burst_index : Int) -> @math3d.Vec3 {
  match track.pattern {
    Ring => {
      let angle = burst_index.to_double() * 2.399963229728653
      let outward = @math3d.Vec3::new(@math.cos(angle), 0.25, @math.sin(angle))
      track.initial_velocity_max.add(outward.scale(0.6))
    }
    Column => track.initial_velocity_max.add(@math3d.Vec3::new(0.0, 0.45, 0.0))
    Line => track.initial_velocity_max.add(@math3d.Vec3::new(0.0, 0.18, 0.0))
    Point => track.initial_velocity_max
  }
}

///|
fn scheduled_burst_config(
  track : EffectTrack,
  burst_index : Int,
) -> @particle3d.EmitterConfig {
  {
    position: burst_origin(track, burst_index),
    spawn_rate: track.burst_particles.to_double(),
    initial_velocity_min: emitter_velocity_min(track, burst_index),
    initial_velocity_max: emitter_velocity_max(track, burst_index),
    lifetime_min: track.lifetime_min,
    lifetime_max: track.lifetime_max,
    size_min: track.size_min,
    size_max: track.size_max,
    color_start: track.color_start,
    color_end: track.color_end,
    gravity: track.gravity,
    max_particles: track.burst_particles,
  }
}

///|
fn resolve_track(track : EffectTrack, placement : EffectPlacement) -> EffectTrack {
  let scale = if placement.scale <= 0.000001 { 1.0 } else { placement.scale }
  let target = match placement.target {
    Some(target) => target
    None => placement.origin.add(track.secondary_origin.scale(scale))
  }
  {
    ..track,
    origin: placement.origin.add(track.origin.scale(scale)),
    secondary_origin: target,
    spread_radius: track.spread_radius * scale,
    size_min: track.size_min * scale,
    size_max: track.size_max * scale,
    initial_velocity_min: track.initial_velocity_min.scale(scale),
    initial_velocity_max: track.initial_velocity_max.scale(scale),
    gravity: track.gravity.scale(scale),
  }
}

///|
fn append_effect_runtime_window_for_range(
  doc : EffectDocument,
  from_time : Double,
  to_time : Double,
  placement : EffectPlacement,
  scheduled_bursts : Array[ScheduledEffectBurst],
) -> Unit {
  if to_time + 0.000001 < from_time {
    return
  }
  for base_track in doc.tracks {
    if !base_track.enabled {
      continue
    }
    let track = resolve_track(base_track, placement)
    let end_time = effect_track_end_time(track)
    if to_time + 0.000001 < track.start_time || from_time > end_time + 0.000001 {
      continue
    }
    let interval = max_double(track.burst_interval, 0.000001)
    let window_end = if to_time < end_time { to_time } else { end_time }
    let mut burst_index = 0
    let mut spawn_time = track.start_time
    while spawn_time <= window_end + 0.000001 {
      if spawn_time > from_time + 0.000001 {
        scheduled_bursts.push({
          track_id: track.id,
          track_label: track.label,
          spawn_time,
          age: to_time - spawn_time,
          config: scheduled_burst_config(track, burst_index),
        })
      }
      burst_index += 1
      spawn_time = track.start_time + burst_index.to_double() * interval
    }
  }
}

///|
pub fn build_effect_runtime_window(
  doc : EffectDocument,
  previous_time : Double,
  current_time : Double,
  placement : EffectPlacement,
) -> Array[ScheduledEffectBurst] {
  let scheduled_bursts : Array[ScheduledEffectBurst] = []
  if doc.duration <= 0.000001 {
    return scheduled_bursts
  }
  if doc.looping {
    let from_time = effect_document_time(doc, previous_time)
    let to_time = effect_document_time(doc, current_time)
    if current_time <= previous_time {
      return scheduled_bursts
    }
    if to_time + 0.000001 >= from_time {
      append_effect_runtime_window_for_range(
        doc,
        from_time,
        to_time,
        placement,
        scheduled_bursts,
      )
    } else {
      append_effect_runtime_window_for_range(
        doc,
        from_time,
        doc.duration,
        placement,
        scheduled_bursts,
      )
      append_effect_runtime_window_for_range(
        doc,
        0.0,
        to_time,
        placement,
        scheduled_bursts,
      )
    }
    return scheduled_bursts
  }
  let from_time = @cmp.maximum(0.0, previous_time)
  let to_time = @cmp.minimum(doc.duration, current_time)
  append_effect_runtime_window_for_range(
    doc,
    from_time,
    to_time,
    placement,
    scheduled_bursts,
  )
  scheduled_bursts
}

///|
pub fn build_effect_runtime_plan(
  doc : EffectDocument,
  preview_time : Double,
) -> EffectRuntimePlan {
  let normalized_time = effect_document_time(doc, preview_time)
  let active_track_ids : Array[String] = []
  let scheduled_bursts : Array[ScheduledEffectBurst] = []
  let mut total_particles = 0
  for track in doc.tracks {
    if !track.enabled {
      continue
    }
    let end_time = effect_track_end_time(track)
    if normalized_time >= track.start_time && normalized_time <= end_time {
      active_track_ids.push(track.id)
    }
    if normalized_time + 0.000001 < track.start_time {
      continue
    }
    let interval = max_double(track.burst_interval, 0.000001)
    let emission_end = if normalized_time < end_time {
      normalized_time
    } else {
      end_time
    }
    let mut burst_index = 0
    let mut spawn_time = track.start_time
    while spawn_time <= emission_end + 0.000001 {
      let age = normalized_time - spawn_time
      if age <= track.lifetime_max + 0.000001 {
        scheduled_bursts.push({
          track_id: track.id,
          track_label: track.label,
          spawn_time,
          age,
          config: scheduled_burst_config(track, burst_index),
        })
        total_particles = total_particles + track.burst_particles
      }
      burst_index += 1
      spawn_time = track.start_time + burst_index.to_double() * interval
    }
  }
  {
    preview_time,
    normalized_time,
    active_track_ids,
    total_particles,
    scheduled_bursts,
  }
}
