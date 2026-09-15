# projectile3d

描画や敵の型に依存しない、3D の飛翔体の処理。現在は予告後に発射するビームを提供する。

`BeamPath` は発射地点・予告時に固定した狙い・発射までの秒数・速度・光線の長さ・最大距離を持つ。
`new` の入力には有限値を渡す。方向がゼロ、待ち時間が負、速度・長さ・距離が非正なら `None`。
時間は秒、位置と長さはゲームのワールド単位。実行中の age、命中済みかどうか、ダメージ、寿命は呼び出し側が保持する。

```moonbit
let path = @projectile3d.BeamPath::new(
  origin, aim, delay=1.2, speed=220, length=22, range=200,
).unwrap()
// HUD の予告と発射音
let progress = path.charge_progress(age)
let fired = path.just_fired(previous_age, age)
// 描画はその瞬間の範囲、衝突判定は前の末尾から現在の先端までの範囲。
let visible = path.segment_at(age)
let sweep = path.swept_segment(previous_age, age)
```

どちらの範囲も `@math3d.Segment3?`。予告中と最大距離を末尾まで通過した後は `None`。
一度の更新で予告終了をまたいでも、衝突範囲は発射地点から始まる。
`Segment3.distance_squared(center)` と半径の二乗を比較すれば、高速な弾も位置の飛び越しで判定を失わない。
停止中は age を進めず、発射方向を変えたいときは新しい `BeamPath` を作る。

使用例は `examples/games/emberwing`。同じ path を戦闘判定、3D 表示、HUD が参照する。
