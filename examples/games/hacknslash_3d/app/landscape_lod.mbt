///|
struct SceneryRegion {
  region : Int
  mesh : @mesh3d.Mesh3D
  // Contiguous index spans, in the same order as the detailed region chunks.
  ranges : Array[(Int, Int)]
}

///|
struct SceneryCache {
  seed : Int
  regions : Array[SceneryRegion]
  backdrop : @mesh3d.Mesh3D
}

///|
/// Scenery packs a constant face color in UV.x. All low-detail materials share
/// one static vertex/index buffer and one inexpensive shader, without textures.
fn scenery_color(
  g : @procedural3d.RigidGeometry,
  start : Int,
  hex : Int,
) -> Unit {
  for i in (start / 8)..<(g.vertices.length() / 8) {
    g.vertices[i * 8 + 6] = hex.to_double()
    g.vertices[i * 8 + 7] = 0.0
  }
}

///|
fn build_scenery_region(land : @game.Landscape) -> SceneryRegion {
  let g = @procedural3d.RigidGeometry::new()
  let ranges : Array[(Int, Int)] = []
  let field = land.bed
  let grass = [0x1B2C21, 0x403126, 0x1B3030, 0x302C35][land.region]
  for cz in 0..<4 {
    for cx in 0..<5 {
      let start = g.indices.length()
      let x0 = cx * chunk_size
      let z0 = cz * chunk_size
      let x1 = (x0 + chunk_size).min(@game.map_cols)
      let z1 = (z0 + chunk_size).min(@game.map_rows)
      for z = z0; z < z1; z = z + 8 {
        for x = x0; x < x1; x = x + 8 {
          let ex = (x + 8).min(x1)
          let ez = (z + 8).min(z1)
          fn p(x : Double, z : Double) -> @math3d.Vec3 {
            @math3d.Vec3::new(x, field.sample(x, z), z)
          }
          let vstart = g.vertices.length()
          // Retain unit-spaced boundary vertices. Detailed and coarse chunks meet
          // at exactly the same heights; interior cells use a eight-tile resolution.
          let center = p((x + ex).to_double() * 0.5, (z + ez).to_double() * 0.5)
          if x != x0 && z != z0 && ex != x1 && ez != z1 {
            g.quad(
              p(x.to_double(), z.to_double()),
              p(x.to_double(), ez.to_double()),
              p(ex.to_double(), ez.to_double()),
              p(ex.to_double(), z.to_double()),
              0,
            )
          } else {
            for
              (ax, az, bx, bz, edge) in [
                (x, z, x, ez, x == x0),
                (x, ez, ex, ez, ez == z1),
                (ex, ez, ex, z, ex == x1),
                (ex, z, x, z, z == z0),
              ] {
              let n = if edge {
                (bx - ax).abs().max((bz - az).abs())
              } else {
                1
              }
              for i in 0..<n {
                let t = i.to_double() / n.to_double()
                let u = (i + 1).to_double() / n.to_double()
                g.triangle(
                  center,
                  p(
                    ax.to_double() + (bx - ax).to_double() * t,
                    az.to_double() + (bz - az).to_double() * t,
                  ),
                  p(
                    ax.to_double() + (bx - ax).to_double() * u,
                    az.to_double() + (bz - az).to_double() * u,
                  ),
                  0,
                )
              }
            }
          }
          scenery_color(
            g,
            vstart,
            if center.y > 6.0 {
              0x58615C
            } else if center.y < 0.0 {
              0x867B58
            } else {
              grass
            },
          )
          if field
            .at(x, z)
            .min(field.at(ex, z))
            .min(field.at(ex, ez))
            .min(field.at(x, ez)) <
            -1.35 {
            let v = g.vertices.length()
            g.quad(
              @math3d.Vec3::new(x.to_double(), -1.35, z.to_double()),
              @math3d.Vec3::new(x.to_double(), -1.35, ez.to_double()),
              @math3d.Vec3::new(ex.to_double(), -1.35, ez.to_double()),
              @math3d.Vec3::new(ex.to_double(), -1.35, z.to_double()),
              0,
            )
            scenery_color(g, v, 0x235D68)
          }
        }
      }
      if cx == 2 && cz == 0 {
        let v = g.vertices.length()
        let y = field.sample(61.5, 18.5)
        g.loft(
          61.5,
          18.5,
          [(y, 6.0, 8.0), (y + 5.8, 3.6, 6.5), (y + 6.1, 0.8, 5.0)],
          6,
          0,
        )
        scenery_color(g, v, 0x58615C)
      }
      if cx == 0 && cz == 2 {
        let v = g.vertices.length()
        let y = field.sample(15.5, 55.5)
        g.loft(15.5, 55.5, [(y, 1.6, 1.6), (y + 6.8, 0.85, 0.85)], 5, 0)
        scenery_color(g, v, 0x55574B)
      }
      ranges.push((start, g.indices.length() - start))
    }
  }
  {
    region: land.region,
    mesh: @mesh3d.Mesh3D::new(g.vertices, g.indices),
    ranges,
  }
}

