// A Cookie-Clicker economy with a feedback loop:
//
//   CLICK (interactive) --5--> COOKIES         <- click for cookies
//   HIRE  (interactive) --1--> GRANDMA         <- click to hire a grandma
//   CURSORS(automatic)  --1--> COOKIES         <- passive cookies, and...
//        GRANDMA ===modifier(+1 each)===> (the CURSORS->COOKIES rate)
//   SUN   (automatic)   --2--> ENERGY --2--> FORGE(gate) --1--> COOKIES
//                                                         \--1--> GEMS
//
// Each hired GRANDMA permanently speeds up passive cookie production: the
// CURSORS->COOKIES rate is 1 + (grandma count). Click gold nodes; SPACE runs
// time so the automatic sources and the feedback loop tick.

///|
fn build_sample() -> @mac.Diagram {
  let dg = @mac.Diagram::new()
  let click = dg.source(
    "CLICK",
    flow=@mac.Flow::Push,
    activation=@mac.Activation::Interactive,
    x=90.0,
    y=60.0,
  )
  let hire = dg.source(
    "HIRE",
    flow=@mac.Flow::Push,
    activation=@mac.Activation::Interactive,
    x=90.0,
    y=185.0,
  )
  let sun = dg.source("SUN", x=90.0, y=320.0)
  let cursors = dg.source("CURSORS", x=250.0, y=60.0)
  let cookies = dg.pool("COOKIES", initial=0, x=440.0, y=110.0)
  let grandma = dg.pool("GRANDMA", initial=0, x=250.0, y=200.0)
  let energy = dg.pool("ENERGY", initial=0, x=250.0, y=330.0)
  let forge = dg.gate("FORGE", x=410.0, y=330.0)
  let gems = dg.pool("GEMS", initial=0, x=560.0, y=330.0)
  let _ = dg.connect(click, cookies, rate=@mac.Rate::Fixed(5))
  let _ = dg.connect(hire, grandma, rate=@mac.Rate::Fixed(1))
  let cursors_edge = dg.connect(cursors, cookies, rate=@mac.Rate::Fixed(1))
  let _ = dg.connect(sun, energy, rate=@mac.Rate::Fixed(2))
  let _ = dg.connect(energy, forge, rate=@mac.Rate::Fixed(2))
  let _ = dg.connect(forge, cookies, weight=1.0)
  let _ = dg.connect(forge, gems, weight=1.0)
  // Feedback: each grandma adds +1 to the passive cookie rate.
  let _ = dg.state_to_edge(
    grandma,
    cursors_edge,
    @mac.StateKind::Modifier,
    factor=1.0,
  )
  dg
}
