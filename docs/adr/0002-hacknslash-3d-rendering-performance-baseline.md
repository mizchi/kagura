# ADR 0002: `hacknslash_3d` の render tuning は現時点で一旦完了扱いにし、次の主戦場を update 側へ移す

- Status: Accepted
- Date: 2026-03-12

## Context

`examples/games-3d/hacknslash_3d` は、今回の一連の最適化前は Web 側 encode/upload が主ボトルネックになっていた。

実測では、headed Chrome / real GPU の `default` シナリオで次の状態だった。

- `frameTimeMs.mean = 36.29 ms`
- `renderUploadCpuMs.mean = 27.55 ms`
- `renderEncodeCpuMs.mean = 29.80 ms`
- `gpuFrameMs.mean = 2.42 ms`
- `drawCalls.mean = 2758.88`

この値から分かる通り、当初の問題は GPU 実行時間ではなく、

- minimap を含む大量 draw call
- Web runtime 側の upload / encode CPU
- 不要な post-process / shadow path

にあった。

その後、次の改善を順に入れた。

- minimap の batched geometry 化
- WebGPU runtime の upload/encode 計測と micro-cache
- visible dungeon merged mesh cache
- entity instancing / skinned fast path
- enemy stress scenario 専用の pre-skinned cache と scratch 再利用
- `enemy-enemy separation` の scratch 再利用つき spatial bucketing
- `enemy_ai_phase` の same-room direct chase fast path
- `enemy_movement_contact_phase` の player-state hoist と cheap overlap 判定

最新の headed Chrome 実測では、`stress_enemies_256` でも次の値に収まっている。

- `frameTimeMs.mean = 9.05 ms`
- `renderUploadCpuMs.mean = 0.47 ms`
- `renderEncodeCpuMs.mean = 0.77 ms`
- `gpuFrameMs.mean = 0.70 ms`
- `drawCalls.mean = 148`

また `rAF` baseline は `8.22 ms` なので、render path はほぼ browser cadence に張り付いている。

同時に `world.tick` の phase bench も追加し、update 側の支配項を切り分けた。直近の microbench は次の通り。

- `enemy_ai_phase/stress_enemies_256 = 4.31 µs`
- `enemy_movement_contact_phase/stress_enemies_256 = 2.73 µs`
- `enemy_enemy_separation/stress_enemies_256 = 46.05 µs`

この値から、update 側の主戦場は `enemy_enemy_separation` に寄っており、render core はもう主要ボトルネックではないと判断できる。

## Decision

`hacknslash_3d` の render tuning は、現時点では一旦完了扱いにする。

完了の判断基準は次である。

1. `default` と `stress_enemies_256` の両方で frame time が `~10 ms` 未満
2. `renderEncodeCpuMs` が `1 ms` 未満
3. `gpuFrameMs` が `1 ms` 前後で、render core が GPU bound ではない
4. draw call と upload CPU が十分小さく、支配項が render 外へ移っている
5. `world.tick` の phase bench により、`enemy_enemy_separation` が次の最適化対象として明確になっている

今後の最適化の主戦場は render path ではなく、`update / gameplay / stress scenario design` とする。

## Consequences

### Positive

- render 最適化を無限に続けず、次のボトルネックへ移れる
- `hacknslash_3d` は 256 体 stress でも常用上十分軽い状態を確保できた
- 以後の回帰は headed Chrome perf と Moon bench で検出できる
- `hacknslash_3d` で効いた最適化のうち、engine 共通のものを `kagura` コアへ切り出す判断基準ができた
- update 側も `AI / movement-contact / separation / projectiles / items` まで分解できた

### Negative

- `FXAA / shadows / SSAO` を常時 on に戻す場合は再評価が必要
- より極端な scenario (`512+ enemies`, projectile-heavy, larger dungeon) では再び render が支配項になる可能性がある
- native 側の同等計測はまだ Web ほど揃っていない

## Follow-up

次の優先作業は render ではなく次の順とする。

1. `enemy_enemy_separation` の残り最適化
2. gameplay stress scenario の拡張
3. native 側 frame breakdown の整備
4. render / update regression を監視する perf runbook の整理

## Scope Boundary

今回の tuning のうち、次は `kagura` コアとして扱うべきものと、`hacknslash_3d` 側に残すものを分ける。

### `kagura` コアへ寄せる

- WebGPU runtime の upload / encode 計測と micro-cache
- `scene3d` の instanced / skinned command helper
- `particle3d` の scratch buffer 再利用
- `HudContext` の batched rect helper

今回の段階で、少なくとも次は core API / contract として整理済みである。

- `ParticleManager::append_draw_commands(...)`
- `scene3d.uniform_instance_color(...)`
- `scene3d.push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(...)`
- `scene3d.push_skinned_mesh_gpu_commands_with_color_optimization_and_view_projection(...)`
- `DrawTrianglesCommand.resource_cache_key`
- `HudContext::append_rect_batch_geometry(...)`
- `HudContext::push_rect_batch_command(...)`
- `shadow3d.new_shadow_depth_command(...)`
- `shadow3d.new_camera_depth_command(...)`
- `tilemap2d.append_tile_indexed_chunk_draw_commands(...)`
- `tilemap2d.append_tile_indexed_chunk_batched_draw_commands(...)`
- `tilemap2d.TileChunkBatchCache`

これらは `hacknslash_3d` 専用の helper ではなく、`terrain_demo` など他 example でも利用できる形にしてから採用している。

### `hacknslash_3d` 側に残す

- minimap の layout / tile color / marker 意味付け
- visible dungeon merged mesh cache
- enemy stress scenario の設計
- `enemy-enemy separation` の gameplay 最適化
- same-room direct chase など room-aware AI policy

## Reference

- [hacknslash_3d rendering performance summary](/Users/mz/ghq/github.com/mizchi/kagura/docs/performance/hacknslash_3d-rendering-performance.md)
- [GPU perf summary 8299](/Users/mz/ghq/github.com/mizchi/kagura/output/playwright/hacknslash_3d_gpu_perf-headed-8299/summary.json)
- [GPU perf summary 8302](/Users/mz/ghq/github.com/mizchi/kagura/output/playwright/hacknslash_3d_gpu_perf-headed-8302/summary.json)
- [GPU perf summary 8318](/Users/mz/ghq/github.com/mizchi/kagura/output/playwright/hacknslash_3d_gpu_perf-headed-8318/summary.json)
