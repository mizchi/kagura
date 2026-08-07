# Modeling 3D

Kagura の code-first 3D modeling / VLM review loop を集約した workspace です。

## 構成

```
tools/modeling3d/
  src/                     mizchi/kagura_modeling3d — 共有ライブラリ
    model_types.mbt          document schema (ModelDocument / PrimitiveNode / SculptLayer ...)
    authoring_profile.mbt    AuthoringProfile（example ごとのレビュー方針）
    model_context.mbt        context JSON / summary
    model_edit.mbt           sculpt 編集
    model_export.mbt         GLB export
    model_gizmo.mbt          gizmo drag
    model_history.mbt        stamp history
    model_pick.mbt           surface pick
    model_render.mbt         render object 構築
    model_selection.mbt      selection
    model_surface.mbt        surface bake
    model_roundtrip.mbt      GLB import の差分比較
    model_roundtrip_patch.mbt round-trip patch plan / review prompt / bundle
    authoring_app.mbt        run_authoring（js のエディタ本体）
    native/
      authoring_app_native.mbt  run_authoring_native（native の 1 フレームキャプチャ）
  examples/<name>_authoring/
    src/model_doc.mbt          この example のモデルデータのみ
    src/authoring_profile.mbt  この example のレビュー方針
    src/main.mbt               run_authoring を呼ぶだけ（js）
    src/main_native.mbt        run_authoring_native を呼ぶだけ（native）
    src/main_stub.mbt          その他 target 用スタブ
  scripts/                 root の scripts/ から呼ばれる modeling/VLM helper 群
```

- examples: `chair` / `dragon` / `frog` / `model` / `shelf` の 5 つ
- docs: root `docs/` の modeling tool 関連資料（`docs/tools/vlm-modeling-runbook.md`）
- todo: `tools/modeling3d/TODO.md`

## example を追加するとき

必要なのは 4 ファイルだけです。エディタ・レンダラ・round-trip loop は共有ライブラリ側にあります。

1. `src/model_doc.mbt` — `default_model_document()` と `apply_imported_patch*()`
   - 先頭に `using @modeling3d { type ModelDocument }` を置く
   - **`fn default_model_document() -> ModelDocument {` と
     `fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {` のシグネチャは
     この字面のまま維持すること。** `scripts/model-authoring-vlm-apply-patch.mjs` が
     この文字列を探してパッチを当てる
2. `src/authoring_profile.mbt` — `review_profile_id` / `review_constraints` / `doc_source_path`
   - この 3 つが VLM のレビュープロンプトとバンドルにそのまま入る
3. `src/main.mbt` / `main_native.mbt` / `main_stub.mbt` — 各 3 行
4. `moon.mod` に `"mizchi/kagura_modeling3d@0.1.0"`、`moon.work` に `"../.."` を追加

## 共有コードを直すとき

`src/` を 1 箇所直せば 5 example に反映されます（以前は 11 ファイルが 5 重複していて、
`main.mbt` の 1 行修正に 5 箇所の編集が必要でした）。

```sh
cd tools/modeling3d
moon check --deny-warn --target js
moon check --deny-warn --target native
moon test --target js
```

example 側は native パッケージ（`supported_targets = "native"`）なので、
`moon check --deny-warn --target native` で検証します。
