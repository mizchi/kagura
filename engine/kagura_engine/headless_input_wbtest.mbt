///|
test "headless input callback replays press release and press in tick order" {
  let observed : Array[Bool] = []
  let result = render_headless_frame(
    update=input => observed.push(input.pressed_keys.contains(9)),
    draw=_ => [],
    width=2,
    height=2,
    frames=3,
    input_at=tick => {
      @core.new_input_snapshot(
        0.0,
        0.0,
        0.0,
        0.0,
        if tick == 1 {
          []
        } else {
          [9]
        },
      )
    },
  )
  assert_eq(observed, [true, false, true])
  assert_eq(result.frames, 3)
}
