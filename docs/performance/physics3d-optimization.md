# 3D 物理エンジンの最適化

- Date: 2026-09-10
- Scope: `engine/physics/collision3d`, `engine/physics/physics3d`
- 前提: [physics-benchmarks.md](./physics-benchmarks.md) の bench で計測している
- 結果: **`step_pile_256` が 4.72 ms → 1.90 ms（2.48x）**。挙動は bit 一致

## Conclusion

- **JS ターゲットでは `Int64` を hot path の Map key にしてはいけない。** MoonBit は
  `Int64` を `BigInt` にコンパイルする。生成 JS を読むと、broadphase の cell key 1 個を
  作るのに `BigInt` 割り当てが 6 回、それを hash するのに 8 回。256 体 pile では
  衝突判定を 1 回もする前に毎フレーム数万回の `BigInt` 割り当てが走っていた
- **immutable struct も JS では heap object。** `RigidBody` と `@math3d.Vec3` はどちらも
  immutable なので、「2 体読んでベクトル演算して 2 体書く」という素直な Gauss-Seidel は
  constraint ごとに struct 2 個 + `Vec3` 約 14 個を割り当てる。実測で solve pass は
  **frame の 53%** を占めていた
- **支配項は broadphase ではなく solve pass だった。** 前回の doc は「3D は broadphase +
  narrowphase 律速」と結論していたが、これは phase bench を信じた結果で誤りだった（下記）
- **phase bench が solve を 5x 過小評価していた。** reset 直後の body 状態で測ると
  impulse 書き込みがガードに落ちて割り当てが起きない。allocation-bound なループの
  「安い分岐」を測っていた
- native でも同じだけ速くなった（`step_pile_256` 2.07x、`step_pile_1024` 2.32x）。
  `Int64` が無料の native でも broadphase が 1.86x 速いのは、Map そのものと
  cell ごとの配列割り当ても消えたから。**BigInt は最大の一因だが唯一ではない**

## 調べたこと

