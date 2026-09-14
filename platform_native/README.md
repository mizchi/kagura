# Native platform integration

トップレベルの `platform_native/` に配置した native host の統合 module です。
既存の import 名は `mizchi/native_runtime_hooks` を使用します。

`platform/` の `DesktopNativeHooks` に従ってウィンドウ・入力を接続し、
wgpu-native、音声、フォントの hook も起動時に結線します。
`PlatformDriver` や入力の共通型は `mizchi/kagura_platform` が所有します。

ルートと各 example/editor の `moon.work` から参照します。この module の
`moon.work` でも依存をローカル解決できます。native の prebuild は
`../scripts/moon-prebuild-native-link-flags.cjs` を使用します。

`gfx_wgpu_native/` は GPU・GLFW・音声 FFI と backend state を所有します。
`capture/` は engine のキャプチャデータをファイルへ出力する native adapter です。
両方ともこの module の prebuild を共有し、engine からは import しません。
