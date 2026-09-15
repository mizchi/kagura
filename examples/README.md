# Examples の選び方と配置

Studio の一覧は [catalog.json](catalog.json) に集約する。現在は 25 個のコード examples と 1 個の素材プロジェクト。各 example は目的を持ち、似た画面でも検証する API が異なる場合は、その違いを一覧に示す。

## Pages のゲーム一覧

公開用の [ゲーム一覧](https://mizchi.github.io/kagura/examples/) は、`catalog.json` の `category: "games"` を使って `just pages` で生成する。各ゲームの `gallery` に表示順、2D / 3D、ジャンル、紹介、入力方法、サムネイルの代替テキストを定義する。通常は `/<id>/` へ直接リンクし、独自ビルドを持つ IRON YARD は `gallery.playPath` で Studio 同梱のゲーム本体を指定する。公開先のサブパスに依存しない相対 URL を使う。

画像は [assets/pages/thumbnails](../assets/pages/thumbnails/) の実プレイ画面。全画像をコミットし、Pages の CI ではゲームの撮影や GPU の起動を行わない。一覧自体も静的 HTML / CSS と画像だけで動き、ゲーム本体を先読みしない。

更新手順:

1. `just pages` で公開物を生成し、`_site` を静的 HTTP サーバーで配信する。
2. `just pages-thumbnails http://127.0.0.1:8082/kagura/` で撮影する。URL は実際の配信ルートに合わせる。この明示タスクだけがチェックインする画像を上書きする。
3. 画像を確認して `just pages` で再生成する。`just pages-gallery-test` で欠落を検証し、`just pages-test` で公開物のリンクとレスポンシブ表示を検証する。

撮影は独立した Playwright コンテキストで行うため、普段遊んでいるブラウザのセーブデータには触れない。7 本の起動手順は [pages-thumbnails.spec.ts](../e2e/pages-thumbnails.spec.ts) にまとめる。新しいゲームを追加するときはカタログ・公開用ビルド・撮影手順を一緒に追加する。

| 配置 | 役割 | 実行方法 |
|---|---|---|
| `games/` | 複数機能を組み合わせたゲーム開発の例 | Studio または MoonBit |
| `demos-2d/`, `demos-3d/` | 機能・API を学ぶための小さな例 | Studio または MoonBit |
| `assets/` | 共通エディタで扱う素材と `.kgrprj` | Studio。MoonBit ビルド不要 |
| `smoke/` | 実行基盤・画像・FFI の回帰検証 | CI / 個別タスク |
| `experimental/` | 外部サービスや別言語ホストを含む実験 | 各 README の手順 |

入門は **Flappy Bird**（2D）または **Arena 3D**（3D）、ドメイン特化エディタの実装は **IRON YARD**、RPG の統合例は **Hack & Slash 3D** を参照する。単一の API を調べる場合は、次の機能デモから選ぶ。

## コードと素材の規約

MoonBit は `moon.mod` と同じ階層をソースルートにし、`src/` を置かない。`moon.pkg` が直下にあればビルド入口は `.`、`app/` などに分ける場合はプロジェクト設定で明示する。シーンは `scenes/`、ゲーム固有の編集拡張は `editor/`、ゲーム固有の素材はそのプロジェクトの `assets/` に置く。Rust / Zig / TypeScript の独立プロジェクトはそれぞれの言語・ツールの配置を使う。

リポジトリ共通の配布物はルートの [assets/](../assets/README.md) にまとめる。個別ゲームの素材を共通フォルダへ移すのは、複数のプロジェクトから実際に利用するときに限る。

## 今回の統合

`gltf_viewer` / `obj_viewer` の個別 MoonBit ランタイムを廃止し、素材を [Model Assets](assets/model_assets/model_assets.kgrprj) に統合した。表示・カメラ操作は `editor/model-viewer` が担当する。旧 CLI 名・公開デモ一覧・VRT 対象を整理し、GLB / OBJ の GPU readback 検証は Studio の `e2e/model-assets.spec.mjs` に集約した。

素材を追加する際は、新しい viewer example を作らず、この素材プロジェクトか対象ゲームの `resources` に追加する。モデル以外も共通エディタで検査できるようになった時点で、同じ方針で整理する。

## 残す違いと次の統合候補

| 対象 | 現在の違い | 次の整理 |
|---|---|---|
| draw2d_ui_demo / ui_demo | 枠線・scissor の描画 / UI ツリー・レイアウト・フォーカス | API 階層の違いが分かる名称・説明を保ち、低水準検証は UI の複雑な例に埋め込まない |
| collision3d_demo / physics3d_demo / ragdoll_demo | 衝突照会 / 剛体シミュレーション / 関節拘束 | デバッグ表示の共通化を検討し、各機能の小さな再現例は残す |
| scene_demo / Flappy Bird | Scene API の最小記法 / ゲーム状態と動的階層 | 最小記法の説明が Flappy Bird だけで読みやすく示せる時点で再評価する |

2D 戦闘ゲームは Survivor に集約し、Action RPG と Hack & Slash (2D) は削除した。FPS Demo の一人称操作・射撃・ジャンプは Arena 3D に統合した。Arena は V で視点を切り替え、箱や球の剛体シミュレーションも試せる。専用の physics3d_demo は物理 API の小さな再現例として残す。

## 一覧

| Example | 目的 |
|---|---|
| [Arena 3D](games/arena3d/arena3d.kgrprj) | 一人称・三人称、射撃・ジャンプ、箱や球の剛体物理を組み合わせる例 |
| [Card Game](games/card_game/card_game.kgrprj) | カード効果・ターン制戦闘・経済バランスを扱う例 |
| [Collision 3D](demos-3d/collision3d_demo/collision3d_demo.kgrprj) | レイ・AABB・球の衝突照会と broadphase を確認する |
| [Draw2d Ui Demo](demos-2d/draw2d_ui_demo/draw2d_ui_demo.kgrprj) | 低水準の矩形・枠線・scissor 描画を確認する |
| [Ecs Demo](demos-2d/ecs_demo/ecs_demo.kgrprj) | ECS のエンティティ・コンポーネント・システムを確認する |
| [Fetch Image](demos-2d/fetch_image/fetch_image.kgrprj) | 画像リソースの非同期読込と GPU アップロードを確認する |
| [EMBERWING](games/emberwing/emberwing.kgrprj) | ドラゴンの多重ロック・火線・編隊戦闘を扱う空中シューティング |
| [Flappy Bird](games/flappy_bird/flappy_bird.kgrprj) | 最小の 2D ゲームと宣言的シーン・ライブ状態編集の基準例 |
| [Hack & Slash 3D](games/hacknslash_3d/hacknslash_3d.kgrprj) | 3D ダンジョン・装備・スキル・保存を組み合わせる統合例 |
| [Ik Demo](demos-3d/ik_demo/ik_demo.kgrprj) | 逆運動学による関節チェーンの追従を確認する |
| [IRON YARD](games/iron_yard/iron-yard.kgrprj) | メカ戦闘・専用シーン編集・描画性能の統合例 |
| [Machinations](demos-2d/machinations_demo/machinations_demo.kgrprj) | 資源フロー・ノード発火・経済シミュレーションの例 |
| [Model Assets](assets/model_assets/model_assets.kgrprj) | 汎用エディタで GLB・glTF・OBJ の静的プレビューを確認する素材集 |
| [Particle System](demos-3d/particle_demo/particle_demo.kgrprj) | パーティクルの発生・更新・描画を確認する |
| [Pbr Demo](demos-3d/pbr_demo/pbr_demo.kgrprj) | 金属度・粗さなどの PBR マテリアル表現を確認する |
| [Physics 2D](demos-2d/physics2d_demo/physics2d_demo.kgrprj) | 2D 剛体の衝突応答と動的生成を確認する |
| [Physics 3D](demos-3d/physics3d_demo/physics3d_demo.kgrprj) | 3D 剛体の重力・反発・接触を確認する |
| [Post Effects](demos-3d/postfx_demo/postfx_demo.kgrprj) | ポストエフェクトと描画パスの接続を確認する |
| [Ragdoll](demos-3d/ragdoll_demo/ragdoll_demo.kgrprj) | 関節・ばねによるラグドールの拘束を確認する |
| [Scene Demo](demos-2d/scene_demo/scene_demo.kgrprj) | ゲーム固有処理を最小にした宣言的 2D Scene API の入門例 |
| [Shadow 3D](demos-3d/shadow3d_demo/shadow3d_demo.kgrprj) | シャドウマップと影の描画パスを確認する |
| [Skeletal Animation](demos-3d/skeletal_anim/skeletal_anim.kgrprj) | 骨格・キーフレーム・アニメーションの再生を確認する |
| [Sprite Anim](demos-2d/sprite_anim/sprite_anim.kgrprj) | 2D スプライトのフレームアニメーションを確認する |
| [Survivor](games/survivor/survivor.kgrprj) | 自動攻撃・大量の敵・経験値とアップグレードの 2D ゲーム例 |
| [Terrain Demo](demos-3d/terrain_demo/terrain_demo.kgrprj) | 高さデータによる地形メッシュ生成・描画を確認する |
| [UI Demo](demos-2d/ui_demo/ui_demo.kgrprj) | UI ツリー・レイアウト・フォーカス・ヒット判定を確認する |
