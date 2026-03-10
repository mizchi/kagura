///|
struct SSAOConfig {
  enabled : Bool
  radius : Double
  bias : Double
  intensity : Double
}

///|
fn SSAOConfig::enabled_default() -> SSAOConfig {
  { enabled: true, radius: 0.5, bias: 0.025, intensity: 1.0 }
}

///|
fn SSAOConfig::disabled_default() -> SSAOConfig {
  { ..SSAOConfig::enabled_default(), enabled: false }
}
