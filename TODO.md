# TODO (Ebiten 同等機能ロードマップ)

このファイルは未完了タスクのみを管理する。
完了済みは `docs/mvp.md` の `DONE` セクションへ退避。

## ゴール再確認

- 目標: Ebiten と同等の 2D ゲームエンジン機能を MoonBit で提供する
- 優先: WebGPU (browser) と native wgpu (macOS) で同一ゲームロジックを早期に動かす
- 非目標: WebGL/WebGL2 フォールバック
- 3D 拡張は 2D API/実装安定後

## 現在の優先タスク (優先順位順)

### Windows / Linux Native 対応

現在 Native ビルドは macOS のみ対応。wgpu-native と GLFW 自体は Windows/Linux をサポートしているため、以下の対応で拡張可能:

- [ ] `scripts/setup-wgpu-native.sh` を Windows (MSYS2/MinGW) / Linux に対応
- [ ] `moon.pkg` の `cc-link-flags` をプラットフォーム別に分岐（macOS: Metal frameworks、Linux: Vulkan + X11/Wayland、Windows: D3D12/Vulkan）
- [ ] Audio バックエンドの抽象化（現在 AudioToolbox に依存 → Linux: PulseAudio/ALSA、Windows: WASAPI）
- [ ] CI に `native-linux` (ubuntu-latest) / `native-windows` (windows-latest) ジョブ追加

### scene3d API 改善

`src/scene3d/` パッケージは抽出済み（`scene3d()` ビルダー + `render_scene3d()` レンダラー + テスト）。

- [ ] arena3d を `scene3d` API に移行（現在は独自の MeshBatch で CPU 側投影を実装）
- [x] scene3d に material / texture サポート追加
- [x] scene3d のパフォーマンス最適化（per-object frustum culling）

### オーディオ改善

arena3d で基本的な SE 再生（Web/Native 両方）は動作確認済み。

- [x] BGM 対応（ループ再生 + 音量調整） — `MixerAudioContext::play_bgm` 等
- [x] フェードイン/アウト — `fade_bgm + tick_bgm`
- [x] AudioWorklet への移行（現在 ScriptProcessorNode、Chrome で非推奨警告）
- [x] クロスフェード — `crossfade_bgm + dispose_outgoing_bgm`

## 3D ゲームエンジン拡張ロードマップ

### Tier 1: 最低限のゲーム制作に必要

- [x] 衝突判定 (collision3d) - AABB/Sphere/Ray
- [x] 衝突判定ブロードフェーズ - SpatialHashGrid
- [x] シーングラフ (親子階層) - 親子 Transform 伝播
- [x] 複数光源 - PointLight, SpotLight, 複数灯対応
- [x] glTF loader - 業界標準フォーマット対応
- [ ] glTF/OBJ ローダーを別パッケージに切り出し（mizchi/glfw と同様に mooncakes 化）

### Tier 2: まともな 3D ゲームに必要

- [ ] スケルタルアニメーション - ボーン, スキンメッシュ, キーフレーム補間
- [x] 物理エンジン - リジッドボディ, 重力, 衝突応答（physics3d: impulse-based, Baumgarte 補正, Coulomb 摩擦）
- [x] シャドウマッピング - 深度バッファベースの影（shadow3d パッケージ: depth-to-color + PCF）
- [ ] パーティクルシステム - エフェクト (煙, 火, 爆発)

### Tier 3: 品質向上

- [ ] PBR マテリアル - Metallic/Roughness ワークフロー
- [x] 法線マップ - バンプ表現（derivative-based TBN + normal map shader）
- [x] ポストエフェクト - ブルーム, トーンマッピング (Reinhard/ACES), FXAA
- [ ] 3D オーディオ定位 - 距離減衰, パンニング
- [x] フラスタムカリング - オブジェクト単位の視錐台カリング
- [ ] LOD - 距離に応じたメッシュ切替

### アーキテクチャ課題

- CPU ラスタライザ → GPU パイプライン移行: scene3d は CPU で頂点変換して 2D コマンドに変換している。draw3d に WGSL シェーダはあるので GPU 側に移行すべき
- 頂点フォーマットの柔軟化: 現在 stride=8 固定。スキンメッシュではボーンウェイトが必要

## 完了条件 (第一段階)

- 2D 基本機能（sprite/offscreen/shader/text/input）が js/native 同一 API で動作
- backend は WebGPU (browser) + native wgpu を維持
- `moon check/test` (js/native) + Playwright e2e が常時通る
- `docs/ebiten_reference.md` の主要項目に `未着手` がない

## 参照

- 完了済み一覧: `docs/mvp.md`
