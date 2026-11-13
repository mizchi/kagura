# シーン遷移の状態機械

`Definition` にシーンとイベントの遷移表を宣言し、同じ定義を実行・検証・可視化に使う。
描画や Studio に依存しない。JSON の最小例は [example.json](./example.json)。

```moonbit
let definition : @scene_flow.Definition = {
  entry: "title",
  scenes: ["title", "play", "result"],
  terminal: ["result"],
  transitions: [
    { from: "title", event: "start", to: "play" },
    { from: "play", event: "finish", to: "result" },
    { from: "play", event: "retry", to: "play" },
  ],
}
let report = definition.analyze()
let flow = @scene_flow.Flow::from_definition(definition)
let ticket = flow.send("start")
// 読込・検証が成功したら確定する。失敗時は cancel(ticket)。
ignore(flow.commit(ticket))
assert_eq(flow.current(), "play")
```

状態は `Flow`、遷移と解析は `Definition` が所有する。`from_definition` は宣言のコピーを保持し、
構造エラーのある定義を拒否する。ロード中の再要求、無効なイベント、未宣言の遷移を拒否しても
現在のシーンと有効なチケットを変更しない。取り消したチケットや古いチケットでは確定できない。

`send(event)` は現在のシーンでイベントを解決する。`request(target)` も宣言された辺だけを許可する。
既存の enum・Signal・保存データで状態を持つゲームでは `Definition::require_transition(from, to)` で
遷移を検証できる。状態を `Flow` と二重管理せず、検証に成功した後でゲーム側の状態を更新する。
従来の `Flow::new(ids, entry)` は互換用で、登録済みシーン間の移動を制限しない。
新しいゲームでは `from_definition` を使う。条件判定はゲーム側で行い、成立時にイベントを送る。
終端は明示し、終端からの出辺は定義しない。リトライ可能な結果画面は終端に含めない。

## 検証項目

| 対象 | 診断 | 扱い |
| --- | --- | --- |
| 空・重複したシーンID、未定義の開始・終端 | `invalid-scene`, `duplicate-scene`, `invalid-entry`, `unknown-terminal`, `duplicate-terminal` | エラー |
| 未定義の遷移元・遷移先、空のイベント | `unknown-source`, `unknown-target`, `invalid-event` | エラー |
| 同じシーン・イベントの重複、終端からの遷移 | `ambiguous-event`, `terminal-transition` | エラー |
| 開始シーンから到達できないシーン | `unreachable-scene` | 警告 |
| 到達不能な遷移元、不正な辺 | `dead-transition` | 警告 |
| 終端として宣言されていない行き止まり | `dead-end` | 警告 |
| 終端への経路がない状態・循環 | `no-terminal-path` | 警告 |

`report.valid` はエラーの有無を示す。警告も含めて問題なしを要求する場合は `report.issues.is_empty()` を使う。
診断の `transition` は定義配列の0始まりの添字で、シーン単位の診断は `-1`。
循環と自己遷移は許可する。終端を宣言しないゲームでは終端への経路を要求しない。

到達可能性は宣言の構造に対する判定であり、任意の条件式やコールバック内部のデッドコード、
イベントが実際のプレイで発火するか、遷移の実行カバレッジまでは判定しない。

## Studio と CLI

Studio のツールバーの「シーン遷移」から定義 JSON を読み込むと、遷移図・イベント一覧・検証結果を表示する。
図の番号は一覧の番号に対応し、問題を選ぶと対象のシーンと関係する行を強調する。
不正な定義も検証用に表示でき、JSON の構文・型エラーでは以前の表示を保持する。
Mermaid (`.mmd`) と定義 JSON を書き出せる。`Definition::to_mermaid()` でも図を取得できる。

「プロジェクトから読込」は Arena などの `kagura.scene` コンポーネントを持つ名前付きシーンに対応する。
現在編集中のシーンと他のシーンの未保存ドラフトを読み、ゲームと同じ MoonBit コンパイラでポータルを変換する。
ポータルIDを `portal:<id>` イベントに使い、ポータルのないシーンを終端とする。
`scene_data.Project::flow_definition()` と `Session` も同じ変換を使うため、実行時にも未宣言の移動を拒否する。
表示は読み込んだ時点の内容で、変更後は再読込する。ポータル以外の画面遷移はプロジェクトに宣言した定義、または手動で読み込んだ JSON を使う。

### 既存ゲームへの適用

examples カタログのゲーム9本を共通の検証対象にしている。

| ゲーム | 対象 |
| --- | --- |
| Arena 3D | 編集可能なシーン間のポータル |
| Flappy Bird | タイトル・プレイ・ゲームオーバー |
| Survivor | タイトル・プレイ・レベルアップ・ゲームオーバー |
| AFTERSHIFT | タイトル・プレイ・一時停止・敗北・クリア |
| EMBERWING | タイトル・プレイ・一時停止・敗北・勝利 |
| IRON YARD | 準備・プレイ・一時停止・敗北・勝利 |
| Ember Ascent | タイトル・設定・キャラクター選択・プレイ |
| FATHOM | 街・探索・戦闘・宝箱・警告・遠征達成 |
| ASHEN REALMS | タイトル・キャラクター選択・プレイ・ゲームオーバー |

各ゲームの `flow/definition.mbt` が実行時と可視化の共通定義。
Arena は同じポータル定義を読み、それ以外は `editor/scene-flow.json` を MoonBit のエクスポートから生成する。
`.kgrprj` の `sceneFlow: {"resource":"sceneFlow"}` と `resources.sceneFlow` で生成物を参照する。
Studio の「プロジェクトから読込」は、この宣言があれば名前付き空間シーンのないゲームでも画面遷移を表示する。
`studio-examples-build` も定義の再生成と同梱を行う。

```sh
just scene-flow-examples-build                # 全9本の定義をコンパイル・生成
just scene-flow-examples-build card_game      # 1本だけ再生成
just scene-flow-examples-check                # 構造検証と生成物の鮮度確認
just scene-flow-examples-test                 # 全ゲームのJS/native・共通契約テスト
```

通常の画面変更はゲーム側の型付き遷移メソッドを通す。新規インスタンスの生成、セーブ・デバッガーの復元、
テスト・プレビューの初期状態設定は状態の生成・復元として扱う。戦闘内のターン進行や UI オーバーレイは
この画面遷移の定義には含めていない。シーン遷移のない単一画面の描画デモは対象外。

```sh
just scene-flow-check                         # サンプル定義を検証
just scene-flow-check path/to/flow.json       # 警告・エラーで終了コード1
just scene-flow-mermaid path/to/flow.json > flow.mmd
node scripts/scene-flow.mjs --json path/to/flow.json
just scene-flow-test                         # JS/native、型、CLI のテスト
just scene-flow-e2e                          # Studio の操作テスト
just scene-flow-ui                           # Studio dev server 起動後の表示検証
```

CLI の終了コードは問題なし `0`、構造上の警告・エラー `1`、入力や読込の失敗 `2`。
`-` で標準入力を読める。解析本体は MoonBit で、JS は JSON の受け渡しと入出力のみを扱う。
ブラウザ向け生成物は `just web-runtime-build` で再生成し、`just web-runtime-check` で鮮度を検証する。
