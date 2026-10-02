# kagura_ui

レイアウト、入力イベント、フォーカス、UI snapshotを提供する共通UIモジュールです。

## ドラッグ＆ドロップ

`UIDragController` は `InputSnapshot` からマウス・タッチを取得し、`Array[UIEvent]` を返します。DOMや描画方式に依存しないため、Canvasのカード、インベントリ、エディタの項目などで使えます。OSのファイルドロップは別のホスト入力として扱います。

```moonbit
let drag = @ui.UIDragController::new(threshold=8.0)
// 毎フレーム呼ぶ。sources / targets は描画にも使う LayoutResult の配列。
let events = drag.update(
  input,
  source_at=fn(x, y) { @ui.hit_test(sources, x, y) },
  target_at=fn(source, x, y) {
    match @ui.hit_test(targets, x, y) {
      Some(target) => if accepts(source, target) { Some(target) } else { None }
      None => None
    }
  },
)
for event in events {
  match event {
    @ui.UIEvent::Drag({ phase: @ui.UIDragPhase::Drop, source, target: Some(target), .. }) =>
      apply_drop(source, target)
    _ => ()
  }
}
```

`source_at` はドラッグできる要素を、`target_at` は現在の位置で受け入れ可能な対象を返します。対象が重なる場合の優先順位も呼び出し側で決めます。既存の `UITree` のIDを使うか、`UINodeId::new` で描画側のIDを渡せます。IDは操作中に安定させ、要素の削除、画面変更、フォーカス喪失では `cancel()` を呼びます。移動するデータやゲームルールは呼び出し側が管理し、コントローラーは変更しません。

| イベント | 意味 |
| --- | --- |
| `Click(source)` | 移動量がしきい値に達する前に離した |
| `Drag(Start)` | しきい値に達した。既定は論理座標で8 |
| `Drag(Move)` | ドラッグ開始または座標の変更 |
| `Drag(Enter / Leave)` | 受け入れ可能な対象への出入り。対象変更はLeave → Enter |
| `Drag(Drop)` | 離した位置の対象が受け入れ可能 |
| `Drag(Cancel(reason))` | 明示的な取消、入力取消、無効化、対象外へのドロップ |
| `Drag(End(success))` | 開始済みのドラッグの終了。Dropの後だけtrue |

`UIDragEvent` は開始位置・現在位置、source、target、pointerを保持する不変の値です。Enter / Leaveのtargetは入った対象 / 離れた対象を示します。Startの後に必ずEndが1回あり、正常終了はDrop → End(true)、取消はCancel → End(false)です。しきい値前の取消はCancelだけを返します。

`snapshot()` は表示用の読み取り専用状態を返し、`dragging` でクリック候補とドラッグを区別できます。離す直前にも対象を再判定するため、対象の移動や受け入れ条件の変更を反映します。

`UIPointerInputAdapter` は最初の指を離すまで同じTouch IDを追跡します。他の指やマウスへ操作を引き継がず、マウス操作中に触れた指も無視します。Esc / 右・中央クリックは取消入力になります。座標変換は入力元で済ませてください。`enabled=false` でも `update` を毎フレーム呼ぶことで、無効中の入力が再開時に持ち越されません。

独自のホスト入力では `handle_pointer(UIPointerFrame, ...)` を使い、press / move / release / cancelを渡せます。`pointer()` は `update` が使う入力アダプターのフレームを返します。`update` の返り値には従来のPointer / Key / Scrollイベントも含まれます。`UIEvent` を網羅的にmatchしている利用側は、新しいPointerCancel / Click / Dragも扱ってください。

```bash
just ui-dnd-test  # JS / nativeの共通UIテストと警告チェック
```
