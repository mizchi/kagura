# physics の follow-up を検証した記録

- Date: 2026-09-10
- Scope: `engine/physics/physics2d`, `engine/physics/physics3d`, `engine/physics/experiments/simd`
- 前提: [physics-benchmarks.md](./physics-benchmarks.md)（bench の設計）と
  [physics3d-optimization.md](./physics3d-optimization.md)（3D の 1 周目）
- 対象: physics3d-optimization.md の末尾に残した作業項目 6 件と、relaxed SIMD

## Conclusion

**自分が書いた仮説のうち 3 つが実測で外れた。** 外れ方に価値があるので順に記録する。

| 記録していた仮説 | 実測 |
|---|---|
| 密な pile が寝ないのは relax pass が無いから | **外れ。** angular の sleep 閾値だけが原因だった。relax pass は寝ることに直接は寄与しない |
| pile が寝ない理由は「速度が閾値 0.5 に対し 1.0〜3.2 に留まる」 | **外れ。** 1200 フレームで linear 閾値を落ちる body は 256 体中 0〜1 体。落ちていたのは angular（164/256）|
| `phase_contact_constraints` が重いのは constraint の `Vec3` フィールド 8 個 | **外れ。** レイアウトを潰すと**逆に遅くなった**（0.83x）。重かったのは warm start の割り当て（phase の 56%）|

そして 3D の 1 周目で得た「割り当てを消す」は**万能ではない**。flat な
`Array[Double]` に移すときは効くが、**フィールド数の多い struct に移すと逆に遅くなる**。

物理エンジン全体の成果（同一マシン、main と交互 5 回の中央値、`step_pile_256`）:

| | 1 周目の前 | 1 周目の後 | 今回の後 |
|---|---:|---:|---:|
| physics3d | 4.72 ms | 1.90 ms | **1.55 ms 相当**（下記の内訳） |
| physics2d | — | 5.26 ms | **1.29 ms（4.08x）** |

physics2d は physics3d より**遅かった**（5.26 対 3.14 ms）。2D-first のエンジンで
逆になっていた。今は 2D が 1.25 ms、3D が 3.32 ms で正しい順序になった。

## 1. relax pass は「寝ない」の原因ではなかった（`SolverConfig3D::relax_iterations`）

Box2D v3 の Soft Step の relaxation half を実装した（substep ごとに bias・softness・
restitution を全部切って 2 周目を回す）。**既定 0 = 無効**にしたので既定経路は bit 一致。

実測（256 球 pile、1200 フレーム）:

| | quiet（両閾値を満たす body） | angular 閾値を落ちる body |
|---|---:|---:|
| relax なし | 92 / 256 | 164 |
| relax 1 回 | **193 / 256** | 63 |
| relax 2 回 | 192 / 256 | 64 |

relax pass は残留運動を確かに半減させる。しかし **sleeping は 0/256 のまま**だった。
つまり寝ないことの原因は別にある。substep ごとに solve pass が丸ごと 1 回増える
（+14% 程度）ので、既定では無効にしてある。

## 2. 原因は angular の sleep 閾値だった

sleep の条件は `|v| < 0.5` と `|w| < 0.2` の 2 つの独立した判定だった。1200 フレーム時点で
**linear を落ちる body は 0〜1 体、angular を落ちる body は 164 体**。

2 つの閾値は**単位が違うので比較できず、厳しい方が黙って全部決める**。しかも
「ある回転が速いかどうか」は body の大きさに依存するので、rad/s の 1 つの数字では
玉と箱に同時に合わせられない。実測でこの pile の 0.5 半径の球では、0.2 rad/s は
表面速度 0.1 units/s に相当し、隣に並んでいる linear 閾値 0.5 の **5 倍厳しい**。

Box2D v3 が判定している量に置き換えた:

```
sleep_velocity = |v| + max_extent * |w|
```

これで 64 球 pile は**完全に寝る**（従来は 0/64）。256 球は relax 2 回で
閾値を超える body が 1 体だけになるが、island sleep は全員一致が条件なので寝ない。
**1/256 が 256 体を起こしている**。これは island sleep の性質で、Box2D も同じ。

## 3. 寝てもすぐ起きていた（warm start が寝ている body を叩いていた）

