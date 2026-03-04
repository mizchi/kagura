///|
/// A scene that can be updated and drawn.
pub(open) trait Scene {
  update(Self, @core.InputSnapshot) -> Unit
  draw(Self, @engine.EngineContext) -> Array[@gfx.DrawTrianglesCommand]
}

///|
/// Scene manager with transition support.
pub struct SceneManager {
  mut current : &Scene
  mut next : &Scene?
  mut transition_progress : Double // 0.0 = current, 1.0 = next
  mut transition_duration : Double // seconds
  mut transitioning : Bool
}

///|
pub fn SceneManager::new(initial : &Scene) -> SceneManager {
  {
    current: initial,
    next: None,
    transition_progress: 0.0,
    transition_duration: 0.5,
    transitioning: false,
  }
}

///|
/// Request transition to a new scene.
pub fn SceneManager::transition_to(
  self : SceneManager,
  next : &Scene,
  duration~ : Double = 0.5,
) -> Unit {
  self.next = Some(next)
  self.transition_progress = 0.0
  self.transition_duration = duration
  self.transitioning = true
}

///|
/// Call each frame with delta time in seconds.
pub fn SceneManager::update(
  self : SceneManager,
  input : @core.InputSnapshot,
  dt~ : Double = 1.0 / 60.0,
) -> Unit {
  if self.transitioning {
    self.transition_progress = self.transition_progress +
      dt / self.transition_duration
    if self.transition_progress >= 1.0 {
      self.transition_progress = 1.0
      // Complete transition
      match self.next {
        Some(next_scene) => {
          self.current = next_scene
          self.next = None
          self.transitioning = false
          self.transition_progress = 0.0
        }
        None => {
          self.transitioning = false
          self.transition_progress = 0.0
        }
      }
      self.current.update(input)
    } else {
      // Update current scene during transition
      self.current.update(input)
    }
  } else {
    self.current.update(input)
  }
}

///|
/// Returns draw commands. During transitions, returns current scene's commands
/// (the fade effect would be handled by a post-processing overlay).
pub fn SceneManager::draw(
  self : SceneManager,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  if self.transitioning && self.transition_progress >= 0.5 {
    // After halfway, show the next scene
    match self.next {
      Some(next_scene) => next_scene.draw(ctx)
      None => self.current.draw(ctx)
    }
  } else {
    self.current.draw(ctx)
  }
}

///|
/// Returns true if a transition is in progress.
pub fn SceneManager::is_transitioning(self : SceneManager) -> Bool {
  self.transitioning
}

///|
/// Returns the current transition progress (0.0 to 1.0).
pub fn SceneManager::progress(self : SceneManager) -> Double {
  self.transition_progress
}

///|
/// Returns the fade alpha for overlay rendering.
/// 0.0 = fully transparent, 1.0 = fully opaque.
/// Fades out (0->1) in first half, fades in (1->0) in second half.
pub fn SceneManager::fade_alpha(self : SceneManager) -> Double {
  if not(self.transitioning) {
    return 0.0
  }
  let p = self.transition_progress
  if p < 0.5 {
    p * 2.0 // 0.0 -> 1.0
  } else {
    (1.0 - p) * 2.0 // 1.0 -> 0.0
  }
}
