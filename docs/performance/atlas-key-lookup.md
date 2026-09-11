# atlas の asset key 探索は O(n) だが、出荷している経路では薄い（入れなかった）

- Date: 2026-09-11
- Scope: `engine/kagura_engine/sprite2d`（bench のみ）
- 出発点: [physics-id-lookup.md](./physics-id-lookup.md) の作業項目 3
  「atlas 側にも同じ形の線形探索が残っている。そちらは fixture が 1 entry なので
  bench が効果を隠している —— **先に fixture を直してから**測る」

## Conclusion

fixture を直して測った結果、**索引は入れなかった。**

`@atlas.get_atlas_draw_source` は確かに O(n)（`repo.images` を early exit なしで
走査し、key を String で比較する）。傾きも測れた。**ただし出荷している経路では
1 フレーム 2.5 µs** —— 16.67 ms の **0.015%** である。

そして `resolve_tile_atlas_key`（tile ごとに走査する方、2 乗になりうる側）は
**`tilemap2d` の whitebox test 以外から呼ばれていない**。索引を入れても、
呼ばれていないコードが速くなるだけだった。

入れたのは **fixture の修正と値段表**である。

## まず fixture が壊れていた

`bench_particle_repo(700, "particle/a")` の **700 は `atlas_id` であって entry 数ではない**。
4 つの fixture すべてが **1 entry の atlas** を作っていたので、
`append_atlas_sprite_draw_command` が毎回通る走査は 1 要素しか見ておらず、
**bench は自分が測っているつもりのコストを測っていなかった**。

entry 数を引数にして、既定を **30** にした。リポジトリ内で毎フレーム描画に使われる
唯一の atlas —— `hacknslash_3d` のアイコン atlas（6 pattern × 4 rarity + skill 6 =
30 entry）に合わせた数である。探索する key は最後に登録している（early exit が
無いので、どこに置いても走査は全件で、これが平均でも最悪でもある）。

## 値段（`moon bench` workspace regime）

### 傾き

3 回中央値（baseline に記録した値）:

| entry 数 | 1000 回の探索 | 1 回あたり |
|---:|---:|---:|
| 1 | 16.0 µs | 16.0 ns |
| 8 | 34.7 µs | 34.7 ns |
| 30 | 100.8 µs | 100.8 ns |
| 128 | 411.0 µs | 411.0 ns |

**きれいに線形**で、傾きは **1 entry あたり 3.11 ns**、固定費が約 13 ns。
String 比較 1 回が 3 ns 級ということでもある。

### パイプラインの中での値段

isolated な傾きが in situ でも成り立つとは限らないので、**atlas の entry 数だけが
違う同じ bench**を並べた（値は baseline の 3 回中央値）:

| bench | µs |
|---|---:|
| `particles/pipeline_same_state_10000`（30 entry） | 4840 |
| `particles/pipeline_same_state_10000_atlas1`（1 entry） | 4020 |
| **差（10,000 回の探索）** | **820** |

**1 回 82 ns** で、isolated な傾きから引いた予測（97.92 − 15.83 = 82.1 ns）と
**一致する**。つまりこの走査は単体でもパイプラインの中でも同じ値段である。

つまり 30 entry の atlas では、**per-quad な atlas 描画のコストの 17%（820/4840）が
key の走査**である。

**ここで一度嘘を書きかけた。** 最初は 1 回ずつの run を引き算して「in situ では
146 ns、isolated 予測の 1.8x」と書いていた。3 回中央値で取り直したら 82 ns で
予測どおりだった —— `pipeline_same_state_10000` は baseline での自分の幅が
**1.124**（この群で最大）で、単発の 5.36 ms は中央値 4.84 ms から上に振れた側だった。
**2 つの単発 run の差は、どちらの幅より小さい差を語れない。**

### batched 経路との差の内訳

| bench | µs |
|---|---:|
| `particles/pipeline_batched_10000` | 1240 |
| `particles/pipeline_same_state_10000` | 4840 |

