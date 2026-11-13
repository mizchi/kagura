///|
test "ask tell protocol rejects incomplete fitness without advancing" {
  let search = Search::new([0.5, 0.5], 0.3, 42)
  assert_true(
    try {
      search.tell([])
      false
    } catch {
      _ => true
    },
  )
  let candidates = search.ask()
  assert_true(candidates.length() >= 4)
  assert_true(
    try {
      search.ask() |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      search.tell([1.0])
      false
    } catch {
      _ => true
    },
  )
  assert_eq(search.generation(), 0)
  search.tell(candidates.map(p => p[0] * p[0] + p[1] * p[1]))
  assert_eq(search.generation(), 1)
  assert_true(search.ask().length() >= 4)
}

///|
test "CMA ES is reproducible and improves a coupled quadratic" {
  let a = Search::new([0.6, 0.4], 0.3, 731)
  let b = Search::new([0.6, 0.4], 0.3, 731)
  let mut best = 1.0
  for _ in 0..<35 {
    let candidates = a.ask()
    assert_eq(candidates, b.ask())
    let loss = candidates.map(p => {
      (p[0] - 0.2) * (p[0] - 0.2) + (p[0] + p[1] - 0.5) * (p[0] + p[1] - 0.5)
    })
    for value in loss {
      best = best.min(value)
    }
    a.tell(loss)
    b.tell(loss)
  }
  assert_true(best < 0.0001)
}
