# ASHEN HUNT の効果音

暗い森を歩く狩人向けに設計した、オリジナルの手続き生成音源です。録音素材や第三者のサンプルは使用していません。以前の Kenney 素材はすべて置き換えています。

| ファイル | 音の役割 |
| --- | --- |
| attack_slash.ogg | 刃の風切りと革の擦れ |
| enemy_hit.ogg | 敵への命中。低い打撃と乾いた骨のひび |
| hurt_hit.ogg | プレイヤーの被弾。重い衝撃 |
| dodge_cloak.ogg | 回避開始時のコートと靴の風切り |
| pickup_loot.ogg | 袋に落ちる小さな金属片 |
| pickup_health.ogg | 小瓶の液体と気泡 |
| spell_chain_lightning.ogg | 放電の破裂音と低い雷鳴 |
| spell_fireball.ogg | 火球の低い噴射音、燃焼音 |
| spell_ice_nova.ogg | 氷が割れて細かく散る音 |
| spell_homing_missile.ogg | 空洞のある風音と魔力の共鳴 |
| floor_complete.ogg | 遠くで響く低い鐘 |

再生成はリポジトリルートで `just hunter-audio`（Node.js 24、ffmpeg が必要）。
音の設計は `../../scripts/design-audio.mjs` にあり、シードを固定したノイズ、材質の共鳴、短い反射音を合成します。全音源は 44.1 kHz ステレオ。低域の偏りと鋭い高域を抑え、先頭と末尾を滑らかにして、混戦時の音量に余裕を残しています。

`bank.json` は各音の説明、長さ、元 PCM のハッシュです。`output/ashen-sfx-preview.wav` に上表の順序で、音の間に 0.3 秒の無音を入れた試聴用ファイルを出力します。OGG のバイト列は ffmpeg のエンコーダーに依存しますが、元 PCM は再現可能です。

再生は種類ごとに一つの音声を使い、再生中の同じ音を巻き戻しません。連鎖や散弾の同時イベントで先頭音が連打されることを防ぎます。回避音は開始時に一度だけ鳴り、移動中の残像では鳴りません。
