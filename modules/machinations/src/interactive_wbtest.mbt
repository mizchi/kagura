///|
test "interactive source only fires when activated" {
  let dg = Diagram::new()
  let click = dg.source("CLICK", flow=Push, activation=Interactive)
  let cookies = dg.pool("COOKIES")
  let _ = dg.connect(click, cookies, rate=Fixed(5))
  let st = SimState::init(dg)
  step(dg, st) // not activated -> nothing
  assert_eq(st.values[cookies], 0)
  st.activate(click)
  step(dg, st) // activated -> +5
  assert_eq(st.values[cookies], 5)
  step(dg, st) // activation consumed -> no more
  assert_eq(st.values[cookies], 5)
}

///|
test "automatic time source and interactive clicks combine" {
  let dg = Diagram::new()
  let click = dg.source("CLICK", flow=Push, activation=Interactive)
  let time = dg.source("TIME", flow=Push, activation=Automatic)
  let cookies = dg.pool("COOKIES")
  let _ = dg.connect(click, cookies, rate=Fixed(5))
  let _ = dg.connect(time, cookies, rate=Fixed(1))
  let st = SimState::init(dg)
  step(dg, st) // +1 (time only)
  assert_eq(st.values[cookies], 1)
  st.activate(click)
  step(dg, st) // +1 time +5 click
  assert_eq(st.values[cookies], 7)
  st.reset(dg)
  assert_eq(st.values[cookies], 0)
}
