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
- [x] ドットマトリクスフォント修正 (座標計算バグ、数字文字コード、小文字自動大文字化)
- [x] RPG UI 読みやすさ改善 (不透明背景、フォントサイズ調整、レイアウト整理)
- [x] 装備ドロップ散乱エフェクト (敵撃破時にアイテムが飛び散る)
- [x] CMA-ES バランスチューナー (5プロファイル最適化、CSV出力)
## Next — すぐ取り組めるもの

### Balance Experiment Plan
- [ ] `default / autoplay_progression / build_diverse_hackslash / mechanics_roguelike_v2` を floor 1 / floor 5 の両方で headless 比較し、`before_change / after_tune` を DuckDB に継続蓄積する
- [ ] `ArchetypeAligned` で tuned した値を固定して、`AntiSynergy` build に cross-eval し、「明らかに噛み合わない build はちゃんと死ぬ」ことを確認する
- [ ] `Melee / Mage / Summoner / Ranger` を別々に tune し、各 archetype ごとに `skill unlock / drop table / stat scaling` の探索範囲を個別化する
- [ ] 爽快感重視 (`build_diverse_hackslash`) とメカニクス重視 (`mechanics_roguelike_v2`) を preset として維持し、同じ seed 群で継続比較する
- [ ] 探索時間を減らす方向の仮説として、`map_room_count_scale / map_room_size_scale / map_corridor_width_bonus / pack_large_room_bonus` を優先探索し、広場が多い地形での clear time を確認する
- [ ] アイテム更新の spike を強める方向として、`base tier / prefix / suffix / modifier tier` の floor scaling を tuning し、`equip_upgrades` と `learned_skill_count` の増え方を見る
- [ ] 敵パターン増加後の stress case を固定し、`弾幕 / タックル / 炎上 / 死亡爆発` が追加された状態で `total_damage / near_death_rate / floors_cleared` を再基準化する
- [ ] `爽快感` の proxy として `kill cadence / knockback distance / particle burst count` を experiment metric に追加する
- [ ] `examples/hacknslash_3d/scripts/balance_hypothesis_record.mjs` の出力から `best_generation` 推移を可視化し、収束しない仮説を早めに切る
- [ ] 詳細な実行手順は [docs/performance/hacknslash_3d-balance-tuning.md](/Users/mz/ghq/github.com/mizchi/kagura/docs/performance/hacknslash_3d-balance-tuning.md) に残し、この TODO では「次に試す仮説」と「採用判断」だけを管理する

### UI / UX
- [ ] TTF フォントレンダリング対応 (init 順序問題の解決: GameState 生成を on_start 内に移動)
- [ ] ダメージ数値ポップアップ (敵に与えたダメージを画面上に表示)
- [ ] ゲームオーバー時のスコアサマリー画面
- [ ] アイテム比較表示 (装備中と選択中の差分ハイライト)

### ゲームプレイ
- [ ] スキル個別クールダウン (現在は attack_cooldown のみ、Power Strike/Whirlwind を分離)
- [ ] ドロップレート・アフィックス重み分布をチューナブルに
- [ ] 敵の種類別 AI 差別化 (ranged は距離を取る、tank は突進する等)
- [ ] ボス固有アニメーション (charge モーション)
- [ ] フロアクリア時の報酬選択 (スキルポイント or HP回復 or レアアイテム)

### バランスチューナー
- [ ] プロファイル間のバランス多様性を保つ joint optimization
- [ ] Web UI でのリアルタイム最適化可視化
- [ ] スキル個別クールダウンのチューニングパラメータ追加

### グラフィック
- [ ] glTF モデル差し替え対応
  - Mixamo 等のアセット生成サービスから .glb をダウンロードして配置
  - `assets/` に .glb → `js_fetch_bytes` + `parse_glb` + `skinned_scene_from_gltf` でロード
  - PlayerCharacter / EnemyModels の skeleton/bind_mesh/skin_data/clips を差し替え
  - AnimationStateMachine で idle/run/attack をクロスフェード管理
- [ ] ディフューズテクスチャ適用
- [ ] ノーマルマップ (凹凸表現)
- [ ] フォグ / 大気演出

### PBR マテリアル
- [ ] Cook-Torrance BRDF シェーダー統合
- [ ] メタリック / ラフネスパラメータ
- [ ] エミッシブ (光源オブジェクト)

## Future — エンジン拡張が必要
- [ ] 複数ポイントライト (シェーダー統合)
- [ ] デカール (魔法陣等の地面エフェクト)
- [ ] カスケードシャドウマップ
- [ ] Sound effects + BGM — Audio バックエンド抽象化が前提
- [ ] Native build support
