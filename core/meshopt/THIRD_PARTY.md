# Third-party provenance

`vertex_codec.mbt`, `index_codec.mbt` and `filters.mbt` port the decoders of meshoptimizer 1.3 (commit `9e1f07b159d3`): the scalar paths of `meshopt_decodeVertexBuffer` (`src/vertexcodec.cpp`), `meshopt_decodeIndexBuffer` / `meshopt_decodeIndexSequence` (`src/indexcodec.cpp`) and `meshopt_decodeFilter{Oct,Quat,Exp,Color}` (`src/vertexfilter.cpp`). The test fixtures in `fixtures_test.mbt` were encoded by the same library and decoded by its scalar build (`MESHOPTIMIZER_NO_SIMD`).

## meshoptimizer license

MIT License

Copyright (c) 2016-2026 Arseny Kapoulkine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