| 出典 | 採ったもの / 採らなかった理由 |
|---|---|
| [Box2D v3 (Soft Step)](https://box2d.org/posts/2024/08/releasing-box2d-3.0/) | v2.4 比 2x 超の主因は **data-oriented design と SIMD**。velocity state を flat SoA (`b2BodyState`) に置く形をそのまま採った |
| [Solver2D](https://box2d.org/posts/2024/02/solver2d/) | TGS Soft = substepping + soft constraint + **relaxation pass**。soft constraint と substepping は既に入っている。relax pass は未実装（下記 follow-up） |
| [Box3D](https://box2d.org/posts/2026/06/announcing-box3d/) | 「wide SIMD contact solver」「graph coloring for large islands」「dynamic BVH broadphase」。SIMD と多スレッドは MoonBit にまだ無い。BVH は下記の理由で採らなかった |
| [BVH vs spatial hash の比較研究](https://www.sciencedirect.com/science/article/pii/S1524070323000103) | 動的剛体では BVH が優位（refit が O(log n)、空間分布に適応）。ただし **pair の出力順が変わる** ので solver の出力が変わる。今回は「bit 一致を保ったまま速くする」を条件にしたので範囲外 |
| [DOD vs OOP のベンチ](https://arxiv.org/pdf/2512.07841) と JS ECS の実測 | flat な primitive 配列は cache locality と SIMD の両方に効く。**GC 言語ではそれ以前に「割り当てが消える」ことが本体** |

BVH と SIMD と多スレッドを外すと、残るのは data-oriented design だけになる。
そしてこのコードベースではそれが 2.5x あった。

## 入れた変更（4 つ、それぞれ独立に計測）

### 1. broadphase の cell table（`collision3d/broadphase.mbt`）

`Map[Int64, Array[Int]]` を、32bit `Int` hash の open addressing テーブル + 並列配列に
置き換えた。

- cell 座標は**パックせず保存して比較する**ので、`Int64` key が持っていた ±1M cell の
  範囲がそのまま残る（3 軸を 1 個の `Int` に詰めると 1 軸 10bit しか取れない）
- cell は **first-touch 順**に並ぶ。MoonBit の `Map` は挿入順の linked list を持ち
  `each` はその順で回るので、`cell_count` の添字ループが**同じ pair 列**を出す。
  pair 順は solver の結果に影響するのでここは load-bearing
- cell 配列と bucket、`get_pairs` の mask バッファは `clear()` を跨いで pool する。
  `clear()` は毎フレーム走るので、body 数が落ち着けば割り当てゼロになる

### 2. contact cache（`physics3d/contact_cache.mbt`）

`Map[Int64, ContactManifold3D]` を、body id ペアで引く flat な SoA テーブルにした。

`Int64` key の話に加えて、**読まれないものを書いていた**。manifold の `local_a` /
`local_b` / `penetration` は毎フレーム全 contact 分書かれて誰も読まない。
前 2 者を作る `Vec3::sub` 2 回は完全な無駄だった。warm start が読むのは normal と
accumulated impulse 2 個だけなので、列はそれだけにした。

`ContactManifold3D` / `ManifoldPoint3D` は他に produce/consume する関数が無かったので
削除した（**破壊的変更**、下記）。

### 3. solve pass の velocity を flat 配列へ（`physics3d/velocity_state.mbt`）

solve pass の間だけ velocity を `Array[Double]` × 6 に移し、終わったら書き戻す。
constraint ループは**割り当てゼロ**になる。

ベクトル式は手で展開した。**グルーピングは load-bearing** で、
`n.scale(j).scale(inv_mass)` は `(n.x * j) * inv_mass`、
`r.scale(j * inv_inertia)` は `r.x * (j * inv_inertia)` になる。各サイトの
括弧を保存することが「だいたい同じ」ではなく「bit 一致」の条件。

position と rotation は body に残した。`phase_integrate_positions` は CCD sweep に
body 全体が必要で、どちらも solve pass 中は変わらない。

書き戻しは**変化した body だけ**にした。AoS 版は impulse を出した constraint の
両側を（static 側も、成分が変わっていない側も）書き直していたが、同じ値の struct を
作り直すのは観測できないので、比較して飛ばすのは等価。寝ているシーンではほぼ全部飛ぶ。

joint solver 2 本も同じ buffer を取る。contact と solve pass を共有しているので、
working set も共有しなければ順序が壊れる。**コピーを作らない**ためにシグネチャを
変えた（破壊的変更）。

### 4. `precompute_constraint3d` の一時 `Vec3` を消した

`v_rel` と tangent 方向はどちらも純粋な一時オブジェクトで、`tangent` だけが
残る。contact ごとに 5〜6 個の `Vec3` を作って捨てていた。

これは 256 体では noise に埋もれる（1.02x）が、**1024 体では 3 回とも一貫して
1.17x**（scalar 8.11/8.37/9.12 ms 対 vec3 9.97/9.28/9.78 ms、全試行で分離）。
contact が 4 倍あって GC 閾値を越えるので、そこで差が出る。

## 実測

`moon bench --target js -p mizchi/physics/physics3d`、同一マシンで main と branch を
**交互に 3 回**回した中央値。ペア測定にしたのは、このコンテナの run 間分散が
`phase_contact_constraints` で ±25% あり、単発では 1.2x 程度の差が読めないため。

| bench | main | branch | 倍率 |
|---|---:|---:|---:|
| `step_pile_64` | 979 µs | 419 µs | **2.34x** |
| `step_pile_256` | 4.72 ms | 1.90 ms | **2.48x** |
| `step_pile_1024` | 20.46 ms | 9.66 ms | **2.12x** |
| `step_scatter_1024` | 3.56 ms | 1.81 ms | 1.97x |
| `step_resting_256` | 2.03 ms | 863 µs | **2.35x** |
| `step_rope_256` | 965 µs | 670 µs | 1.44x |
| `step_ball_chain_256` | 1.46 ms | 928 µs | 1.57x |
| `phase_broadphase_pile_256` | 739 µs | 303 µs | **2.44x** |
| `phase_contact_constraints_pile_256` | 772 µs | 561 µs | 1.38x |
| `phase_solve_velocities_pile_256` | 79 µs | 45 µs | 1.79x |
| `phase_save_contact_cache_pile_256` | 176 µs | 19 µs | **9.47x** |
| `phase_sleep_islands_resting_256` | 34 µs | 25 µs | 1.36x |
| `build_pile_1024` | 79 µs | 72 µs | 1.10x |

joint 系（rope / ball_chain）の伸びが小さいのは、contact が少なく solve pass の
割り当てが元から小さいから。`build_` が動かないのは構築を触っていないから。
どちらも「効くはずのところだけ効いている」ことの確認になる。

### native

`MOON_CC=clang moon bench --target native`、2 回の中央値。

| bench | main | branch | 倍率 |
|---|---:|---:|---:|
| `step_pile_256` | 2.71 ms | 1.31 ms | **2.07x** |
| `step_pile_1024` | 15.66 ms | 6.75 ms | **2.32x** |
| `step_scatter_1024` | 1.72 ms | 1.06 ms | 1.62x |
| `phase_broadphase_pile_256` | 322 µs | 173 µs | 1.86x |
| `phase_save_contact_cache_pile_256` | 103 µs | 8.7 µs | **11.8x** |

native では `Int64` は本物の 64bit 整数なので `BigInt` の話は消える。それでも
broadphase が 1.86x、cache が 11.8x になるのは、**Map そのもの**と cell ごとの
配列割り当て、読まれない manifold フィールドが消えた分。JS 固有の最適化ではない。

## 挙動不変の確認

6 fixture（pile 64/256、scatter、resting、rope、ball_chain）を 50 フレーム回して、
全 body の position / velocity / angular velocity / rotation の重み付き総和、
sleeping 数、contact cache 長、pair 数を出す fingerprint を取り、**4 つの変更すべての
後で main と bit 一致**することを確認した。1237 test も通っている。

fingerprint は一時ファイルで、commit には含めていない。同じものを作るなら
`world.step` を回して `bodies[i]` の各成分に `(i+1)` を掛けて足すだけでよい
（順序依存を拾うために重みを付ける）。

## 測定の方法論として得たこと

### phase bench は reset 状態を測る。それは substep が見る状態ではない

`phase_integrate_velocities` / `phase_solve_velocities` /
`phase_integrate_positions` は「reset した body 状態」から 1 phase を回す。
substep loop はその状態を一度も見ない。重力で加速された直後の body を見る。

旧コードではこの差が致命的だった。velocity が収束近くにあると impulse 書き込みが
`> 1e-15` のガードに落ち、**書き込みを飛ばすことは struct 2 個と `Vec3` 12 個の
割り当てを飛ばすこと**を意味した。だから phase bench は allocation-bound なループの
安い分岐だけを測っていた。

| 測り方 | 旧コード | 新コード |
|---|---:|---:|
| `phase_solve_velocities_pile_256`（単独） | 77 µs | 46 µs |
| substeps=4 固定で `velocity_iterations` 1→2→4 の傾き | **394 µs** | 65 µs |
| 比 | **5.1x 過小評価** | 1.4x |

新コードで差が縮んだのは偶然ではない。flat 配列ではガードが飛ばすのは算術だけなので、
状態がコストをほとんど左右しなくなる。**乖離は noise ではなく、fixture が回避していた
割り当てそのものだった。**

対策として `substep_` prefix の bench を 3 本追加した。1 substep の
**累積 prefix** になっていて、隣同士の差が phase のコストになる。`moon bench` に
iteration ごとの setup hook が無いので、現実的な状態に到達するために必要な処理は
測定の中に入れるしかない ── ならば累積にして差を取るのが唯一正直な形。

`phase_` の 3 本はそのまま残した。低ノイズで床を引ける数字であり、`physics2d` と
比較できるのはこちら。ただし **substep のコストではない**。

### 傾きで測る

「この phase はいくらか」を isolated bench で答えられないとき、**設定を振って傾きを
取る**のが効いた。

- `substeps` を 1/2/4/8 に振る → 傾きが 1 substep、切片が 1 フレーム 1 回の phase 群
- `velocity_iterations` を 1/2/4 に振る → 傾きが constraint 全体 1 パス

どちらも出荷している `step` をそのまま回すので、コピーを測る危険がない。
ただし `substeps` を振ると `sub_dt` も変わり solver の挙動が変わるので、
これは **1 substep の純コストではない**（実測でも `substep_` 連鎖の 106 µs に対し
傾きは 213 µs で、2 倍の開きがある）。順位付けには使えるが、絶対値として引用しては
いけない。

### baseline を 1 台で撮り直した

`scripts/bench-baseline.json` は 2 回の記録が混ざっていた（`generatedAt` は
2026-05-23 のまま、physics の 38 entry だけ後から差し替え）。今回の変更を反映しようと
すると、触っていない physics2d や atlas の entry がこのマシンでは軒並み 0.4〜0.6x
（= このマシンが約 2 倍速い）と出て、機械差と実効果が混ざる。

baseline は 1 台で内部整合しているべきなので、**全 78 entry を 1 回の run で
撮り直した**。だから baseline の diff は「このマシンでの絶対値」であり、
**速くなった証拠は baseline の差分ではなく上のペア測定**である。

## 破壊的変更（`mizchi/physics`）

publish 済みパッケージの public API が 3 点変わる。いずれも `step` が内部で使う
solver の配線で、このリポジトリ内では physics3d の外から誰も触っていない。

1. `PhysicsWorld.contact_cache` の型が `Map[Int64, ContactManifold3D]` →
   `ContactCache3D`。`velocity_state : VelocityState3D` フィールドが増えた
2. `ContactManifold3D` / `ManifoldPoint3D` を削除（produce する関数も consume する
   関数も無くなったため）
3. `solve_distance_joint3d` / `solve_ball_joint3d` が `VelocityState3D` 引数を取る

`moon.mod` の version は上げていない。このリポジトリは全モジュールを揃えて
bump する（`scripts/publish.sh` の `MODULES` はトポロジカル順）ので、
**publish 時に major/minor を上げる判断が必要**。

## 残っている作業項目

1. **`phase_contact_constraints` が最大の phase になった**（561 µs、frame の約 29%）。
   内訳は narrowphase 52 µs / precompute + warm start 約 465 µs。つまり
   `precompute_constraint3d` が本体で、`ContactConstraintRuntime3D` は `Vec3` を
   8 個フィールドに持つので contact ごとに struct 1 + `Vec3` 5 個が残っている。
   **constraint 配列を SoA 列にすれば消える**が、solver / world / bench / wbtest に
   波及するので今回はやっていない
2. **`phase_integrate_velocities` / `phase_integrate_positions`** は substep ごとに
   body struct を作り直す（256 × 4 × 2 = 2048 回/frame）。velocity buffer を
   substep loop 全体に広げれば integrate_velocities の分は消える。CCD sweep が
   body の velocity を読むので、bullet body だけ書き戻す形になる
3. **`get_pairs` は pair ごとに tuple を割り当てる**（1438 個/frame）。並列 `Array[Int]`
   2 本に書き出す `get_pairs_into` を足せば消えるが、`get_pairs` の戻り値型は public
4. **relax pass が無い**。Box2D v3 の Soft Step は substep ごとに bias 無しで 2 周目を
   回して「bias が入れたエネルギー」を抜く。[physics-benchmarks.md](./physics-benchmarks.md)
   に記録した「密な pile が寝ない」はこれが原因である可能性が高い。**寝ないことは
   性能問題でもある**（寝ているシーンは `step_resting_256` が示すとおり半額以下）。
   ただしこれは挙動が変わる変更で、bit 一致では入れられない
5. **physics2d は手を付けていない。** 同じ `Int64` の問題があり、しかも 2D の
   `get_pairs` は候補 pair **ごと**に `Map[Int64, Unit]` へ dedupe insert する（3D は
   min-corner mask で dedupe するので cell あたり 0 回）。2D は frame VRT が gating
   なので、pair 順が変わる変更は baseline を貼り直すことになる
6. **`just bench-gate` は CI で回っていない**（前回からの持ち越し）。baseline が
   機械依存なので、入れるなら runner を固定する必要がある
