# Web host sources

DOM、WebGPU、音声出力、Worker、Node キャプチャの手書きホスト実装。
`just web-runtime-build` が `.js` を `assets/web` へ同期する。相対 import は配布先を基準とし、
Node テストも配布先の実装を検証する。配布 URL と ESM export は変更しない。
入力・再生・配置・統計のアルゴリズムは MoonBit 側に置く。
