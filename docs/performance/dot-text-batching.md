# dot text が 1 ドット 1 draw command だった

- Date: 2026-09-11
- Scope: `engine/renderer2d`、`engine/kagura_engine`（headless の meta）、
  `game/kagura_game/scene`（bench）、`lib/web`、`scripts/render-frame.mjs`
- 出発点: [physics-followups.md](./physics-followups.md) の作業項目
  「4.2x 速い `new_atlas_quad_batch_draw_command` が誰からも呼ばれていない」。
  **その関数は配線しなかった** —— まとめて描くべき quad が atlas ではなく
  dot text にあったため（下記「なぜ atlas ではなかったか」）

## Conclusion

`@renderer2d.append_dot_text` は 3x5 ドットマトリクス glyph の**点灯ドット 1 個ごとに
`@gfx.DrawTrianglesCommand` を 1 個**作っていた。1 文字あたり 8〜11 個。

これはリポジトリの 2D テキスト経路の**全部**である: `@scene.label`、`@hud` の 2 箇所、
engine の profiler、editor の authoring HUD、example 20 本以上がここを通る。

ラン単位で 1 command にまとめた。**三角形とその順序は変わらない**ので rasterizer は
同じリストを歩き、同じピクセルを出す（frame VRT 17/17 バイト一致）。

| example | frame の draw command | 三角形 |
|---|---:|---:|
| `machinations_demo` | 1603 → **80**（20.0x） | 3062 → 3062 |
| `card_game` | 1215 → **117**（10.4x） | 1810 → 1810 |
| `draw2d_ui_demo` | 600 → **27**（22.2x） | 1212 → 1212 |
| `ui_demo` | 490 → **20**（24.5x） | 980 → 980 |
| `scene_demo` | 242 → **18**（13.4x） | 475 → 475 |
| `ecs_demo` | 181 → **25**（7.2x） | 268 → 268 |
| `action_rpg` | 177 → **3**（59x） | 354 → 354 |
| `survivor` | 128 → **3**（42.7x） | 256 → 256 |
| `flappy_bird` | 40 → **5**（8.0x） | 80 → 80 |
| `physics2d_demo` | 16 → 16（1.0x） | 112 → 112 |

**`physics2d_demo` が動かないのが対照群である** —— このフレームにテキストが無い。
三角形数が全部一致しているのが「同じ絵を描いている」ことの一次証拠で、
PNG のバイト一致がその確認になる。

この数は `just render <example>` が出すようにした（`N triangles in M command(s)`）。
**三角形数と独立に動く**ので、どちらか片方だけでは quad ごとの command 化に
戻ったことを検知できない。

## なぜ「ラン」が正しい粒度なのか

色は**頂点属性ではなく uniform** である（`color_to_uniform_dwords` →
`cmd.uniform_dwords`、rasterizer 側は `decode_uniform_color`）。だから色の違う quad は
頂点レイアウトを変えない限り同じ command に入れられない —— 隣り合う `@scene.rect` を
まとめられないのはこれが理由。

1 つのテキストランのドットは dst / shader / pipeline / blend / **色**をすべて共有する。
つまりランは **ABI を一切変えずにまとめられる最大の単位**である。

## なぜ atlas ではなかったか

`new_atlas_quad_batch_draw_command`（10,000 quad で 4.2x）は、同じ atlas source を
共有する quad 列を要求する。しかし**この repo の 2D ゲームは atlas quad 経路を通らない**:
`survivor` / `card_game` / `action_rpg` / `flappy_bird` はすべて `@scene.rect` /
`@scene.label` で描き、`@scene.render_rect` は `@renderer2d.append_rect_fill` を
rect ごとに呼ぶ。per-quad な atlas API の実利用は `hacknslash_3d` の 30 エントリ
アイコン（約 40 quad/frame）、`animation2d/draw.mbt`、`fetch_image`、smoke 2 本で、
どれも薄い。`append_atlas_tilemap_draw_commands` も、tilemap 側に
`append_tile_indexed_chunk_batched_draw_commands` が既にある分の legacy 経路だった。

**探していたワークロードは別の場所にあった**、というだけである。atlas batch API は
そのまま残してある（呼び出し側が現れたときのため）。

## 実測（`moon bench`、merge base と交互 3 回、中央値）

`text.mbt` / `primitives.mbt` の 2 ファイルだけを差し替えて交互に回した。bench
ファイルは両側で同一なので、変わっているのは実装だけである。**`just bench-gate` が
使うのと同じ regime**（workspace 全体の `moon bench --target js`）で測った。理由は
次節。

