# Third-party provenance

`dfg.mbt` contains the DFG lookup table from Three.js 0.185.1 `src/renderers/shaders/DFGLUTData.js`, decoded from half floats by `examples/games/iron_yard/scripts/import-dfg.mjs`. The indirect-light multiple-scattering calculation in `environment.mbt` is adapted from Three.js `ShaderChunk/lights_physical_pars_fragment.glsl.js`.

The Standard material profile is ported to WGSL from the same version:

- `shaders/standard.wgsl`: `lights_physical_pars_fragment.glsl.js`, GGX, direct/indirect multiple scattering and environment lighting.
- `shaders/cube_uv.wgsl`: `cube_uv_reflection_fragment.glsl.js`, native PMREM CubeUV sampling and roughness mapping.
- `shaders/color.wgsl`: `tonemapping_pars_fragment.glsl.js`, ACESFilmic color matrices and RRT/ODT fit; color-space and fog shader chunks.

`standard_sources.mbt` embeds these WGSL files and carries the same provenance. The Three.js MIT license follows.

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
