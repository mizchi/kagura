# spatial3d — 座標だけで 3D の交差判定ができるかを測る LLM ベンチ

LLM に 3D 形状を**座標の JSON だけ**で渡し、2 つの物体が交差するか
（または 5 物体のうちどの組が交差するか）を答えさせる。画像は渡さない。
正解は GJK で計算し、全問に**検証可能な証明**を付けてから出題する。

Node 22 だけで動く（依存なし。Anthropic API を叩くときだけ `@anthropic-ai/sdk`）。
moon module `benchmarks` の下に置いているが MoonBit は使わない。

## データセット `spatial3d-v1`

`data/problems.jsonl`（出題）と `data/answers.jsonl`（正解とメタデータ）が正本。
`manifest.json` に sha256 がある。**モデルに渡すのは problems だけ**。

| category | 件数 | 内容 |
|---|---|---|
| `pair` | 240 | 凸形状 2 個。label（交差/非交差）× 難易度 3 段 × 40 件 |
| `torus` | 36 | トーラス × 球/点。半数は球の中心が穴の中（`through_hole`） |
| `scene` | 24 | 凸形状 5 個。交差する組（10 組中 1〜6 組）を全部列挙 |

`split: "lite"` が 78 件（各セルの 1/4）。安く回したいときは `--split lite`。

形状は `point` `sphere` `aabb` `obb` `segment` `capsule` `cylinder` `cone`
`triangle` `tetrahedron` `torus`。すべて中身の詰まった立体で、定義は
`lib/prompt.mjs` の `SHAPE_DEFINITIONS`（プロンプトにそのまま入る）。
point/point、point/segment、point/triangle、segment/segment は
交差が測度ゼロ（常に NO）になるので出題しない。

座標は小数 2 桁、OBB の軸とトーラスの軸は 3 桁に丸める。**正解は丸めた後の値で
計算する**ので、丸めが答えを変えることはない（OBB の軸は丸めで厳密な正規直交では
なくなるが、定義 `center + Σ s_i axes_i` のとおりに判定する）。

### 難易度

`relative_margin = |clearance| / 小さい方の物体の大きさ`（大きさは外接球半径、
segment は半長、torus は管の半径、point は相手側を使う）。

| difficulty | relative_margin |
|---|---|
| hard | 0.02 – 0.10 |
| medium | 0.10 – 0.30 |
| easy | 0.30 – 1.00 |

`clearance` は離れていれば最短距離。めり込んでいれば、96 方向 + 中心方向に
動かして離れるまでの最小移動量（貫通深さの**上界**）。だから交差側の難易度は
実際より易しく分類されることがある。絶対値 0.01 未満の問題は捨てている。

### 正解の検証

- 凸形状は support function + GJK（Johnson 部分アルゴリズムの総当たり）。
- GJK が返す 2 つの witness 点を、support function とは独立に書いた
  包含判定（`lib/verify.mjs`）で確かめる。交差なら両方に含まれる同一点、
  非交差なら「witness 間の距離（上界）」と「witness 方向の分離平面の幅（下界）」が
  一致することを示す。生成器は全問でこの証明が通らなければ落ちる。
- トーラスは非凸なので閉形式（中心円までの距離 − 管半径 − 球半径）。
- `node --test benchmarks/spatial3d/*.test.mjs`（`just spatial3d-test`）が
  球/AABB の閉形式との一致、3000 組のランダム凸ペアの証明、穴のケースを固定する。

## 他のモデルで追試する

```bash
cd benchmarks/spatial3d

# 1. API: 1 問 1 リクエスト（推奨の条件）
npm i @anthropic-ai/sdk
node run.mjs --provider anthropic --model claude-opus-5-5 --effort high
node run.mjs --provider openai --model <model> --base-url <OpenAI 互換 /v1>
node run.mjs --provider command --model <label> --cmd "<CLI を非対話で、stdin にプロンプト>"

# 2. API を使わない: プロンプトを書き出して任意のハーネスで回す
node run.mjs --export-prompts prompts.jsonl          # {id, task, prompt} の JSONL
node run.mjs --export-batches batches/ --split lite  # チャット UI 用にまとめたもの
node import.mjs --model <model> --harness "chat-ui batched" --out results/<model>.responses.jsonl reply*.txt

# 3. 採点（複数ファイルを並べられる）
node score.mjs results/*.responses.jsonl
```

回答ファイルは 1 行 1 問の JSONL で、最低限 `{"id": "...", "response": "<モデルの生テキスト>"}`。
採点器は `response` の**最後の `ANSWER:` 行**を読む。pair は `YES`/`NO`、
scene は `A-C, B-D` か `NONE`。読めない回答・未回答は不正解として数える。
`model` / `provider` / `prompt_version` / `settings` を残しておくと表に出る。

