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
/// Sampling mode for an image. `Pixelated` is a stricter form of
/// `Nearest` used for low-res 2D art that must stay sharp at upscale.
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
/// Backend-defined image identifier plus a cached size for cheap
/// CPU-side width/height queries. Constructed by `GraphicsDriver.new_image`
/// (or `new_image_handle` when bridging from a non-MoonBit allocator).
pub(all) struct ImageHandle {
  /// Opaque, backend-assigned. Treat as cookie; do not invent values.
  id : Int
  width : Int
  height : Int
} derive(Debug)

///|
pub impl Show for ImageHandle with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Wrap a backend-assigned id with its size. Use only from a backend
/// that allocated `id`; ordinary callers get handles from
/// `GraphicsDriver.new_image`.
pub fn new_image_handle(id : Int, width : Int, height : Int) -> ImageHandle {
  { id, width, height }
}

///|
/// Backend-defined shader identifier plus a copy of the source string
/// so the queue can fingerprint or re-emit the shader without
/// round-tripping the backend.
pub(all) struct ShaderHandle {
  id : Int
  source : String
} derive(Debug)

///|
pub impl Show for ShaderHandle with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Wrap a backend-assigned shader id together with its compiled source.
pub fn new_shader_handle(id : Int, source : String) -> ShaderHandle {
  { id, source }
}

///|
/// Backend-defined pipeline state identifier. Pipelines are hashed by
/// `DrawTrianglesCommand.pipeline_id` so two commands hashing to the
/// same pipeline can share a draw call.
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
