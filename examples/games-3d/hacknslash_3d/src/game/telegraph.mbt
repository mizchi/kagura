// Telegraph marker system: FF14-style persistent ground indicators
// Shows danger zones that fill up over cast time, then disappear on execution.

///|
pub(all) enum TelegraphShape {
  Circle // circular AoE (meteor, fire nova)
  Line // directional (tackle charge, bolt)
}

///|
pub(all) struct TelegraphMarker {
  x : Double // center X in game world
  y : Double // center Y in game world
  radius : Double // radius for Circle, width for Line
  shape : TelegraphShape
  mut frames_remaining : Int // countdown to execution
  total_frames : Int // original cast time
  // For Line shape: direction endpoint
  end_x : Double
  end_y : Double
}

///|
pub fn TelegraphMarker::progress(self : TelegraphMarker) -> Double {
  let elapsed = (self.total_frames - self.frames_remaining).to_double()
  elapsed / self.total_frames.to_double().max(1.0)
}

///|
pub fn TelegraphMarker::is_expired(self : TelegraphMarker) -> Bool {
  self.frames_remaining <= 0
}

///|
pub fn add_telegraph_circle(
  world : GameWorld,
  x : Double,
  y : Double,
  radius : Double,
  cast_frames : Int,
) -> Unit {
  world.telegraph_markers.push({
    x,
    y,
    radius,
    shape: Circle,
    frames_remaining: cast_frames,
    total_frames: cast_frames,
    end_x: x,
    end_y: y,
  })
}

///|
pub fn add_telegraph_line(
  world : GameWorld,
  start_x : Double,
  start_y : Double,
  end_x : Double,
  end_y : Double,
  width : Double,
  cast_frames : Int,
) -> Unit {
  world.telegraph_markers.push({
    x: start_x,
    y: start_y,
    radius: width,
    shape: Line,
    frames_remaining: cast_frames,
    total_frames: cast_frames,
    end_x,
    end_y,
  })
}

///|
pub fn tick_telegraph_markers(world : GameWorld) -> Unit {
  let still_active : Array[TelegraphMarker] = []
  for marker in world.telegraph_markers {
    marker.frames_remaining = marker.frames_remaining - 1
    if marker.frames_remaining > 0 {
      still_active.push(marker)
    }
  }
  world.telegraph_markers = still_active
}
