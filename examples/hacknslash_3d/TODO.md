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
- [x] 影の統合 (shadow3d)
  - ディレクショナルライトのシャドウマップ生成
  - ダンジョン壁・エンティティのシャドウキャスター登録
  - PCF ソフトシャドウ付きフラグメントシェーダー
  - シャドウボリューム (カメラ追従)
- [x] PostFX: ACES トーンマッピング + FXAA
- [x] PostFX: Bloom (閾値抽出 → ガウスブラー → 加算合成)
- [x] PostFX: SSAO (カメラ深度パス + スクリーンスペース AO)
- [x] パーティクルエフェクト (particle3d)
  - ヒットスパーク、デスバースト、ダッシュトレイル、アイテム取得、被ダメージ
- [x] terrain3d 統合
  - Grid→Mesh 変換で壁を立体的に描画
  - 壁の高さバリエーション (height_map)
  - ドアタイル (ピラー装飾)
- [x] 弓による遠隔攻撃 (auto-aim, projectile system)
- [x] カメラ相対移動 (カメラ yaw に基づく入力回転)
- [x] 固定 60fps タイムステップ (120Hz ディスプレイ対応)
- [x] Dvorak キーボード対応 (,aoe → WASD)
- [x] RPG システム (インベントリ、装備、スキルツリー、セーブ/ロード)
- [x] enum 化 (GameMode, EnemyKind, ItemKind, UIMode)
- [x] 描画最適化 (空間チャンキング、バッチシャドウデプス、tinted lighting cache)
- [x] 走りアニメーション (移動中に切替、腕振り + 上下ボブ + 前傾)
- [x] 被ダメージアニメーション (のけぞり — torso jerk back + recovery)
- [x] ミニマップ (プレイヤー中心、敵・ボス表示)
- [x] 環境パーティクル (ダンジョンの塵 — プレイヤー周辺に定期スポーン)

## Next — グラフィック強化

### テクスチャ・マテリアル
- [ ] glTF モデル差し替え対応
  - Mixamo 等のアセット生成サービスから .glb をダウンロードして配置
  - `assets/` に .glb → `js_fetch_bytes` + `parse_glb` + `skinned_scene_from_gltf` でロード
  - PlayerCharacter / EnemyModels の skeleton/bind_mesh/skin_data/clips を差し替え
  - AnimationStateMachine で idle/run/attack をクロスフェード管理
- [ ] ディフューズテクスチャ適用
- [ ] ノーマルマップ (凹凸表現)

### PBR マテリアル
- [ ] Cook-Torrance BRDF シェーダー統合
- [ ] メタリック / ラフネスパラメータ
- [ ] エミッシブ (光源オブジェクト)

## Future — エンジン拡張が必要
- [ ] 複数ポイントライト (シェーダー統合)
- [ ] フォグ / 大気演出
- [ ] デカール (魔法陣等の地面エフェクト)
- [ ] カスケードシャドウマップ

## Future — ゲームプレイ
- [ ] ボス固有アニメーション (charge モーション) — 敵ごとのアニメーション状態管理が必要
- [ ] Sound effects + BGM — Audio バックエンド抽象化が前提
- [ ] Native build support
