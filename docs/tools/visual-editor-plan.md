# Visual Editor Plan

ビジュアルエディタ（シーン配置・パラメータ調整 GUI）は、ゲームとしての基本機能が揃った段階で着手する。

## 方針

- preview-first 戦略に沿い、重い統合 editor を追わない
- code-first + AI authoring で大半の編集操作をカバーする前提
- ビジュアルエディタは「コードで書いた結果を確認・微調整する」ための補助ツールとして位置付ける

## 前提条件（着手の目安）

- ゲームループ（入力・更新・描画）が安定している
- RPG システム（装備・スキル・インベントリ）が一通り動いている
- PostFX パイプライン（Bloom / SSAO / Tonemap / FXAA）が機能している
- セーブ / ロードが動いている
- プロファイラで性能を確認できる

## スコープ案

- シーン配置: エンティティの位置・回転・スケールの GUI 操作
- パラメータ調整: ライティング、PostFX、カメラなどの数値をスライダーで変更
- プレビュー連携: 変更をリアルタイムに preview host へ反映
- undo/redo: 操作履歴の管理

## 参考

- `TODO.md` の「Editor / AI Authoring 方針」セクション
- `docs/tools/editor-authoring.md`（editor 統合の設計方針）
