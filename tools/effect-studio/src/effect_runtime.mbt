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