///|
fn scenery_horizon_height(x : Double, z : Double) -> Double {
  let mountain = @game.landscape_mountain_height(x, z).min(38.0)
  let ridges = 7.0 *
    @math.sin(x * 0.054 + @math.sin(z * 0.023)) *
    @math.cos(z * 0.044)
  let distance = (-x).max(x - 198.0).max(-z).max(z - 158.0).max(0.0)
  let mut h = mountain + ridges * (distance / 40.0).min(1.0)
  let water = @game.landscape_coast_distance(x, z).min(
    @game.landscape_river_distance(x, z),
  )
  if water < 2.0 {
    let t = ((water + 0.7) / 2.7).clamp(min=0.0, max=1.0)
    h = -4.0 + (h + 4.0) * t * t * (3.0 - 2.0 * t)
  }
  // Offshore islands and a distant broken volcanic rim interrupt the horizon.
  for
    (ix, iz, rise, radius) in [
      (-65.0, 15.0, 32.0, 28.0),
      (-105.0, 97.0, 22.0, 23.0),
      (62.0, 228.0, 26.0, 35.0),
    ] {
    let d = ((x - ix) * (x - ix) + (z - iz) * (z - iz)).sqrt() / radius
    h = h.max(-4.0 + rise * (1.0 - d).max(0.0))
  }
  h
}

///|
fn build_scenery_backdrop() -> @mesh3d.Mesh3D {
  let g = @procedural3d.RigidGeometry::new()
  for
    (x0, z0, x1, z1) in [
      (-220, -220, 0, 380),
      (198, -220, 430, 380),
      (0, -220, 198, 0),
      (0, 158, 198, 380),
    ] {
    for z = z0; z < z1; z = z + 16 {
      for x = x0; x < x1; x = x + 16 {
        let ex = (x + 16).min(x1)
        let ez = (z + 16).min(z1)
        fn p(x : Int, z : Int) -> @math3d.Vec3 {
          @math3d.Vec3::new(
            x.to_double(),
            scenery_horizon_height(x.to_double(), z.to_double()),
            z.to_double(),
          )
        }
        let v = g.vertices.length()
        if ex == 0 || x == 198 || ez == 0 || z == 158 {
          let center = p((x + ex) / 2, (z + ez) / 2)
          for
            (ax, az, bx, bz, edge) in [
              (x, z, x, ez, x == 198),
              (x, ez, ex, ez, ez == 0),
              (ex, ez, ex, z, ex == 0),
              (ex, z, x, z, z == 158),
            ] {
            let n = if edge { (bx - ax).abs().max((bz - az).abs()) } else { 1 }
            for i in 0..<n {
              g.triangle(
                center,
                p(ax + (bx - ax) * i / n, az + (bz - az) * i / n),
                p(ax + (bx - ax) * (i + 1) / n, az + (bz - az) * (i + 1) / n),
                0,
              )
            }
          }
        } else {
          g.quad(p(x, z), p(x, ez), p(ex, ez), p(ex, z), 0)
        }
        scenery_color(
          g,
          v,
          if scenery_horizon_height(x.to_double(), z.to_double()) > 17.0 {
            0x75848B
          } else {
            0x3D5559
          },
        )
      }
    }
    let v = g.vertices.length()
    g.quad(
      @math3d.Vec3::new(x0.to_double(), -1.35, z0.to_double()),
      @math3d.Vec3::new(x0.to_double(), -1.35, z1.to_double()),
      @math3d.Vec3::new(x1.to_double(), -1.35, z1.to_double()),
      @math3d.Vec3::new(x1.to_double(), -1.35, z0.to_double()),
      0,
    )
    scenery_color(g, v, 0x235D68)
  }
  @mesh3d.Mesh3D::new(g.vertices, g.indices)
}

///|
fn build_scenery_cache(world : @game.GameWorld) -> SceneryCache? {
  guard world.dungeon.landscape is Some(active) else { return None }
  guard world.atlas is Some(atlas) else { return None }
  let regions : Array[SceneryRegion] = []
  for region in @game.world_regions {
    let land = if region.id == atlas.current {
      active
    } else {
      @game.generate_landscape(
        @game.region_seed(atlas.world_seed, region.id),
        region.id,
      )
    }
    regions.push(build_scenery_region(land))
  }
  Some({ seed: atlas.world_seed, regions, backdrop: build_scenery_backdrop(), })
}

