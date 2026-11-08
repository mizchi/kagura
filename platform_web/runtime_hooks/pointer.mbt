///|
/// Pointer input contract shared across backends. Browser installations on the
/// same canvas share one buffer; unsupported hosts return None when polled.
pub struct WebPointerInput {
  priv handle : Int32
}

///|
pub fn WebPointerInput::new(selector~ : String = "#app") -> WebPointerInput {
  { handle: create_pointer_input(selector), }
}

///|
/// Consume one press/release/cancel edge before sampling the latest movement.
/// Coordinates are mapped from the canvas CSS box to the requested viewport.
pub fn WebPointerInput::poll(
  self : WebPointerInput,
  width~ : Double,
  height~ : Double,
) -> @ui.UIPointerFrame? {
  let values = poll_pointer_input(self.handle, width, height)
  if values.length() == 0 {
    return None
  }
  Some(
    @ui.UIPointerFrame::new(
      if values[6] == 0.0 {
        @ui.Mouse
      } else {
        @ui.Touch(values[7].to_int())
      },
      values[0],
      values[1],
      pressed=values[2] == 1.0,
      released=values[3] == 1.0,
      down=values[4] == 1.0,
      cancelled=values[5] == 1.0,
    ),
  )
}

///|
pub fn WebPointerInput::dispose(self : WebPointerInput) -> Unit {
  dispose_pointer_input(self.handle)
}
