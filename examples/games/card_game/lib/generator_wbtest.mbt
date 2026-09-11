///|
/// Tests for the generate-then-evaluate loop.

///|
test "every generated card is runnable (no grounding failures)" {
  // The paper's headline failure was generated artifacts that never ran.
  // Over the closed IR grammar, generation is total: runnable == generated.
  let summary = generate_and_grade(200)
  assert_eq(summary.runnable, summary.generated)
  assert_eq(summary.runnable, 200)
  // The three verdict buckets partition the batch.
  assert_eq(
    summary.underpowered + summary.balanced + summary.overpowered,
    summary.generated,
  )
  // A reasonable generator should land at least some cards in each band.
  assert_true(summary.balanced > 0)
}

///|
test "the balance filter only returns balanced cards" {
  let cards = generate_balanced(10)
  assert_true(cards.length() > 0)
  for card in cards {
    assert_true(eval_synth(card).verdict == Balanced)
  }
}

///|
test "evaluation flags an obviously overpowered card" {
  // 0-cost, 40 damage twice — way over budget.
  let op : SynthCard = {
    cost: 0,
    effects: [DealDamage(amount=Const(40), target=ChosenEnemy, hits=2)],
  }
  assert_true(eval_synth(op).verdict == Overpowered)
}

///|
test "evaluation flags an obviously underpowered card" {
  // 3-cost, deal 1 damage — far under budget.
  let weak : SynthCard = {
    cost: 3,
    effects: [DealDamage(amount=Const(1), target=ChosenEnemy, hits=1)],
  }
  assert_true(eval_synth(weak).verdict == Underpowered)
}

///|
test "a hand-tuned card grades as balanced" {
  // 1-cost, deal 6 — this is literally Strike, the 6-DPE baseline.
  let strike_like : SynthCard = {
    cost: 1,
    effects: [DealDamage(amount=Const(6), target=ChosenEnemy, hits=1)],
  }
  assert_true(eval_synth(strike_like).verdict == Balanced)
}

///|
test "describe_card renders generated effects" {
  let card : SynthCard = {
    cost: 1,
    effects: [
      DealDamage(amount=Const(8), target=ChosenEnemy, hits=2),
      GainBlock(5),
    ],
  }
  assert_eq(describe_card(card), "[1E] deal 8 x2 to target, gain 5 block")
}
