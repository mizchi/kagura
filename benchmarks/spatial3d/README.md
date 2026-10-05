# spatial3d — 座標だけで 3D の交差判定ができるかを測る LLM ベンチ

LLM に 3D 形状を**座標の JSON だけ**で渡し、2 つの物体が交差するか
（または複数物体のうちどの組が交差するか）を答えさせる。画像は渡さない。
正解は GJK で計算し、全問に**検証可能な証明**を付けてから出題する。

Node 22 だけで動く（依存なし。Anthropic API を叩くときだけ `@anthropic-ai/sdk`）。
moon module `benchmarks` の下に置いているが MoonBit は使わない。

データセットは 2 つある。**新しく測るなら v2**。v1 は Opus 5.5 で全問正解になり
飽和したので、比較用に残している。

| | v1 | v2 |
|---|---|---|
| 問題数 | 300 | 348 |
| 最小の余裕（物体サイズ比） | 2% | **0.2%** |
| 座標の桁 | 小数 2 桁 | 小数 3 桁 |
| 箱の回転 | 軸ベクトル 3 本 | **四元数** |
| 非凸形状 | トーラス | トーラス、**角穴フレーム**、**L/U 字の複合形状** |
| シーンの物体数 | 5（10 組） | **8〜10（28〜45 組）** |
| AABB ヒューリスティック | 69.6% | 53.1% |

データは `data/<version>/` の `problems.jsonl`（出題）と `answers.jsonl`
（正解とメタデータ）が正本。`manifest.json` に sha256 がある。
**モデルに渡すのは problems だけ**。結果は `results/<version>/`。

## データセット `spatial3d-v2`

| category | 件数 | 内容 |
|---|---|---|
| `pair` | 180 | 凸形状 2 個。label（交差/非交差）× 難易度 3 段 × 30 件 |
| `compound` | 48 | L 字または U 字（回転した箱 2〜3 個の和集合）× 凸形状。半数は相手を凹みに向けて置く（`in_concavity`） |
| `frame` | 48 | 角穴の開いた板 × 凸形状。半数は相手を穴の軸に沿って置く（`through_hole`） |
| `torus` | 48 | トーラス × 球/点。半数は穴の軸に沿って置く（`through_hole`） |
| `scene` | 24 | 8〜10 個（凸形状・複合形状・フレーム）。交差する組（4〜9 組）を全部列挙 |

pair 系の各 category は label × 難易度の各セルが同数で、交差/非交差は半々。
`split: "lite"` が 90 件（各セルの 1/4）。

### 難易度（v2）

`relative_margin = |clearance| / 小さい方の物体の大きさ`。大きさは外接球の半径
（segment は半長、torus は管の半径、point は相手側、複合形状とフレームは
最小の部品）で測る。絶対値 0.002 未満の問題は捨てている。

| difficulty | relative_margin |
|---|---|
| extreme | 0.002 – 0.01 |
| hard | 0.01 – 0.03 |
| medium | 0.03 – 0.10 |

シーンは全 28〜45 組が relative_margin ≥ 0.01、かつ絶対値 ≥ 0.002。
シーンの難易度は最小の組で付ける（≥ 0.1 は `easy`）。

`clearance` の意味は次のとおり。

- 離れているとき: 最短距離（厳密）。
- めり込んでいるとき（凸×凸）: 96 方向 + 中心方向について、動かして離れるまでの
  移動量を求め、その最小値を取る。貫通深さの上界で、方向の刻みから見て
  真の値より数 % 大きい程度。
- めり込んでいるとき（複合形状・フレーム）: 重なっている凸部品の組ごとに上記を求め、
  その最大値を取る（最も深い接触の深さ）。
- トーラス: 閉形式。

### 形状の定義

定義は `lib/prompt.mjs` の `SHAPE_DEFINITIONS_V2`（v1 は `SHAPE_DEFINITIONS`）で、
プロンプトにそのまま入る。

- 回転は Hamilton 規約の単位四元数 `[w, x, y, z]`。
  `world = center + R(q) * local`。小数 4 桁に丸めるので、使う前に正規化する。
- `frame` は板 `|x|≤ox, |y|≤oy, |z|≤t` から穴 `|x|<ix, |y|<iy` を除いたもの
  （ローカル座標）。
- `compound` はワールド座標で与えた部品の和集合。

point/point、point/segment、point/triangle、segment/segment は交差が
測度ゼロ（常に NO）なので、2 物体問題には出さない。
座標を丸めた後の値で正解を計算するので、丸めが答えを変えることはない。

### 正解の検証

- 凸形状は support function + GJK（Johnson 部分アルゴリズムの総当たり）。
  非凸形状は凸部品に分解する。フレームは板 4 枚、複合形状は部品そのもの。
  どれかの部品の組が交差すれば交差とする。
- GJK が返す 2 つの witness 点を、support function とは独立に書いた包含判定
  （`lib/verify.mjs`）で確かめる。
  - 交差なら、両方に含まれる同一点を示す。
  - 非交差なら、witness 間の距離（上界）と、witness 方向の分離平面の幅（下界）が
    一致することを示す。

  生成器は、部品の全組でこの証明が通らなければ落ちる。
- 四元数から回転を作る処理は、検証側で `q v q*` から別に実装している。
  フレームの分解は、「板から穴を除く」直接の包含判定とランダムな点で突き合わせる。
- `node --test benchmarks/spatial3d/*.test.mjs`（`just spatial3d-test`）が上記を固定する。
  あわせて、コミット済みの v1/v2 の全問を、出題した形状から再計算して
  answer key と一致することも確かめる。
