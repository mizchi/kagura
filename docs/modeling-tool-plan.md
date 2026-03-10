# Modeling Tool Plan

Kagura 上でモデリングツールを作るなら、Blender の完全代替ではなく、`code-first + preview + VLM patch loop` に特化した authoring system として設計する。

この文書は、Blender / Three.js の現行プラクティスを踏まえて、Kagura 側で持つ責務、外部ツールへ逃がす責務、実装フェーズを整理する。

運用手順は [docs/vlm-modeling-runbook.md](./vlm-modeling-runbook.md) に切り出している。現状の成果と評価は [docs/modeling-tool-status.md](./modeling-tool-status.md) にまとめている。未完了タスクは [tools/modeling3d/TODO.md](../tools/modeling3d/TODO.md) で管理する。

## 方針

- **Source of Truth はコード**に置く
- **ハードサーフェス / parametric モデリング**を最初の主戦場にする
- **sculpting は voxel / SDF layer** から始める
- **VLM には screenshot だけでなく構造化 context を渡す**
- **最終アセット化は glTF export を軸に Blender と往復**する

## 外部比較

### vs Blender

Blender は sculpt workflow が成熟している。Dyntopo は stroke 中に topology を動的に増減し、Voxel Remesh は voxel size を軸に volume から topology を再構築し、Multiresolution は subdivision level を維持したまま detail を積める。

示唆:

- 造形探索は dynamic topology / voxel workflow が強い
- 最終 polish、retopo、UV、bake は Blender に任せるのが合理的
- Kagura は triangle direct sculpt を最初に作るより、`blockout -> preview -> export` を優先すべき

### vs Three.js

Three.js は DCC ではないが、editor/runtime authoring の足場が良い。`BufferGeometry` は attribute/index を直接管理でき、`Raycaster` は picking の基本、`OrbitControls` は editor camera の定番、`GLTFExporter` は asset export の出口、`MarchingCubes` は volumetric sculpt の叩き台になる。

`threejs-skills` の発想で有効なのは、実装コードと別に以下を明示的な context として持つこと:

- shape DSL
- editing conventions
- performance tips
- export/import rules
- prompt templates

Kagura でも同じく、モデル編集ループで必要な暗黙知を文書化し、VLM が構造を失わずに patch を返せる状態を作る。

## Kagura 側の設計

### データモデル

モデルは以下の 2 層で持つ:

1. **Primitive layer**
   - cube / sphere / plane などの parametric nodes
   - transform / material / color
2. **Sculpt layer**
   - ordered brush stamps
   - `Add / Subtract`
   - voxel size / half extent / color

この構成なら、

- hard-surface 部分はコードレビューしやすい
- sculpt 部分は VLM が「どこに何を盛ったか / 削ったか」を読める
- 後段で Marching Cubes や mesh bake を差し込める

### VLM ループ

VLM に渡す入力は固定する:

1. screenshot
2. `globalThis.__kaguraModelingContext`
3. 編集対象ファイルの diff

ベストプラクティスは「画像だけで推測させない」こと。画像は結果、JSON は構造、diff は変更意図の境界になる。

### 編集アーキテクチャ

Phase 1 は次の分離で十分:

- `model_doc.mbt`
  - source of truth
- `model_edit.mbt`
  - ray build / stamp append / layer-local edit logic
- `model_render.mbt`
  - render object / selection overlay 生成
- `model_context.mbt`
  - VLM 向け JSON / summary / recent history
- `main.mbt`
  - runtime loop と browser publish

この分離により、編集ロジックは wbtest で守り、描画と publish は再生成可能に保てる。

## 実装フェーズ

### Phase 1: Code-first preview loop

目的:

- コードで primitive / sculpt stamps を定義
- scene preview を出す
- JSON context を browser global に publish する

状態:

- 実装済み

### Phase 2: Interactive stamp authoring

目的:

- cursor から world ray を作る
- real surface に hit させる
- click で stamp を追加 / 削除する
- preview sphere で brush 範囲を可視化する

状態:

- 実装済み
- 現在は primitive / voxel の nearest surface pick と layer-local stamp append まで
- plane primitive は sculpt editing の pick 対象から除外している

### Phase 3: Selection and editor feedback

目的:

- primitive / voxel / baked mesh に対する ray pick
- layer selection
- gizmo / selection 表示
- recent history と active layer の可視化

状態:

- 一部実装済み
- primitive / voxel に対する click selection は入った
- selected primitive に対する axis gizmo drag は入った
- sculpt layer については `voxel -> boundary surface samples` の proxy bake を作り、baked-first pick に切り替えた
- sculpt layer の表示は smoothed exposed-face mesh bake に切り替えた
- active sculpt layer と recent stamp history を HUD / JSON context に出している
- latest stamp rollback と recent stamp mute/unmute は入った
- triangle baked mesh pick はまだ未実装

必要:

- `Raycaster` 相当の picking contract
- depth / BVH / coarse broadphase

### Phase 4: Surface reconstruction

状態:

