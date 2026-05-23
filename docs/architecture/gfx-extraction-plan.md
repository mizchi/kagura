# gfx 切り出し計画

`modules/kagura_engine/src/gfx/` を独立 moon module `modules/gfx_core/` に分離し、
最終的には kagura 抜きでも利用可能な形にするための段階的計画。

## 現状

- gfx パッケージ: 4,710 行 (`contracts.mbt` 891 / `shader_contracts.mbt` 1478 /
  `backend_contracts.mbt` 351 / hooks stub 350 / wbtest 2574 / kagura_engine module 内)
- 主要な抽象: `GraphicsDriver` trait, `DrawTrianglesCommand`, `CommandQueue`,
  `StubGraphicsDriver` + native/web hooks registry
- 既に「中立コマンドバッファ + trait ベース backend」設計になっており、
  kagura 固有概念 (Scene / ECS / ゲームループ) への参照はゼロ
- 81 箇所が `mizchi/kagura_engine/gfx` を import

## 障害

| 項目 | 内容 | フェーズ |
|---|---|---|
| `@platform.SurfaceToken` 依存 | `backend_contracts.mbt` が platform 型を直接参照 | Phase 1 |
| `ImageHandle` / `ShaderHandle` の世代未管理 | id : Int のみ。invalid 状態の表現が contractに存在しない | Phase 1 |
| `vertex_stride_hint : Int` のマジックナンバー | `0 = auto, 4 = 2D, 8 = 3D, 16 = skinned` がコメントに | Phase 1 |
| `asset.AtlasDrawSource` 直接参照 | `draw2d/contracts.mbt` が gfx 外型を持つ | Phase 1 |
| WGSL ハードコード | shader 生成が WGSL 文字列ベタ書き | Phase 2 以降 |
| backend impl が module 内同居 | `gfx_wgpu_native/` は kagura_engine module 内サブパッケージ | Phase 2 |

## ターゲット構成

```
modules/
  gfx_core/                   <- 新規 (旧 kagura_engine/src/gfx/)
    src/
      command.mbt             <- 旧 contracts.mbt から分離
      handle.mbt              <- ImageHandle / ShaderHandle + 世代管理
      uniform.mbt             <- 旧 shader_contracts.mbt から分離
      backend.mbt             <- 旧 backend_contracts.mbt から SurfaceToken 切離後
      shader.mbt              <- ShaderFrontend, BuiltinShaderSourceRepo
      contracts_wbtest.mbt
      shader_contracts_wbtest.mbt
      moon.pkg
    moon.mod.json             <- deps: moonbitlang/core/cmp のみ

  gfx_backends_wgpu_native/   <- 旧 kagura_engine/src/gfx_wgpu_native/
    moon.mod.json             <- deps: gfx_core + platform + glfw

  gfx_backends_webgpu/        <- 旧 js_runtime/src/gfx_webgpu/
    moon.mod.json             <- deps: gfx_core + js_runtime FFI

  kagura_engine/              <- gfx/ サブパッケージは削除、再エクスポート無し
    src/
      sprite2d/               <- `mizchi/gfx_core` を直接 import
      ...
```

`platform` は kagura_engine 内に残す (gfx_core を独立させる方が大事)。

## 段階

### Phase 0 — 内部整理 (1 セッション、Option A 相当、現セッション着手)

gfx パッケージを kagura_engine 内に置いたままで以下を実施。後で module 分離する際の摩擦を減らす。

1. **`gfx/contracts.mbt` の関心別分割**
   - `command.mbt` — `DrawTrianglesCommand`, `DrawCommandDispatch`, `BlendMode`, `Color`,
     `CommandQueue`, `SimpleCommandQueue`
   - `handle.mbt` — `ImageHandle`, `ShaderHandle`, `new_image_handle`, `new_shader_handle`
   - `pipeline.mbt` — `RenderPassDesc`, `GraphicsDriver` trait, lifecycle ops
   - 各 891 → 300 行前後に分割

2. **`ImageHandle` / `ShaderHandle` に generation フィールド追加**
   - 既存 callsite は `new_image_handle(id, w, h)` を維持。内部で generation=0 を生成
   - `pub fn handle_invalidated(handle, generation) -> Bool` を追加
   - backend 側が解放時に generation++ する将来パスを用意

