# Third-party provenance

`assets/source/room-pmrem.rgba16f` and its JSON metadata are an offline export of Three.js 0.185.1 `RoomEnvironment`, filtered with `PMREMGenerator` at blur 0.04. The original 768×1024 CubeUV atlas is preserved as little-endian RGBA16F. `tests/render-reference.json` records rendered MeshStandardMaterial and ACESFilmic reference patches from the same version. Regenerate these with `scripts/export-three-reference.mjs`. Three.js is only needed for offline export; runtime rendering uses Kagura.

`engine/kagura_engine/draw3d/dfg.mbt` and `tests/dfg-reference.json` contain the DFG lookup table from Three.js `src/renderers/shaders/DFGLUTData.js`, decoded from half floats by `scripts/import-dfg.mjs`.

The WGSL Standard material profile in `engine/kagura_engine/draw3d/shaders/` adapts Three.js `lights_physical_pars_fragment.glsl.js`, `cube_uv_reflection_fragment.glsl.js`, `tonemapping_pars_fragment.glsl.js`, and color-space/fog shader chunks. The legacy `draw3d/environment.mbt` also adapts its indirect-light multiple-scattering calculation. These sources and assets are covered by the Three.js MIT license below.

`shaders/shadow.wgsl` (under `draw3d/`) ports the r185 `shadowmap_pars_fragment.glsl.js` PCF, Vogel disk sampling and interleaved gradient noise. `tests/shadow-reference.json` in IRON YARD is rendered from that original GLSL with a WebGL comparison sampler by `scripts/export-shadow-reference.mjs`.

## Three.js license

The MIT License

Copyright © 2010-2026 three.js authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
