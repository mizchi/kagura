# Geometry and draw storage

`installGfxHelpers()` exposes these APIs on `globalThis.__kaguraGfx`; they are also ES module exports from `kagura-gfx.js`. All resources are scoped to a WebGPU runtime (`gpu`).

## Explicit geometry generations

```js
registerGeometry(gpu, "level/wall", 0, vertices, indices);
// Reuse the same source arrays in draw submissions: lookup is O(1).
vertices[0] = newX;
registerGeometry(gpu, "level/wall", 1, vertices, indices);
// Remove when the asset is unloaded.
unregisterGeometry(gpu, "level/wall");
```

- IDs are strings, safe integers or symbols (used internally for the static shortcut). Revisions are nonnegative safe integers and must increase when contents or source arrays change. Re-registering the same ID/revision and arrays is an O(1) no-op. Stale revisions and conflicting owners are errors.
- Both vertex and index source arrays identify a resource. They may not be registered under multiple IDs. Uploads pack vertices to f32 and indices to u32 only at registration/revision changes. Callers must treat returned snapshots as read-only.
- Already queued draws retain their old immutable snapshots across revisions, including same-size edits. Unregistered arrays keep the legacy content-comparison behavior; do not opt mutable meshes into the static shortcut.
- `registerStaticGeometry(gpu, vertices, indices)` is a convenience for assets whose arrays never change, as in IRON YARD. It registers once and reuses the snapshot on subsequent calls. Static IDs are internal.
- Registered immutable snapshot buffers are shared across shadow/main passes and draw slots. Unused GPU buffers are destroyed within 240 rendered frames; all are destroyed by `releaseGpuResources`. Explicit registry entries remain until unregister/release. Old queued generations do not depend on their registry entries.

## Frame ownership

`beginDrawFrame(gpu)` resets the command cursor. `enqueueCustomDraw(gpu, command)` copies uniforms and texture IDs into storage owned by that queued draw. Submit with `renderGpu` before beginning the next frame. The pool may overwrite submitted CPU records only after submission; WebGPU has copied uploaded bytes. The renderer retains a separate uploaded-uniform snapshot so in-place reuse does not suppress updates.

`submitCustomDraw` accepts positional shader/geometry/uniform/target arguments from the MoonBit JS FFI and writes directly to the same frame pool, without an intermediate descriptor. Borrowed arrays are consumed synchronously and copied before this call returns. The descriptor API remains available through `enqueueCustomDraw`. Bind groups compare actual texture views and samplers; cached draws allocate no entry descriptors or texture-key strings.

MoonBit `pbr_uniform_dwords` and `new_pbr_mesh_draw_command` accept optional `storage=Some(array)`. Supply the exact layout length (72/84/92/104 words). Every draw in a frame needs a distinct array; reuse it after frame submission. Padding is reset along with active values. Default callers still receive fresh arrays.

## Opt-in uniform instancing

`instanceUniformShader(source, dwords)` adapts the Standard/depth WGSL contract (`Uniforms`, `VertexInput`, `VertexOutput`, `vs_main`, `fs_main`) to 32 uniform records. It validates known entry-point signatures and reserves flat varying location 7. Uniform records must be 16-byte aligned, at most 128 dwords: the maximum buffer size is 16 KiB. Unknown shaders remain unchanged unless explicitly passed to this adapter.

Submit one complete uniform record per draw through `enqueueCustomDraw`. Adjacent opaque draws merge only when shader, immutable geometry, texture IDs, destination dimensions and vertex format agree. Materials and transforms may differ: both shader stages select the same record via instance index. Transparent draws remain separate and preserve submission order. No automatic sorting or regrouping occurs in the backend. IRON YARD groups only its opaque enemy bodies by batch before submitting; transparent enemy parts preserve enemy order. Existing shaders and explicitly instanced commands keep their original path.

See `kagura-gfx.test.mjs` for generation, pooling, sharing, capacity and ordering tests. IRON YARD's Metal parity tests exercise nonzero instance indices against original Three.js PBR output.
