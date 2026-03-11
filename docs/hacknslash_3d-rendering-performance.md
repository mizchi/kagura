# `hacknslash_3d` Rendering And Update Performance Summary

- Date: 2026-03-12
- Scope: `examples/hacknslash_3d`
- Goal: render path の CPU/GPU ボトルネックを潰し、通常シーンと enemy stress case の両方で `rAF` 基準に近いフレーム時間へ寄せたうえで、`world.tick` の phase ごとの支配項を切り分ける

## Conclusion

現時点では、`hacknslash_3d` の render tuning は一旦締めてよい段階まで来ている。update 側も phase bench による主要 hotspot の切り分けと、主要 3 phase の最適化まで完了している。

- 通常シーンでは render path は十分軽い
- `stress_enemies=256` でも Web 側 encode / GPU ともに小さい
- `world.tick` 側は `enemy_enemy_separation` が残り主戦場
- `enemy_ai_phase` と `enemy_movement_contact_phase` は既に十分小さい

つまり、「render path のパフォーマンス改善」はこの時点で一周完了しており、次に進めるなら render ではなく `update` や gameplay 側を詰めるのが自然である。

## Measured Result

### Headed Chrome / real GPU

計測コマンド:

```sh
node scripts/hacknslash_3d_gpu_perf.mjs \
  --serve \
  --port 8318 \
  --samples 6 \
  --warmup 3 \
  --scenarios default,stress_enemies_256 \
  --headed \
  --channel chrome \
  --out-dir output/playwright/hacknslash_3d_gpu_perf-headed-8318
```

参照:
- [summary.json](/Users/mz/ghq/github.com/mizchi/kagura/output/playwright/hacknslash_3d_gpu_perf-headed-8318/summary.json)

主要値:

| Scenario | Frame Time mean | Render Upload CPU | Render Encode CPU | GPU Frame | Draw Calls | Vertex Count |
|---|---:|---:|---:|---:|---:|---:|
| `default` | `8.48 ms` | `0.45 ms` | `0.82 ms` | `0.76 ms` | `126` | `96,048` |
| `stress_enemies_256` | `9.05 ms` | `0.47 ms` | `0.77 ms` | `0.70 ms` | `148` | `98,757` |

`rAF` baseline は `8.22 ms` なので、`stress_enemies_256` でもほぼ browser cadence に張り付いている。

### Moon bench / update phase

最新 bench では `world.tick` の主要 phase を分解している。参照コマンド:

```sh
moon -C examples/hacknslash_3d bench --target js
```

直近の主要値:

| Phase | Stress 64 | Stress 256 |
|---|---:|---:|
| `enemy_ai_phase` | `1.03 µs` | `4.31 µs` |
| `enemy_movement_contact_phase` | `0.70 µs` | `2.73 µs` |
| `enemy_enemy_separation` | `12.52 µs` | `46.05 µs` |

補足:

- `projectiles_phase/player_hit = 0.03 µs`
- `items_phase/pickup = 0.03 µs`

この時点で update 側の支配項は `enemy_enemy_separation` に明確に寄っている。`enemy_ai_phase` は same-room direct chase fast path により、stress 256 でも `4.31 µs` まで低下している。

### Improvement against earlier encode-bound state

比較対象:
- [summary.json](/Users/mz/ghq/github.com/mizchi/kagura/output/playwright/hacknslash_3d_gpu_perf-headed-8299/summary.json)
- [summary.json](/Users/mz/ghq/github.com/mizchi/kagura/output/playwright/hacknslash_3d_gpu_perf-headed-8302/summary.json)

`default` シナリオの代表値:

| Stage | Frame Time mean | Render Upload CPU | Render Encode CPU | GPU Frame | Draw Calls |
|---|---:|---:|---:|---:|---:|
| pre-fix (`8299`) | `36.29 ms` | `27.55 ms` | `29.80 ms` | `2.42 ms` | `2758.88` |
| minimap batch 後 (`8302`) | `8.93 ms` | `0.69 ms` | `1.16 ms` | `0.84 ms` | `151` |
| latest (`8318`) | `8.48 ms` | `0.45 ms` | `0.82 ms` | `0.76 ms` | `126` |

主ボトルネックは GPU ではなく Web 側 upload/encode だった。特に minimap の大量 draw call が支配的だったため、そこを潰したことでほぼ収束した。

### Moon bench

最新 bench の代表値:

- `hacknslash_3d/draw_playing/default = 43.44 µs`
- `hacknslash_3d/draw_playing/stress_enemies_256 = 230.88 µs`
- `hacknslash_3d/enemy_character_pass/stress_enemies_256 = 152.73 µs`
- `hacknslash_3d/enemy_enemy_separation/stress_enemies_256 = 46.05 µs`
- `hacknslash_3d/enemy_ai_phase/stress_enemies_256 = 4.31 µs`
- `hacknslash_3d/enemy_movement_contact_phase/stress_enemies_256 = 2.73 µs`
- `hacknslash_3d/entities_pass/default = 12.18 µs`
- `hacknslash_3d/dungeon_pass/default = 7.84 µs`
- `hacknslash_3d/hud_pass/default = 7.17 µs`

この時点で stress でも render command build は sub-millisecond 相当で、CPU/GPU の主ボトルネックではない。update 側も `enemy_enemy_separation` 以外はかなり小さい。

## Main Changes

今回の改善で効いたのは主に次の系統である。

1. WebGPU runtime の無駄削減
- `context.configure(...)` の毎フレーム呼び出しを廃止
- `renderGpu(...)` の CPU 時間を `upload / bind / pass encode / submit` に分解
- static / unchanged buffer の `queue.writeBuffer` を回避