閾値を直したら 64 球 pile は frame 446 で寝た。だが **1200 フレームで 22 回起きた**。

warm start と `solve_constraint3d` は constraint が指す body に velocity を書き込み、
どちらも `is_sleeping` を見ていなかった。寝た瞬間に自分の cache 済み impulse で
再加速されていた。

**両側とも動かせない constraint を丸ごと飛ばす**ようにした（static/static、
static/寝ている、寝ている/寝ている）。

| | wake events / 1200 | 寝ていたフレーム数 |
|---|---:|---:|
| 前 | 22 | 83 / 1200 |
| 後 | **0** | **754 / 1200**（relax 1 回で 1034）|

副作用として**観測可能なバグが直った**。従来コードでは「完全に寝ている」resting
シーンの y 速度の総和が **+2008** あった。warm start が与えた velocity で、
integrator は寝ている body を無視するので位置には出ないが、`body.velocity` を
読む側（ゲームロジック、描画、音）には見えていた。今は厳密に 0。

そして寝ているシーンが**本当に安くなった**（contact を作らないので）:

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `step_resting_256` | 1.48 ms | 845 µs | **1.75x** | yes |
| `phase_sleep_islands_resting_256` | 59.7 µs | 33.0 µs | 1.81x | yes |
| 起きている pile / 全 phase | | | 1.0x 前後 | no（noise）|

## 4. constraint のレイアウトは犯人ではなかった（変更を差し戻した）

`ContactConstraintRuntime3D` の `Vec3` フィールド 7 個を `Double` 21 個に潰した。
contact あたり 8 個の割り当てのうち 7 個が消え、bit 一致。**それで遅くなった。**

| bench | Vec3 フィールド | scalar フィールド | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `phase_contact_constraints_pile_256` | 954 µs | 1.15 ms | **0.83x** | yes |
| `step_pile_256` | 3.62 ms | 4.00 ms | 0.91x | yes |

5 回交互で完全に分離している。34 フィールドの object は、20 フィールドの object +
3 フィールドの object 7 個より V8 では高いらしい（後者は nursery が最も得意な形）。

**これは 1 周目の「割り当てを消す」という経験則の反例**であり、経験則の適用範囲を
決める: 割り当てを **flat な `Array[Double]` に移すと効く**が、**より広い struct に
移すと効かない**。差し戻した。

## 5. 犯人は warm start だった（3D 1.30x / 2D はさらに大きい）

同じ pair・同じ narrowphase・同じ precompute で、cache が warm な場合と空の場合を測った:

| | 時間 |
|---|---:|
| constraints、warm cache | 918 µs |
| constraints、空 cache | 397 µs |
| cache clear だけ（床） | 3.6 µs |

**warm start が 517 µs、phase の 56%、frame の約 14%。** ベクトル 1 本を 2 つの velocity に
足すために、cached contact ごとに struct 3 個と `Vec3` 7 個を作っていた
（`{ ..constraint, acc_jn, acc_jt }` が、`precompute_constraint3d` が返したばかりの
~30 フィールドの object を作り直していた）。

`acc_jn` / `acc_jt` は唯一の `mut` フィールドなので in-place 代入にし、impulse を
スカラーに展開した。struct 3 + `Vec3` 7 → struct 2 + `Vec3` 2。

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `phase_contact_constraints_pile_256` | 1.00 ms | 769 µs | **1.30x** | yes |
| `step_pile_1024` | 16.96 ms | 15.19 ms | 1.12x | yes |
| `step_pile_256` | 3.67 ms | 3.14 ms | 1.17x | no |

## 6. physics2d に一式移植した（4.08x）

2D は 3D と同じ問題を全部持っていて、いくつかはより悪かった。

**solve pass**: `solve_constraint2d` は body struct を 4 個書き（normal で 2、friction で
2）、既に `mut` な accumulator を入れるために constraint struct を作り直し、途中で
`Vec2` を 18 個ほど heap に置いていた ── **constraint × iteration あたり約 23 個**。
1900 contact × 4 substep で **frame あたり 17 万回**。だから 2D の step の 48% を
占めていた（3D は 12%）。

**broadphase**: cell が `Map[Int64, Array[Int]]` なのは 3D と同じだが、`get_pairs` が
**cell 内の候補 pair ごとに** `Map[Int64, Unit]` へ insert していた（3D は
min-corner mask で dedupe するので cell あたり 0 回）。

