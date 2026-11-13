///|
test "a round records every hit with stable target identities and monotonic ids" {
  let g = new_game()
  g.command("enter", -1)
  g.begin_battle(true)
  g.command("all-attack", -1)
  assert_true(g.effects.length() >= 6)
  assert_true(
    g.effects.any(e => {
      match e.target {
        Enemy(_) => true
        _ => false
      }
    }),
  )
  assert_true(
    g.effects.any(e => {
      match e.target {
        Party(_) => true
        _ => false
      }
    }),
  )
  for i in 0..<g.effects.length() {
    assert_true(g.effects[i].amount > 0)
    if i > 0 {
      assert_true(g.effects[i].id > g.effects[i - 1].id)
    }
  }
  let before = g.snapshot()
  assert_true(
    try {
      g.command("attack", 0)
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.snapshot(), before)
}

///|
test "visual cues report actual recovery and distinguish flame and defended hits" {
  let g = new_game()
  g.command("enter", -1)
  g.party[0].hp = 22
  g.command("field-heal", 0)
  assert_eq(g.effects.length(), 1)
  assert_eq(g.effects[0].amount, 2)
  assert_true(g.effects[0].kind == Recovery)
  g.begin_battle(true)
  for _ in 0..<4 {
    g.command("guard", -1)
  }
  g.command("flame", -1)
  g.command("guard", -1)
  g.command("resolve", -1)
  assert_true(g.effects.any(e => e.kind == FlameHit))
  assert_true(g.effects.any(e => e.kind == GuardHit))
}

///|
test "presentation history stays bounded and a new expedition discards old cues" {
  let g = new_game()
  for _ in 0..<100 {
    g.cue(Impact, Party(0), 1)
  }
  assert_eq(g.effects.length(), 48)
  let id = g.effects[g.effects.length() - 1].id
  g.command("enter", -1)
  assert_eq(g.effects.length(), 0)
  g.cue(Impact, Enemy(0), 1)
  assert_true(g.effects[0].id > id)
}
