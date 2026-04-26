# mizchi/kagura_js_runtime

`modules/js_runtime` は JS 専用ランタイムパッケージを分離した MoonBit module です。

- core module: `../../moon.mod.json`
- js runtime module: `modules/js_runtime/moon.mod.json`
- package prefix: `mizchi/kagura_js_runtime/*`

検証:

```sh
cd modules/js_runtime
moon check --target js
```
