# Effect IR とカード生成・評価ループ — 評価ドキュメント

## 背景と動機

論文 *"Grounding Machine Creativity in Game Design Knowledge Representations"*
(Liu & Tatar) は、ゲームデザインパターンを LLM に**実行可能なエンジンコードとして
直接生成させる**実験を行い、生成物が**一つもコンパイルできなかった**
(pass@k = 0.0) ことを報告した。支配的な失敗要因は「存在しない型・構造を参照する」
グラウンディング失敗だった。

本作業は、その知見を kagura の Slay the Spire 風サンプル (`examples/games-2d/card_game`)
に適用したもの。カードの**振る舞いをコードではなくデータ (IR) として表現**することで、

1. 既存のハードコードされたカード効果をデータ駆動に置き換え（保守性・拡張性）
2. 論文が到達できなかった「生成 → 実行評価」ループを成立させる

ことを目的とした。

---

## 1. Effect IR（データ駆動カード効果）

### 課題

移行前、カードの数値（cost / base_damage / base_block）は `CardDef` という struct で
データ化されていたが、**振る舞い**（Heavy Blade の STR3倍、Whirlwind の X連撃、
Fiend Fire の手札全消費 など）は `execute_card` の巨大な match 分岐に
ハードコードされていた。

### 設計

カードを「効果のリスト」として表現する小さな中間表現を導入した。

```
カード = Array[Effect]              // 「何をするか」= データ（パターン意味論）
apply_effects(state, effects, ...)  // 「どう適用するか」= 単一のインタプリタ
```

- `Amount`（`Const` / `PlayerBlock` / `StrengthScaled` / `RampageScaled`）で
  「数式」もデータ化 — Body Slam・Heavy Blade・Rampage のような文脈依存ダメージを表現。
- `Effect` はパラメトリックコア（DealDamage / GainBlock / ApplyVulnerable /
  ApplyWeak / GainStrength / GainEnergy / DrawCards / LoseHP）と、
  カード固有の専用ノード（WhirlwindDamage / FiendFire / ReaperDamage /
  DealDamageWithKillBonus / RecallTopDiscardToDraw / ExhaustRandomFromHand /
  ReduceEnemyStrength / DoubleStrength / DoubleBlock / SetCorruption など）に分かれる。

### 結果

**全 42 枚のカードを Effect IR に移行完了**。`execute_card_legacy` は参照用フォールバック
として残置。

#### 等価性の保証

ホワイトボックステストで、IR 経路（`apply_effects`）と旧経路（`execute_card_legacy`）が
**全 42 枚 × 2 シナリオ（通常 / 瀕死）で完全一致する戦闘ステート fingerprint** を
生成することを assert（HP・ブロック・エナジー・STR・各 Power・各 Pile 長・敵ステータス
を網羅）。瀕死シナリオは Feed の最大HP増加・Reaper のライフスティールなどの分岐も発火させる。

---

## 2. 生成 → 実行評価ループ

### 設計

```
gen_card(seed)          // IR のパラメトリックコアからカードを生成
                        //   （PRNG。LLM をこの文法に制約しても同じ）
  → eval_synth(card)    // 実カードと同じ apply_effects で「実行」して計測
  → Verdict             // Underpowered / Balanced / Overpowered に採点
```

論文との決定的な違い：**IR は型で閉じたデータ**なので、`Array[Effect]` 型の値を
生成する限り**必ず実行可能**。生成器（PRNG でも LLM でも）はグラウンディング失敗を
起こせない。

### 多ターン差分シミュレーション評価

初期実装の「単発計測」では、Strength スケーリングや持続 Power（Demon Form,
Metallicize, Barricade）といった**遅延価値**が単発スナップショットで 0 に見えるという
問題があった。これを**多ターン差分シミュレーション**に置き換えた：

- 制御された戦闘を `EVAL_HORIZON`（6）ターン回し、
  「候補カードをターン1に打った場合」と「打たない場合」の**差分**を取る。
- プレイヤーは毎ターン baseline 攻撃（残りデッキの代用）を行うため、
  STR/Vulnerable バフが乗算する対象を持つ。
- baseline 攻撃は `apply_damage` 経由なので、ダミーへの Vulnerable シナジーが効く。
- ダミーは STR を持って反撃するため、Disarm / Weak が被ダメ減として計測される。
- 価値の重みは `economy.mbt` のバランス基準（Strike ≈ 6 DPE 等）に揃えた。

---

## 3. 実行結果（実測）

### 生成バッチ（1000 枚）

