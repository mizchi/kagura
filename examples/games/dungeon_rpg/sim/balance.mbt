///|
#derive(Eq, Debug)
pub(all) struct BalanceParams {
  enemy_hp_scale : Double
  enemy_damage_scale : Double
  encounter_steps : Int32
}

///|
pub fn BalanceParams::default() -> BalanceParams {
  { enemy_hp_scale: 1.0, enemy_damage_scale: 1.0, encounter_steps: 8, }
}

///|
pub fn BalanceParams::to_json(self : BalanceParams) -> Json {
  {
    "enemyHpScale": self.enemy_hp_scale,
    "enemyDamageScale": self.enemy_damage_scale,
    "encounterSteps": self.encounter_steps,
  }
}

///|
/// Apply an immutable configuration before departure, after full validation.
pub fn Game::configure_balance(self : Game, source : String) -> Unit raise {
  if self.mode != Town {
    fail("balance_locked")
  }
  let data = @json.parse(source)
  guard data is Object(fields) else { fail("invalid_balance") }
  let mut hp = self.balance.enemy_hp_scale
  let mut damage = self.balance.enemy_damage_scale
  let mut steps = self.balance.encounter_steps.to_double()
  for key, value in fields {
    guard value is Number(n, ..) else { fail("invalid_balance") }
    match key {
      "enemyHpScale" => hp = n
      "enemyDamageScale" => damage = n
      "encounterSteps" => steps = n
      _ => fail("unknown_balance_parameter")
    }
  }
  if !(hp >= 0.5 &&
    hp <= 3.0 &&
    damage >= 0.5 &&
    damage <= 3.0 &&
    steps >= 4.0 &&
    steps <= 16.0) ||
    steps != steps.to_int().to_double() {
    fail("invalid_balance")
  }
  self.balance = {
    enemy_hp_scale: hp,
    enemy_damage_scale: damage,
    encounter_steps: steps.to_int(),
  }
}

///|
pub fn Game::encounter_steps(self : Game) -> Int32 {
  self.balance.encounter_steps - self.floor
}

///|
pub fn Game::sweep_damage(self : Game) -> Int32 {
  (self.master.tables.rules[0].sweep_damage.to_double() *
  self.balance.enemy_damage_scale +
  0.5)
  .to_int()
  .max(1)
}

///|
pub extend BalanceParams with Eq::{equal, not_equal}

///|
pub extend BalanceParams with @moonbitlang/core/debug.Debug::{to_repr}