- 最小版を実装済み
- 現在は stamp density field を half-voxel grid に落として `Marching Tetrahedra` で continuous surface を bake している
- preview mesh は backface 欠けを避けるため double-sided triangle として出している
- Marching Cubes / dual contouring 相当の品質最適化はまだない

目的:

- voxel preview cube を滑らかな mesh に変換
- normals / tangents を再計算
- glTF export 可能な形へ bake

候補:

- Marching Cubes
- dual contouring

### Phase 5: Asset handoff

状態:

- 最小版を実装済み
- 現在は document から primitive mesh / baked sculpt mesh をまとめて `.glb` に export できる
- browser runtime では `G` で download し、repo 内の `parse_glb + scene_graph_from_gltf` では round-trip できる
- export する `node / mesh / material` には Kagura 側の source id と kind を `extras` として埋めている
- browser runtime では `I` で `.glb` を再読込し、`extras.kagura_*` を使った diff summary を `__kaguraModelingRoundTrip` に publish できる
- round-trip diff は missing / extra / transform / material color / stamp count を検出できる
- export material は preview 互換のため `doubleSided` で出している
- Blender が入っている環境では `node tools/modeling3d/scripts/blender-roundtrip-check.mjs <file.glb>` で headless import inspection と GLB 期待値比較を回せる
- `node tools/modeling3d/scripts/blender-roundtrip-check.mjs <inspected.glb> <expected.glb>` とすると、Blender で再 export した GLB を元の Kagura export 基準で diff できる
- `node tools/modeling3d/scripts/blender-roundtrip-edit.mjs <input.glb> <output.glb>` は deterministic な Blender edit を当てて、export 後に root `extras.kagura_*` も補完する
- `node tools/modeling3d/scripts/blender-roundtrip-scenarios.mjs <source.glb>` で `missing / extra / moved / rescaled / recolored / primitive_kind / stamp_count` の scenario matrix を一括生成できる
- 現状の Blender 実測では `extras.kagura_*` custom properties と material color / double-sided は保持される
- Blender object transform は raw 値のままだと Y-up basis なので、比較時は `gltf_space_location = [x, z, -y]` と `gltf_space_scale = [x, z, y]` に戻す
- Blender 5.0 headless 実測では node custom properties は残るが、root `extras.kagura_document_name` はそのままだと落ちるので、再 export 後は `gltf-patch-kagura-extras.mjs` か `blender-roundtrip-edit.mjs` 経由で補完するのが安全
- 既定 profile は `pedestal_move_recolor`、`guide_orb_delete`、`blender_helper_add`、`clay_head_stamp_count_increment`、`pedestal_kind_mismatch`、`roundtrip_diff_bundle`
- browser runtime では `I` で round-trip diff と patch proposal を `__kaguraModelingRoundTrip` / `__kaguraModelingPatch` に publish し、`P` で primitive の position / scale / color / kind の安全な subset を in-memory apply できる
- `P` / `U` の後は imported GLB に対する residual diff を再計算して、`__kaguraModelingRoundTrip` / `__kaguraModelingPatch` を更新する
- patch proposal payload には `moonbit_patch` / `snippet_filename`、`review_prompt` / `review_filename`、`opt_in_append_source_ids` / `opt_in_remove_source_ids`、`manual_issue_details` を含めていて、`K` で `.mbt` snippet、`L` で VLM review prompt、`U` で opt-in primitive sync を回せる
- browser runtime では `J` で `current_document + roundtrip_report + patch_payload` をまとめた機械可読 bundle を download できる
- bundle には `review_profile` と `review_constraints` も含めていて、example 名ハードコードではなく profile-driven に VLM review を切り替えられる
- `node tools/modeling3d/scripts/model-authoring-vlm-review.mjs --screenshot <angled.png> --screenshot <front.png> --screenshot <side.png> --screenshot <top.png> --bundle <json> --prompt <md>` で multi-view screenshot / bundle / prompt を 1 request にまとめた VLM payload を dry-run 生成できる
- `--provider openrouter --preset free|preview|fast|balanced|quality --execute` と `OPENROUTER_API_KEY` を付けると OpenRouter chat/completions に画像 + bundle + prompt を投げて structured JSON review を返せる
- 2026-03-10 時点の preset は `free = mistralai/mistral-small-3.1-24b-instruct:free`、`preview = google/gemini-3.1-flash-lite-preview`、`fast = google/gemini-2.5-flash-lite`、`balanced = google/gemini-2.5-flash`、`quality = anthropic/claude-sonnet-4.5`
- OpenRouter の既定 preset は `preview` で、`google/gemini-3.1-flash-lite-preview` を使う
- `preview` は credits 不足や upstream limit のときだけ `free` 候補へ自動 fallback する
- `node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --serve --edit-profile roundtrip_diff_bundle --provider openrouter` で local preview 起動、source GLB export、Blender edit profile、re-import、`angled / front / side / top` screenshot、bundle / prompt / request.json 生成までを 1 コマンドで回せる
- `--interactive` を付けると headed browser の workbench page を開いたまま rerun できる。capture は single-page multi-view に寄せてあり、extra view ごとに page を作り直さない
- 既定 profile は `model_authoring = generic_model`、`chair_authoring = hard_surface_prop`、`shelf_authoring = hard_surface_prop`、`frog_authoring = organic_character`
- 現状の auto patch は primitive の transform / color / kind と sculpt layer color まで。missing / extra / stamp_count / sculpt transform は manual review に残す
- つまり handoff のボトルネックは metadata loss ではなく coordinate basis と Blender 側の編集差分の扱い
- Blender 向けの material polish、re-export 後 diff、named node round-trip はまだ未整備

