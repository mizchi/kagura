///|
test "trader exchanges resources atomically" {
  let dg = Diagram::new()
  let gold = dg.pool("GOLD", initial=7)
  let market = dg.trader("MARKET")
  let gems = dg.pool("GEMS")
  let _ = dg.connect(gold, market, rate=Fixed(3)) // give 3 gold
  let _ = dg.connect(market, gems, rate=Fixed(1)) // get 1 gem
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[gold], 4)
  assert_eq(st.values[gems], 1)
  step(dg, st)
  assert_eq(st.values[gold], 1)
  assert_eq(st.values[gems], 2)
  step(dg, st) // only 1 gold (< 3) -> no exchange
  assert_eq(st.values[gold], 1)
  assert_eq(st.values[gems], 2)
}

///|
test "register holds a value that feeds a modifier" {
  let dg = Diagram::new()
  let mult = dg.register("MULT", value=3)
  let time = dg.source("TIME", flow=Push, activation=Automatic)
  let out = dg.pool("OUT")
  let e = dg.connect(time, out, rate=Fixed(1))
  let _ = dg.state_to_edge(mult, e, Modifier, factor=1.0) // +3
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[out], 4) // 1 + 3
  assert_eq(st.values[mult], 3) // register keeps its value (no resource flow)
}

///|
test "delay releases its input after N steps" {
  let dg = Diagram::new()
  let src = dg.source("SRC", flow=Push, activation=Automatic)
  let d = dg.delay("DELAY", steps=2)
  let out = dg.pool("OUT")
  let _ = dg.connect(src, d, rate=Fixed(1))
  let _ = dg.connect(d, out, weight=1.0)
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[out], 0) // step 1: nothing out yet
  step(dg, st)
  assert_eq(st.values[out], 0) // step 2: still buffered
  step(dg, st)
  assert_eq(st.values[out], 1) // step 3: first unit released
  step(dg, st)
  assert_eq(st.values[out], 2)
}

///|
test "queue releases at a fixed rate" {
  let dg = Diagram::new()
  let src = dg.source("SRC", flow=Push, activation=Automatic)
  let q = dg.queue("QUEUE", rate=2)
  let out = dg.pool("OUT")
  let _ = dg.connect(src, q, rate=Fixed(5)) // 5 in per step
  let _ = dg.connect(q, out, weight=1.0)
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[out], 2) // release capped at 2
  step(dg, st)
  assert_eq(st.values[out], 4)
  step(dg, st)
  assert_eq(st.values[out], 6)
}