**比較してよいのは同じ `dataset_version` と `prompt_version` の結果だけ。**
1 問 1 リクエストとまとめて渡す batched（`prompt_version` に `+batch` が付く）は
別の条件として扱う。ツール（コード実行）を許すと計算問題になるので、
プロンプトでも禁止している。ツールを持つハーネスで回すときはツール無しにすること。

### 出力の読み方

- `overall pair+torus`: 2 値判定の正答率。チャンスレートは 50%（label は半々）。
- `label`: 交差／非交差それぞれの正答率。片側に寄った回答はここで分かる。
- `difficulty`, `shape`（その形状を含む問題）, `tag through_hole`。
- `scene exact set`: 10 組すべて正しい割合。`per-pair` は組単位の正答率、
  `F1` は交差する組の検出。
- 95% 区間は Wilson。1 セル 40 件なので ±15pt 程度の幅がある。

### ベースライン

`node baselines.mjs` が推論しないヒューリスティックの回答を `results/` に書く。
モデルの数字はこれと並べて読む。

| | pair+torus | pair hard | torus | scene exact | scene F1 |
|---|---|---|---|---|---|
| 常に NO | 50.0% | 50.0% | 50.0% | 0.0% | 0.0% |
| 外接球が重なれば YES | 58.0% | 52.5% | 61.1% | 0.0% | 54.9% |
| AABB が重なれば YES | 69.6% | 57.5% | 52.8% | 4.2% | 69.8% |

どちらのヒューリスティックも交差側は 100% 当たり、非交差側で外す
（外接体は保守的なので）。つまりこのデータセットの非交差問題は
「外接ボックスは重なるが実体は離れている」ものが多い。

## 実測結果

結果ファイルは `results/`。

### claude-opus-5-5（2026-10-05, batched）

`results/claude-opus-5-5.batched.responses.jsonl`。Claude Code のサブエージェント 14 個に
問題を分けて渡した（pair/torus は 27〜28 問、scene は 6 問ずつ）。effort はセッション既定の
`medium`、thinking は adaptive。各エージェントには「問題ファイルを 1 回 Read したら、
以後ツールを使わず頭の中だけで解く」と指示した。transcript で確認したところ、
どのエージェントも使ったツールは `Read` 1 回だけだった。
問題ファイルに正解やメタデータは含めていない。
1 問 1 リクエストの API 条件（`run.mjs --provider anthropic`）ではまだ測っていない。

| | pair+torus | pair hard | torus | through_hole | scene exact | scene F1 |
|---|---|---|---|---|---|---|
| claude-opus-5-5 | **276/276 (100%)** | 80/80 | 36/36 | 14/14 | **24/24** | 100% |
| AABB ヒューリスティック | 69.6% | 57.5% | 52.8% | 64.3% | 4.2% | 69.8% |

全問正解。95% 区間の下限は pair+torus で 99%、scene exact で 86%。
各エージェントは自分で際どいと判断した問題について、推定した余裕を報告していた。
それを正解の `clearance` と並べると、ほぼ同じ値になっている。
当て推量ではなく、実際に距離を計算して判定していることが分かる。

| id | 形状 | モデルが報告した余裕 | 正解 clearance |
|---|---|---|---|
| torus-007 | sphere/torus | 約 0.013 離れている | 0.01358 |
| torus-022 | torus/point | 約 0.015 離れている | 0.01535 |
| pair-012 | cylinder/segment | 約 0.018 離れている | 0.01651 |
| pair-156 | capsule/segment | 約 0.02 離れている | 0.01906 |
| pair-212 | sphere/triangle | 約 0.02 めり込む | −0.02065 |
| torus-024 | torus/sphere | 約 0.02 めり込む | −0.0212 |
| pair-097 | cone/sphere | 約 0.036 離れている | 0.03615 |
| torus-021 | sphere/torus | 約 0.036 離れている | 0.03594 |

**v1 はこのモデルでは飽和している。** 上限を測るには、もっと難しい問題が要る。
候補は次のとおり。

- 余裕を 0.002 未満にする。そのためには座標の小数桁を増やす必要があり、dataset version が変わる
- scene の物体数を増やす（8〜10 個、28〜45 組）
- 非凸形状や複合形状を加える（凸分解した L 字、穴あき板など）
- 回転を軸ベクトルではなく四元数やオイラー角で与える

消費は 14 エージェント合計で約 112 万 token（各エージェントの system prompt を含む）。
所要時間はバッチあたり 1.6〜5.5 分。
