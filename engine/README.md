# mizchi/kagura_engine

描画・表示ツリー・アセット・音声・実行ループの基盤です。core の計算結果から
描画コマンドを作り、platform contract の hook を通して実行します。
ゲームのルールと platform backend 実装には依存しません。

- `application`, `runtime`: 描画・更新 callback、実行オプション、フレーム駆動。
- `scene`, `scene2d`, `scene3d`: 2D/3D の表示構造とドキュメント。
- `hud`, `tilemap2d`, `sprite_packer`: 表示部品、タイル描画、アトラス構築。
- `inspection`: 状態を表示・編集する型付き接続。ゲームの不変条件は利用側が検証。
- `draw3d`, `renderer3d`, `postfx`, `shadow3d`: 描画コマンドとパイプライン。

物理・IK・地形の計算は `core`、敵やアイテム・進行は `game`、wgpu-native と
ネイティブキャプチャ IO は `platform_native` に置きます。
時計・ファイル操作・フレーム予約は `platform/services`、バイト取得は `platform/fetch` の契約を使います。
アトラスのデコード・管理とロード待ち行列は engine に残し、通信実装を注入します。
`renderer2d`, `text`, `widget2d`, `ui`, `atlas`, `asset_loader`, `audio` は独立 module です。

[層の責務と依存方向](../docs/architecture/module_boundaries.md)
