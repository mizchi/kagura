# チュートリアル

[English](tutorials.md)

## 推奨学習順

1. `runtime_smoke`
2. `flappy_bird`
3. `survivor`
4. `action_rpg`
5. `arena3d`

## 1. runtime_smoke で最小構成を理解する

- 参照: `examples/runtime_smoke/src/main_js.mbt`
- 目的: `platform` + `gfx` + `runtime` の最小接続を把握する

## 2. flappy_bird で 2D ゲームループを作る

- 参照: `examples/flappy_bird/src/game.mbt`
- 目的: 入力処理、状態更新、描画コマンド生成の分離を学ぶ

## 3. survivor で拡張可能な構造を学ぶ

- 参照: `examples/survivor/src/game.mbt`
- 目的: エンティティ更新、武器ロジック、UI的表示を同居させる構造を学ぶ

## 4. action_rpg / arena3d で応用する

- 参照: `examples/action_rpg/src/game.mbt`, `examples/arena3d/src/game.mbt`
- 目的: 2D/3D 拡張時の責務分割を確認する

## 実行メモ

各 example は個別 module です。実行時は対象ディレクトリで:

```bash
(cd examples/<name> && moon run src --target <target>)
```
