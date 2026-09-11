# body id の解決を O(1) にした（と、自分で入れた regression を測って直した）

- Date: 2026-09-11
- Scope: `engine/physics/physics2d`, `engine/physics/physics3d`
- 出発点: [ecs-write-path.md](./ecs-write-path.md) の作業項目 1。ECS 用に追加した
  bench が `PhysicsWorld::get_body` の O(n) 探索を掘り出した

## Conclusion

物理には id → body を線形探索する経路が 4 つあり、**そのうち 2 つは毎フレーム、
オブジェクト数に比例した回数呼ばれていた**。

| 経路 | 呼ばれ方 |
|---|---|
| `PhysicsWorld::get_body(id)`（3D） | `@ecs.system_sync_from_physics` が **entity ごと**に毎フレーム |
| `PhysicsWorld2D::get_body(id)` | 例（ragdoll / physics2d_demo）から |
| `find_body_index3d`（3D joints） | joint precompute が **joint ごとに 2 回**、毎フレーム |
| `find_body_index`（2D joints） | 同じ |

つまり entity 数 × body 数、joint 数 × body 数 で、**どちらも 2 乗**。1,000 body の
sync で 100 万回、`step_rope_256` で 1 フレームあたり約 13 万回の比較だった。

id → index の open addressing 表（`ContactCache3D` と broadphase の cell 表と同じ形）を
world に持たせて、全部 O(1) にした。**挙動は bit 一致**（表は scan と同じ index を返し、
id が重複したときの「最初が勝つ」も保存している）。

## 実測（merge base と交互 6 回、中央値）

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `ecs/system_sync_from_physics_1000` | 916.9 µs | **24.9 µs** | **36.9x** | yes |
| 2D `phase_joint_constraints_rope_256` | 125.7 µs | **22.0 µs** | **5.7x** | yes |
| 3D `phase_joint_constraints_rope_256` | 139.1 µs | **26.1 µs** | **5.3x** | yes |
| 2D `step_rope_256` | 400.9 µs | 304.3 µs | **1.32x** | yes |
| 2D `step_hinge_256` | 380.1 µs | 292.2 µs | **1.30x** | yes |
| 3D `step_rope_256` | 563.5 µs | 463.5 µs | **1.22x** | yes |
| 3D `step_ball_chain_256` | 785.9 µs | 656.1 µs | 1.20x | no |

joint の step が 1.2〜1.3x 動くのは、**joint precompute が step の 1/3 を占めていた**
ということでもある（2D rope で 126 µs / 401 µs）。それが 22 µs になった。

## 自分で入れた regression を測って直した

最初の実装は `add_body` で表に insert していた。それで **`build_pile_1024` が 2.1x 遅く
なった**（2D 66.5 → 142.4 µs、3D 78.7 → 158.4 µs、どちらも分離）。1,024 body で
+76 µs、**1 body あたり 74 ns** —— open addressing の insert と、64 → 2048 への 5 回の
再ハッシュ。このリポジトリの他の hash 表も insert は 50〜75 ns なので、値としては妥当で、
**「world を作るだけで id 解決を使わない側」に払わせていたのが間違い**だった。

そこで**表を lazy にした**: `add_body` は触らず、`ensure(bodies)` が最初の lookup で
未登録分だけ追い付く。body は append しかされないので、追い付きは常に suffix の走査で
済む。`ensure` は 2 回目以降は比較 1 回なので、毎フレームの経路が無条件に呼んでよい。

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| 2D `build_pile_1024` | 65.0 µs | 64.9 µs | 1.001x | no |
| 3D `build_pile_1024` | 76.9 µs | 75.3 µs | 1.022x | no |

**これは bench がこの PR の中で仕事をした 2 つ目の例**（1 つ目は ECS 側の bench が
この O(n²) を見つけたこと）。`build_` prefix の bench が無ければ、
「joint が 5.7x 速くなった」だけを見て出荷していた。

## 入れた変更

- `physics3d/body_index.mbt` / `physics2d/body_index.mbt`: id → index の表。
  32bit hash の open addressing、`insert` は最初の id を保持、`ensure` で lazy に追い付く
- `PhysicsWorld` / `PhysicsWorld2D` に `body_index` フィールド。`get_body` と
  `phase_joint_constraints` が `ensure` してから `find`
- joint precompute（4 本）は `bodies` を走査せず、解決済みの表を受け取る。
  `find_body_index3d` / `find_body_index` は削除
- `phase_joint_constraints_rope_256` bench を 2D / 3D に追加。**この phase には bench が
  無く、joint の step bench の中に埋まっていた**

## 検証

- **fingerprint**: 3D 4861 行 / 2D 4841 行（fixture 6 個 × 50 フレーム × body ごとの
  全状態 + cache 長）が merge base とバイト一致
- **frame VRT 17/17 バイト一致**（`physics2d_demo` は gating）
- js で workspace 1237 test、native は `moon check --deny-warn` 全体 + physics 2D 66 /
  3D 37 test

## 残っている作業項目

1. **id が変わらないことが契約になった。** 表は id で引くので、body を追加したあとに
   `world.bodies[i]` の id を書き換えると表が古くなる。エンジン内で id を書き換える
   コードは無く（grep 済み）、`find` の doc comment に書いたが、型では守られていない
2. **body の削除は今も無い。** 表は append 前提（`ensure` が suffix しか見ない）。
   削除 API を足すときは表の再構築か tombstone が必要
3. atlas 側にも同じ形の線形探索が残っている（`get_atlas_draw_source` が描画ごとに
   `repo.images` を走査、`resolve_tile_atlas_key` が tile ごとに `table.entries` を走査）。
   そちらは fixture が 1 entry なので bench が効果を隠している —— **先に fixture を
   直してから**測る
