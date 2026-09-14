# camera3d

透視投影、Orbit/FPSカメラ、追従の平滑化とカメラ座標の変換を提供する。
公開APIは `pkg.generated.mbti` を参照。

## TPSのカメラ距離と衝突

`sweep_camera_boom(anchor, eye, blocked, step=0.12)` は区間をサンプリングし、
最初に衝突する直前の割合を0〜1で返す。`anchor.lerp(eye, fraction)` が安全側の位置になる。
カメラ半径、地形、建物をどう判定するかは `blocked(position)` へ渡す。
世界・物理エンジン・ゲームの状態には依存しない。

始点は安全な位置を前提とし、長さ0.001未満では照会せず1を返す。
これは連続衝突判定ではない。薄い壁を飛び越さないよう、壁の厚みより小さい `step` を選ぶ。
`step` が非正またはNaNなら0.12を使う。座標には有限値を渡す。

`release_camera_boom(previous, available, release~)` は縮める方向には即座に反映し、
伸ばす方向には指定割合で追従する。`release` は0〜1へクランプし、1なら即座に戻る。
カメラ更新ごとに一度呼び、フレームレートに応じた追従率は呼び出し元で決める。
衝突の影響を受ける実距離と、ユーザーが設定した希望距離は分けて保持する。

```moonbit
let clear = @camera3d.sweep_camera_boom(anchor, desired_eye, blocks_camera)
let available = requested_distance * clear
let distance = @camera3d.release_camera_boom(previous_distance, available, release=0.18)
```

遮蔽物自体を透過させる描画処理は上位層の `mizchi/kagura_engine/draw3d` にある。
