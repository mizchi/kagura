# phase の境界に残っていたコスト

- Date: 2026-09-11
- Scope: `engine/physics/physics2d`, `engine/physics/physics3d`,
  `engine/physics/collision3d`, `scripts/bench-gate*`
- 前提: [physics-benchmarks.md](./physics-benchmarks.md)（bench の設計）、
  [physics3d-optimization.md](./physics3d-optimization.md)（1 周目）、
  [physics-followups.md](./physics-followups.md)（2 周目）
- 対象: physics-followups.md に残した作業項目 2 / 3 / 4（の一部）/ 6 / 7

## Conclusion

2 周目で phase の**中**の割り当ては潰した。残っていたのは phase の**境界**だった。

- solve pass は呼ばれるたびに velocity buffer を load して store していた。substep が 4 なら
  frame あたり load 4 回 + store 4 回で、その間 `phase_integrate_velocities` は
  「重力を足した結果を入れる」ためだけに body struct を substep ごとに作り直していた
- broadphase は pair ごとに tuple を割り当て、次の phase が次の行でそれを分解していた
- 2D の sleep phase は island 表を毎フレーム `Map` で作り、**動いているシーンでも**
  union-find を全部回していた（3D は 1 周目から fast path を持っていた）

そして**3 つ目の「割り当てを消す」の境界**が出た。1 周目は「flat な `Array[Double]` に
移すと効く」、2 周目は「広い struct に潰すと逆効果」。今回は
**割り当てを 1 個も落とさない phase を flat 配列読みに移すと遅くなる** ——
`Array[Double]` の添字は境界チェック付きで、無料ではない。

`step_pile_256`、merge base と**交互 6 回**の中央値:

| | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| **physics2d** | 1.20 ms | **864 µs** | **1.38x** | yes |
| physics3d | 2.97 ms | 2.64 ms | 1.125x | no |

2D の方が大きいのは、2D が**この 3 つ全部**を受け取ったから（3D は 1 周目から sleep の
fast path を持っていた）。2D の他のサイズと fixture:

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `step_scatter_1024`（contact 0） | 2.44 ms | 1.71 ms | **1.43x** | yes |
| `step_pile_64` | 247.7 µs | 176.6 µs | 1.40x | yes |
| `step_pile_1024` | 5.38 ms | 4.37 ms | 1.23x | yes |
| `step_rope_256` | 885.9 µs | 716.4 µs | 1.24x | yes |
| `step_hinge_256` | 851.9 µs | 732.6 µs | 1.16x | yes |

3D は phase 単位では大きいが step では noise に埋まる。**分離したのは cumulative prefix と
joint chain の方**:

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `substep_integrate_velocities` | 40.7 µs | 11.0 µs | **3.70x** | yes |
| `substep_solve_velocities`（累積） | 144.0 µs | 84.4 µs | **1.71x** | yes |
| `substep_integrate_positions`（= 1 substep 全体） | 198.7 µs | 159.6 µs | 1.245x | yes |
| `step_ball_chain_256` | 1.70 ms | 1.42 ms | 1.20x | yes |
| `step_scatter_1024` | 2.99 ms | 2.76 ms | 1.083x | yes |
| `step_pile_256` | 2.97 ms | 2.64 ms | 1.125x | no |
| `step_pile_1024` | 11.13 ms | 11.50 ms | 0.968x | no |

**3 回交互では `step_pile_1024` が「1.10x 遅い、分離」と読めた**（base 10.70〜11.21 対
branch 11.34〜12.31）。6 回にすると帯が重なって 0.968x / 非分離になった。2 周目に
「3 回で分離と読めたものが 5 回で 1 つの帯に収まる」と書いたのと同じことが、今度は
**遅い側**で起きた。触っていないモジュール（`ecs/` `draw3d/` `atlas_quad/` など 12 本）は
1.007〜1.101x で**どれも非分離**なので、leg に系統的な偏りは無い。

## 1. velocity buffer を substep loop 全体に広げた（3D / 2D）

2 周目で solve pass を flat 配列に移したとき、**load と store は phase の中に置いたまま**
だった。だから:

