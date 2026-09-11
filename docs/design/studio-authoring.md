# AI操作を前提とするKagura Studio

## 参照した実装と観察

2026-09-10、modeling-playground `aa7ab3ea9ed08e457b574547e27f4b0c8e463f04` の以下を読み、React UIのコピーではなく、データと操作の意味をMoonBitへ再設計した。

- [試作記録](https://github.com/mizchi/modeling-playground/blob/aa7ab3ea9ed08e457b574547e27f4b0c8e463f04/docs/prototyping-notes.md): リソースAPI、用途別ビュー、レイアウトの仮説、状態と表示の分離。
- [Scene Studio](https://github.com/mizchi/modeling-playground/blob/aa7ab3ea9ed08e457b574547e27f4b0c8e463f04/docs/scene-studio.md): 編集コピーと試遊、原子的履歴、無音シーク、Scene / Action / GameEventの分離。
- [契約](https://github.com/mizchi/modeling-playground/blob/aa7ab3ea9ed08e457b574547e27f4b0c8e463f04/game/studio/contracts.ts): 安定ID、単位、参照整合性、厳密な入力検証。
- [制作能力の振り返り](https://github.com/mizchi/modeling-playground/blob/aa7ab3ea9ed08e457b574547e27f4b0c8e463f04/docs/agent-capabilities.md): 単一画像だけで品質を判断せず、多方向・時間方向・数値検証を分ける。
- `integration/moonbit/src/scene.mbt`: エンジン型を持たない配置をmizchi/threeへ変換する接続例。

リポジトリ内の `editor/modeling3d` のdocument/context/roundtripと、`editor/effect-studio` のdocument/runtime/timeline分離も参照した。
既存アセットや生成済みメディアはコピーしていない。

## 今回実装した判断

**編集の入口を共有する。** 人間の入力、AIのJSON、ファイル読込は同じコマンド検証を通す。
期待revisionを必須にし、人がInspectorで触った後に古いAI提案が上書きする状況を検出する。
バッチの成功時にだけ履歴へコミットする。Undo/Redoもrevisionを進め、版番号の巻き戻しによる古い提案の再受理を防ぐ。

**永続ドキュメントと作業コンテキストを分ける。** ノードとAction、ゲーム固有リソース、フォーム定義は保存対象。
選択、視点、レイアウト、再生時刻は作業対象であり、ドキュメントのUndoに混ぜない。
SceneとActionのレイアウトは同じビューを再配置するため、切替で編集が消えない。
現段階では1つの選択と時計を共有する。独立時計を持つ比較ビューは必要になった段階で追加する。

**レンダラーを再構築可能にする。** MoonBitで検証済みドキュメントからthreeのグラフを構築し、ビューの破棄時にはgeometry/material/購読/RAF/イベントを解放する。
プレビュー変位は別グラフに適用し、保存やGLB書出は編集ドキュメントから生成する。
三次元の前後・側面・上面の確認は共通カメラ操作で行う。

**シークを純粋な関数にする。** 現段階の閃光と反動は `Action × time -> Preview`。
逆方向にも同じ結果を返す。Actionは安定IDでターゲットを参照し、対象削除と参照解除は同じUndo単位。
音声イベントは未実装。後で追加する場合もシークによる音声再生とライブイベント消費を分離する。

**限界を実装と一緒に示す。** 今回のプリミティブID一覧はリソースAPIの最小形であり、完全なアセットDBやプラグインSDKではない。
3列それぞれを上下に分割し、境界ドラッグで列幅と各列の高さを調整する。全体は100vh、各ペーンがスクロールを所有する。
寸法はScene / Actionごとの作業状態として保存し、編集履歴には入れない。2つの配置プリセットは固定であり、任意のドッキング機構ではない。
テストは操作・データ整合性の確認であり、ゲームやモデルの見た目の品質保証ではない。

## ヘッドレスの境界

`core/editor.mbt` の `Editor` がSessionと作業コンテキスト（選択、時刻、レイアウト名）を所有する。
LunaのSignalはその表示用の写しとし、ヘッドレス版へUI状態ロジックを複製しない。
ブラウザ版とNode版のどちらも同じコントローラへリクエストを送り、JSONのsnapshotまたは構造化エラーを受け取る。
ペーン寸法やカメラなど表示だけの状態はブラウザアダプターに残す。

`headless` はcoreだけに依存するJSエクスポート。DOM・Luna・threeを読み込まず、プロセス内で独立したインスタンスを生成できる。
NodeのJSONL CLIはstdin/stdoutとファイルI/Oを担当し、部分的に成功した実行を完成データとして保存しない。
正常な起動時ロードはrevision 0から開始し、履歴はそのプロセス中だけ保持する。稼働中の読込は通常のUndo可能な編集。
MoonBitの内部Resultや構造体を公開する代わりに、初期化エラーだけJS例外へ変換し、操作は安定したJSON応答に統一する。

CLIは開いている画面のセッションへ接続しない。描画・GLB書出は現状ブラウザ側の機能。
描画のないNodeテストに加え、同じ操作をブラウザへ送るE2Eでsnapshotとエラーの一致を確認する。

## 拡張順序

| 接続 | 追加する契約・アダプター | 成立条件 |
| --- | --- | --- |
| GLBなどのアセット | Asset ID、種別、生成レシピ、source/provenance、依存、版。ローダーはレンダラー側 | 読込失敗や遅延で現在のシーンを壊さず、ID参照を復元できる |
| modeling3d | ModelDocumentを独立リソースとして登録し、プレビューとGLB出力をビューへ | 再生成でsceneのインスタンスIDと配置を失わない |
| effect-studio | EffectDocumentと純粋な時刻サンプルをActionビューから参照 | 逆シーク・再生・停止が同じ編集データから一致する |
| モーション・IK | リグ・クリップ・poseの別契約とドメインコマンド | 元クリップを保持し、焼込後のGLB再読込で姿勢と時間が一致する |
| 音声 | 生成コードとプリセット、イベントIDと同時発音制限 | シークは無音、再生のみイベントを消費、出典を追跡できる |
| Game実行 | 検証済みドキュメントからruntime planを作り、別実行セッションへ渡す | 停止後に編集状態を保持、再実行で時計とイベントをリセット |
| カスタムビュー（基盤実装済み） | 宣言的manifest＋JSON invoke＋任意mount。JS / MoonBit JS / wasm32 | 親がWebMCP公開と編集検証を所有し、表示を閉じてもツールを利用できる |
| 比較・レイアウト | ビューID・対象版・時計グループを含むレイアウト契約 | 採用版を保持し、候補だけ破棄できる |

kaguraへの接続は editor -> engine の向きだけにする。エンジン公開型からLunaやエディタのSessionを参照しない。
SceneDocumentをkaguraの世界全体の永続仕様とはしない。実際のゲーム接続時に、sceneからruntime planへの変換契約を別に定義する。

## 検証

`just studio-ci` でドメインテスト、warning-free check、静的ビルド、Playwright E2Eを実行する。
原子的失敗、整数の厳密性、版競合、循環と欠落参照、削除・Undo、JSON往復、逆シークをドメイン側で確認。
UIとAIの混在編集、保存・復元、不正読込、対象切替、購読解除、GLBの編集座標、狭い画面、入力拒否からの復帰をブラウザ側で確認する。

実行環境: Node 24.12.0 / MoonBit 0.1.20260824 / pnpm 10.33.0。
ルートの既存 `moon test --target js` は `engine/physics/physics3d/world.mbt` などの `Array(capacity=...)` と現行コンパイラの不整合で失敗した。
本エディタは独立workspaceで検証する。既存エンジン全体が通ったという主張はしない。

## カスタムペーンとWebMCPの境界

ペーン自身がツールのSchemaと効果を宣言する [プラグインAPI v1](pane-plugin-api.md) を追加した。JS、MoonBitのJS出力、線形メモリWasmが共通JSON transportを使い、親ホストが名前空間、世代交代、キャンセル、revision、コマンドのcommitを管理する。WebMCP登録の寿命をビューのmountと分け、ヘッドレスでも同じツール処理を利用できる。

カスタムペーンは右下のタブホストへ同期mountし、閉じる・切替・差し替えで購読と外部リソースを解放する。ゲームデータは版付きResourceとして保存し、DOMや関数は保存しない。フォーム定義もResourceに置くため、AIやヘッドレスから作成した定義をブラウザで復元できる。汎用Resourceのゲーム固有制約はゲーム側で検証し、フォームの検証とDOM表示は別ファイルへ分ける。

Luna componentsの実部品はMoonBit側で描画し、編集APIの結果だけをSignalへ反映する。未確定の入力をプレビュー時計の更新で上書きしない。

WebMCPはdocument.modelContextへの登録アダプター。ツールのJSON Schema、実行・破棄、MoonBitドメイン検証を分離する。ツール実行による編集にもexpectedRevisionを要求する。対応しないブラウザで偽のAPIを注入せず、既存の編集APIを利用できる状態を保つ。実装はChromium 153の実APIで検証し、進行中の仕様案との呼び出し引数の差はテストのクライアント側で扱う。

## ストレージの境界

永続化をSceneDocumentと分け、StorageProviderのread/write/list/removeとBlob・MIME・ETagへ抽象化した。IndexedDB、DirectoryHandle、Worker HTTPを登録し、`{store,key}`でルーティングする。URLソースは読み取り専用でブラウザ/Nodeから直接取得する。JSONリソースのゲーム固有IDとオブジェクトストレージ上のキーは別の名前空間。

DocumentStorageは編集revisionと保存先ETagを別々に検証する。取得後もexpectedRevisionを通し、遅い通信で新しい編集を上書きしない。IndexedDBとR2は原子的な条件付き書き込み、File Systemは能力差を明示する。保存結果は呼び出し時点のrevisionに対応し、未保存編集が進んでも保存内容を後から差し替えない。

WorkerがR2 bindingと認証を所有し、UIとヘッドレスは同じHTTPプロバイダーを使用する。初期の認可範囲は単一共有ワークスペース。テナント分離は実際のゲーム配信・認証基盤への接続時に別途設計する。資格情報・DOMハンドルは保存ドキュメントへ含めない。
