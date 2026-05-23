///|
/// Opaque resource identifiers handed out by `GraphicsDriver`.
///
/// `id` is backend-defined and meaningless without the matching driver.
/// `FilterMode` lives here because it is part of the sampler state baked
/// into an `ImageHandle` view.
///
/// Ebiten refs:
/// - internal/graphicsdriver/graphics.go
/// - internal/atlas/image.go

///|
pub(all) enum FilterMode {
  Nearest
  Linear
  Pixelated
} derive(Debug)

///|
pub impl Show for FilterMode with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn filter_mode_to_int(mode : FilterMode) -> Int {
  match mode {
    FilterMode::Nearest => 0
    FilterMode::Linear => 1
    FilterMode::Pixelated => 2
  }
}

///|
pub fn filter_mode_from_int(mode : Int) -> FilterMode {
  match mode {
    0 => FilterMode::Nearest
    1 => FilterMode::Linear
    2 => FilterMode::Pixelated
    _ => FilterMode::Nearest
  }
}

///|
pub(all) struct ImageHandle {
  id : Int
  width : Int
  height : Int
} derive(Debug)

///|
pub impl Show for ImageHandle with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn new_image_handle(id : Int, width : Int, height : Int) -> ImageHandle {
  { id, width, height }
}

///|
pub(all) struct ShaderHandle {
  id : Int
  source : String
} derive(Debug)

///|
pub impl Show for ShaderHandle with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn new_shader_handle(id : Int, source : String) -> ShaderHandle {
  { id, source }
}

///|
pub(all) struct PipelineHandle {
  id : Int
} derive(Debug)

///|
pub impl Show for PipelineHandle with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn new_pipeline_handle(id : Int) -> PipelineHandle {
  { id, }
}
