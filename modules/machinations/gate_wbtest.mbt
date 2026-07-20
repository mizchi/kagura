///|
test "gate splits deterministically by weight" {
  let dg = Diagram::new()
  let src = dg.pool("SRC", initial=10)
  let g = dg.gate("SPLIT") // automatic, pull, deterministic
  let a = dg.pool("A")
  let b = dg.pool("B")
  let _ = dg.connect(src, g, rate=Fixed(4))
  let _ = dg.connect(g, a, weight=3.0)
  let _ = dg.connect(g, b, weight=1.0)
  let st = SimState::init(dg)
  step(dg, st)
  assert_eq(st.values[src], 6) // pulled 4
  assert_eq(st.values[a], 3)
  assert_eq(st.values[b], 1)
}

///|
test "gate deterministic remainder favors the larger fractional part" {
  let dg = Diagram::new()
  let src = dg.pool("SRC", initial=10)
  let g = dg.gate("SPLIT")
  let a = dg.pool("A")
  let b = dg.pool("B")
  let _ = dg.connect(src, g, rate=Fixed(5))
  let _ = dg.connect(g, a, weight=1.0)
  let _ = dg.connect(g, b, weight=1.0)
  let st = SimState::init(dg)
  step(dg, st)
  // 5 split 1:1 -> 3 and 2, the remainder going to the first edge.
  assert_eq(st.values[a] + st.values[b], 5)
  assert_eq(st.values[a], 3)
  assert_eq(st.values[b], 2)
}

///|
test "gate probabilistic conserves total and is reproducible" {
  let build = fn() {
    let dg = Diagram::new()
    let src = dg.pool("SRC", initial=100)
    let g = dg.gate("SPLIT", gate_mode=Probabilistic)
    let a = dg.pool("A")
    let b = dg.pool("B")
    let _ = dg.connect(src, g, rate=Fixed(10))
    let _ = dg.connect(g, a, weight=1.0)
    let _ = dg.connect(g, b, weight=1.0)
    dg
  }
  let dg1 = build()
  let st1 = SimState::init(dg1, seed=7)
  run(dg1, st1, 3)
  // 30 pulled over 3 steps; nothing is lost (no capacities).
  assert_eq(st1.values[2] + st1.values[3], 30)
  assert_eq(st1.values[0], 70)
  let dg2 = build()
  let st2 = SimState::init(dg2, seed=7)
  run(dg2, st2, 3)
  assert_eq(st1.values[2], st2.values[2])
  assert_eq(st1.values[3], st2.values[3])
}

///|
test "gate drops overflow beyond destination capacity" {
  let dg = Diagram::new()
  let src = dg.pool("SRC", initial=10)
  let g = dg.gate("SPLIT")
  let a = dg.pool("A", capacity=Some(1))
  let b = dg.pool("B")
  let _ = dg.connect(src, g, rate=Fixed(4))
  let _ = dg.connect(g, a, weight=1.0)
  let _ = dg.connect(g, b, weight=1.0)
  let st = SimState::init(dg)
  step(dg, st)
  // 4 split 2:2; A capped at 1 (1 dropped), B takes 2.
  assert_eq(st.values[a], 1)
  assert_eq(st.values[b], 2)
}
