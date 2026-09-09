///|
test "converter spends inputs to make outputs, and stops when short" {
  let dg = Diagram::new()
  let cookies = dg.pool("COOKIES", initial=25)
  let buy = dg.converter("BUY")
  let grandma = dg.pool("GRANDMA")
  let _ = dg.connect(cookies, buy, rate=Fixed(10)) // cost 10
  let _ = dg.connect(buy, grandma, rate=Fixed(1)) // yields 1
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[cookies], 15)
  assert_eq(st.values[grandma], 1)
  step(dg, st)
  assert_eq(st.values[cookies], 5)
  assert_eq(st.values[grandma], 2)
  step(dg, st) // only 5 left (< 10) -> does not fire
  assert_eq(st.values[cookies], 5)
  assert_eq(st.values[grandma], 2)
}

///|
test "converter is atomic across multiple inputs" {
  let dg = Diagram::new()
  let wood = dg.pool("WOOD", initial=3)
  let stone = dg.pool("STONE", initial=1) // not enough
  let build = dg.converter("BUILD")
  let house = dg.pool("HOUSE")
  let _ = dg.connect(wood, build, rate=Fixed(2))
  let _ = dg.connect(stone, build, rate=Fixed(2)) // needs 2, has 1
  let _ = dg.connect(build, house, rate=Fixed(1))
  let st = SimState::init(dg)
  step(dg, st)
  // One input is short, so nothing is consumed or produced.
  assert_eq(st.values[wood], 3)
  assert_eq(st.values[stone], 1)
  assert_eq(st.values[house], 0)
}

///|
test "interactive converter only fires on activation" {
  let dg = Diagram::new()
  let cookies = dg.pool("COOKIES", initial=100)
  let buy = dg.converter("BUY", activation=Interactive)
  let grandma = dg.pool("GRANDMA")
  let _ = dg.connect(cookies, buy, rate=Fixed(10))
  let _ = dg.connect(buy, grandma, rate=Fixed(1))
  let st = SimState::init(dg)
  step(dg, st) // not activated
  assert_eq(st.values[grandma], 0)
  assert_eq(st.values[cookies], 100)
  st.activate(buy)
  step(dg, st)
  assert_eq(st.values[grandma], 1)
  assert_eq(st.values[cookies], 90)
}
