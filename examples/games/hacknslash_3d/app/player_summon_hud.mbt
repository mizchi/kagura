///|
#derive(ToJson)
struct HunterSummonedZombieView {
  hp : Int32
  max_hp : Int32
  x : Double
  y : Double
}

///|
pub extend HunterSummonedZombieView with ToJson::{to_json}

///|
#derive(ToJson)
struct HunterSkullView {
  remaining : Int32
  x : Double
  y : Double
  attacking : Bool
}

///|
pub extend HunterSkullView with ToJson::{to_json}

///|
#derive(ToJson)
struct HunterSummonsView {
  zombies : Array[HunterSummonedZombieView]
  skulls : Array[HunterSkullView]
  zombie_limit : Int32
  skull_limit : Int32
  lifetime : Int32
}

///|
pub extend HunterSummonsView with ToJson::{to_json}

///|
fn GameState::hunter_summons_view(self : GameState) -> HunterSummonsView {
  {
    zombie_limit: @game.summoned_zombie_limit,
    skull_limit: @game.flaming_skull_limit,
    lifetime: @game.flaming_skull_lifetime,
    zombies: self.world.summons.zombies
    .filter(z => z.body.alive)
    .map(z => {
      hp: z.body.hp,
      max_hp: z.body.max_hp,
      x: z.body.x,
      y: z.body.y,
    }),
    skulls: self.world.summons.skulls.map(s => {
      remaining: @game.flaming_skull_lifetime - s.age,
      x: s.x,
      y: s.y,
      attacking: s.target is Some(_),
    }),
  }
}
