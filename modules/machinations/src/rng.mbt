// Deterministic RNG (xorshift64*) so simulations are reproducible from a seed.

///|
/// Advance the RNG and return the next 64-bit value. Mutates `state.rng`.
pub fn next_u64(state : SimState) -> UInt64 {
  let mut x = state.rng
  // Guard against a zero state, which xorshift cannot escape.
  if x == 0 {
    x = 0x9E3779B97F4A7C15
  }
  x = x ^ (x >> 12)
  x = x ^ (x << 25)
  x = x ^ (x >> 27)
  state.rng = x
  x * 0x2545F4914F6CDD1D
}

///|
/// Uniform integer in [0, n). Returns 0 for n <= 0.
pub fn next_int(state : SimState, n : Int) -> Int {
  if n <= 0 {
    return 0
  }
  let r = next_u64(state)
  (r % n.to_uint64()).to_int()
}

///|
/// Roll `count` dice with `sides` faces (1..sides) and return the sum.
pub fn roll_dice(state : SimState, count : Int, sides : Int) -> Int {
  if count <= 0 || sides <= 0 {
    return 0
  }
  let mut total = 0
  for _ in 0..<count {
    total = total + next_int(state, sides) + 1
  }
  total
}
