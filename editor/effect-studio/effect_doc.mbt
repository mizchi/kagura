///|
pub enum EffectSpawnPattern {
  Point
  Ring
  Column
  Line
} derive(Debug)

///|
pub impl Show for EffectSpawnPattern with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct EffectTrack {
  id : String
  label : String
  start_time : Double
  duration : Double
  burst_interval : Double
  burst_particles : Int
  pattern : EffectSpawnPattern
  origin : @math3d.Vec3
  secondary_origin : @math3d.Vec3
  spread_radius : Double
  initial_velocity_min : @math3d.Vec3
  initial_velocity_max : @math3d.Vec3
  lifetime_min : Double
  lifetime_max : Double
  size_min : Double
  size_max : Double
  color_start : @math3d.Vec4
  color_end : @math3d.Vec4
  gravity : @math3d.Vec3
  enabled : Bool
} derive(Debug)

///|
pub impl Show for EffectTrack with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct EffectDocument {
  name : String
  duration : Double
  looping : Bool
  notes : String
  ai_edit_goal : String
  tracks : Array[EffectTrack]
} derive(Debug)

///|
pub impl Show for EffectDocument with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn effect_spawn_pattern_name(pattern : EffectSpawnPattern) -> String {
  match pattern {
    Point => "point"
    Ring => "ring"
    Column => "column"
    Line => "line"
  }
}

///|
pub fn effect_track_end_time(track : EffectTrack) -> Double {
  track.start_time + track.duration
}

///|
pub fn effect_document_time(
  doc : EffectDocument,
  preview_time : Double,
) -> Double {
  if preview_time <= 0.0 {
    0.0
  } else if doc.duration <= 0.000001 {
    0.0
  } else if doc.looping {
    let loops = (preview_time / doc.duration).to_int()
    preview_time - loops.to_double() * doc.duration
  } else if preview_time > doc.duration {
    doc.duration
  } else {
    preview_time
  }
}

///|
fn flash_track() -> EffectTrack {
  {
    id: "core_flash",
    label: "Core Flash",
    start_time: 0.0,
    duration: 0.18,
    burst_interval: 0.32,
    burst_particles: 24,
    pattern: Point,
    origin: @math3d.Vec3::new(0.0, 0.28, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.28, 0.0),
    spread_radius: 0.0,
    initial_velocity_min: @math3d.Vec3::new(-0.1, 0.8, -0.1),
    initial_velocity_max: @math3d.Vec3::new(0.1, 1.8, 0.1),
    lifetime_min: 0.12,
    lifetime_max: 0.22,
    size_min: 0.10,
    size_max: 0.22,
    color_start: @math3d.Vec4::new(1.0, 0.95, 0.65, 1.0),
    color_end: @math3d.Vec4::new(1.0, 0.45, 0.10, 0.0),
    gravity: @math3d.Vec3::new(0.0, -1.4, 0.0),
    enabled: true,
  }
}

///|
fn ember_track() -> EffectTrack {
  {
    id: "embers_ring",
    label: "Ember Ring",
    start_time: 0.08,
    duration: 0.64,
    burst_interval: 0.12,
    burst_particles: 10,
    pattern: Ring,
    origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
    spread_radius: 0.32,
    initial_velocity_min: @math3d.Vec3::new(-0.2, 1.2, -0.2),
    initial_velocity_max: @math3d.Vec3::new(0.2, 2.2, 0.2),
    lifetime_min: 0.45,
    lifetime_max: 0.85,
    size_min: 0.05,
    size_max: 0.12,
    color_start: @math3d.Vec4::new(1.0, 0.65, 0.18, 1.0),
    color_end: @math3d.Vec4::new(0.9, 0.15, 0.05, 0.0),
    gravity: @math3d.Vec3::new(0.0, -2.8, 0.0),
    enabled: true,
  }
}

///|
fn smoke_track() -> EffectTrack {
  {
    id: "smoke_column",
    label: "Smoke Column",
    start_time: 0.16,
    duration: 1.0,
    burst_interval: 0.20,
    burst_particles: 8,
    pattern: Column,
    origin: @math3d.Vec3::new(0.0, 0.12, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.12, 0.0),
    spread_radius: 0.14,
    initial_velocity_min: @math3d.Vec3::new(-0.05, 0.6, -0.05),
    initial_velocity_max: @math3d.Vec3::new(0.05, 1.2, 0.05),
    lifetime_min: 0.80,
    lifetime_max: 1.30,
    size_min: 0.14,
    size_max: 0.24,
    color_start: @math3d.Vec4::new(0.65, 0.68, 0.74, 0.60),
    color_end: @math3d.Vec4::new(0.12, 0.15, 0.20, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.4, 0.0),
    enabled: true,
  }
}

///|
pub fn default_effect_document() -> EffectDocument {
  {
    name: "forge_burst",
    duration: 1.8,
    looping: true,
    notes: "Short forge impact with flash, embers, and smoke.",
    ai_edit_goal: "Keep the timing readable in the timeline and make the burst feel punchy at 0.0-0.2s.",
    tracks: [flash_track(), ember_track(), smoke_track()],
  }
}

///|
pub extend EffectSpawnPattern with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EffectSpawnPattern with Show::{to_string, output}

///|
pub extend EffectTrack with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EffectTrack with Show::{to_string, output}

///|
pub extend EffectDocument with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EffectDocument with Show::{to_string, output}