///|
fn scenery_index_runs(
  ranges : Array[(Int, Int)],
  visible : Array[Bool],
) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  let mut offset = 0
  let mut count = 0
  for i, r in ranges {
    if visible[i] {
      if count == 0 {
        offset = r.0
      }
      count += r.1
    } else if count > 0 {
      result.push((offset, count))
      count = 0
    }
  }
  if count > 0 {
    result.push((offset, count))
  }
  result
}

///|
fn GameState::cave_roof_hidden(self : GameState) -> Bool {
  self.world.dungeon.landscape is Some(_) &&
  self.camera_settings.mode == 0 &&
  (self.world.player.x / tile_size - 61.5).abs() < 8.0 &&
  self.world.player.y / tile_size > 12.0 &&
  self.world.player.y / tile_size < 24.7
}

///|
fn GameState::push_scenery_commands(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  guard self.scenery is Some(scenery) else { return }
  guard self.world.atlas is Some(atlas) else { return }
  if self.motion_preview ||
    self.world.authored_scene is Some(_) ||
    self.world.dungeon.landscape is None {
    return
  }
  let current = @game.world_regions[atlas.current]
  let px = self.world.player.x / tile_size
  let pz = self.world.player.y / tile_size
  fn draw(
    mesh : @mesh3d.Mesh3D,
    ox : Double,
    oz : Double,
    runs : Array[(Int, Int)],
  ) -> Unit {
    @web_hooks.register_static_geometry(mesh.vertex_data, mesh.indices)
    let model = @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(ox, 0.0, oz),
    ).to_mat4()
    for (offset, count) in runs {
      cmds.push(
        @draw3d.new_lit_colored_mesh_draw_command(
          dst,
          self.scenery_shader,
          @gfx.new_dst_region(0, 0, screen_w, screen_h, count),
          offset,
          0,
          0,
          @gfx.BlendMode::from_int(0),
          mesh,
          model,
          vp,
          self.lighting,
          @math3d.Vec4::new(px, 0.0, pz, 1.0),
          [],
        ),
      )
    }
  }
  draw(
    scenery.backdrop,
    -current.x.to_double() * 98.0,
    -current.z.to_double() * 78.0,
    [(0, scenery.backdrop.indices.length())],
  )
  for r in scenery.regions {
    let other = @game.world_regions[r.region]
    let ox = (other.x - current.x).to_double() * 98.0
    let oz = (other.z - current.z).to_double() * 78.0
    let ready = self.region_mesh_ready(r.region)
    let adjacent = (other.x - current.x).abs() + (other.z - current.z).abs() ==
      1
    let visible = Array::makei(r.ranges.length(), i => {
      let cx = i % 5
      let cz = i / 5
      if r.region == atlas.current {
        (cx - px.to_int() / chunk_size).abs() > 1 ||
        (cz - pz.to_int() / chunk_size).abs() > 1
      } else {
        !(ready && adjacent && neighbor_detail_visible(cx, cz, px - ox, pz - oz))
      }
    })
    draw(r.mesh, ox, oz, scenery_index_runs(r.ranges, visible))
  }
}

///|
fn scenery_shader_wgsl() -> String {
  let source =
    #|struct Uniforms {
    #| mvp: mat4x4<f32>, model: mat4x4<f32>, normal0: vec4<f32>, normal1: vec4<f32>, normal2: vec4<f32>,
    #| light_dir: vec4<f32>, light_color: vec4<f32>, ambient_color: vec4<f32>, focus: vec4<f32>,
    #|};
    #|@group(0) @binding(0) var<uniform> u: Uniforms;
    #|struct In { @location(0) p: vec3<f32>, @location(1) n: vec3<f32>, @location(2) uv: vec2<f32> };
    #|struct Out { @builtin(position) p: vec4<f32>, @location(0) n: vec3<f32>, @location(1) world: vec3<f32>, @location(2) color: vec3<f32> };
    #|@vertex fn vs_main(v: In) -> Out {
    #| var o: Out;
    #| o.p=u.mvp*vec4(v.p,1.0); o.n=v.n; o.world=(u.model*vec4(v.p,1.0)).xyz;
    #| let c=u32(v.uv.x); o.color=vec3(f32((c>>16u)&255u),f32((c>>8u)&255u),f32(c&255u))/255.0;
    #| return o;
    #|}
    #|@fragment fn fs_main(v: Out) -> @location(0) vec4<f32> {
    #| let light=u.ambient_color.xyz+u.light_color.xyz*max(dot(normalize(v.n),normalize(-u.light_dir.xyz)),0.0);
    #| let lit=v.color*light;
    #| let fog=smoothstep(45.0,230.0,length(v.world.xz-u.focus.xz));
    #| return vec4(mix(lit,vec3(0.392,0.498,0.537),fog),1.0);
    #|}
  source
}
