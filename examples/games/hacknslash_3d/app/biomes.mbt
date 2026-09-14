///|
/// A shared world-space transition field; boundaries meander over a forty-tile
/// ecotone. Region activation never changes its coordinates or palette.
fn biome_weights(x : Double, z : Double) -> Array[Double] {
  fn ease(v : Double) -> Double {
    let t = v.clamp(min=0.0, max=1.0)
    t * t * (3.0 - 2.0 * t)
  }
  let east = ease((x - 98.0 - 4.0 * @math.sin(z * 0.07) + 20.0) / 40.0)
  let south = ease((z - 78.0 - 4.0 * @math.sin(x * 0.06) + 20.0) / 40.0)
  [
    (1.0 - east) * (1.0 - south),
    east * (1.0 - south),
    (1.0 - east) * south,
    east * south,
  ]
}

///|
/// Gradually mix existing plant/rock families instead of switching at a border.
fn biome_species(x : Double, z : Double, hash : Int) -> Int {
  let roll = (hash % 100).abs().to_double() / 100.0
  let weights = biome_weights(x, z)
  let mut cumulative = 0.0
  for i, weight in weights {
    cumulative += weight
    if roll < cumulative {
      return i
    }
  }
  3
}

///|
let biome_palettes : Array[Array[@math3d.Vec4]] = Array::makei(4, i => {
  world_region_palette(i)
})

///|
/// Vertex shading interpolates colors across each low-poly face. Palettes are
/// embedded once in the shader; no CPU vertex recoloring or extra draw calls.
fn biome_shader_wgsl() -> String {
  let colors = StringBuilder::new()
  for palette in biome_palettes {
    for c in palette {
      colors.write_string("vec3<f32>(\{c.x},\{c.y},\{c.z}),")
    }
  }
  let source =
    #|fn biome_color(material: u32, p: vec2<f32>) -> vec3<f32> {
    #| let east=smoothstep(78.0,118.0,p.x-4.0*sin(p.y*0.07));
    #| let south=smoothstep(58.0,98.0,p.y-4.0*sin(p.x*0.06));
    #| let north=mix(biome_colors[material],biome_colors[24u+material],east);
    #| let southern=mix(biome_colors[48u+material],biome_colors[72u+material],east);
    #| return mix(north,southern,south);
    #|}
  "const biome_colors=array<vec3<f32>,96>(" +
  colors.to_string() +
  ");\n" +
  source
}

///|
fn GameState::scenery_focus(self : GameState) -> @math3d.Vec4 {
  let region = self.world.atlas.map(a => a.current).or(0)
  @math3d.Vec4::new(
    self.world.player.x / tile_size,
    @game.world_regions[region].x.to_double() * 98.0,
    self.world.player.y / tile_size,
    @game.world_regions[region].z.to_double() * 78.0,
  )
}