目的:

- glTF / GLB export
- Blender で retopo / UV / bake / final polish
- 必要なら round-trip import

## 現在の prototype

`tools/modeling3d/examples/model_authoring` は以下を持つ:

- primitive + voxel sculpt を定義する model document
- render object への変換
- VLM 向け JSON context 生成
- browser 側への `__kaguraModelingContext` publish
- minimal interactive editing
  - `click`: hover target を selection
  - `drag gizmo`: selected primitive を axis 方向に移動
  - `A + click`: add stamp
  - `S + click`: subtract stamp
- `Z`: rollback latest stamp in active sculpt layer
- `1-4`: mute / unmute recent history entries
- `D / E`: brush radius adjust
- `G`: current document を `.glb` export
- `I`: `.glb` を import して current document と diff
- `P`: safe な auto patch subset を in-memory apply
- `U`: safe な auto patch に加えて imported primitive remove / append candidate を opt-in apply
- `J`: current document / diff / patch payload をまとめた VLM bundle JSON を download
- `K`: round-trip patch proposal から `.mbt` snippet を download
- `L`: round-trip manual review 用の VLM prompt を download
- `node tools/modeling3d/scripts/model-authoring-vlm-review.mjs --provider openrouter --screenshot <png> --bundle <json> --prompt <md>`: 既定で `google/gemini-3.1-flash-lite-preview` に screenshot / bundle / prompt をまとめて投げる
- `node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --serve --edit-profile roundtrip_diff_bundle --provider openrouter`: preview から screenshot / bundle / prompt / request 生成までを自動化する
- `just vlm-handoff-interactive frog_authoring roundtrip_diff_bundle openrouter 8113`: browser を開いたまま current workbench state から rerun する
- `O`: reset document
  - selection overlay / active layer / recent stamp history panel
- sculpt layer ごとの `surface_sample_count` を JSON context に publish
- sculpt layer ごとの `baked_vertex_count` / `baked_triangle_count` を JSON context に publish
- export 済み `.glb` には Blender handoff 用の `extras.kagura_*` metadata を埋める
- import 済み `.glb` の round-trip diff は `__kaguraModelingRoundTrip` と HUD badge に出す
- patch proposal は `__kaguraModelingPatch` に publish し、`moonbit_patch` / `review_prompt` / `opt_in_append_source_ids` / `opt_in_remove_source_ids` / `manual_issue_details` を含む
- material color 変更も round-trip diff に含める

この段階ではまだ full sculpt editor ではない。`screen ray -> surface proxy bake -> marching tetra baked mesh -> primitive gizmo / ordered stamps -> glb export` に加えて、selection / history を VLM loop に返すところまでが責務。

## 非目標

当面は以下をやらない:

- Blender 相当の full triangle sculpt
- advanced brush falloff / masking / symmetry
- multires sculpt stack
- retopo / UV editor
- rigging / weight paint

## 次の実装順

1. Marching Cubes か dual contouring に差し替えて mesh 品質と triangle 数を改善する
2. screenshot / context / diff / rollback を 1 画面に統合する
3. primitive transform gizmo を rotate / scale まで広げる
4. baked mesh pick に BVH / broadphase を入れる
5. Blender import 後の material/export options を足す

## 参考

- Three.js skills reference:
  - https://github.com/CloudAI-X/threejs-skills
- Blender Dyntopo:
  - https://docs.blender.org/manual/en/latest/sculpt_paint/sculpting/tool_settings/dyntopo.html
- Blender Voxel Remesh:
  - https://docs.blender.org/manual/en/latest/sculpt_paint/sculpting/tool_settings/remesh.html
- Blender Multiresolution:
  - https://docs.blender.org/manual/en/latest/modeling/modifiers/generate/multiresolution.html
- Three.js BufferGeometry:
  - https://threejs.org/docs/pages/BufferGeometry.html
- Three.js OrbitControls:
  - https://threejs.org/docs/pages/OrbitControls.html
- Three.js Raycaster:
  - https://threejs.org/docs/pages/Raycaster.html
- Three.js GLTFExporter:
  - https://threejs.org/docs/pages/GLTFExporter.html
- Three.js MarchingCubes:
  - https://threejs.org/docs/pages/MarchingCubes.html
- OpenAI images and vision:
  - https://platform.openai.com/docs/guides/images-vision
- OpenAI structured JSON outputs:
  - https://platform.openai.com/docs/guides/gpt/chat-completions-api
