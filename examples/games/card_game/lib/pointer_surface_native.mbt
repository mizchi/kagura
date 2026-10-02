///|
fn Game::surface_input(
  self : Game,
  input : @core.InputSnapshot,
) -> @core.InputSnapshot {
  scale_pointer_input(
    input,
    self.layout.w,
    self.layout.h,
    self.layout.w,
    self.layout.h,
  )
}
