///|
extern "js" fn browser_viewport() -> Array[Int] =
  #| () => {
  #|   if (globalThis.__kaguraHeadless) return [960, 640];
  #|   if (globalThis.innerWidth <= 640) return [360, 640];
  #|   const w = Math.min(960, Math.max(640, Math.floor(globalThis.document?.querySelector('#app')?.getBoundingClientRect().width || 960)));
  #|   return [w, Math.max(440, Math.round(w * 2 / 3))];
  #| }

///|
fn default_viewport() -> (Int, Int) {
  let size = browser_viewport()
  (size[0], size[1])
}