3. **`vertex_stride_hint : Int` を enum 化**
   - `pub enum VertexStrideHint { Auto, Stride2D, Stride3D, StrideSkinned, Custom(Int) }`
   - `DrawTrianglesCommand.vertex_stride_hint` を enum 型に
   - 旧 Int の callsite を移行

4. **shader_contracts.mbt の関心別分割**
   - `uniform.mbt` — `UniformValue`, `PackedUniforms`, packing helpers
   - `shader.mbt` — `ShaderIR`, `ShaderFrontend`, `BuiltinShaderSourceRepo`
   - 1478 → ~700 + ~700 に分割

5. **docs/architecture/gfx-api.md 新規** — `gfx` の公開 API インデックス。
   後で gfx_core README の元になる

### Phase 1 — 依存切離 (1 セッション、抽出前の最終整地)

1. **`SurfaceToken` の gfx_core 化**
   - 案 A: `pub struct SurfaceToken { id : Int }` を gfx_core に複製定義、platform 側はそれを再エクスポート
   - 案 B: gfx は surface を `Int` ID として扱い、platform 側で意味付け
   - 推奨: 案 A (型としてのアイデンティティを保ったまま move 可能)

2. **`asset.AtlasDrawSource` を trait に**
   - `draw2d/contracts.mbt` の `atlas_quad_resource_cache_key(source : AtlasDrawSource)` を
     `trait AtlasSource { atlas_id() -> Int; ... }` に置き換え
   - asset/ がその trait を impl する

3. **`uniform_hash` 算出を public 化**
   - 現状 backend だけが使う private path → `pub fn compute_uniform_hash(packed) -> Int`
   - Cross-backend test で同一性検証が書けるようになる

### Phase 2 — module 分離 (1-2 セッション)

1. **`modules/gfx_core/` を新規作成**
   - `moon.mod.json` 作成、`moon.work` に追加
   - `kagura_engine/src/gfx/` を `gfx_core/src/` に `git mv`
   - 81 箇所の `mizchi/kagura_engine/gfx` import を `mizchi/gfx_core` に書き換え

2. **`modules/gfx_backends_wgpu_native/` を新規作成**
   - `kagura_engine/src/gfx_wgpu_native/` を移動
   - kagura_engine module から removal

3. **`modules/gfx_backends_webgpu/` を新規作成**
   - `js_runtime/src/gfx_webgpu/` を移動
   - js_runtime module から removal

4. **kagura_engine の gfx 関連サブパッケージは残す**
   - `sprite2d`, `text`, `renderer3d`, `scene3d` 等は kagura_engine module 内のまま
   - 単に import 先が `mizchi/gfx_core` に変わる

### Phase 3 — publish 準備 (将来、外部 consumer が出てきたら)

- shader DSL 設計 (現状 WGSL ハードコード)
- cross-backend integration test suite
- API stabilization markers (`api-tiers.md` で `experimental` / `stable` を明示)
- semver 設計 (`mizchi/gfx_core 0.1.0` の意味を明文化)
- 外部リポへ移送 + `moon publish`

## 互換性方針

- Phase 0-2 を通じて kagura 内部 API は壊さない (`@gfx.ImageHandle` の callsite は変えない)
- Phase 2 の import 変更は機械的 sed で一括処理 (1 コミット)
- 各 phase は **`moon check --target js` および `moon test --target js`** が通ることを着地点とする

## 進捗

- [ ] Phase 0.1 contracts.mbt 分割
- [ ] Phase 0.2 ImageHandle/ShaderHandle generation
- [ ] Phase 0.3 VertexStrideHint enum
- [ ] Phase 0.4 shader_contracts.mbt 分割
- [ ] Phase 0.5 gfx-api.md
- [ ] Phase 1.1 SurfaceToken 切離
- [ ] Phase 1.2 AtlasSource trait
- [ ] Phase 1.3 uniform_hash public
- [ ] Phase 2.1 modules/gfx_core/ 移動
- [ ] Phase 2.2 modules/gfx_backends_wgpu_native/ 移動
- [ ] Phase 2.3 modules/gfx_backends_webgpu/ 移動