```
generated = 1000   runnable = 1000     ← グラウンディング失敗ゼロ
underpowered = 394 (39%)   balanced = 254 (25%)   overpowered = 352 (35%)
```

採択された balanced カードの例：

```
[2E] gain 1 energy, apply 2 vulnerable    value=17.5  budget=12
[2E] lose 2 HP, deal 10 x2 to target      value=18    budget=12
[1E] gain 1 energy, draw 1                value=7.5   budget=6
[2E] gain 1 strength                      value=12    budget=12
```

### 評価器 vs 設計済み 42 枚（校正テスト）

評価器を設計者が手調整した 42 枚に当て、単発評価から多ターン評価への改善を確認：

| 判定 | 単発評価 | 多ターン評価 |
|---|---|---|
| Underpowered | 14 | **7** |
| Balanced | 9 | **14** |
| Overpowered | 19 | 21 |

多ターン化で正しく評価されるようになった遅延価値カードの例：

```
Inflame[1E]      value 0 → 24    (STR+2 が 6ターン×2攻撃に乗る)
Metallicize[1E]  value 0 → 23.4  (毎ターン +3 ブロック)
Demon Form[3E]   value 0 → 60    (毎ターン累積 STR)
Disarm[1E]       value 0 → 6     (敵 STR 減少を被ダメ減として計測)
```

---

## 4. 評価（考察）

### 成功した点

1. **生成ループの成立** — 1000/1000 実行可能。論文の pass@k = 0.0 を、IR の型閉包に
   よって構造的に解消した。これが本作業の中心的成果。
2. **多ターン差分が遅延価値の盲点を解消** — Strength スケーリングと持続 Power の価値を
   定量化できるようになり、設計済みカードの Balanced 一致が 9 → 14 に改善。
3. **既存のバランス分析基盤との接続** — `economy.mbt` の価値基準を再利用し、生成カードを
   既存プロジェクトの語彙で採点できる。

### 残る限界（そしてそれが論文の主張を裏付けること）

多ターン評価後も、次のカードは value ≈ 0 のまま残った：

```
Body Slam        （既存ブロックに依存）
Barricade        （持続させる既存ブロックが前提）
Feel No Pain     （Exhaust シナジーが前提）
Corruption       （Skill 無料化を未モデル化）
Limit Break      （既存 STR の倍化が前提）
Entrench         （既存ブロックの倍化が前提）
```

これらは**すべて文脈・コンボ依存**のカードであり、中立的なダミー戦闘では公平に評価できない。
一方、高レアリティのカード（Demon Form, Bludgeon, Fiend Fire）は「Overpowered」と
判定されたが、これは Strike 基準より上＝レアは曲線の上、という設計意図と整合する。

この切り分け — **素直なパターンは安価にグラウンド・評価できるが、スケーリング/持続/
コンボパターンは高い評価文脈（多ターン、デッキ全体）を要求する** — は、論文の
「人間–機械の知識境界はタスク一様ではなく、個別パターン単位で位置づけられるべき」という
結論を実装上で再現したものと言える。

### 含意

- **生成器が使うパラメトリックコアは評価器の妥当域に収まっている**ため、生成 →
  自動採点 → balanced フィルタというデザイナー支援ループは、その範囲で実用的に機能する。
- コンボ/条件付きカードを公平に評価するには、`economy.mbt` の**フル戦闘シミュレーション**
  （実デッキ・実敵での多戦闘）へ生成カードを注入する次段が必要。これが今後の発展方向。

---

## 5. 再現方法

```bash
cd examples/games-2d/card_game

# テスト（IR 等価性 + 生成ループ + 全ロジック、計 114 件）
moon test --target js

# 生成 → 評価レポート（セクション 7 に出力）
moon run src/headless --target js
```

`moon run src/headless` の出力セクション7で、生成分布・採択カード例・設計済みカード
校正が再現可能なレポートとして表示される（`format_generation_report()`）。

---

## 関連ファイル

| ファイル | 役割 |
|---|---|
| `src/lib/effect.mbt` | Effect IR の型定義と `apply_effects` インタプリタ、`card_effects`（全42枚） |
| `src/lib/effect_wbtest.mbt` | IR ↔ legacy 等価性テスト（全42枚 × 2シナリオ） |
| `src/lib/generator.mbt` | カード生成、多ターン差分評価、レポート生成 |
| `src/lib/generator_wbtest.mbt` | 生成ループのテスト |
| `src/lib/cards.mbt` | `all_card_ids()` を追加 |
| `src/headless/main.mbt` | セクション7：再現可能な生成評価レポート |
