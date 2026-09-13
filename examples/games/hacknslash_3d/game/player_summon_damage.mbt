///|
fn hurt_summoned_zombie(zombie : SummonedZombie, damage : Int) -> Unit {
  let body = zombie.body
  if !body.alive || body.damage_timer > 0 {
    return
  }
  body.hp = (body.hp - damage.max(1)).max(0)
  body.damage_timer = 12
  if body.hp == 0 {
    body.alive = false
  }
}

///|
fn GameWorld::damage_summons_circle(
  self : GameWorld,
  x : Double,
  y : Double,
  radius : Double,
  damage : Int,
) -> Unit {
  for zombie in self.summons.zombies {
    let body = zombie.body
    let dx = body.x - x
    let dy = body.y - y
    if dx * dx + dy * dy <= radius * radius {
      hurt_summoned_zombie(zombie, damage)
    }
  }
}

///|
fn GameWorld::intercept_summon_projectile(
  self : GameWorld,
  projectile : Projectile,
  x0 : Double,
  y0 : Double,
) -> Unit {
  if !projectile.alive || projectile.is_player {
    return
  }
  // Select nearest actual contact; a zombie behind the hunter cannot intercept for them.
  let mut contact = segment_circle_contact(
    x0,
    y0,
    projectile.x,
    projectile.y,
    self.player.x,
    self.player.y,
    pickup_radius_sq.sqrt(),
  ).unwrap_or(2.0)
  let mut target : SummonedZombie? = None
  for zombie in self.summons.zombies {
    let body = zombie.body
    if !body.alive {
      continue
    }
    if segment_circle_contact(
        x0,
        y0,
        projectile.x,
        projectile.y,
        body.x,
        body.y,
        body.size / 2.0 + 2.0,
      )
      is Some(t) &&
      t < contact {
      contact = t
      target = Some(zombie)
    }
  }
  if target is Some(zombie) {
    hurt_summoned_zombie(zombie, projectile.damage)
    projectile.alive = false
    self.events.push(HitSparks(zombie.body.x, zombie.body.y))
  }
}