**contact cache**: `Map[Int64, ContactManifold2D]` で、しかも毎フレーム
**2 個目の Map を作って 1 個目にコピー**していた。contact あたり key 構築 2 回、
hash 2 回、insert 2 回。

| bench | 移植前 | 移植後 | 倍率 |
|---|---:|---:|---:|
| `step_pile_256` | 5.26 ms | **1.29 ms** | **4.08x** |
| `step_pile_1024` | 26.09 ms | 5.91 ms | 4.41x |
| `step_pile_64` | 1.00 ms | 264 µs | 3.79x |
| `step_resting_256` | 2.41 ms | 656 µs | 3.67x |
| `phase_solve_velocities_pile_256` | 502.8 µs | 27.3 µs | **18.4x** |
| `phase_save_contact_cache_pile_256` | 284.9 µs | 23.9 µs | **11.9x** |
| `phase_broadphase_pile_256` | 965.2 µs | 222.7 µs | **4.33x** |
| `phase_contact_constraints_pile_256` | 523.8 µs | 158.4 µs | 3.31x |

**2D はすべて bit 一致でなければならない。** `physics2d_demo` が gating な frame VRT に
入っているので、double が 1 bit 変われば描画バイトが変わる。2 通りで確認した:
fixture 8 個 × 50 フレームの fingerprint（pair 数と cache 長も含む）と、
**frame VRT の 17 フレームが committed baseline とバイト一致**すること
（`cmp` は `vlmkit diff png --threshold 0` より厳しい）。

なお 3D の min-corner mask trick は 2D に移植して**いない**。pair を emit する cell が
変わるので pair 順が変わり、bit 一致でなくなる。3D の sleep 判定の変更も 2D には
入れていない（同じ理由）。

## 7. relaxed SIMD は効かなかった

`engine/physics/experiments/simd/` に leaf kernel を作って測った。詳細は
そこの README。要点だけ:

| constraints | JS | wasm scalar | wasm simd | wasm relaxed | simd/scalar | relaxed/simd |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 1.48 | 1.29 | 1.51 | 1.58 | **0.85x** | 0.95x |
| 256 | 4.95 | 3.16 | 3.43 | 3.56 | **0.92x** | 0.96x |
| 688 | 13.22 | 10.46 | 9.50 | 10.01 | 1.10x | 0.95x |
| 2048 | 47.87 | 34.72 | 28.05 | 26.74 | 1.24x | 1.05x |

- **`f64x2.relaxed_madd` は現実的なサイズで速くならない**（0.95〜1.05x）。この kernel は
  constraint あたり 30 数個の演算のうち multiply-add が 6 個で、律速は lane ごとの
  gather/scatter と直列依存。relaxed SIMD は律速でない部分を狙っている
- **strict SIMD も 500 constraint 未満では損**。`f64x2` は 2 lane しかなく、
  constraint の 2 body は任意の index なので lane を 1 個ずつ埋めるしかない
- **そもそも wasm に移すこと自体（1.15〜1.57x）が SIMD の上乗せ（1.1〜1.24x）より大きい**

そして 3 つの障壁がある。いずれも実測:

1. **データが linear memory に無く、wasm-gc では原理的に置けない**。1 フレーム分の
   solver state を element-wise に出し入れすると **12.9 µs**。688 constraint で SIMD が
   返すのは 3.8 µs なので、**境界のコストが 3 倍以上**。iron_yard の MVP 実験が測った
   逆転と同じ
2. **Gauss-Seidel は直列依存**。2 constraint が lane を共有できるのは 4 body が全部
   別のときだけで、そうでなければ group 内で Jacobi に化けて挙動が変わる。この実験の
   fixture は**あらかじめ着色してある**ので、上の数字は「constraint graph coloring が
   既にある」前提の上限値
3. **relaxed SIMD は再現しない**。`relaxed_madd` は fuse してよく、V8 はする:
   scalar と strict SIMD が 4098/4098 bit 一致のところ relaxed は 3765/4098。
   ランダムな multiply-add の **19.7% が fuse で丸めが変わる**。physics3d は今 js と
   native で bit 一致しており、それを捨てる取引になる

