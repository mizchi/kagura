# hypercube — n 次元ルービックキューブで高次元の空間把握を測る LLM ベンチ

3×3×…×3 の n 次元パズル（n = 3 が普通のルービックキューブ、n = 4 が Magic Cube 4D の 3^4）を、
**座標とルールの文章だけ**で渡して解かせる。画像は渡さない。正解はシミュレーションで決める。

Node 22 だけで動く（依存なし）。spatial3d と同じく、Claude Code のサブエージェントで追試できる。

## ルール（プロンプトに書いてある内容）

- ピースは {-1,0,1}^n の格子点にある。0 でない座標の数だけステッカーを持ち、その向きは
  ±（その軸）。完成状態では、どのステッカーも自分の向きと同じ色をしている。
- 手 `S:i>j` は、S 軸の座標が S の符号と等しいピース（1 層）を、i–j 平面で +i が +j に
  向くように 90° 回す。`new_j = old_i`、`new_i = -old_j`。ステッカーの向きも同じように回る。
  `S:j>i` が逆手。中心ピースは動かないので、完成は色だけで判定できる。
- n = 3 では普通のルービックキューブと一致する（1 手で見た目が変わるステッカーは 12 枚、
  R U R' U' の位数は 6。どちらも `puzzle.test.mjs` で確認）。

## データセット `hypercube-v1`（72 問, seed 20261009）

| タスク | 内容 | 条件 | 問題数 |
|---|---|---|---|
| track | 手順を順に適用したあと、指定ステッカーがどの位置・向きにあるか | n = 3/4/5 × 手数 1/3/6/10 × 4 問 | 48 |
| solve | 色がずれているステッカーの一覧（n = 4 の 3 手で約 100 行）から、完成に戻す手順を答える | n = 3/4（1〜3 手）、n = 5（1〜2 手）× 3 問 | 24 |

- track の手は 75% の確率で追跡中のピースを含む層を回す（素通りばかりの問題にしない）。
- solve は**どんな手順でも完成すれば正解**（シミュレーションで判定）。上限は max(6, 2×手数) 手。
  何手でスクランブルしたかは問題文に書いてある。
- `data/v1/` が正本（`manifest.json` に sha256）。`batches/v1/` はサブエージェント用の
  バッチ（track は 8 問、solve は 4 問ずつ）。

```bash
node generate.mjs                     # data/v1 と batches/v1 を作り直す
node --test puzzle.test.mjs           # ルールと正解データの検証
node score.mjs results/v1/<label>.answers.txt
```

## 追試の手順（Claude Code）

spatial3d と同じ（`../spatial3d/harness/claude-code.md`）。バッチごとにサブエージェントを 1 つ立て、
次のプロンプトの `<PATH>` だけを差し替える。

```
You are a test subject in an n-dimensional spatial-reasoning benchmark. Use the Read tool exactly once to read this file:
<PATH>
After that, use NO tools at all (no Bash, no code, no other file reads, no searching the repository) — computing with tools or looking at any answer key invalidates the measurement. Solve every problem by reasoning in your head only, carefully.
End your final reply with the answer lines in the format the file specifies (one line per problem, in order), then a last line: TOOLS_USED_AFTER_READ: none
```

transcript の監査と回答の取り出しは `../spatial3d/harness/extract-claude-code.mjs`、
トークン数の集計は `harness/usage.mjs`。

## 実測結果

### claude-opus-5-5（2026-10-09, batched）

`results/v1/claude-opus-5-5.batched.answers.txt`。12 バッチすべての transcript を監査した。
モデルは全部 `claude-opus-5-5`、ツールは `Read` 1 回だけ。effort はセッション既定（medium）。

| | n = 3 | n = 4 | n = 5 | 計 |
|---|---|---|---|---|
| track（10 手まで） | 16/16 | 16/16 | 16/16 | **48/48** |
| solve（3 手まで、n = 5 は 2 手まで） | 9/9 | 9/9 | 5/6 | **23/24** |

- 唯一の誤答 solve-019（n = 5, 2 手）は、2 つの手そのものは正しく特定できていた。
  交わる 2 層（x = +1 と z = -1）を戻す**順序を逆にした**ため、完成しなかった。
- 次元を上げても正答率は落ちなかった。n = 4 の 3 手スクランブル（ずれたステッカー約 100 枚）
  からも、手と順序を毎回復元できている。
- 1 バッチの所要時間は track が 23〜36 秒、solve が 32 秒〜5 分。

**費用は合計約 $6**（このセッションの累計が $152.93 → $159.19。集計作業ぶんも含む）。
サブエージェント 1 本の費用の大半は、起動時の約 6 万トークンのキャッシュ書き込みで、
推論そのものは少ない。spatial3d の Opus 5 測定（約 $750）の 100 分の 1 以下。

### 読み方と次の一手

v1 は Opus 5.5 にはほぼ飽和している。差を出すなら、安いまま難しくできる方向は次のとおり。

- solve の手数を 4〜6 に上げる（逆算に必要な順序の推論が組合せ的に増える）。
- n = 6 以上（ステッカー数は 2n·3^(n-1)。n = 6 で 2,916 枚、1 手でずれるのは約 300 枚）。
- 手の数を伏せる、あるいは 2 層を同時に回す手（スライス）を足す。
