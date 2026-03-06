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

## Next — グラフィック強化 (PoE2 をゴールとして段階的に)

### 1. 影の統合 (shadow3d)
- [x] ディレクショナルライトのシャドウマップ生成
- [x] ダンジョン壁・エンティティのシャドウキャスター登録
- [x] PCF ソフトシャドウ付きフラグメントシェーダーに切替
- [x] シャドウボリューム (カメラ追従)

### 2. Bloom + トーンマッピング (postfx)
- [ ] HDR レンダーターゲット
- [ ] 閾値抽出 → ガウスブラー → 加算合成
- [ ] ACES フィルミック トーンマッピング
- [ ] FXAA アンチエイリアス

### 3. パーティクルエフェクト (particle3d)
- [ ] 攻撃エフェクト (剣の軌跡、ヒットスパーク)
- [ ] 被ダメージエフェクト
- [ ] アイテム取得エフェクト
- [ ] 環境パーティクル (ダンジョンの塵)

### 4. terrain3d 統合
- [ ] Grid→Mesh 変換で壁を立体的に描画
- [ ] 壁の高さバリエーション
- [ ] ドアタイルの半高ブロック化

### 5. テクスチャ・マテリアル
- [ ] glTF モデル差し替え対応
  - Mixamo 等のアセット生成サービスから .glb をダウンロードして配置
  - `assets/` に .glb → `js_fetch_bytes` + `parse_glb` + `skinned_scene_from_gltf` でロード
  - PlayerCharacter / EnemyModels の skeleton/bind_mesh/skin_data/clips を差し替え
  - AnimationStateMachine で idle/run/attack をクロスフェード管理
- [ ] ディフューズテクスチャ適用
- [ ] ノーマルマップ (凹凸表現)

### 6. PBR マテリアル
- [ ] Cook-Torrance BRDF シェーダー統合
- [ ] メタリック / ラフネスパラメータ
- [ ] エミッシブ (光源オブジェクト)

## Future — エンジン拡張が必要
- [ ] 複数ポイントライト (シェーダー統合)
- [ ] SSAO (スクリーンスペース環境遮蔽)
- [ ] フォグ / 大気演出
- [ ] デカール (魔法陣等の地面エフェクト)
- [ ] カスケードシャドウマップ

## Future — ゲームプレイ
- [ ] 被ダメージアニメーション (のけぞり)
- [ ] ボス固有アニメーション (charge モーション)
- [ ] 走りアニメーション (移動中に切替)
- [ ] Sound effects + BGM
- [ ] ミニマップ (3D版)
- [ ] Native build support