3.9x という差が出るが、**その 3600 µs のうち 820 µs（23%）は key の走査**だと
分かった。batched API は command を 1 個にするだけでなく、
`get_atlas_draw_source` を **10,000 回から 1 回に**減らしている。
[dot-text-batching.md](./dot-text-batching.md) で「4.2x」と書いたときは
この内訳を持っていなかった（その 4.2x は 1 entry の fixture、つまり走査の分を
含まない条件での値である）。

## 出荷している側の量

| | |
|---|---|
| 毎フレーム走査する唯一の呼び出し元 | `hacknslash_3d` のアイコン atlas |
| その entry 数 | **30** |
| 1 フレームの描画回数 | 装備 3 枠 + インベントリ行（画面高で決まる、最大 25 程度）+ skill offer 数個。**しかもインベントリ／skill パネルを開いている間だけ** |
| 1 フレームのコスト | 30 回 × 82 ns = **2.5 µs**（16.67 ms の 0.015%）|

他の per-quad atlas 利用（`animation2d/draw.mbt`、`fetch_image`、smoke 2 本）も薄い。

**大きな atlas を作りうる API は `@animation2d.register_sprite_sheet`（cols × rows）
だけで、これも自分の whitebox test 以外から呼ばれていない。**

## tilemap 側は呼ばれていない

`resolve_tile_atlas_key` は tile ごとに `table.entries` を走査し、その直後に
`resolve_tile_quad` が `get_atlas_draw_source` も呼ぶ —— tile あたり
**2 本の走査**で、画面の広さに比例する。40×23 tile の chunk を 64 entry の
tileset と atlas で描けば 1 フレーム約 118,000 回の比較になる。

**ところがこの経路には出荷している呼び出し元が無い。**
`collect_chunk_tile_quads` と `append_atlas_tilemap_draw_commands` /
`append_tile_indexed_*`（4 本）を grep すると、`game/tilemap2d/contracts_wbtest.mbt`
しか出てこない。example もゲームも通らない。

atlas batch builder が呼ばれていなかったのと同じ形である。**索引の前に
「誰が呼ぶか」を数えないと、動かないコードを速くする。**

## 入れた変更

- `bench_particle_repo` に `entries~` を足し、既定を 30 に（**1 entry の fixture は
  測定したいコストを消していた**）
- `particles/atlas_lookup_{1,8,30,128}x1000`: 傾きが読める size sweep
- `particles/pipeline_same_state_10000_atlas1`: 30 entry 版と対にして、
  **パイプラインの中での**走査の値段を常設の数字にした
- `scripts/bench-baseline.json` を貼り直した。`particles/pipeline_*` が
  **遅くなっているのは fixture が正直になったから**で、regression ではない

索引そのものは入れていない。`get_atlas_draw_source` も `resolve_tile_atlas_key` も
1 行も変えていない。

## いつ薄くなくなるか

この判断は現状の量に紐づいているので、条件を書いておく。次のどちらかが起きたら
測り直す価値がある（bench はそのために置いてある）:

1. **atlas の entry 数が 100 を超える。** packed sprite sheet
   （`register_sprite_sheet`）を実際に使い始めると簡単に届く。128 entry で
   1 回 411 ns、per-quad 描画が数百あれば 1 フレーム 0.1 ms 級になる
2. **tilemap の描画経路が出荷される。** tile あたり走査 2 本なので、
   上の 118,000 回が現実になる。そのときは
   `physics-id-lookup.md` の `BodyIndex` と同じ形（32bit hash の open addressing、
   lazy な `ensure`）がそのまま当てはまる ——
   ただし key が String なので hash は `AssetKey` 側に持たせることになる

## 残っている作業項目

1. **`tilemap2d` の描画 API 5 本に出荷している呼び出し元が無い。** 性能以前に、
   使われていない API が 5 本あるという事実の方が重要である。使うのか畳むのかは
   設計判断なので触っていない
2. `get_atlas_draw_source` は **early exit が無く、最後に一致したものを返す**
   （last-wins）。重複 key を許す仕様なのか偶然なのかはコードから読めない。
   索引を入れるときはここを決める必要がある（`BodyIndex` では
   scan の first-wins を保存した）
