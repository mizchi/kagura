# Ember Ascent: GitHub Pages release（2026-10-03）

公開先: [Ember Ascent](https://mizchi.github.io/kagura/card_game/)。トップページとゲーム一覧からも起動できる。

既存の `deploy.yml` により `main` をGitHub Pagesへ公開する。`just pages` はゲームとStudioをreleaseビルドし、相対URLの静的サイトとして `_site/` に出力する。JevのNodeクライアントやAPIキーはゲームの公開ファイルに含めない。

公開版では開発用の `key` / `name` / `subject` が削除されるため、操作に必要な識別子を `@scene.ui_key(id, node)` として分離した。公開版でもダイアログとフォーカスがUI snapshotに残り、Canvas内のTab制御が働く。従来の開発用情報の除去もreleaseテストで検証する。この検証をデプロイ前にも実行する。

Ember AscentのCanvasに `image-rendering: pixelated` を指定し、非整数倍率でドット文字がぼやけてコントラストが低下する問題を修正した。E2Eのゲーム入力はpress/releaseがそれぞれ描画フレームに観測されるまで待ち、短い固定待ち時間への依存を減らした。

| 検証 | 結果 |
| --- | --- |
| `just pages` | 全公開ページとStudioのビルド成功 |
| ゲーム・共通UIのテスト | ゲーム199件をJS/nativeで通過。scene 15件、release契約2件も各ターゲットで通過 |
| `just card-game-e2e` | 28件通過 |
| `just pages-test` | ローカル静的サイトで11件通過。画像更新専用7件は通常実行時にスキップ |
| 公開版の起動・操作 | 1280px/390pxで一覧→タイトル→キャラクター→ステージ→分岐マップ→戦闘、山札、ドラッグ、ターン終了を検証。debugプレビュー指定でもタイトルから開始 |
| vlmkit 0.23.2と画像幾何・コントラスト | 公開版のマップ・戦闘をPC/スマートフォンで撮影した4画像すべて通過 |
| Pagesテンプレート・カタログ | Nodeテスト13件通過 |
| Nodeスクリプト全体 | 328件通過。更新したWebランタイムを埋め込むCLIの生成物も同期 |

デプロイ後は `just pages-test https://mizchi.github.io/kagura/` で実際の公開URLを検証する。
