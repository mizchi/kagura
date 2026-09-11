# ECS の write path — immutable struct を 1 個作るのに 264 ns

- Date: 2026-09-11
- Scope: `game/kagura_game/ecs`, `engine/anim3d/transform3d`,
  `examples/demos-2d/ecs_demo`
- 前提: 物理の 3 周
  （[physics3d-optimization.md](./physics3d-optimization.md) /
  [physics-followups.md](./physics-followups.md) /
  [physics-phase-boundaries.md](./physics-phase-boundaries.md)）で確立した
  「割り当てを消す」の適用範囲と、ペア測定 + 分離の判定

## Conclusion

物理の外で最も重い per-entity コストは ECS の書き込みだった。`ecs/system_movement_10000`
は **3.84 ms**、同じ walk を読むだけの `each_with_transform_10000` は **60.9 µs** ——
**書き込みが読み出しの 60 倍**。

そして**仮説のうち 2 つが生成 JS を読んだ時点で外れた。**

| 立てた仮説 | 生成 JS が言ったこと |
|---|---|
| `Array[T?]` の `Option` が entity ごとに 1 個割り当てられている | **外れ。** `Option[Transform3D]` は nullable 参照（`=== undefined`）にコンパイルされる。無料 |
| `match (a, b)` が tuple を 1 個割り当てている | **外れ。** tuple は消えて、`undefined` チェックの入れ子になる。無料 |
| `Vec3::new` が効いている | **ほぼ外れ。** escape しない限り V8 が消す（下記の 41.0 → 40.1 µs）|

残った 1 個 —— **`Transform3D` の作り直し** —— が phase の 90% だった。

## 分解（10,000 entity、同一 run 内）

`system_movement` の中身を 1 段ずつ足して測った:

| variant | µs | 追加分 |
|---|---:|---:|
| loop + `alive` + `Option` 2 回読み + `t.position.x` | 41.0 | — |
| + `Vec3::new` 1 個（消費するだけ） | 40.1 | **±0** |
| + `with_position`（`Transform3D` を 1 個作る） | **2580** | **+2540** |
| + 配列へ書き戻す（= `system_movement` 相当） | 2690 | +110 |
| bench entry（checksum walk を含む） | 2840 | +150 |

**1 個の 3 フィールド struct を作るのに 264 ns。** 単なる bump allocation では説明できない
大きさで、原因は切り分けていない（world.transforms への store で世代間 write barrier が
走り、作った object が long-lived 配列から参照されて promote され、前フレームの分が
old space のゴミになる —— このどれがどれだけかは未測定）。**測れた事実は「escape する
struct 1 個で 264 ns」であり、理由づけはそこまで。**

## 書き込みの形を 3 つ測った

| 形 | µs | 倍率 | 割り当て/entity |
|---|---:|---:|---:|
| 現状: immutable 再構築 + 配列へ store | 2840 | 1.00x | 2（`Vec3` + `Transform3D`）|
| `mut position : Vec3` に代入 | **203** | **14.0x** | 1（`Vec3`）|
| `mut pos_x/pos_y/pos_z : Double` に代入 | 73 | 38.9x | 0 |

**38.9x ではなく 14x を採った。** 差は 130 µs（2.84 ms の 4.6%）しかなく、scalar 版は
`position` を 3 本の `Double` に割るので `Transform3D` を持つ 98 箇所と
`each_with_transform` の callback 型に波及する。**94% の利得を API 互換で取れるなら
そちらが正しい。**

読み出しを無料に保つ制約も同じ結論を指す: `each_with_transform` は**保存している object を
そのまま渡す**ので今 28.7 µs で済んでいる。position を flat 列に移すと、渡すために
`Transform3D` を entity ごとに作ることになり、上の 264 ns がそのまま読み出し側に移る。

## 入れた変更

- `Transform3D` の 3 フィールドを `mut` にし、`set_position` / `set_rotation` /
  `set_scale`（in-place）を足した。`with_*` はそのまま残る —— 値として扱う側
  （scene graph、animation blending、IK）はそちらを使う
- **所有権の契約を doc comment に書いた**: transform を保存する側がその instance を
  所有する。`World::set_transform` は渡された instance をそのまま持つので、1 個を複数
  entity に共有させると in-place 更新で全部動く。リポジトリ内の書き込み 5 箇所
  （すべて `ecs_demo`）はいずれも毎回新しい instance を作っているので、現状の違反は無い
- `system_movement` と `system_sync_from_physics` を in-place に。後者は
  `with_position(...).with_rotation(...)` で **entity あたり 2 個**作っていた
