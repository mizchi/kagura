# ゲーム一覧のサムネイル

`/examples/` で使う実際のゲーム画面。JPEG、品質 85、960 × 600 のブラウザから撮影する。通常のデモは canvas だけ、独自 HUD を持つ EMBERWING / ASHEN REALMS / IRON YARD はプレイ領域全体を保存するため、画像の縦横比はゲームごとに異なる。一覧は比率を維持して表示する。

生成: `just pages-thumbnails <公開物を配信しているルート URL>`。撮影の後に画像を目視確認し、`just pages` でサイトに反映する。通常のビルド・E2E は画像を上書きしない。

- EMBERWING: `?encounter=swarm` の Wave 9 を開始した画面。
- ASHEN REALMS: `?snapshot=site&site=ruins&seed=42&mute=1` の廃墟。
- IRON YARD: 通常の出撃メニューから開始した市街地。
- その他: 標準の初期ステージを開始。Flappy Bird は土管が入るまで羽ばたき、Survivor は敵が出現してから撮影。

出典はすべてこのリポジトリの `examples/games/<id>`。新しい画像は `<id>.jpg` とし、説明・代替テキストは `examples/catalog.json` の `gallery` に置く。