```
substep ごとに:
  integrate_velocities : body を読み、新しい body struct を書く（velocity のため）
  solve_velocities     : body → buffer に load、解く、buffer → body に store
  integrate_positions  : body を読み、新しい body struct を書く（position と rotation）
```

256 体 pile の 4 substep で、load 4 回 store 4 回、`RigidBody` の再構築 1024 回
（それぞれ `Vec3` 4〜5 個を連れている）。数字を 2 つの場所の間で写すためだけの仕事である。

`step` が loop の**前で 1 回 load、後で 1 回 store**し、間の 3 phase はすべて buffer を
直接読み書きする形にした。

**順序が load-bearing:**

- `phase_contact_constraints` と joint の precompute は restitution と bias のために
  body の velocity を読む。だから load は**その後**（その時点では body と buffer は
  bit 一致している）
- `phase_update_sleep` は body の velocity を読む。だから store は**その前**
- `ccd_sweep_body3d` / `ccd_sweep_body` は buffer を引数で受ける。substep の途中では
  body 側の velocity は 1 substep 古く、sweep が要るのは今の substep の速度

## 2. isolated phase の符号だけ見ると逆の結論が出る

同じ 1 つの変更で、隣り合う 2 つの phase が**逆方向に動いた**。

| phase | 何が起きたか |
|---|---|
| `phase_integrate_velocities` | body struct の再構築が丸ごと消える → 大幅に速い |
| `phase_integrate_positions` | position と angle を書くので**再構築は残る**。`Vec3` 1 個を配列読み 6 回と交換しただけ → 遅い |

`Array[Double]` の添字は境界チェック付きなので、割り当てを落とさない phase では
コストが増えるだけになる。判断は substep 全体（`substep_` の累積 prefix）で行う。

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| 3D `phase_integrate_velocities` | 38.0 µs | 8.8 µs | **4.31x** | yes |
| 3D `phase_integrate_positions` | 52.3 µs | 63.7 µs | **0.822x** | yes |
| 3D `substep_integrate_positions`（両方を含む累積） | 198.7 µs | 159.6 µs | 1.245x | yes |
| 2D `phase_integrate_velocities` | 24.1 µs | 6.0 µs | **4.04x** | yes |
| 2D `phase_integrate_positions` | 23.5 µs | 25.6 µs | 0.919x | no |

isolated な phase bench には `vel.load` が入っている（phase が buffer を要求するのに
`moon bench` に iteration ごとの setup hook が無い）。その load は
`phase_reset_bodies_constraints_velocity_pile_256` が単独で値付けしていて、3D で
**6.85 µs 対 2.66 µs = 4.2 µs**。つまり `phase_integrate_velocities` の実体は
約 4.8 µs 対 38.0 µs、`phase_integrate_positions` の実体は 59.5 µs 対 52.3 µs。

## 3. broadphase を割ったら insert が重かった

`phase_broadphase_pile_256` を「grid を埋めるまで」と「pair を数え上げる」に分けるため、
`phase_broadphase_insert_pile_256`（`clear` + body ごとに `insert`）を足した。

| | grid を埋める | phase 全体 | insert の割合 |
|---|---:|---:|---:|
| physics3d | 299〜307 µs | 459〜484 µs | **約 64%** |
| physics2d | 100〜106 µs | 188〜201 µs | 約 52% |

body 1 個が最大 8 cell にまたがるので、256 体で `find_or_create_cell`（hash + 線形探索）と
push がそれぞれ 2048 回走る。**pair の数え上げ（min-corner mask trick 込み）はその半分以下。**
つまり pair tuple の除去は、broadphase の中でも軽い側の一部分を削る話だった。

## 4. pair tuple を落とした（`get_pairs_into`）

grid が持つ pooled な 2 列（`pair_id_a` / `pair_id_b`）に書いて count を返す
`get_pairs_into` を足した。`get_pairs` はその上に tuple を積む wrapper として残し、
step の経路は前者を使う。emit する pair とその順序は変わらない。

