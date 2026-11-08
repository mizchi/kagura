# Webポインター入力

JS用の`WebPointerInput`はCanvasごとにマウス・タッチ・ペンの入力を保持し、共通UIの`UIPointerFrame`へ変換する。

JS以外のバックエンドでも型とメソッドは同じで、`poll`は`None`を返す。入力を`InputSnapshot`へフォールバックする処理を共通に書ける。

```moonbit
let pointer = @hooks.WebPointerInput::new(selector="#app")
// CSS上のCanvasサイズからゲームの論理座標へ変換する。
let frame = pointer.poll(width=game_width, height=game_height)
// Some(frame)ならUIModalLayer.handle_pointerやUIDragController.handle_pointerへ。
// Canvasのないヘッドレス実行ではNoneなのでInputSnapshotにフォールバックできる。
pointer.dispose()
```

押下・解放・取消はキューで保持し、フレーム間に完了した短いタップも押下→解放の順に消費する。移動は最新の小数座標を使い、補間しない。最初のポインターを解放まで所有し、別の指へ操作を移さない。ペンはTouch IDとして扱う。

Pointer CaptureでCanvasの外まで追跡し、`pointercancel`・Capture喪失・Esc・右クリック・ウィンドウのフォーカス喪失・非表示化で取消を通知する。非表示化とフォーカス喪失では未消費のクリックも破棄する。Canvasにフォーカスがある間はTab、Space、方向キーのブラウザ既定動作を抑止する。

同じCanvasへの再登録は入力とイベントリスナーを共有する。別のCanvasは独立する。`dispose()`は共有ハンドルを無効化してリスナーとCaptureを解放し、同じCanvasへ改めて登録できる。`@hooks.uninstall()`／`shutdown()`でも全バッファを解放する。

UIの入力スコープやゲームの合法手はこのホスト層へ持ち込まない。マウスとタッチを同じUI契約へ渡し、モーダル制御と実際の操作判定は共通UI／アプリ側が担当する。
