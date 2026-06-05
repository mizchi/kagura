// Sample economy with a gate:
//   INCOME --4--> GOLD --2--> SPLIT (gate) --1--> SAVINGS
//                    \--1--> UPKEEP        \--1--> LOOT
// Per step GOLD gains 4 and loses 3 (1 upkeep + 2 into the gate), so GOLD
// climbs by 1; the gate splits its 2 evenly, so SAVINGS and LOOT each gain 1.

///|
fn build_sample() -> @mac.Diagram {
  let dg = @mac.Diagram::new()
  let income = dg.source("INCOME", x=80.0, y=180.0)
  let gold = dg.pool("GOLD", initial=0, x=240.0, y=180.0)
  let upkeep = dg.drain("UPKEEP", x=240.0, y=330.0)
  let split = dg.gate("SPLIT", x=410.0, y=120.0)
  let savings = dg.pool("SAVINGS", initial=0, x=565.0, y=70.0)
  let loot = dg.pool("LOOT", initial=0, x=565.0, y=200.0)
  let _ = dg.connect(income, gold, rate=@mac.Rate::Fixed(4))
  let _ = dg.connect(gold, upkeep, rate=@mac.Rate::Fixed(1))
  let _ = dg.connect(gold, split, rate=@mac.Rate::Fixed(2))
  let _ = dg.connect(split, savings, weight=1.0)
  let _ = dg.connect(split, loot, weight=1.0)
  dg
}
