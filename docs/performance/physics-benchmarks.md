# 2D / 3D 物理エンジンのベンチマーク

- Date: 2026-09-10
- Scope: `engine/physics/physics2d`, `engine/physics/physics3d`, `scripts/bench-gate*.mjs`
- Goal: 「何を測っているか」が名前から判る physics bench にし、**測っている仕事が消えたことを検知できる**状態にする

> **この doc の数字は最適化前の状態である。** この bench を使って 3D 側を最適化した結果と、
> ここに書いた結論のうち 1 つが誤りだったこと（下記「3D の支配項」）は
> [physics3d-optimization.md](./physics3d-optimization.md) にある。

方法論は [mizchi/pixel-lab](https://github.com/mizchi/pixel-lab) の `benchlib` に倣う。
pixel-lab の bench 結果はどれも **boundary**（`resident` / `construction-inclusive` /
`end-to-end`）を明示し、**`correctness: {passed, checks, summary}` を結果に埋め込む**。
後者が本質で、前者だけでは足りない。速度だけを見るゲートは「遅くなった」しか検知できず、
ワークロードそのものが消滅した bench は永久に緑のまま何も測らなくなる。

## Conclusion

- **2D には bench が 1 本も無かった。** 2D-first のエンジンで physics2d が完全に未計測だった。19 本追加した
- **3D の bench は step の実装を私的にコピーしていた。** `world_bench.mbt` が
  `world.mbt` の integration / solve ループを複製していたので、片方だけ直すと bench が
  出荷されていないコードを測り続ける。`step()` を phase 関数へ分解し、bench と `step()` が
  **同じ関数**を呼ぶようにした（挙動は不変、既存 1217 test が全て通る）
- **3D の旧 fixture は warm start 経路を一度も通っていなかった。** 毎 iteration で world を
  作り直していたので contact cache は空（実測: 測定対象の step に入る時点で cache length 0、
  出る時点で 144）。毎フレーム走る分岐に bench カバレッジがゼロだった
- **2D と 3D で支配項が違う。** 2D は solver 律速（`solve_velocities` が substep 込みで 41.4%、
  broadphase は 17.5%）、3D は broadphase + narrowphase 律速（合わせて 38.6%、solver は 11.5%）。
  同じ最適化を両方に当てても効かない
  - **⚠️ 3D についてこの結論は誤りだった。** 下の phase 表を信じた結果で、その表の
    `solve_velocities` は 5x 過小評価されていた。reset 直後の body 状態で測ると
    impulse 書き込みがガードに落ち、当時の AoS solver ではそれが「struct 2 個と
    `Vec3` 12 個を割り当てない」ことを意味したため。in situ で測ると solve pass は
    **frame の 53%** で、3D の最大の支配項だった。経緯と対策（`substep_` prefix bench）は
    [physics3d-optimization.md](./physics3d-optimization.md)
- **broadphase は 1 回の呼び出しとしては両方で最も重い**（2D 907 µs / 3D 1410 µs）。3D では
  substep 4 回分の solver 合計の 1.6 倍
- **2D には 3D にある sleep fast path が無い。** 同名 bench を並べて初めて見えた
- ゲートを両側にした。**3x 以上速くなったら止まって確認を促す**

## ベンチマークの設計

### boundary を名前に入れる

`moon bench` は closure 全体を計測し、iteration ごとの setup フックが無い。だから
closure がやったことは全部その数字に入る。名前で区別する:

| prefix | 数字に含まれるもの |
|---|---|
| `step_` | warm 済み world の `step` 1 回 + reset |
| `phase_` | その step の 1 phase + 必要な reset |
| `phase_reset_` | reset だけ。`phase_` から引く床 |
| `build_` | world 構築のみ（warm up は含めない） |

`phase_` は床を引いて読む。実測で床は 1.0〜2.9 µs、最小の phase が 20 µs なので誤差は
数 % に収まる。`step_` に対しては 3 桁下なので無視してよい。

### 毎 iteration 同じフレームを測る

`step` は world を変える。batch runner は closure を数千回呼ぶ。reset しないと pile は
30 iteration ほどで沈んで寝てしまい、bench は solver ではなく **sleep fast path** を
測り始める。名前は `step_pile_256` のままで。

`reset` は warm 済み snapshot を書き戻す。`RigidBody2D` / `RigidBody` は immutable
struct なので body 1 個あたり参照 1 write、allocation なし。contact cache は**あえて
触らない**: 毎 iteration 同一の body 状態から step するので cache は 1 回目で収束して
以後固定される。決定的かつ warm、という都合の良い状態になる。

solve の bench は constraint accumulator も戻す。`solve_constraint2d` は配列要素を
**丸ごと差し替える**（field を in-place で書かない）ので、pristine template は壊れず
参照 1 write で戻せる。戻さないと accumulator が収束して `delta_jn.abs() > 1e-15` の
分岐に落ち、「もう何も解いていない solve」を計測することになる。

### fixture

決定的に作る（`@random` ではなく固定 seed の LCG）。完全な対称格子は solver の
退化した経路に落ちるので jitter は入れるが、機械をまたいで同じ値が出る必要がある。

| fixture | 中身 | 測る対象 |
|---|---|---|
| `pile` | 箱の中に触れ合う状態で詰めた円/球 | 密な contact、深い island、warm start |
| `scatter` | broadphase が 1 pair も見つけない間隔 | フレームの per-body 床 |
| `resting` | 床に接して静止、互いには触れない | **寝ているシーン**の経路 |
| `rope` | distance joint の鎖 | distance joint solver |
| `hinge` / `ball_chain` | revolute / ball joint の鎖 | 各 joint solver |

`pile` の壁は飾りではない。球は 0.02 だけ食い込んだ状態から始める（フレーム 1 で既に
contact があるように）ので、その overlap を解消する力で pile が外へ広がる。閉じ込めないと
薄くなる: 実測で床だけの 256 球 pile は warm 8 フレームで candidate pair 1764 → 354 まで落ちた。

### 寝ている fixture が pile でない理由

**この solver では密な pile は寝ない。** 400 フレーム（6.7 秒相当）まで回し、spacing
0.98〜1.1、damping 0.05〜0.3 で振っても、256 体 pile の最大速度は 1.0〜3.2 units/s に
留まり、sleep 閾値 0.5 を常に上回る。island 内に 1 体でも閾値超えがいると island 全体が
起きたままなので、pile を warm して寝かせることは原理的にできない。

だから `resting` は単層に離して置いた静止シーンにした。各 dynamic body が自分だけの
island になり、実測で 256/256 が寝て、床との contact 256 本が残る。pile を `settled` と
名付けていたら、**完全に起きている solver を測る `settled` bench** ができていた。

### 壊れたときに落ちる方を作る

`bench_fixtures_wbtest.mbt`（2D / 3D 各 1 本、計 20 test）が fixture が名前どおりの
仕事を生んでいることを assert する:

- `pile` は body 数以上の pair と constraint を生む / size sweep で仕事が実際に増える / 起きている
- `resting` は全部寝ている **かつ** contact が 256 本残っている
- `scatter` は contact 0 / `rope` は distance joint だけ、contact 0（joint を測るため）
- `reset` が測定対象フレームを完全に復元する / 2 回作った fixture が bit 一致する
- solve を 2 周させて、2 周目も 1 周目と同じだけ body が動く（= 収束して no-op になっていない）

これが無いと、contact を生まなくなった refactor は「3 倍速くなった」として通る。
CLAUDE.md の「純黒 18 枚を baseline に焼き付けた」のと同じ失敗である。

## 実測

`just bench` (target=js)。値は `scripts/bench-baseline.json` に入っている
（この表は 1 台での相対比較用。絶対値は機械依存）。

### full step, size sweep

| bench | 2D | 3D |
|---|---:|---:|
| `step_pile_64` | 937 µs | 1.81 ms |
| `step_pile_256` | 5.19 ms | 7.60 ms |
| `step_pile_1024` | 26.2 ms | 37.6 ms |
| `step_scatter_1024` (contact 0) | 4.16 ms | 6.68 ms |
| `step_resting_256` (全部寝ている) | 2.31 ms | 4.14 ms |
| `step_rope_256` | 1.10 ms | 1.79 ms |
| `step_hinge_256` / `step_ball_chain_256` | 1.24 ms | 2.84 ms |
| `build_pile_1024` (構築のみ) | 134 µs | 154 µs |

64 → 256 → 1024 で 2D は 5.5x / 5.1x、3D は 4.2x / 4.9x。body 数 4 倍あたり 4〜5.5 倍なので、
**contact 密度の増加分だけ線形より悪い**。fixture の仕事量も一緒に増えていることは
wbtest が保証している（2D pile: 107 → 456 → 1883 contact）。

`step_scatter_1024` が contact 0 で 4.16 ms ということは、**per-body の床が
4.1 µs/body/frame** ある。1024 体 pile の 26.2 ms のうち 16% は contact に一切関係ない。

### phase 内訳（pile 256, substeps=4, velocity_iterations=1）

`step` 内の呼ばれ方に合わせて回数を掛けたもの。

| phase | ×回数 | 2D 合計 | 2D 比 | 3D 合計 | 3D 比 |
|---|---:|---:|---:|---:|---:|
| `broadphase` | 1 | 907 µs | **17.5%** | 1410 µs | **18.6%** |
| `narrowphase` | 1 | 48 µs | 0.9% | (contact に統合) | — |
| `contact_constraints` | 1 | 485 µs | 9.3% | 1520 µs | **20.0%** |
| `integrate_velocities` | 4 | 98 µs | 1.9% | 179 µs | 2.4% |
| `solve_velocities` | 4 | 2151 µs | **41.4%** | 873 µs | 11.5% |
| `integrate_positions` | 4 | 104 µs | 2.0% | 253 µs | 3.3% |
| `save_contact_cache` | 1 | 289 µs | 5.6% | 372 µs | 4.9% |
| `clear_forces` | 1 | 21 µs | 0.4% | 19 µs | 0.3% |
| `sleep_islands` | 1 | 87 µs | 1.7% | 21 µs | 0.3% |
| 合計 | | 4188 µs | 80.7% | 4647 µs | 61.2% |

phase の合計は step 実測を下回る。単独で回す phase は同じ状態を繰り返し叩くので
JIT と cache に有利であり、この差は「取りこぼした phase」ではなく**測定条件の差**として
読むこと。2D で 81% 説明できているので phase 分解自体は妥当。3D の残差が大きい理由は
未追跡。

## ここから出てきた作業項目

> 3D 側の 1 / 3 / 4 は [physics3d-optimization.md](./physics3d-optimization.md) で対応済み
> （broadphase 2.44x、`save_contact_cache` 9.47x、`step_pile_256` 全体で 2.48x）。
> 2D 側は未着手。5 も未着手。

1. **broadphase**: 1 回の呼び出しとしては両方で最も重く（2D 907 µs / 3D 1410 µs、step 比
   17.5% / 18.6%）、3D では最大の支配項。`get_pairs` は cell 内の候補 pair ごとに
   `Map[Int64, Unit]` へ dedupe insert する。JS target では Int64 key が重い。
   `scatter` の per-body 床 4.1 µs もここに乗っている。**3D で最初に手を付ける場所**
1b. **2D の `solve_velocities`**: substep 4 回で 2151 µs、step の 41.4% で 2D 最大の支配項。
   1 回あたりは 538 µs なので、削るなら substep 数か 1 constraint あたりのコストのどちらか
2. **2D の sleep_islands が 3D の 4 倍**（87 µs vs 21 µs）。3D は「寝ている body も
   寝かけの body も無ければ union-find を丸ごと飛ばす」fast path を持つが、2D には無く、
   さらに `Map[Int, Bool]` を毎フレーム作る（3D は `Array[Bool]`）。3D 側の実装を移植すれば済む。
   fast path の有無は `phase_sleep_islands_pile_256`（起きている、21 µs）と
   `phase_sleep_islands_resting_256`（寝ている、42 µs）の 2 本で押さえてある
3. **3D の `contact_constraints` が 2D の 2.9 倍**（1520 µs vs 485+48 µs）。narrowphase と
   precompute が融合していて切り分けられない。2D と同じ形に割れば内訳が見える
4. **`save_contact_cache` が毎フレーム 289〜372 µs**。step の末尾にあるので軽そうに見えるが、
   contact ごとに manifold を 1 個割り当てて Map を作り直している
5. **密な pile が寝ないこと自体**（上記）。solver の品質の問題であり、bench の問題ではない
6. **`just bench-gate` は CI で回っていない**。`docs/performance/benchmark-kpi.md` は
   回っていると書いていたので、そこは直した。baseline が機械依存なので、CI に入れるなら
   runner を固定するか閾値を機械差に耐えるところまで緩める必要がある

## ゲートを両側にした

`scripts/bench-gate.mjs` は「1.5x より遅くなったら落とす」だけだった。反対側の失敗が
見えない: contact を生まなくなる、constraint 配列が空になる、シーンが寝る —— どれも
bench は**速くなり**、緑のまま何も測らなくなる。

3x 以上速くなったら `SPEEDUP` として落とし、「本当に最適化なのか、ワークロードが消えたのか」を
確認させる。本物なら `--update` 一回で済む。

閾値が 2x でなく 3x なのは baseline が機械依存だから。実際、この baseline を別の機械で
再生すると無関係な bench が**両方向に**最大 2x 動く。2x ゲートは CPU 差で鳴って無視される
だけになる。ワークロード消滅はそこまで微妙な話ではない: 64 体 fixture から contact を
抜くだけで既に 3.3x、pile が完全に衝突しなくなれば桁で動く。

## 実行方法

```sh
just bench                       # 全 bench
just bench-gate                  # baseline と比較（両側）
just bench-update                # 意図した変化のあとに貼り直す
cd engine/physics && moon bench --target js -p mizchi/physics/physics2d
cd engine/physics && moon test  --target js   # fixture correctness gate を含む
```
