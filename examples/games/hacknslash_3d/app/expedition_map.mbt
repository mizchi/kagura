///|
struct ExpeditionMapView {
  name : String
  road_path : String
  contours : String
  features : String
  report : @game.ExpeditionValidation
} derive(ToJson)

///|
struct ExpeditionAnchorView {
  id : Int
  name : String
  x : Double
  z : Double
  height : Double
  unlocked : Bool
  reward : String
} derive(ToJson)

///|
/// Geometry-derived UI is cached with the region mesh; HUD serialization never
/// reruns generation, pathfinding or slope validation.
fn build_expedition_map(world : @game.GameWorld) -> ExpeditionMapView? {
  guard world.atlas is Some(atlas) else { return None }
  if atlas.generator_version < 2 || world.authored_scene is Some(_) {
    return None
  }
  let plan = if atlas.generator_version >= 3 {
    @game.landscape_plan(world.seed, atlas.current)
  } else {
    @game.expedition_plan(world.seed, atlas.current)
  }
  let roads = StringBuilder::new()
  for r in plan.routes {
    roads.write_string("M\{r.ax} \{r.az}L\{r.bx} \{r.bz}")
  }
  let contours = StringBuilder::new()
  if world.dungeon.terrain_surface is Some(field) {
    for z in 0..<20 {
      for x in 0..<25 {
        let h = field.sample(
          x.to_double() * 4.0 + 2.0,
          z.to_double() * 4.0 + 2.0,
        )
        let color = if world.dungeon.landscape is Some(land) &&
          (
            land.kind(x * 4 + 2, z * 4 + 2) == @game.Sea ||
            land.kind(x * 4 + 2, z * 4 + 2) == @game.River
          ) {
          "#367e91"
        } else {
          ["#243e3b", "#36534a", "#57634d", "#7c7960", "#a49b7d"][(h / 2.0)
          .to_int()
          .clamp(min=0, max=4)]
        }
        contours.write_string(
          "<rect x='\{x * 4}' y='\{z * 4}' width='4.1' height='4.1' fill='\{color}'/>",
        )
      }
    }
  }
  let features = StringBuilder::new()
  if world.dungeon.landscape is Some(land) {
    for b in land.bridges {
      features.write_string(
        "<path d='M\{b.ax} \{b.az}L\{b.bx} \{b.bz}' stroke='#f2d1a0' stroke-width='1.8'/>",
      )
    }
    features.write_string(
      "<path d='M61.5 26.5V10.5L50 13' fill='none' stroke='#9da9bc' stroke-width='1.6' stroke-dasharray='1 1'/><text x='65' y='18' fill='#ece6d1' font-size='3'>抜け洞窟</text><circle cx='15.5' cy='55.5' r='1.5' fill='#f2d1a0'/><text x='8' y='60' fill='#ece6d1' font-size='3'>灯台</text>",
    )
  }
  Some({
    name: plan.name,
    features: features.to_string(),
    road_path: roads.to_string(),
    contours: contours.to_string(),
    report: @game.validate_expedition(world.dungeon, atlas.current),
  })
}

///|
fn GameState::expedition_anchors(
  self : GameState,
) -> Array[ExpeditionAnchorView] {
  if self.expedition_map is None {
    return []
  }
  self.world.chests.map(c => {
    id: c.id,
    name: @game.hunting_sites[c.site].name,
    x: c.x / tile_size,
    z: c.y / tile_size,
    height: @game.get_tile_height(self.world.dungeon, c.x, c.y),
    unlocked: c.opened,
    reward: if @game.hunting_sites[c.site].kind == @game.Ruins {
      "高台・遠距離の敵 / レア装備"
    } else {
      "集団戦 / 装備と回復"
    },
  })
}

///|
fn GameState::finish_expedition_travel(self : GameState) -> Unit {
  self.combat_visuals.clear()
  self.active_effects.clear()
  self.damage_popups.clear()
  self.particle_manager.emitters.clear()
  self.ground_targeting = false
  self.combat_feedback.look_x = 0.0
  self.combat_feedback.look_y = 0.0
  self.camera = self.camera.with_target(
    @math3d.Vec3::new(
      self.world.player.x / tile_size,
      @game.get_tile_height(
        self.world.dungeon,
        self.world.player.x,
        self.world.player.y,
      ) +
      0.3,
      self.world.player.y / tile_size,
    ),
  )
  self.invalidate_minimap_cache()
  self.save_game()
}
