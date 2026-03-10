# Modeling Tool Status

Kagura 上の authoring / VLM loop について、現時点の成果、強い部分、弱い部分をまとめる。

設計方針は [docs/modeling-tool-plan.md](./modeling-tool-plan.md)、日常運用の手順は [docs/vlm-modeling-runbook.md](./vlm-modeling-runbook.md) を参照。

現在の workspace ルートは `tools/modeling3d/` で、authoring example は `tools/modeling3d/examples/*`、VLM/Blender 連携 script は `tools/modeling3d/scripts/*` に集約している。

## いま出来ること

- `code-first` の 3D authoring example を preview できる
- primitive / voxel sculpt stamp を source of truth として持てる
- Web preview と native preview の renderer parity を確認できる
- `live-review` で current workbench state を 4 view atlas にして VLM へ投げられる
- `roundtrip` で GLB export / Blender edit / re-import / diff を回せる
- VLM review は structured output で受け取り、task queue / patch scaffold / local feedback artifact に落とせる
- web の高速 loop は daemon 化してあり、dry-run では low-latency に反復できる

## 実装済み example

- `model_authoring`
  - baseline の authoring sandbox
- `chair_authoring`
  - hard-surface seat / support structure の検証用
- `shelf_authoring`
  - hard-surface shelf / storage prop alignment の検証用
- `frog_authoring`
  - organic voxel maquette の検証用
- `dragon_authoring`
  - organic voxel creature silhouette の検証用

## 何がうまくいっているか

### 1. hard-surface の review loop

`chair_authoring` と `shelf_authoring` はかなり安定している。

- primitive の位置ずれ
- repeated part の alignment
- overlap / floating prop
- helper 的な混入

このあたりは VLM がかなり安定して検出できる。

現状の実務的な位置づけ:

- hard-surface prop review: 実用に近い
- deterministic patch scaffold: 実用に近い

### 2. local-first な review loop

日常の反復は GitHub や PR comment を介さず、ローカルだけで閉じる。

- preview
- screenshot atlas
- bundle / prompt
- VLM request / parsed review
- local feedback artifact

`daemon + dry-run` を使うと、browser 起動コストを日常の反復から外せる。

### 3. browser / native parity

native capture は一時期 plain visual が壊れていたが、offscreen target 直接 readback に直して parity を取れるようにした。

現在は:

- `same_current_document = true`
- `same_summary = true`
- silhouette / visual の両方で threshold 内

まで確認済み。

## どこがまだ弱いか

### 1. organic sculpt の quality

`frog_authoring` と `dragon_authoring` は、review loop 自体は回るが、quality は hard-surface ほど安定しない。

organic では VLM が主に以下を返す:

- blob っぽい
- landmark が弱い
- wing / tail / limb の接続が甘い
- stamp の半径と位置を詰める必要がある

つまり今の VLM は organic では `sculptor` より `art director / QA` に近い。

### 2. automatic repair の範囲

hard-surface では deterministic fix を増やし始めているが、organic ではまだ manual review が中心。

いま強いのは:

- set position / scale / color / primitive kind
- review_alignment / review_overlap からの hard-surface patch scaffold

まだ弱いのは:

- sculpt stamp の自動再配置
- organic silhouette を保ったままの auto-improvement

## 例ごとの現状評価

### chair_authoring

- 評価: `B+`
- 状態: hard-surface の review loop としてかなり安定
- 主な強み: alignment, support structure, helper detection

### shelf_authoring

- 評価: `B+`
- 状態: shelf frame はよく読める
- 主な強み: stacked planes, upright alignment, storage prop placement
- 補足: `storage_bundle` を sculpt から primitive 群へ置き換えて改善済み

### frog_authoring

- 評価: `C+`
- 状態: stylized frog maquette としては review できる
- 主な弱み: organic detail は manual sculpt review に寄る

### dragon_authoring

- 評価: `C+`
- 状態: voxel dragon blockout は成立し始めた
- 現在の読み:
  - head / neck / tail は dragon として読める
  - main issue は wing integration
  - VLM は `review_alignment` を一貫して返す

現時点の結論:

- `voxel base で dragon を書けるか`: yes
- `説得力のある final dragon までそのまま行けるか`: not yet

## 性能の要点

### web live-review

`daemon + dry-run` では local loop はかなり軽い。

ボトルネックは atlas capture ではなく:

- browser launch
- page open
- execute 時の provider 応答待ち

### execute 時

`--execute` の律速はほぼ VLM provider 応答待ち。

運用上は:

- 普段: `dry-run`
- 節目: `--execute`

に分けるのが合理的。

## 現時点の結論

この prototype は、Blender の代替 DCC ではなく、

- `code-first modeling`
- `preview + review loop`
- `local-first VLM feedback`

に強い authoring system としては成立している。

特に hard-surface は次の段階に進みやすい。
organic は引き続き blockout / review 用としては有効だが、quality 向上はまだ manual sculpt judgment に依存する。

## 次に進めるなら

- hard-surface:
  - `review_alignment / review_overlap` から deterministic auto-fix を増やす
  - `robot_authoring` や `cabinet_authoring` を増やす
- organic:
  - wing / tail / limb の scaffold を増やす
  - silhouette/depth atlas を review input に加える
  - stamp scaffold を VLM の review output に直結する