同じループで 1 つ無料の修正もした: `self.entries[bucket[i]]` が **`j` ループの中**にあった
ので `i` ごと 1 回に引き上げ、AABB テストが通る前に計算していた min/max も後ろに回した。

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| 2D `phase_broadphase_pile_256` | 216.5 µs | 194.9 µs | 1.11x | yes |
| 3D `phase_broadphase_pile_256` | 494.0 µs | 466.9 µs | 1.058x | no |

2D で 22 µs、3D で 27 µs。**frame 比では 2D 2.5%、3D 1.0%** で、2 周目に「薄い」と
書いたとおりの大きさだった。tuple は 2D 697 個 / 3D 1438 個で、1 個あたり 30〜19 ns。

## 5. 2D の sleep phase（3D の実装を移植）

2D だけ `Map[Int, Bool]` を毎フレーム作り、しかも**動いているシーンでも** union-find を
回していた。3D の形に揃えた:

- island 表を `Array[Bool]`（添字は island root = body index）に。root でない添字は
  誰も読まず、dynamic body は自分の root を必ず書いてから読むので初期値 `true` で
  `None` 分岐と等価
- **寝ている body も寝かけの body も無ければ union-find ごと飛ばす。** 候補が無ければ
  どの island も `false` になり、寝ている body が無ければ apply loop は何も書かない
  ので、飛ばしても結果は同じ

sleep 判定そのもの（`|v| < 0.5` と `|w| < 0.2` の 2 閾値）は**触っていない**。3D で
入れた `|v| + max_extent * |w|` に揃えると挙動が変わり、gating な frame VRT の貼り直しに
なる。これは follow-up に残す。

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| 2D `phase_sleep_islands_pile_256` | 84.9 µs | 20.3 µs | **4.19x** | yes |
| 3D `phase_sleep_islands_pile_256`（参考、変更なし） | 20.2 µs | 19.6 µs | 1.03x | no |

2 周目に「2D 88 µs 対 3D 20 µs の 4.5 倍差」と書いた差は**消えて 20.3 対 19.6 µs**に
なった。`step_scatter_1024`（contact 0、pile ではない）が 1.43x 速いのは主にこれで、
動いているシーンで毎フレーム回っていた union-find + `Map` が丸ごと消えた分である。

## 6. 2D の relax pass を 3D と同じ形にした

`_solve_relaxation2d` は `_` 接頭辞で warning を抑えられた未接続の関数で、しかも
2 周目より前の AoS solver の形（body struct を書き、constraint struct を作り直す）で
取り残されていた。**削除して**、3D と同じ `use_bias` スイッチにした:

- `solve_constraint2d` / `solve_distance_joint` / `solve_revolute_joint` が `use_bias` を取る
- `SolverConfig2D::relax_iterations`（既定 0）。0 なら経路も数値も従来どおり
- softness 抜きの effective mass は**保存せず、relax 分岐の中で計算する**。3D は
  constraint に持たせているが、2D は既定オフの機能のために既定経路の struct を
  広げないことにした（保存しても計測差は無かった。下記 8）

3D の実測では relax pass は残留運動を半減させるが、それだけでは pile は寝ない
（[physics-followups.md](./physics-followups.md) の 1）。だから既定は 0 のままで、
「2D にも同じ実装がある」ことだけを揃えた。

## 7. bench-gate を中央値にした

`scripts/bench-gate.mjs` は 1 回の run を baseline に記録し、1 回の run と比べていた。
2 周目で見つけたとおり `ecs/spawn_10000` は同じコードで 1.55x 揺れるので、
**閾値 1.5x と区別できない**。

- `--runs N` で N 回回して bench ごとの**中央値**を取る
- baseline に `runs` と bench ごとの `spread`（中央値が何倍の幅で揺れたか）を記録する
  （schema version 2。version 1 と legacy flat も読める）
- **自分の幅が閾値より広い bench は判定できない**ので、`REGRESSION` ではなく `NOISY` として
  幅を添えて報告し、落とさない。閾値より狭い bench は従来どおり落とす
- `just bench-update` は既定で 3 回の中央値を記録する

ノイズで落ちるゲートは全員に無視されるようになり、黙って通るゲートは本物の regression を
隠す。どちらでもない third option がこれ: **測れないことを測れないと言う。**

