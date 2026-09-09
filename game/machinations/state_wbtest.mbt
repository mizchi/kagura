///|
test "modifier adds a source value to an edge rate" {
  let dg = Diagram::new()
  let grandma = dg.pool("GRANDMA", initial=3)
  let time = dg.source("TIME", flow=Push, activation=Automatic)
  let cookies = dg.pool("COOKIES")
  let e = dg.connect(time, cookies, rate=Fixed(1)) // base rate 1
  let _ = dg.state_to_edge(grandma, e, Modifier, factor=1.0) // +3
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[cookies], 4) // 1 + 3
}

///|
test "modifier scales by factor" {
  let dg = Diagram::new()
  let boost = dg.pool("BOOST", initial=4)
  let time = dg.source("TIME", flow=Push, activation=Automatic)
  let out = dg.pool("OUT")
  let e = dg.connect(time, out, rate=Fixed(2))
  let _ = dg.state_to_edge(boost, e, Modifier, factor=0.5) // +2 (4*0.5)
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[out], 4) // 2 + 2
}

///|
test "activator gates an edge until its threshold" {
  let dg = Diagram::new()
  let key = dg.pool("KEY", initial=0)
  let src = dg.source("SRC", flow=Push, activation=Automatic)
  let out = dg.pool("OUT")
  let e = dg.connect(src, out, rate=Fixed(2))
  let _ = dg.state_to_edge(key, e, Activator, factor=1.0) // enabled iff KEY >= 1
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[out], 0) // KEY 0 -> blocked
  st.values[key] = 1
  step(dg, st)
  assert_eq(st.values[out], 2) // enabled
}

///|
test "activator disables a node" {
  let dg = Diagram::new()
  let key = dg.pool("KEY", initial=0)
  let src = dg.source("SRC", flow=Push, activation=Automatic)
  let out = dg.pool("OUT")
  let _ = dg.connect(src, out, rate=Fixed(2))
  let _ = dg.state_to_node(key, src, Activator, factor=1.0)
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[out], 0) // SRC disabled
  st.values[key] = 5
  step(dg, st)
  assert_eq(st.values[out], 2)
}