- `generate-v1.mjs` と `generate-v2.mjs` は決定的で、コミット済みのデータを
  バイト単位で再現する。

## 他のモデルで追試する

```bash
cd benchmarks/spatial3d

# 1. API: 1 問 1 リクエスト（推奨の条件）。--dataset の既定は v2
npm i @anthropic-ai/sdk
node run.mjs --provider anthropic --model claude-opus-5-5 --effort high
node run.mjs --provider openai --model <model> --base-url <OpenAI 互換 /v1>
node run.mjs --provider command --model <label> --cmd "<CLI を非対話で、stdin にプロンプト>"

# 2. API を使わない: プロンプトを書き出して任意のハーネスで回す
node run.mjs --export-prompts prompts.jsonl          # {id, task, prompt} の JSONL
node run.mjs --export-batches batches/ --split lite  # チャット UI 用にまとめたもの
node import.mjs --model <model> --harness "chat-ui batched" --out results/v2/<model>.responses.jsonl reply*.txt

# 3. 採点（複数ファイルを並べられる。dataset は回答の prompt_version から判定）
node score.mjs results/v2/*.responses.jsonl
```

回答ファイルは 1 行 1 問の JSONL で、最低限 `{"id", "response": "<生テキスト>"}`。
`prompt_version` が無いときは `--dataset` を渡す。採点器の読み方は次のとおり。

- `response` の**最後の `ANSWER:` 行**を読む。pair は `YES`/`NO`、
  scene は `A-C, B-D` か `NONE`。
- 読めない回答・未回答は不正解として数える。
- `model` / `provider` / `prompt_version` / `settings` を残しておくと表に出る。

**比較してよいのは、同じ dataset と同じ prompt version の結果だけ。**

- 1 問 1 リクエストと、まとめて渡す batched（`prompt_version` に `+batch` が付く）は
  別の条件として扱う。
- ツール（コード実行）を許すと計算問題になるので、プロンプトでも禁止している。
  ツールを持つハーネスで回すときはツールを無効にすること。

### 出力の読み方

- `overall pair tasks`: 2 値判定の正答率。label は半々なので、チャンスレートは 50%。
- `label`: 交差／非交差それぞれの正答率。片側に寄った回答はここで分かる。
- `difficulty`: 難易度別の正答率。
- `shape`: その形状を含む問題の正答率。
- `tag`: `through_hole`、`in_concavity`、`L_shape`、`U_shape` の別。
- `scene exact set`: 全組を正しく答えた割合。
- `scene per-pair`: 組単位の正答率。非交差の組が多いので、常に NO でも 86% になる。
- `scene F1`: 交差する組の検出。
- 95% 区間は Wilson。v2 の非凸セルは 8 件しかないので、幅が広い。

### ベースライン（v2）

`node baselines.mjs --dataset v2` が、推論しないヒューリスティックの回答を書く。

| | pair tasks | pair | compound | frame | torus | scene exact | scene F1 |
|---|---|---|---|---|---|---|---|
| 常に NO | 50.0% | 50.0% | 50.0% | 50.0% | 50.0% | 0.0% | 0.0% |
| 外接球が重なれば YES | 51.2% | 51.7% | 50.0% | 50.0% | 52.1% | 0.0% | 48.8% |
| AABB が重なれば YES | 53.1% | 55.0% | 50.0% | 52.1% | 50.0% | 4.2% | 69.4% |

v2 の非交差問題は、ほぼすべて外接体どうしが重なっている。だから、
外接体で判定できる問題はほとんど残っていない。

## 実測結果

<!-- v2-results -->

### v1: claude-opus-5-5（2026-10-05, batched）

`results/v1/claude-opus-5-5.batched.responses.jsonl`。測り方は次のとおり。

- Claude Code のサブエージェント 14 個に問題を分けて渡した
  （pair/torus は 27〜28 問、scene は 6 問ずつ）。
- effort はセッション既定の `medium`、thinking は adaptive。
- 各エージェントには、問題ファイルを 1 回 Read したら、以後ツールを使わず
  頭の中だけで解くよう指示した。transcript で確認したところ、どのエージェントも
  使ったツールは `Read` 1 回だけだった。

| | pair+torus | pair hard | torus | through_hole | scene exact | scene F1 |
|---|---|---|---|---|---|---|
| claude-opus-5-5 | **276/276 (100%)** | 80/80 | 36/36 | 14/14 | **24/24** | 100% |
| AABB ヒューリスティック | 69.6% | 57.5% | 52.8% | 64.3% | 4.2% | 69.8% |

全問正解だった。各エージェントは、自分で際どいと判断した問題について推定した
余裕を報告していた。それを正解の `clearance` と並べると、ほぼ同じ値になる。
当て推量ではなく、実際に距離を計算して判定していることが分かる。

| id | 形状 | モデルが報告した余裕 | 正解 clearance |
|---|---|---|---|
| torus-007 | sphere/torus | 約 0.013 離れている | 0.01358 |
| torus-022 | torus/point | 約 0.015 離れている | 0.01535 |
| pair-012 | cylinder/segment | 約 0.018 離れている | 0.01651 |
| pair-212 | sphere/triangle | 約 0.02 めり込む | −0.02065 |
| torus-024 | torus/sphere | 約 0.02 めり込む | −0.0212 |
| pair-097 | cone/sphere | 約 0.036 離れている | 0.03615 |

消費は 14 エージェント合計で約 112 万 token、所要時間はバッチあたり 1.6〜5.5 分。
