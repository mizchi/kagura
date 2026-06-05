// A Cookie-Clicker-style economy mixing interactive and time-based growth:
//
//   CLICK  (interactive) --5--> COOKIES        <- click a node to add 5
//   CURSORS(automatic)   --1--> COOKIES        <- passive time growth
//   SUN    (automatic)   --2--> ENERGY         <- passive time growth
//   ENERGY --2--> FORGE (gate) --1--> COOKIES  <- energy is forged into
//                              \--1--> GEMS        cookies and gems
//
// Click an interactive node (gold border) to fire it; press SPACE to let time
// run so the automatic sources tick.

///|
fn build_sample() -> @mac.Diagram {
  let dg = @mac.Diagram::new()
  let click = dg.source(
    "CLICK",
    flow=@mac.Flow::Push,
    activation=@mac.Activation::Interactive,
    x=95.0,
    y=70.0,
  )
  let cursors = dg.source("CURSORS", x=95.0, y=195.0)
  let sun = dg.source("SUN", x=95.0, y=320.0)
  let cookies = dg.pool("COOKIES", initial=0, x=305.0, y=130.0)
  let energy = dg.pool("ENERGY", initial=0, x=305.0, y=305.0)
  let forge = dg.gate("FORGE", x=445.0, y=305.0)
  let gems = dg.pool("GEMS", initial=0, x=585.0, y=320.0)
  let _ = dg.connect(click, cookies, rate=@mac.Rate::Fixed(5))
  let _ = dg.connect(cursors, cookies, rate=@mac.Rate::Fixed(1))
  let _ = dg.connect(sun, energy, rate=@mac.Rate::Fixed(2))
  let _ = dg.connect(energy, forge, rate=@mac.Rate::Fixed(2))
  let _ = dg.connect(forge, cookies, weight=1.0)
  let _ = dg.connect(forge, gems, weight=1.0)
  dg
}
