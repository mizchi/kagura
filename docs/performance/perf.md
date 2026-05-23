# Performance Review Summary

- Date: 2026-03-30
- Scope: `collision3d`, `scene3d`, `physics3d`, VRT readiness
- Goal: エンジンの CPU hotspot を実測で切り分け、改善値と未解消ボトルネックを固定する

## Summary

今回の perf review で、一番大きく落ちたのは `collision3d` の dense broadphase と、`scene3d` / `physics3d` の common path である。

特に `collision3d.SpatialHashGrid::get_pairs` は dense case で `89.86ms -> 2.16ms` まで縮み、`scene3d` は 1024 object の common case が `2.39ms -> 0.93-1.02ms` 帯まで下がった。`physics3d` も `world_step_fresh_dense_64` が初期レビューの `503.89µs` から `223.38-240.57µs` 帯まで下がっている。

一方で、未解消の支配項はまだ残っている。`physics3d` は substep 内の tangent/angular path、`scene3d` は PBR/skinned 経路と小配列割り当て、`gfx` は explicit geometry merge の CPU copy が次の主戦場である。

## Measurement Commands

```sh
moon bench --package physics3d --target js --release
moon -C /tmp/kagura_perf_review bench --target js --release
moon test --package physics3d --target js
pnpm exec playwright test e2e/vrt.spec.ts
```

## Measured Results

### Main improvements

| Area | Metric | Initial review | Latest |
|---|---:|---:|---:|
| `collision3d` | `get_pairs_dense_512` | `89.86 ms` | `2.16 ms` |
| `collision3d` | `get_pairs_sparse_512` | `12.25 µs` | `12.13 µs` |
| `scene3d` | `render_scene3d_gpu_1024` | `2.39 ms` | `0.93-1.02 ms` |
| `scene3d` | `render_scene3d_gpu_1024_sorted` | `2.53 ms` | `1.07-1.10 ms` |
| `physics3d` | `world_step_fresh_dense_64` | `503.89 µs` | `223.38-240.57 µs` |
| `physics3d` | `world_step_fresh_sparse_64` | `90.55 µs` | `69.20-79.34 µs` |

### `physics3d` stage bench

`src/physics3d/world_bench.mbt` で `step` を段階分解して計測している。最新の代表値は次の通り。

| Stage | Dense 64 |
|---|---:|
| `pairs` | `30-31 µs` |
| `constraints` | `49-52 µs` |
| `velocity` | `2.5-2.6 µs` |
| `solve` | `75-80 µs` |
| `solve_only` | `6.8-7.0 µs` |
| `position` | `2.6 µs` |
| `substeps` | `198-199 µs` |
| `full` | `223-226 µs` |

`pairs` や `constraints` はもう支配的ではなく、今は `substeps` が本体である。残りは `solve_constraint3d` の tangent/angular path と、persistent world 前提の buffer reuse を切り分ける段階に入っている。

### `scene3d` notes

効いた変更は次の系統だった。

- sort を object copy ではなく index sort に変更
- white tint / plain unskinned object の fast path
- `Transform3D::to_mat4()` の translation-only fast path
- translation-only normal matrix fast path
- shared light dwords と exact-size uniform packing
- `transform_aabb` の temp array 削減

`scene3d` は common case ではかなり軽くなったが、`DstRegion` / `dst_regions` / `src_image_ids` の小配列割り当てと、PBR/skinned 経路の uniform packing がまだ残っている。

### Remaining hotspot outside the current fixes

explicit geometry merge は未着手のまま重い。

| Bench | Result |
|---|---:|
| `sprite2d/same_state_10000` | `2.84 ms` |
| `sprite2d/alternating_texture_pages_10000` | `2.15 ms` |

完全に同一 state のほうが遅く、CPU 側で全 vertex/index を詰め直す merge が逆噴射している。

## VRT Validation

`pnpm exec playwright test e2e/vrt.spec.ts` は 2026-03-30 時点で `19 passed (53.9s)`。

確認できたのは次のカテゴリ。

- `2d-scene`: `scene_demo`, `ui_demo`
- `2d-game`: `flappy_bird`, `survivor`, `action_rpg`, `fps_demo`, `physics2d_demo`
- `3d-render`: `arena3d`, `collision3d_demo`, `physics3d_demo`, `skeletal_anim`, `ragdoll_demo`, `obj_viewer`, `gltf_viewer`
- `3d-postfx`: `shadow3d_demo`, `postfx_demo`, `hacknslash_3d`
- `asset`: `fetch_image`
- snapshot mode: `hacknslash_3d?snapshot=playing&frames=60&tick=5`

VRT を通すために、`examples/smoke/runtime_smoke` / `examples/smoke/runtime_smoke_native` / `examples/games-2d/action_rpg` の `mizchi/font` 依存を `0.7.0` に揃え、`examples/games-2d/action_rpg/src/moon.pkg` に `mizchi/font` import を追加した。

## Next

1. `physics3d` の tangent/angular path を削る
2. `physics3d` の persistent world 前提 buffer reuse を試す
3. `scene3d` の PBR/skinned uniform packing を詰める
4. explicit geometry merge を再設計する
