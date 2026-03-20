# TODO (kagura roadmap)

このファイルは未完了タスクのみを管理する。
完了済みは `docs/mvp.md` の `DONE` セクションへ退避する。

3D modeling / VLM authoring 関連の未完了は `tools/modeling3d/TODO.md` で管理する。

## ゴール

- `wgpu` renderer を持つ host 上で、wasm guest として 2D/3D アプリケーションコードを動かす
- preview/HMR を強くした code-first 開発体験を作り、MoonBit を基準にしつつ同じ WIT を満たす guest を Rust / Zig にも開く
- WebGL/WebGL2 フォールバックは非目標
- Unity / Godot 風の重い統合 editor を先に作ることは非目標
- 複雑な編集 UI をそのまま利用者に露出することは非目標

## 現在のオープンタスク

### P0: Toolchain / Platform

- [ ] Windows native build workaround を GitHub Actions / 実機で確定する
  repo 側で OS 別の `cc` wrapper 切り替えと `vcpkg` の `glfw3` 解決を追加した。ローカルでは `just target=native check` と `examples/native_triangle` の build まで通っているので、残りは `windows-latest` runner と実機での確認。

### P1: Engine Architecture

- [ ] 頂点フォーマットを柔軟化する
  現在は stride=8 前提の箇所が残っている。スキンメッシュや将来の拡張頂点属性を載せられる表現へ整理する。

### P2: Package Boundary / Deferred

- [ ] glTF/OBJ ローダーを別パッケージへ切り出す
  現状は `mesh3d` / `scene3d` / `skeleton3d` / `animation3d` など複数パッケージへ強く依存している。基盤パッケージの独立とテクスチャパイプライン安定後に着手する。

## ベンチマーク方針

- ベンチマークゲームは Isometric Hack & Slash ARPG を継続する
- 既存の Phase 進行、レビュー修正、周辺機能の完了分は `docs/mvp.md` を参照する
- 新規の ARPG 固有タスクは、完了済み checklist を増やさず、このファイルの open task として再整理して追加する

## 参照

- 完了済み一覧: `docs/mvp.md`
- 詳細な実装ログ: Git 履歴
