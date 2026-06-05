// A full Cookie-Clicker loop:
//
//   CLICK (interactive) --5--> COOKIES
//   COOKIES --10--> BUY (interactive converter) --1--> GRANDMA   (spend to buy)
//   CURSORS(automatic) --1--> COOKIES
//        GRANDMA ===modifier(+1 each)===> (the CURSORS->COOKIES rate)
//   SUN   (automatic) --2--> ENERGY --2--> FORGE(gate) --1--> COOKIES
//                                                       \--1--> GEMS
//
// Loop: CLICK to bank cookies, BUY (costs 10 cookies) to hire a GRANDMA, and
// each GRANDMA permanently speeds passive cookie production (1 + grandmas).
// Click gold nodes; press SPACE to let time run.

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
  let buy = dg.converter("BUY", activation=@mac.Activation::Interactive, x=90.0, y=185.0)
  let sun = dg.source("SUN", x=90.0, y=320.0)
  let cursors = dg.source("CURSORS", x=250.0, y=60.0)
  let cookies = dg.pool("COOKIES", initial=0, x=440.0, y=95.0)
  let grandma = dg.pool("GRANDMA", initial=0, x=250.0, y=200.0)
  let energy = dg.pool("ENERGY", initial=0, x=250.0, y=330.0)
  let forge = dg.gate("FORGE", x=410.0, y=330.0)
  let gems = dg.pool("GEMS", initial=0, x=560.0, y=330.0)
  let _ = dg.connect(click, cookies, rate=@mac.Rate::Fixed(5))
  let _ = dg.connect(cookies, buy, rate=@mac.Rate::Fixed(10)) // cost
  let _ = dg.connect(buy, grandma, rate=@mac.Rate::Fixed(1)) // yield
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
