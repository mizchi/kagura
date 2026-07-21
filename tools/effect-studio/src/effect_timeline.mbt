///|
pub struct TimelineTrackLane {
  id : String
  label : String
  start_ratio : Double
  duration_ratio : Double
  active : Bool
  marker_ratios : Array[Double]
  accent_color : @math3d.Vec4
} derive(Debug)

///|
pub impl Show for TimelineTrackLane with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub struct TimelineView {
  duration : Double
  normalized_time : Double
  playhead_ratio : Double
  lanes : Array[TimelineTrackLane]
} derive(Debug)

///|
pub impl Show for TimelineView with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
fn clamp_ratio(value : Double) -> Double {
  if value < 0.0 {
    0.0
  } else if value > 1.0 {
    1.0
  } else {
    value
  }
}

///|
pub fn build_timeline_view(
  doc : EffectDocument,
  preview_time : Double,
) -> TimelineView {
  let normalized_time = effect_document_time(doc, preview_time)
  let duration = if doc.duration <= 0.000001 { 1.0 } else { doc.duration }
  let lanes : Array[TimelineTrackLane] = []
  for track in doc.tracks {
    let markers : Array[Double] = []
    let interval = if track.burst_interval <= 0.000001 {
      track.duration + 1.0
    } else {
      track.burst_interval
    }
    let end_time = effect_track_end_time(track)
    let mut burst_index = 0
    let mut spawn_time = track.start_time
    while spawn_time <= end_time + 0.000001 {
      markers.push(clamp_ratio(spawn_time / duration))
      burst_index += 1
      spawn_time = track.start_time + burst_index.to_double() * interval
    }
    lanes.push({
      id: track.id,
      label: track.label,
      start_ratio: clamp_ratio(track.start_time / duration),
      duration_ratio: clamp_ratio(track.duration / duration),
      active: track.enabled &&
      normalized_time >= track.start_time &&
      normalized_time <= end_time,
      marker_ratios: markers,
      accent_color: track.color_start,
    })
  }
  {
    duration,
    normalized_time,
    playhead_ratio: clamp_ratio(normalized_time / duration),
    lanes,
  }
}

///|
pub extend TimelineTrackLane with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TimelineTrackLane with Show::{to_string, output}

///|
pub extend TimelineView with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TimelineView with Show::{to_string, output}