| bench | 前 | 後 | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `primitives/append_dot_text_10x20` | 803.7 µs | **573.3 µs** | **1.40x** | yes |
| `primitives/append_dot_text_scene_content_12` | 439.5 µs | **316.7 µs** | **1.39x** | yes |
| `scene/append_dot_text_direct_12` | 432.4 µs | **333.3 µs** | **1.30x** | yes |
| `scene/render_labels_12` | 418.5 µs | **334.6 µs** | **1.25x** | yes |
| `scene/render_hud_200x12` | 525.7 µs | **432.4 µs** | **1.22x** | yes |
| `scene/render_rects_12` | 2.9 µs | 2.4 µs | 1.21x | yes |
| `primitives/append_rect_fill_geometry_1000` | 362.8 µs | 334.0 µs | 1.09x | no |
| `primitives/append_rect_fill_1000` | 332.7 µs | 318.5 µs | 1.05x | no |
| `primitives/append_rect_fill_floor_1000`（床） | 2.2 µs | 2.2 µs | 1.01x | no |
| `scene/build_hud_200x12`（対照: node 木の構築） | 26.0 µs | 25.8 µs | 1.01x | no |

**CPU 側の利得は 1.2〜1.4x** である。command 数が 8〜24x 減ることの残りは GPU 側
（command 1 個が `setPipeline` / `setBindGroup` / `draw` になる）だが、**そこは測って
いない** —— Linux では移植可能な GPU キャプチャが無い（#9）。だから command 数は
「測れた構造的な変化」として報告し、描画時間の改善としては主張しない。

`scene/render_rects_12` が 1.21x で分離しているのは `append_rect_fill` 経由の
geometry も同じ関数に移ったため。ただし絶対値が 2.4 µs しかないので、フレームでの
意味は小さい。

## 最初に 8.89x と読んだ —— `moon bench -p` の値だった

この作業の最初の測定は `moon bench -p mizchi/renderer2d` で回して
**`append_dot_text` が 8.89x** と出た。上の表は同じ変更を 1.40x と言う。**片方は嘘で、
嘘なのは `-p` の側である。**

同じ after ソースを 2 つの regime で測った（`-p` は当該パッケージだけ、workspace は
`moon bench --target js`）:

| bench | `moon bench -p` | workspace | `-p` / workspace |
|---|---:|---:|---:|
| `primitives/append_rect_fill_floor_1000` | 43.1 µs | 2.2 µs | **19.6x** |
| `primitives/append_rect_fill_1000` | 723.5 µs | 318.5 µs | **2.27x** |
| `primitives/append_dot_text_scene_content_12` | 142.0 µs | 316.7 µs | **0.45x** |
| `primitives/append_dot_text_10x20` | 228.1 µs | 573.3 µs | **0.40x** |
| `primitives/append_rect_fill_geometry_1000` | 120.4 µs | 334.0 µs | **0.36x** |
| `scene/append_dot_text_direct_12` | 317.0 µs | 333.3 µs | 0.95x |
| `scene/render_labels_12` | 337.1 µs | 334.6 µs | 1.01x |
| `scene/render_hud_200x12` | 413.4 µs | 432.4 µs | 0.96x |
| `scene/build_hud_200x12` | 25.5 µs | 25.8 µs | 0.99x |
| `scene/render_rects_12` | 2.6 µs | 2.4 µs | 1.08x |

**分かれ方がきれいである。** `renderer2d` の中に置いた whitebox bench 5 本は
**0.36x から 19.6x まで両方向にずれ**、`kagura_game` から `renderer2d` を呼ぶ
bench 5 本は **0.95〜1.08x でずれない**。原因は切り分けていない。

だから `-p` で出た「8.89x」と、そのとき in-package と cross-module が 2.5x
食い違って見えたことは、**どちらも同じ 1 つの artifact** である。workspace regime では
`primitives/append_dot_text_scene_content_12`（439.5 → 316.7）と
`scene/append_dot_text_direct_12`（432.4 → 333.3）は**前後どちらも一致する**。

**実務上の規則: 倍率を主張するときは `just bench-gate` と同じ regime で測ること。**
`moon bench -p <pkg>` は反復を速く回すためのもので、その絶対値も倍率も、
そのパッケージ自身の whitebox bench については引用してはいけない。
`substeps` を振ったときの「順位付けには使えるが絶対値として引用してはいけない」と
同じ制約が、bench の起動方法にも付いている。

この 2 本はそのまま残してある。1 コマンドで artifact を再現できるようにしておくため
（`moon bench -p mizchi/renderer2d` と `moon bench -p mizchi/kagura_game/scene` で
2.5x 離れ、`moon bench` では一致する）。**ただし
`primitives/append_dot_text_scene_content_12` は baseline での自分の幅が 3.12x** あり、
gate は常に `NOISY` として扱う（落とさない）。`moon bench` は稀にこの 2 本で
112 µs 前後の 3x 低い外れ値を出す —— 中央値は耐えるが、この bench で gate はできない。

### この artifact で 1 つ判断を間違えかけた

バッチ用の配列を `Array::new(capacity=...)` で worst case（glyph あたり 15 ドット、
実際に点灯するのは約 10）に先取りする版を、交互 4 回で測った:

