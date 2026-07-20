///|
fn make_bench_sprites(count : Int, w : Int, h : Int) -> Array[SpriteInput] {
  let inputs : Array[SpriteInput] = []
  let pixels : Array[Int] = Array::make(w * h * 4, 128)
  let spec = @atlas.image_spec_with_rgba8(w, h, pixels)
  for i in 0..<count {
    inputs.push({ key: "bench_" + i.to_string(), spec })
  }
  inputs
}

///|
test "bench pack 100 sprites 16x16" (b : @bench.T) {
  b.bench(name="sprite_packer/pack_100", fn() {
    let inputs = make_bench_sprites(100, 16, 16)
    let _ = pack_sprites(inputs, config=PackerConfig::default())
  })
}

///|
test "bench pack 1000 sprites 16x16" (b : @bench.T) {
  b.bench(name="sprite_packer/pack_1000", fn() {
    let inputs = make_bench_sprites(1000, 16, 16)
    let _ = pack_sprites(inputs, config=PackerConfig::default())
  })
}
