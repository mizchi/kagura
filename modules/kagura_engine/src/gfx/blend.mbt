///|
/// Blend equation primitives and preset modes.
///
/// `BlendMode` is the public surface (Copy/Alpha/Add/Multiply/Custom);
/// `BlendEquation` is the lower-level form a backend actually programs;
/// `BlendFactor` and `BlendOperation` are the components.
///
/// Ebiten ref: internal/graphicsdriver/blend.go

///|
/// Blend factor for custom blend equations.
pub enum BlendFactor {
  Zero
  One
  SrcAlpha
  OneMinusSrcAlpha
  DstAlpha
  OneMinusDstAlpha
  SrcColor
  OneMinusSrcColor
  DstColor
  OneMinusDstColor
} derive(Debug)

///|
pub impl Show for BlendFactor with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Blend operation for custom blend equations.
pub enum BlendOperation {
  Add
  Subtract
  ReverseSubtract
  Min
  Max
} derive(Debug)

///|
pub impl Show for BlendOperation with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Custom blend equation with separate RGB and Alpha channels.
pub struct BlendEquation {
  src_factor_rgb : BlendFactor
  dst_factor_rgb : BlendFactor
  op_rgb : BlendOperation
  src_factor_alpha : BlendFactor
  dst_factor_alpha : BlendFactor
  op_alpha : BlendOperation
} derive(Debug)

///|
pub impl Show for BlendEquation with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub enum BlendMode {
  Copy
  Alpha
  Add
  Multiply
  Custom(BlendEquation)
} derive(Debug)

///|
pub impl Show for BlendMode with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn blend_mode_to_int(mode : BlendMode) -> Int {
  match mode {
    BlendMode::Copy => 0
    BlendMode::Alpha => 1
    BlendMode::Add => 2
    BlendMode::Multiply => 3
    BlendMode::Custom(_) => 4
  }
}

///|
pub fn blend_mode_from_int(mode : Int) -> BlendMode {
  match mode {
    0 => BlendMode::Copy
    1 => BlendMode::Alpha
    2 => BlendMode::Add
    3 => BlendMode::Multiply
    _ => BlendMode::Alpha
  }
}

///|
/// Get the blend equation for any BlendMode including presets.
pub fn blend_mode_to_equation(mode : BlendMode) -> BlendEquation {
  match mode {
    BlendMode::Copy =>
      {
        src_factor_rgb: BlendFactor::One,
        dst_factor_rgb: BlendFactor::Zero,
        op_rgb: BlendOperation::Add,
        src_factor_alpha: BlendFactor::One,
        dst_factor_alpha: BlendFactor::Zero,
        op_alpha: BlendOperation::Add,
      }
    BlendMode::Alpha =>
      {
        src_factor_rgb: BlendFactor::SrcAlpha,
        dst_factor_rgb: BlendFactor::OneMinusSrcAlpha,
        op_rgb: BlendOperation::Add,
        src_factor_alpha: BlendFactor::One,
        dst_factor_alpha: BlendFactor::OneMinusSrcAlpha,
        op_alpha: BlendOperation::Add,
      }
    BlendMode::Add =>
      {
        src_factor_rgb: BlendFactor::SrcAlpha,
        dst_factor_rgb: BlendFactor::One,
        op_rgb: BlendOperation::Add,
        src_factor_alpha: BlendFactor::One,
        dst_factor_alpha: BlendFactor::One,
        op_alpha: BlendOperation::Add,
      }
    BlendMode::Multiply =>
      {
        src_factor_rgb: BlendFactor::DstColor,
        dst_factor_rgb: BlendFactor::Zero,
        op_rgb: BlendOperation::Add,
        src_factor_alpha: BlendFactor::DstAlpha,
        dst_factor_alpha: BlendFactor::Zero,
        op_alpha: BlendOperation::Add,
      }
    BlendMode::Custom(eq) => eq
  }
}

///|
pub fn blend_factor_to_int(factor : BlendFactor) -> Int {
  match factor {
    BlendFactor::Zero => 0
    BlendFactor::One => 1
    BlendFactor::SrcAlpha => 2
    BlendFactor::OneMinusSrcAlpha => 3
    BlendFactor::DstAlpha => 4
    BlendFactor::OneMinusDstAlpha => 5
    BlendFactor::SrcColor => 6
    BlendFactor::OneMinusSrcColor => 7
    BlendFactor::DstColor => 8
    BlendFactor::OneMinusDstColor => 9
  }
}

///|
pub fn blend_factor_from_int(value : Int) -> BlendFactor {
  match value {
    0 => BlendFactor::Zero
    1 => BlendFactor::One
    2 => BlendFactor::SrcAlpha
    3 => BlendFactor::OneMinusSrcAlpha
    4 => BlendFactor::DstAlpha
    5 => BlendFactor::OneMinusDstAlpha
    6 => BlendFactor::SrcColor
    7 => BlendFactor::OneMinusSrcColor
    8 => BlendFactor::DstColor
    9 => BlendFactor::OneMinusDstColor
    _ => BlendFactor::One
  }
}

///|
pub fn blend_operation_to_int(op : BlendOperation) -> Int {
  match op {
    BlendOperation::Add => 0
    BlendOperation::Subtract => 1
    BlendOperation::ReverseSubtract => 2
    BlendOperation::Min => 3
    BlendOperation::Max => 4
  }
}

///|
pub fn blend_operation_from_int(value : Int) -> BlendOperation {
  match value {
    0 => BlendOperation::Add
    1 => BlendOperation::Subtract
    2 => BlendOperation::ReverseSubtract
    3 => BlendOperation::Min
    4 => BlendOperation::Max
    _ => BlendOperation::Add
  }
}
