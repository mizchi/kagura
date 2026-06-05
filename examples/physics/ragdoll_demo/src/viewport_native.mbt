// On native the cursor already arrives in the logical (screen_w x screen_h)
// window space, so reporting the logical size makes the CSS->logical scale in
// the update loop a no-op. See viewport_js.mbt for the web counterpart.

///|
fn canvas_css_w() -> Double {
  screen_w.to_double()
}

///|
fn canvas_css_h() -> Double {
  screen_h.to_double()
}
