# Hack & Slash 3D - TODO

## Done
- [x] 2D版ロジック移植 (combat, enemy_ai, spawn, dungeon)
- [x] OrbitCamera による PoE 風斜め見下ろしビュー
- [x] ダンジョン3D描画 (Floor/Corridor/Wall タイル)
- [x] エンティティ3D描画 (敵種別メッシュ・色分け、アイテムY軸ボブ)
- [x] 2D HUD オーバーレイ (HP、フロア、スコア、敵数、ダッシュCD)
- [x] プロシージャルスケルタルキャラクター (5ボーン: body/arm/sword)
- [x] 剣振りアタックアニメーション (idle/attack ステート切替)
- [x] GPU スキニングレンダリング
- [x] 敵キャラクターもプロシージャルスケルタルモデル化
  - 3ボーン共通スケルトン (root → body → head) + idle 揺れアニメーション
  - 5種類の固有メッシュ: basic(戦士), fast(双刃), tank(肩アーマー), ranged(杖+オーブ), boss(角+大剣)
  - プレイヤーを向いて回転

## Next
- [ ] glTF モデル差し替え対応
  - Mixamo 等のアセット生成サービスから .glb をダウンロードして配置
  - `assets/` に .glb → `js_fetch_bytes` + `parse_glb` + `skinned_scene_from_gltf` でロード
  - PlayerCharacter / EnemyModels の skeleton/bind_mesh/skin_data/clips を差し替え
  - AnimationStateMachine で idle/run/attack をクロスフェード管理

## Future
- [ ] 攻撃エフェクト (パーティクル、剣の軌跡)
- [ ] 被ダメージアニメーション (のけぞり)
- [ ] ボス固有アニメーション (charge モーション)
- [ ] 走りアニメーション (移動中に切替)
- [ ] Sound effects + BGM
- [ ] ミニマップ (3D版)
- [ ] 影描画 (shadow3d 統合)
- [ ] ポストエフェクト (bloom 等)
- [ ] Native build support
