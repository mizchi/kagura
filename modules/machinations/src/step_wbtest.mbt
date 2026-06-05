///|
test "source pushes into a pool" {
  let dg = Diagram::new()
  let s = dg.source("mine") // automatic, push
  let p = dg.pool("gold")
  let _ = dg.connect(s, p, rate=Fixed(2))
  let st = SimState::init(dg)
  run(dg, st, 3)
  assert_eq(st.values[p], 6)
  assert_eq(st.step, 3)
}

///|
test "drain empties a pool, clamped at zero" {
  let dg = Diagram::new()
  let p = dg.pool("gold", initial=10)
  let d = dg.drain("upkeep") // automatic, pull
  let _ = dg.connect(p, d, rate=Fixed(3))
  let st = SimState::init(dg)
  step(dg, st) // 10 -> 7
  assert_eq(st.values[p], 7)
  assert_eq(st.last_flows[0], 3)
  run(dg, st, 2) // 7 -> 4 -> 1
  assert_eq(st.values[p], 1)
  step(dg, st) // 1 -> 0 (only 1 available)
  assert_eq(st.values[p], 0)
  assert_eq(st.last_flows[0], 1)
}

///|
test "capacity caps a pool" {
  let dg = Diagram::new()
  let s = dg.source("mine")
  let p = dg.pool("vault", capacity=Some(5))
  let _ = dg.connect(s, p, rate=Fixed(2))
  let st = SimState::init(dg)
  run(dg, st, 4) // 2, 4, 5(room 1), 5
  assert_eq(st.values[p], 5)
}

///|
test "source -> pool -> drain holds steady (in-order resolution)" {
  let dg = Diagram::new()
  let s = dg.source("mine")
  let p = dg.pool("gold")
  let d = dg.drain("upkeep")
  let _ = dg.connect(s, p, rate=Fixed(2)) // edge 0 resolved first
  let _ = dg.connect(p, d, rate=Fixed(2)) // edge 1
  let st = SimState::init(dg)
  run(dg, st, 5)
  // Each step: +2 into the pool, then 2 pulled out -> net 0.
  assert_eq(st.values[p], 0)
  assert_eq(st.last_flows[0], 2)
  assert_eq(st.last_flows[1], 2)
}

///|
test "PullAll is atomic when the source is short" {
  let dg = Diagram::new()
  let p = dg.pool("gold", initial=1)
  let d = dg.drain("upkeep", flow=PullAll)
  let _ = dg.connect(p, d, rate=Fixed(3))
  let st = SimState::init(dg)
  step(dg, st)
  // Cannot move the full 3, so nothing moves.
  assert_eq(st.values[p], 1)
  assert_eq(st.last_flows[0], 0)
}

///|
test "dice rate is reproducible from a seed" {
  let build = fn() {
    let dg = Diagram::new()
    let s = dg.source("mine")
    let p = dg.pool("gold")
    let _ = dg.connect(s, p, rate=Dice(2, 6))
    dg
  }
  let dg1 = build()
  let st1 = SimState::init(dg1, seed=42)
  run(dg1, st1, 10)
  let dg2 = build()
  let st2 = SimState::init(dg2, seed=42)
  run(dg2, st2, 10)
  assert_eq(st1.values[1], st2.values[1])
  // 2d6 averages 7; 10 steps should land in a sane range.
  assert_true(st1.values[1] >= 20 && st1.values[1] <= 120)
}

///|
test "reset restores initial values" {
  let dg = Diagram::new()
  let p = dg.pool("gold", initial=5)
  let d = dg.drain("upkeep")
  let _ = dg.connect(p, d, rate=Fixed(1))
  let st = SimState::init(dg)
  run(dg, st, 3)
  assert_eq(st.values[p], 2)
  st.reset(dg)
  assert_eq(st.values[p], 5)
  assert_eq(st.step, 0)
}
