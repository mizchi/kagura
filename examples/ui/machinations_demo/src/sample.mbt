// A small sample economy:
//   INCOME (source) --3--> GOLD (pool) --1--> SAVINGS (pool, auto-pull)
//                                      \--1--> UPKEEP (drain, auto-pull)
// Each step GOLD gains 3 and loses 2, so GOLD and SAVINGS both climb by 1/step.

///|
fn build_sample() -> @mac.Diagram {
  let dg = @mac.Diagram::new()
  let income = dg.source("INCOME", x=90.0, y=200.0)
  let gold = dg.pool("GOLD", initial=0, x=280.0, y=200.0)
  // SAVINGS must actively pull from GOLD, so it is automatic + pull.
  let savings = dg.pool(
    "SAVINGS",
    initial=0,
    flow=@mac.Flow::Pull,
    activation=@mac.Activation::Automatic,
    x=480.0,
    y=110.0,
  )
  let upkeep = dg.drain("UPKEEP", x=480.0, y=290.0)
  let _ = dg.connect(income, gold, rate=@mac.Rate::Fixed(3))
  let _ = dg.connect(gold, savings, rate=@mac.Rate::Fixed(1))
  let _ = dg.connect(gold, upkeep, rate=@mac.Rate::Fixed(1))
  dg
}