最も好意的に見積もっても frame の **3.4%** で、そのために solver の第 2 実装を
別言語で持ち、wasm-gc を捨てることになる。**やらない。**

## 計測の方法論

**「分離したか」を必ず併記する。** このコンテナの run 間分散は phase 単位で ±25% ある。
3 回交互で「一貫して 9% 遅い」と報告したものが、5 回交互では全 variant が 1 つの帯に
収まった（main 3.34〜3.54、branch 3.33〜3.54）。以後、**main の 5 回と branch の 5 回が
完全に分離しているか**を表に出している。分離していない比は「向きの参考」にしかならない。

**bit 一致は 2 通りで確認する。** fingerprint（solver の出力そのもの）と、2D では
frame VRT の描画バイト。前者だけだと「physics は同じだが描画経路で違いが出る」を
見落とし、後者だけだと環境の都合で回せないことがある（このコンテナには `vlmkit` が
無いので `scripts/frame-vrt.mjs` は描画までして diff 段で落ちる。描画された PNG を
`cmp` で比べれば代用できる）。

### `ecs/spawn_10000` はゲートの閾値と同じだけ揺れる

baseline を撮り直したあと、**触っていない** `ecs/spawn_10000` が 1.581x の regression として
鳴った。同じコードで 5 回回すと 1.26 / 1.95 / 1.84 / 1.89 / 1.92 ms ── **それ自体が 1.55x
揺れる**。ゲートの閾値 1.5x と同じなので、baseline がたまたま速い側を捕まえると鳴る。
baseline を撮り直して緑にしたが、これは数字を合わせただけで原因ではない。ゲートを CI に
入れるなら、この bench は**中央値を記録する**か、この bench だけ閾値を緩める必要がある
（下記 6）。

## 残っている作業項目

1. **`phase_contact_constraints` は 3D でまだ最大**（848 µs、frame の約 26%）。warm start を
   引いた残りは narrowphase 52 µs + precompute 約 400 µs。precompute の
   `Vec3` 一時オブジェクトは 1 周目で潰したので、残るのは constraint struct 1 個と
   格納する `Vec3` 7 個。**上記 4 の実測から、AoS のまま潰すのは逆効果**なので、
   やるなら pooled SoA 列（`Array[Double]` × 34）しかない。1 周目の実測から
   期待値は frame の 2〜3% 程度で、労力に対して薄い
2. **velocity buffer を substep loop 全体に広げる**（未着手）。`phase_integrate_velocities` と
   `phase_integrate_positions` が substep ごとに body struct を作り直している
   （3D で 2048 回/frame）。buffer を warm start から substep loop の最後まで持たせれば
   integrate_velocities の分は消える。CCD sweep が body の velocity を読むので
   bullet body だけ書き戻す形になる。`precompute_constraint3d` も velocity を読むので
   buffer から読ませないと bit 一致が崩れる
3. **`get_pairs` は pair ごとに tuple を割り当てる**（3D 1438 個/frame、2D 570 個）。
   並列 `Array[Int]` 2 本に書く `get_pairs_into` を足せば消えるが、`get_pairs` の
   戻り値型は public
4. **2D の sleep 判定を 3D と揃えるか**。今は 2D だけ 2 閾値のまま（`Map[Int, Bool]` を
   毎フレーム作る点も含めて）。揃えると挙動が変わるので frame VRT の貼り直しになる。
   `phase_sleep_islands_pile_256` は 2D 88 µs 対 3D 20 µs で、**4.5 倍**の差が残っている
5. **256 球 pile はまだ寝ない**（relax 2 回で閾値超えが 1 体）。island sleep が全員一致を
   要求する以上、閾値か relax 回数のチューニングになる。閾値はユーザーが決める値なので
   触っていない
6. **`just bench-gate` は CI で回っていない**（持ち越し）。baseline が機械依存なので、
   入れるなら runner を固定する必要がある。加えて `scripts/bench-gate.mjs` は 1 回の run を
   そのまま記録するので、`ecs/spawn_10000` のように**それ自体が 1.5x 揺れる** bench は
   閾値と区別できない。記録側を中央値にするのが素直
7. **2D には未接続の relax pass がある**（`_solve_relaxation2d`、`_` 接頭辞で warning を
   抑えている）。3D と同じ `relax_iterations` の形に揃えるか、消すか
