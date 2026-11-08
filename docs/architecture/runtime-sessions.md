# 実行 session と失敗・停止の契約

`engine.start` / `engine.start_game` は `RunSession` を返す。
`run` / `run_game` は従来どおり `Unit` を返す入口で、同じ session 実装へ委譲する。
scene の入口にも `on_error` を渡せる。

```moonbit
let session = @engine.start_game(
  game,
  on_error=fn(error) { println("\{error.stage}: \{error.message}") },
)
// JS は自動的に次のフレームを予約する。
// native / wasm の start はホストが session.step() を駆動する。
// native の run は終了まで step() を繰り返す。
session.stop()
```

## 状態とエラー

型は [session_types.mbt](../../engine/session_types.mbt)、
寿命の処理は [session.mbt](../../engine/session.mbt)、
初期化・フレーム処理は [run_session.mbt](../../engine/run_session.mbt) に置く。

| 状態 | 意味 |
| --- | --- |
| `Starting` | リソース作成中、または非同期 GPU 起動待ち |
| `Running` | backend の readiness を確認し、ゲーム callback を実行可能 |
| `Stopped` | 明示停止・window 終了。以降 callback は実行しない |
| `Failed(RunFailure)` | 起動・描画失敗。原因を保持したまま停止済み |

`RunFailure.stage` は文字列ではなく `RunStage`。
backend / options / platform / surface / graphics / image / shader / frame /
input / resize / update / draw / render / audio を区別する。
初期化例外から仮の image / shader を作って続行しない。
viewport と audio tick の無効値も起動失敗として返す。

WebGPU が待機中は update / draw を呼ばない。失敗・device loss・非同期 shader 診断は
backend probe から session へ通知する。`on_error` は最初の失敗について一度だけ呼ぶ。
`on_error` を省略した入口は段階と原因をログへ出す。呼び出し元が状態を取得する場合は
`start` の戻り値を保持する。

## 所有と解放

session は開始時の clock、終了 hook、frame host を捕捉する。
後から登録を差し替えても、停止時に別の session の hook を呼ばない。

`FrameHost.request_frame` と `on_exit`、services の同名関数は解除関数を返す。
`request_frame` は callback を非同期に予約し、戻る前に callback を実行しない契約とする。
JS 実装は `cancelAnimationFrame` / `removeEventListener` を呼ぶ解除関数を返す。

`stop` / `fail` は先に終端状態へ移行し、予約フレームを無効化・解除してから、
所有する解除関数を取得と逆順に実行する。音声出力も取得に成功した場合だけ閉じる。繰り返し停止しても二重解放しない。
解除後に古い callback が届いてもゲーム処理を呼ばず、新しい予約に干渉しない。
GPU 初期化 promise と vsync submit にも世代を持たせ、停止後に古い GPU 処理が復帰しない。

## 現在の backend 容量

現在の graphics hook は JS realm / native runtime ごとに一つの GPU 状態を持つ。
そのため、既存 session を止めない二重起動は `Failed(Backend)` として拒否する。
入力・GPU のグローバル状態を二つの実行から同時に操作させない。
複数 preview を並べる場合は iframe / worker 等で host を分ける。
`RunSession` の clock・frame host・解除処理そのものは独立して扱える。

固定 timestep の `runtime.run_loop` と per-frame の engine loop は引き続き別の実行モデル。
統合したのは engine の JS / native / wasm 間の初期化・フレーム・停止処理である。

## 検証

`session_wbtest.mbt` / `startup_wbtest.mbt` は失敗注入、待機中の未実行、
解除順序、二重停止、再予約、clock / hook の捕捉、二重起動を fake host で検査する。
`just session-e2e` はブラウザの GPU 起動・失敗・停止後の予約数を検査する。
native window を開くテストは含めない。
