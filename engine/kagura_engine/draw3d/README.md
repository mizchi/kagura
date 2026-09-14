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

## 遮蔽物の透過と距離フェード

`shader3d_visibility_wgsl()` はカスタムWGSLへ連結できる共通関数を返す。
マテリアル、頂点のタグ、照明、バインディング番号は呼び出し元が決める。

- `kagura_camera_opacity(world, mask)`：カメラから注視対象までの範囲にある遮蔽物を透過。
- `kagura_dither_visible(opacity, fragment_position.xy)`：不透明パス内でディザ表示。
  カメラ透過に加え、草などの距離フェードにも利用できる。

```moonbit
let mask : @draw3d.CameraOcclusion = {
  eye: camera_position,
  target: subject_position,
  enabled: true,
  eye_radius: 1.25,
  target_radius: 0.85,
  softness: 0.55,
  end_fraction: 0.97,
}
mask.append_uniform_dwords(command.uniform_dwords)
```

WGSLのuniform構造体の同じ位置に `occlusion: KaguraCameraOcclusion` を置く。
既存uniform末尾は16バイト境界とし、追加分は **3 vec4 / 12 dword / 48バイト**。
`eye` と `target` はワールド座標、半径はワールド単位。
`softness` は完全透過する内側の半径比、`end_fraction` は注視対象の直前で透過を止める比率。
対象の後方やカメラの背後には適用しない。位置と設定値は有限値を渡す。

```wgsl
var opacity = 1.0;
if is_occluder {
  opacity = kagura_camera_opacity(world_position, u.occlusion);
}
if !kagura_dither_visible(opacity, fragment_position.xy) { discard; }
```

透過させるオブジェクトの選択、地面の衝突判定、草の距離範囲は呼び出し元の責務。
追加パス、アルファソート、動的なメッシュ再構築は不要。影・深度パスに組み込む場合も
呼び出し元で方針を選ぶ。草のフラグメントを消しても頂点処理は減らないため、
チャンクカリングや生成数の上限と組み合わせる。

## スキニングuniformの構築コスト

通常のスキニング描画（1,084 dword）と単色インスタンス描画（2,088 dword）は、
最終サイズの配列を一度だけ確保して必要な行列を書き込む。骨・インスタンスの
未使用領域はゼロのまま保持し、配列の段階的な拡張とパディングの追加ループを避ける。
各コマンドが独立した配列を所有するため、後続の描画で内容を書き換えない。
シェーダーのレイアウト、float変換、GPUへ送るバイト数は従来どおり。

`skinning_uniform_wbtest.mbt` が骨・インスタンスの0個／通常数／上限／上限超過と、
モデル変換・色・パディングを含む全dwordの一致を確認する。
consumer側の64体・8組のベンチは
[`game/landscape_bench`](../../../game/landscape_bench/README.md) にある。