- `World::set_position(eid, x, y, z)` を足し、`ecs_demo` の push / clamp
  （毎フレーム走る）をそれに移した
- `ecs/system_sync_from_physics_1000` bench を追加（3D example が毎フレーム通る経路が
  まったく測られていなかった）

## 実測（merge base と交互 6 回、中央値）

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `ecs/system_movement_10000` | 2.85 ms | **264.1 µs** | **10.8x** | yes |
| `ecs/full_frame_tick_1000` | 225.3 µs | **22.3 µs** | **10.1x** | yes |
| `ecs/each_with_transform_10000`（読み出し） | 29.6 µs | 29.9 µs | 0.990x | no |
| `ecs/each_with_transform_velocity_10000` | 45.7 µs | 46.5 µs | 0.982x | no |
| `ecs/spawn_at_10000` | 1.11 ms | 1.09 ms | 1.018x | no |
| `ecs/compact_10000_half_dead` | 1.48 ms | 1.48 ms | 1.003x | no |

**`full_frame_tick` が 10.1x** —— movement だけでなく「1 フレーム分の ECS」がそれだけ
動く。読み出し側は狙いどおり動いていない（0.98〜0.99x、非分離）。触っていない他モジュール
（`physics2d` / `physics3d` / `draw3d` / `gfx_queue` / `postfx` / `shadow3d` など）は
0.897〜1.05x で**どれも非分離**。

`system_sync_from_physics` は別に測った（この PR で追加した bench なので base 側にも
同じ bench を置いて 4 回交互）:

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `ecs/system_sync_from_physics_1000` | 1.37 ms | **972 µs** | **1.41x** | yes |

## この bench が O(n²) を 1 つ掘り出した

最初 10,000 entity で測ったら **98 ms** だった。transform の作り直し 2 個/entity では
説明がつかない大きさで、原因は `PhysicsWorld::get_body(id)` が
**bodies 全体の線形探索**であること。`system_sync_from_physics` はそれを
**entity ごとに毎フレーム**呼ぶので、この bench は entity 数の 2 乗で伸びる。
10,000 では 5,000 万回の比較で、**98 ms の 95%** がそれだった。

そのサイズでは transform の修正は**測定不能**だった（base 99.75 / 101.66 / 104.39 ms 対
branch 102.20 / 95.00 / 104.38 ms、非分離）。bench を 1,000 に下げて 2 つの効果が同じ
オーダーになるようにしてから、上の 1.41x が見えた。

**同じ形が 2D にもある**: `physics2d/joints.mbt` の `find_body_index` も線形探索で、
joint precompute が **joint ごとに 2 回**、毎フレーム呼ぶ（`step_rope_256` は 256 joint ×
257 body × 2 = 約 13 万回/frame）。id → index の解決を O(1) にするのが
次の作業項目（下記 1）である。

## 検証

- `ecs_demo` は **gating な frame VRT** に入っている。描画した PNG は committed baseline と
  **バイト一致**（`vlmkit` がこのコンテナに無いので `cmp` で代用、`--threshold 0` より厳しい）
- ECS 50 test / transform3d 18 test が通る

## 残っている作業項目

1. ~~**`PhysicsWorld::get_body` / `find_body_index` の O(n) 探索**~~ →
   [physics-id-lookup.md](./physics-id-lookup.md) で対応済み。`system_sync_from_physics`
   が **36.9x**、joint precompute が 2D 5.7x / 3D 5.3x、joint の step が 1.2〜1.3x
2. **`ecs/system_death_10000` と `ecs/compact_10000_half_dead` は closure の中で
   `setup_world(10000)` を呼んでいる**（= 約 1.1 ms が setup）。名前の操作は
   300〜600 µs しか測っていないので、物理で作った `phase_reset_` 相当の床が要る
3. **`spawn` / `spawn_at` が 10 本の列に `None` を push する**（entity あたり 10 回）。
   1.0〜1.1 ms / 10,000 entity。列を遅延確保にすれば削れるが、`compact` と
   `destroy` のスロット方針に触ることになる
4. **`entities_with_tag` が tag ごとに `Array[Tag]` を線形比較**（83 µs / 10,000）。
   tag が増えると伸びる
5. `Transform3D` を `mut` にしたので、**保存する側が instance を所有する**という契約が
   コードの外に無い。将来 `set_transform` が defensive copy を取るべきか（1 回あたり
   264 ns）は、共有インスタンスを渡す呼び出しが実際に現れたときに決めればよい