2. `hacknslash_3d` の pass 削減
- `FXAA` / `shadow` / `SSAO` の既定 off
- bloom half-res 化
- minimap の per-tile draw を batched geometry へ変更

3. 3D command build の削減
- entity instancing
- skinned command の fast path
- visible dungeon merged mesh cache
- enemy kind bucket の monochrome instanced path

4. stress case 向け最適化
- `stress_enemies=64/256` scenario 追加
- enemy pre-skinned mesh cache
- `enemy-enemy separation` の scratch 再利用つき spatial bucketing
 - same-room direct chase fast path
 - `enemy movement/contact` の player-state hoist と cheap overlap 判定

## Remaining Work

render tuning を続ける余地がゼロではないが、優先度は下がった。

次にやるべき候補は次の通り。

1. `enemy_enemy_separation` の残り最適化
- 2D cell 近傍化までは入ったので、残る pair 解決の `wall collision` や push 解決をさらに詰める

2. gameplay stress の強化
- `stress_enemies_512` や projectile-heavy scenario を追加し、render 以外の支配項を探す

3. native 側の同等計測
- Web と同じ観点で native renderer の frame breakdown を揃える

4. features を戻した場合の再評価
- `FXAA / shadows / SSAO` を既定 on に戻すなら、もう一度 perf を採る

## Core vs Game-Specific

今回の最適化は、全部を `hacknslash_3d` に閉じ込めるのではなく、`kagura` コアへ上げるものとゲーム固有のものを分けて扱うべきである。

### `kagura` コアへ上げるべきもの

- WebGPU runtime の upload / encode 計測と micro-cache
  - `queue.writeBuffer` の支配性を見えるようにし、static / unchanged upload を飛ばす方針は engine 共通
- `scene3d` の command build helper
  - instanced draw / skinned fast path / monochrome instanced path はゲーム非依存
- `particle3d` の scratch buffer 再利用
  - emitter ごとの毎フレーム alloc を避ける方針は core 側に置くべき
- `HudContext` の batched rect helper
  - minimap 由来で導入したが、実体は HUD 用矩形 batching なので engine の HUD API として再利用できる

### `hacknslash_3d` 固有のもの

- minimap のレイアウトと tile 色の意味付け
- visible dungeon merged mesh cache
  - dungeon chunk 構造と player tile 依存なので、現状はゲーム側責務
- enemy stress scenario (`stress_enemies`, `stress_enemies_256`)
- `enemy-enemy separation` の spatial bucketing と same-room chase policy
  - gameplay / world update の最適化であり engine core ではない

### 今回一般化したもの

今回の段階では、`hacknslash_3d/src/hud.mbt` に閉じていた minimap 用矩形 batching を `src/hud/context.mbt` の generic API に切り出した。

- `HudContext::append_rect_batch_geometry(...)`
- `HudContext::push_rect_batch_command(...)`

これにより、HUD の batched rect は `hacknslash_3d` 固有実装ではなく `kagura` の HUD utility として再利用できる。

加えて、今回の整理で次も `kagura` コア側へ寄せた。

- `ParticleManager::append_draw_commands(...)`
  - particle command を既存 buffer へ append できるようにし、game 側が毎回 `Array` を組み直さなくてよい API にした
- `scene3d.uniform_instance_color(...)`
- `scene3d.push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(...)`
- `scene3d.push_skinned_mesh_gpu_commands_with_color_optimization_and_view_projection(...)`
  - 「同色なら monochrome instanced、混色なら通常 instanced/skinned」を scene3d の責務に寄せた
- `DrawTrianglesCommand.resource_cache_key`
  - Web runtime の upload skip を command 契約で opt-in できるようにした

### 一般化 API の適用先

一般化した API は `hacknslash_3d` だけでなく、他 example でも使えることを確認した。

- `ParticleManager::append_draw_commands(...)`
  - `hacknslash_3d` の render path / bench で、particle command を既存 command buffer へ直接 append する用途に適用済み
- `scene3d.push_instanced_instance_data_gpu_commands_with_color_optimization_and_view_projection(...)`
  - `terrain_demo` の enemy instancing に適用済み
  - `InstanceData` 配列のまま、uniform color 時は monochrome instanced path、mixed color 時は通常 instanced path を選べる
- `DrawTrianglesCommand.resource_cache_key`
  - Web runtime 契約として core に入り、game 固有コードに閉じずに使える状態にした
  - `postfx.new_fullscreen_quad_command(...)`、`draw2d.new_atlas_quad_draw_command(...)`、`text.SimpleTextBatchBuilder`、`shadow3d.new_shadow_depth_command(...)`、`shadow3d.new_camera_depth_command(...)`、`tilemap2d.append_tile_indexed_chunk_draw_commands(...)`、`tilemap2d.append_tile_indexed_chunk_batched_draw_commands(...)` でも、geometry / source / uniform から自動で key を作るようにしてある
- `tilemap2d.TileChunkBatchCache`
  - visible chunk の移動時は全 redraw、同一視界では dirty chunk だけ append する上位 cache contract として整理した
  - `runtime_smoke_native` でも manual diff を持たずに利用できる

## Recommended Stop Line

この時点では、`hacknslash_3d` の render path に対して以下を満たしているため、一旦完了扱いでよい。

- `default` が `~8.5 ms`
- `stress_enemies_256` でも `~9.0 ms`
- `renderEncodeCpuMs < 1 ms`
- `gpuFrameMs < 1 ms`

update 側についても、少なくとも次を満たしている。

- `enemy_ai_phase/stress_enemies_256 < 5 µs`
- `enemy_movement_contact_phase/stress_enemies_256 < 3 µs`
- 支配項は `enemy_enemy_separation` に切り分け済み

今後の最適化は `render` ではなく `update / gameplay / larger stress scenario` を優先する。