## 8. 説明できていない 2.5 µs（`phase_save_contact_cache_pile_256`）

2D のこの bench だけ **23.0 → 25.5 µs（0.90x）で分離している**。`phase_save_contact_cache`
自体はこの PR で 1 行も変えていない。仮説を 2 つ立てて、**どちらも実測で外れた**:

| 仮説 | 検証 | 結果 |
|---|---|---|
| `ContactConstraint2D` に足したフィールドで struct が 13 → 14 になったから | フィールドを外して 3 回計測 | **外れ**。25.11 / 25.22 / 25.54 µs（足したまま: 25.19〜25.87）|
| この PR で追加した bench 2 本が同じプロセス内の後続 bench の heap / JIT 状態を変えたから | 追加分を無効化して 3 回計測 | **外れ**。25.33 / 25.60 / 26.38 µs |

入力も同じであることを確認した（両 tree で pair 697 / contact 456 / constraint 456）。
フィールドを外した今、`ContactConstraint2D` の形は merge base と完全に同一で、
それでも 25 µs 側に留まる。**原因未特定。** frame 比 0.3%（864 µs のうち）で、
この phase を含む `step_pile_256` は 1.38x 速いので、探索はここで止めて記録に回す。

外したフィールドは戻していない ── 戻す理由が「計測で速い」ではなくなったので、
既定オフの機能のために既定経路の struct を広げない方を選んだ。

## 検証

- **fingerprint。** 3D は fixture 6 個 × 50 フレーム、body ごとに position / velocity /
  angular velocity / quaternion / sleep 状態 / timer と contact cache の長さ（4861 行）。
  2D は同じ形で 4841 行。どちらも merge base とバイト一致
- **frame VRT。** `physics2d_demo` は gating な frame VRT に入っているので、2D は
  double が 1 bit 変われば描画バイトが変わる。`vlmkit` がこのコンテナに無いので
  `scripts/frame-vrt.mjs` は 17 枚描いてから diff 段で落ちる。描いた PNG を `cmp` で
  committed baseline と比べ、**17/17 がバイト一致**（`--threshold 0` より厳しい）。
  実ゲートは CI が回す
- **test。** workspace の 1237 test が通る（js）。native は physics2d 66 / physics3d 37 を
  個別に通す（`gfx_wgpu_native` がこのコンテナで `GL/gl.h` を要求するため全体は回せない）

## 残っている作業項目

1. **broadphase の insert が 3D で phase の 64%**（300 µs、frame の 11%）。body 1 個が
   最大 8 cell にまたがり、cell ごとに hash + 線形探索 + push を払う。削るなら
   (a) `insert` に `AABB` ではなく 6 個の `Double` を渡して `world_aabb()` の割り当てを
   消す、(b) `BroadphaseEntry` を flat 列にする、(c) cell あたりの走査を減らす形に
   変える（pair 順が変わるので bit 一致は崩れる）。**次に手を付けるならここ**
2. **`phase_save_contact_cache` の 2.5 µs が未説明**（上記 8）
3. **2D の sleep 判定を 3D と揃える**（未着手）。今は 2D だけ 2 閾値のまま。揃えると
   挙動が変わり、gating な frame VRT の貼り直しになる。3D では同じ変更が「寝ている
   シーンが 1.75x 安くなる」と「resting シーンの y 速度の総和 +2008 というバグが直る」を
   同時に持ってきたので、2D にも同じ利得があるはず
4. **256 球 pile はまだ寝ない**（relax 2 回で閾値超えが 1 体）。island sleep が全員一致を
   要求する以上、閾値か relax 回数のチューニング
5. **2D narrowphase の 3-tuple**（contact ごと、256 体 pile で 456 個）。pair tuple と
   同じ形で列にできるが、上の実測から期待値は frame の 1〜2% 程度
6. **`just bench-gate` は CI で回っていない**（持ち越し）。記録側は中央値になったので、
   あとは runner を固定するかどうかの判断
7. **3D `phase_contact_constraints` は依然 3D 最大**（710 µs、frame の 27%）。2 周目の
   実測（AoS のまま潰すと 0.83x）から、やるなら pooled SoA 列しかない