| bench | 先取りあり | なし | 倍率 | 分離 |
|---|---:|---:|---:|---|
| `primitives/append_dot_text_scene_content_12`（`-p`、whitebox） | 128.8 µs | 142.0 µs | **1.10x** | **yes** |
| `scene/append_dot_text_direct_12`（`-p`、cross-module） | 334.0 µs | 317.0 µs | 0.949x | no |
| `scene/render_labels_12`（`-p`） | 340.5 µs | 337.1 µs | 0.990x | no |

**分離して 1.10x 出たのは、上の表で 0.45x ずれていると分かった側の bench だけ**だった。
先取りした配列はそのまま command の `vertex_data` になるのでフレーム中ずっと最大 50% の
余りを抱える。**払う相手がいないので入れなかった。** コードにもその理由を書いてある。

## label のコストは scene graph ではなくテキストである

`scene/render_labels_12`（後、334.6 µs）を分解した:

| | µs | 全体比 |
|---|---:|---:|
| `scene/render_labels_12` | 334.6 | 100% |
| `scene/append_dot_text_direct_12`（walk と attr 解決を抜いた床） | 333.3 | **99.6%** |
| node 木の walk + 5 属性 × 12 label の解決 + `string_to_char_codes` | 0.85 | 0.25% |
| 空 fragment の `render_scene` | 0.000047 | — |

**attribute 解決は測定に見えない。** `renderer.mbt` の冒頭コメントが「index based
attribute access (O(1) instead of O(n))」を謳っているが、そこは既に問題ではない。
label の値段は 3x5 ドットマトリクスそのものである。

同じ node 数の rect と比べると `scene/render_labels_12` 334.6 µs 対
`scene/render_rects_12` 2.4 µs —— **139x**。「テキストは rect より 2 桁高い」が
2D フレームの形を決めている。

## 入れた変更

- `append_dot_text` はラン全体を 1 command にする。点灯ドットが 0 個のランは
  **今までどおり 1 個も command を出さない**（空 command は rasterizer 側で
  `skipped_commands` に数えられてしまう）
- `push_rect_fill_geometry`（private）を切り出した。frame と rect をスカラーで取るので
  バッチ側はループの外で screen サイズを変換でき、ドットごとの `RectFill2D` も作らない。
  `append_rect_fill_geometry` はその薄いラッパになった
- `HeadlessFrame` に `draw_commands` を足し、`lib/web/kagura-headless-frame.js` →
  `scripts/render-frame.mjs` まで通した。`just render` が
  `N triangles in M command(s)` を出す
- bench を 2 箇所に足した: `engine/renderer2d/primitives_bench.mbt`（primitive builder
  4 本 + 床 + cross-module ペアの片方）、`game/kagura_game/scene/renderer_bench.mbt`
  （build / render を分けた 4 本 + 床）。**scene renderer には bench が 1 本も無かった**
- wbtest を「1 ドット 1 command」から「1 ラン 1 command」に貼り替えた。点灯ドット数は
  `glyph_pattern` から数えるので glyph の絵を直しても落ちない

## 検証

- **frame VRT 17/17 バイト一致**（`vlmkit` がこのコンテナに無いので `cmp` で代用、
  `--threshold 0` より厳しい）。`ui_demo` / `draw2d_ui_demo` / `machinations_demo` /
  `card_game` / `survivor` は label を大量に含む
- `scripts/bench-baseline.json` を `--runs 3` で貼り直した（95 bench）
- 三角形数が 10 example すべてで一致（上の表）
- renderer2d 105 test / workspace 649 test、native は `moon check --deny-warn` 全体
- `lib/web` 51 test / `scripts` 201 test

## 残っている作業項目

1. **`moon bench -p <pkg>` が、そのパッケージ自身の whitebox bench について
   0.36x〜19.6x 違う値を出す理由が分かっていない**（上記）。倍率まで壊れるので、
   これを切り分けないと「速いイテレーション用の `-p`」は使うたびに同じ形の判断ミスを
   生む。**この PR では 8.89x という嘘と、capacity 先取りを入れるという判断ミスを
   2 つ引き起こしている。** 両 regime の生成 JS と実行コマンドを比べるのが次の一手
2. **`glyph_pattern` が glyph ごとに `Array[Int]` を 15 要素作る。** 132 glyph で
   9.5 µs（`-p` 実測なので絶対値は参考値）。15bit のマスクにすれば割り当てが消え、
   popcount で配列を正確なサイズに確保できて `push` を `set` に落とせる。ただし
   text は 1 frame 335 µs（16.67ms の 2%）なので、**優先度は低い**
3. **`card_game` は変更後もフレーム 117 command で、他より 1 桁多い。** 中身を
   数えていない（label が多いのか rect が多いのか）
4. **`@scene.rect` は隣接していてもまとめられない**（色が uniform）。まとめるには
   色を頂点属性に移す必要があり、`mizchi/gfx` の shader と rasterizer の両方に
   触ることになる。フレームの command の残りはここに居る
