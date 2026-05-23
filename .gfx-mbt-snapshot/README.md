# mizchi/gfx

Backend-agnostic GPU command-buffer and driver contracts for MoonBit.

Extracted from [mizchi/kagura](https://github.com/mizchi/kagura) so other
MoonBit projects can reuse the rendering primitives without pulling in
the whole game engine.

## What's in here

The package exposes a layered surface that any WebGPU / wgpu-native /
offscreen backend can implement:

- **Command buffer** — `DrawTrianglesCommand`, `DrawCommandDispatch`,
  `DstRegion`, `Color`, `RenderPassDesc`, `dispatch_checksum`.
- **Handles** — `ImageHandle`, `ShaderHandle`, `PipelineHandle`,
  `FilterMode`.
- **Blend state** — `BlendFactor`, `BlendOperation`, `BlendEquation`,
  `BlendMode`, plus `blend_mode_to_equation` etc.
- **Driver trait** — `GraphicsDriver` (initialize / begin / end / resize
  / new_image / new_shader / draw_triangles / read_pixels) and a
  `FramebufferSnapshot` / `PixelDiffResult` harness for VRT.
- **Command queue** — `CommandQueue` trait and `SimpleCommandQueue`
  implementation that does adjacent-batch merging within a vertex
  budget.
- **Backend hooks** — `StubGraphicsDriver`, `NativeGraphicsHooks`,
  `WebGraphicsHooks`, `GraphicsBackendFactory` for plugging in concrete
  backends at runtime.
- **Shader plumbing** — `ShaderFrontend`, `UniformCanonicalizer`,
  `BuiltinShaderSourceRepo` traits with `BasicShaderFrontend` /
  `BasicUniformCanonicalizer` / `BasicBuiltinShaderSourceRepo`
  reference implementations.
- **Surface descriptor** — `SurfaceKind`, `SurfaceToken`,
  `SurfaceProvider` trait, `create_offscreen_surface_token` and friends.

Nothing here knows about games, scenes, ECS, assets, or platform shells;
those layers live elsewhere (in kagura, in your engine, ...).

## Layout

```
src/
  handle.mbt              ImageHandle / ShaderHandle / PipelineHandle / FilterMode
  blend.mbt               BlendFactor / Operation / Equation / Mode + conversions
  contracts.mbt           DstRegion / Color / RenderPassDesc / DrawTrianglesCommand /
                          DrawCommandDispatch / dispatch_checksum
  driver.mbt              GraphicsDriver trait + FramebufferSnapshot / PixelDiffResult
  queue.mbt               CommandQueue trait + SimpleCommandQueue + merge logic
  surface.mbt             SurfaceKind / SurfaceToken / SurfaceProvider + factories
  backend_contracts.mbt   StubGraphicsDriver / GraphicsBackendKind / hooks registry
  backend_native_hooks_stub.mbt
  backend_web_hooks_stub.mbt
  shader_contracts.mbt    ShaderIR / ShaderFrontend / Uniform plumbing
```

## Status

- API is **unstable** while the kagura migration settles. Treat the
  surface as if it could break between any two patch versions until a
  1.0 line is published.
- All traits are declared `pub(open)` and all command / uniform / handle
  types are declared `pub(all)` so downstream packages can implement /
  construct them.

## Using it locally

`moon.mod.json`:

```json
{
  "deps": {
    "mizchi/gfx": { "path": "../gfx-mbt" }
  }
}
```

`moon.pkg`:

```moonbit
import { "mizchi/gfx" @gfx }
```

## License

Apache-2.0. Inherited from kagura.
