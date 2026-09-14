# draw3d

3Dメッシュ、照明、PBR、スキニングの描画コマンドを構築する。
公開APIは `pkg.generated.mbti` を参照。

## テクスチャを使わない空

`sky_mesh()` と `shader3d_sky_wgsl()` は、内向きの立方体で全天を覆う。
12三角形・1 draw call。地形、シーンの物理状態、アセット読み込みに依存しない。
`SkySettings` で地平線・上空・下半球・雲・太陽の線形RGB、太陽の方向、雲量を指定する。
雲量0で雲を消し、太陽の方向がゼロなら太陽を消す。

```moonbit
// 初期化時にキャッシュ。shader_idはアプリ内で重複しないものを使う。
let sky = @draw3d.sky_mesh()
let shader = @gfx.new_shader_handle(shader_id, @draw3d.shader3d_sky_wgsl())
let settings = @draw3d.SkySettings::default()

// 透視投影カメラで、不透明なシーンの描画より先に送る。
cmds.push(@draw3d.new_sky_draw_command(
  target, shader, sky,
  camera.view_projection_matrix(), camera.position, settings,
))
```

視点の移動は相殺し、回転だけを空の見え方に反映する。立方体の有限な縁は見せない。
クリップ面の精度による欠けを避けるため、遠端の深度はフラグメント出力で指定する。
立方体を視錐台カリング、影、SSAO、衝突判定の入力に含めない。
Webでは `@web_hooks.register_static_geometry(sky.vertex_data, sky.indices)` で
静的ジオメトリとして登録すると、描画コマンド間でGPUバッファを共有できる。

`sky_wbtest.mbt` は内向きの巻き順、三角形予算、視点移動による不変性を検証する。
実GPUの描画はhacknslash_3dの `landscape.spec.ts` で確認する。
