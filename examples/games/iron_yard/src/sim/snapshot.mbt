///|
pub fn vector_json(v : @math3d.Vec3) -> Json {
  [v.x, v.y, v.z]
}

///|
pub fn snapshot(g : Game) -> String {
  let units : Array[Json] = g.units.map(fn(e) {
    {
      "id": e.id,
      "position": vector_json(e.position),
      "yaw": e.yaw,
      "hp": e.hp,
      "lock": e.lock,
      "mode": e.mode,
      "warning": e.warning,
    }
  })
  let json : Json = {
    "version": 1,
    "phase": g.phase,
    "ai": g.ai,
    "elapsed": g.elapsed,
    "wave": g.wave + 1,
    "hp": g.hp,
    "damageFlash": g.damage_flash,
    "pilot": {
      "position": vector_json(g.pilot.position),
      "velocity": vector_json(g.pilot.velocity),
      "yaw": g.pilot.yaw,
      "pitch": g.pilot.pitch,
      "grounded": g.pilot.grounded,
      "boost": g.pilot.boost,
      "gait": g.pilot.gait,
    },
    "units": units,
    "shots": g.shots,
    "missiles": g.missiles,
    "hits": g.hits,
    "kills": g.kills,
    "enemyShots": g.enemy_shots,
    "enemyHits": g.enemy_hits,
    "projectiles": g.projectiles.length(),
    "missileCooldown": g.missile_cooldown,
  }
  json.stringify()
}
