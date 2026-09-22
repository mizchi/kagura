///|
struct HunterChestView {
  id : Int
  name : String
  x : Double
  z : Double
  opened : Bool
  kind : String
} derive(ToJson)
///|
pub extend HunterChestView with ToJson::{to_json}
///|
struct HunterExplorationView {
  nearby_chest : Int
  site_name : String
  chests : Array[HunterChestView]
  wolves : Int
  road_path : String
} derive(ToJson)
///|
pub extend HunterExplorationView with ToJson::{to_json}
///|
fn GameState::hunter_exploration_view(
  self : GameState,
) -> HunterExplorationView {
  let w = self.world
  let mut site_name = ""
  let mut wolves = 0
  for enemy in w.enemies {
    if enemy.alive && enemy.kind == @game.Wolf {
      wolves += 1
    }
  }
  if w.hunting_grounds && w.authored_scene is None {
    for site in @game.hunting_sites {
      if (w.player.x / tile_size - site.x.to_double()).abs() < 8.0 &&
        (w.player.y / tile_size - site.z.to_double()).abs() < 8.0 {
        site_name = site.name
      }
    }
  }
  {
    nearby_chest: if self.paused ||
      self.motion_preview ||
      w.hunter_action_locked() ||
      w.weapon_attack is Some(_) {
      -1
    } else {
      w.nearby_chest().map(c => c.id).or(-1)
    },
    site_name,
    road_path: self.expedition_map
    .map(m => m.road_path)
    .or(hunting_minimap_roads),
    wolves,
    chests: w.chests.map(c => {
      id: c.id,
      name: @game.hunting_sites[c.site].name,
      x: c.x / tile_size,
      z: c.y / tile_size,
      opened: c.opened,
      kind: if @game.hunting_sites[c.site].kind == @game.Ruins {
        "ruins"
      } else {
        "camp"
      },
    }),
  }
}

///|
fn make_treasure_body() -> HuntingAsset {
  let wood = @procedural3d.RigidGeometry::new()
  let iron = @procedural3d.RigidGeometry::new()
  wood.box(0.0, 0.07, 0.0, 0.98, 0.14, 0.80, 0)
  for x in [-0.45, 0.45] {
    wood.box(x, 0.30, 0.0, 0.08, 0.45, 0.80, 0)
  }
  for z in [-0.35, 0.35] {
    wood.box(0.0, 0.30, z, 0.90, 0.45, 0.10, 0)
  }
  for x in [-0.34, 0.34] {
    iron.box(x, 0.29, 0.0, 0.08, 0.53, 0.84, 0)
  }
  iron.box(0.0, 0.40, 0.414, 0.13, 0.19, 0.025, 0)
  {
    name: "ironbound-treasure",
    parts: [hunting_part(wood, 18), hunting_part(iron, 9)],
  }
}

///|
// Lid origin is its rear hinge; rotating it never moves the chest's collision footprint.
fn make_treasure_lid() -> HuntingAsset {
  let wood = @procedural3d.RigidGeometry::new()
  let bands = @procedural3d.RigidGeometry::new()
  wood.loft(
    0.0,
    0.38,
    [(0.0, 0.50, 0.40), (0.10, 0.50, 0.40), (0.28, 0.46, 0.31)],
    8,
    0,
  )
  for x in [-0.34, 0.34] {
    bands.box(x, 0.30, 0.38, 0.09, 0.04, 0.56, 0)
    bands.box(x, 0.12, 0.765, 0.09, 0.21, 0.04, 0)
  }
  {
    name: "hinged-treasure-lid",
    parts: [hunting_part(wood, 18), hunting_part(bands, 9)],
  }
}

///|
let treasure_body : HuntingAsset = make_treasure_body()

///|
let treasure_lid : HuntingAsset = make_treasure_lid()

///|
let treasure_beacon : @mesh3d.Mesh3D = {
  let g = @procedural3d.RigidGeometry::new()
  g.loft(
    0.0,
    0.0,
    [(0.0, 0.0, 0.0), (0.16, 0.095, 0.095), (0.32, 0.0, 0.0)],
    4,
    0,
  )
  g.build_mesh()
}

///|
fn GameState::push_treasure_commands(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let bodies : Array[@scene3d.InstanceData] = []
  let lids : Array[@scene3d.InstanceData] = []
  let beacons : Array[@scene3d.InstanceData] = []
  for chest in self.world.chests {
    if (chest.x - self.world.player.x).abs() > tile_size * 24.0 ||
      (chest.y - self.world.player.y).abs() > tile_size * 24.0 {
      continue
    }
    let x = chest.x / tile_size
    let z = chest.y / tile_size
    let ground = @game.get_tile_height(self.world.dungeon, chest.x, chest.y)
    bodies.push(
      @scene3d.InstanceData::new(
        transform=@transform3d.Transform3D::from_position(
          @math3d.Vec3::new(x, ground, z),
        ),
      ),
    )
    let phase = if chest.opened {
      ((self.world.frame_count - chest.opened_frame).to_double() / 18.0)
      .max(0.0)
      .min(1.0)
    } else {
      0.0
    }
    lids.push(
      @scene3d.InstanceData::new(
        transform=@transform3d.Transform3D::from_position_rotation(
          @math3d.Vec3::new(x, ground + 0.53, z - 0.38),
          @math3d.Quaternion::from_axis_angle(
            @math3d.Vec3::unit_x(),
            -phase * 1.35,
          ),
        ),
      ),
    )
    if !chest.opened {
      beacons.push(
        @scene3d.InstanceData::new(
          transform=@transform3d.Transform3D::from_position(
            @math3d.Vec3::new(
              x,
              ground +
              1.15 +
              @math.sin(self.world.frame_count.to_double() * 0.05) * 0.06,
              z,
            ),
          ),
          color=@math3d.Vec4::new(2.0, 1.45, 0.42, 1.0),
        ),
      )
    }
  }
  for (asset, instances) in [(treasure_body, bodies), (treasure_lid, lids)] {
    for part in asset.parts {
      let tinted = instances.map(instance => {
        @scene3d.InstanceData::new(
          transform=instance.transform,
          color=hunting_palette[part.material],
        )
      })
      push_entity_instances_if_any(
        part.mesh,
        tinted,
        vp,
        self.lighting,
        dst,
        self.shader3d_colored,
        self.shader3d_instanced,
        self.shader3d_instanced_monochrome,
        screen_w,
        screen_h,
        cmds,
      )
    }
  }
  push_entity_instances_if_any(
    treasure_beacon,
    beacons,
    vp,
    self.lighting,
    dst,
    self.shader3d_colored,
    self.shader3d_instanced,
    self.shader3d_instanced_monochrome,
    screen_w,
    screen_h,
    cmds,
  )
}

///|
let hunting_minimap_roads : String = {
  let path = StringBuilder::new()
  for x in 2..<99 {
    path.write_string(if x == 2 { "M" } else { "L" })
    path.write_string(x.to_string() + " " + @game.hunting_road_z(x).to_string())
  }
  for site in @game.hunting_sites {
    path.write_string(
      "M" +
      site.x.to_string() +
      " " +
      site.z.to_string() +
      "L" +
      site.x.to_string() +
      " " +
      @game.hunting_road_z(site.x).to_string(),
    )
  }
  path.write_string("M43 36V66")
  path.to_string()
}
