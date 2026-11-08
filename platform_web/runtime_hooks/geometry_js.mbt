///|
/// Register immutable mesh arrays for repeated draws without scanning vertices.
/// Replace the arrays to change geometry. Registration is scoped to the current
/// GPU runtime and weakly owned, so it is safe to call before every draw.
pub fn register_static_geometry(
  vertices : Array[Double],
  indices : Array[Int32],
) -> Unit {
  js_register_static_geometry(pack_doubles(vertices), pack_ints(indices))
}

///|
extern "js" fn js_register_static_geometry(
  vertices : FixedArray[Double],
  indices : FixedArray[Int32],
) -> Unit =
  #| (vertices, indices) => {
  #|   const gpu = globalThis.__kaguraWebRuntime?.webgpu;
  #|   if (gpu) globalThis.__kaguraGfx?.registerStaticGeometry?.(gpu, vertices, indices);
  #| }
