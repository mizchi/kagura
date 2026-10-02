# Ember Ascent — Roguelike Deckbuilder

kagura エンジン上で動作する Slay the Spire スタイルのデッキ構築型ローグライトカードゲーム。
Ironclad のデータをベースに、StS の面白さを構成する要素を形式的にモデル化している。

## 起動と検証

```bash
just card-game-dev         # http://127.0.0.1:5196
just card-game-test        # MoonBit JS / native + release build
just card-game-e2e         # Chromium ヘッドレスのマウス / キーボード / タッチ
just card-game-vrt         # 18状態 × 5画面サイズの画像差分・vlmkit検査
just card-game-vrt-update  # 意図したUI変更を確認してから基準画像を更新
```

既存の `just dev card_game` でも起動できます。ゲームは戦闘から始まり、勝利後にカードを選び、休息を挟みながら 2 Act / 30 フロアを進みます。

プレイヤーは左、敵は右に配置します。縦長の画面でも左右の関係を保ち、複数の敵は右側で並びます。ゲーム起動ページは共通でウィンドウいっぱいに表示し、「全画面」ボタンでブラウザのフルスクリーンへ切り替えます。「操作ガイド」から操作説明とソースを確認できます。

## 操作

- 攻撃カードを敵にドラッグして離すと、その敵に使用します。
- Skill / Power / 全体攻撃は戦場にドロップします。戦場の外に離すとカードを戻します。
- クリックでも操作できます。対象が複数いる攻撃は、カードをクリックした後に敵をクリックします。
- `1–9` でカード選択、`← / →` で対象変更、`Enter` で使用、`E` でターン終了。
- `D` または DECK ボタンでデッキと獲得レリックを確認します。次ページはボタンか `→`。
- `Esc` / 右クリックで選択を取り消します。ウィンドウを離れた場合もドラッグを取り消します。
- 報酬はカードクリックか `1–3`、スキップは `S`。休息・継続・再挑戦はボタンか `Enter`。
- 手札が多いときはカードにポインターを置くと詳しい効果を表示します。タッチでのドラッグにも対応します。

画面上のカード・ボタン・HPバーは既存の `@scene` コンポーネントで描画します。`layout.mbt` の同じ矩形を描画と当たり判定で使用します。ドラッグの認識とマウス・タッチの取得は共通UIの [`UIDragController`](../../../engine/ui/README.md) が担当し、`interaction.mbt` は `UIEvent::Drag` を受けて選択表示やカード使用へ変換します。使用可能なカード、敵と戦場のドロップ可否はゲーム側で判定します。戦闘とランのルールは従来の `game.mbt` / `run.mbt` にあります。

## アニメーションと進行

カード使用は360msの演出で、攻撃の踏み込み、命中のフラッシュ・揺れ・数値、防御の発光、使用カードの移動を描画します。HP表示は変化量を補間します。敵ターンは320msの予告後、各敵が240msの予備動作と360msの効果表示を順に行い、380msで次の手札を配ります。撃破・敗北は650ms表示してから結果へ進み、報酬・休息・次の戦闘は400msのフェードで切り替えます。繰り返し続ける装飾アニメーションはありません。

`presentation.mbt` が型付きの進行状態と時間を、`presentation_view.mbt` が描画を管理します。入力は演出中もエッジを記録して消費し、カードやターン終了の連打を受け付けません。ブラウザ・nativeでは実時間、ヘッドレスでは60Hzで進めます。長時間のタブ離脱から戻っても、敵全員の行動を一度に飛ばしません。`prefers-reduced-motion: reduce` では移動・揺れ・粒子・フェードを止め、数値と短い間を残します。

戦闘ルールの同期API `end_player_turn` はシミュレーション用に維持し、画面側も同じターン開始・敵行動・ターン終了の処理を使います。演出が戦闘結果を変更しないこと、勝敗や報酬の二重進行を防ぐことをMoonBitとPlaywrightで検証します。

debug版の起動URLに `?preview=card_impact`、`block_effect`、`enemy_windup`、`enemy_impact`、`draw_hand`、`battle_outcome` を付けると、ヘッドレスと同じ状態で演出を確認できます。これらのプレビューはrelease版には含めません。

Canvasの演出途中も画像とUI snapshotでvlmkitのintegrityを検査します。DOM/CSSのanimationゲートではCanvas内の要素を列挙できません。virtual-timeでGPUを有効にすると画素の変化と停止を測れますが、初回描画やHP・数値の更新も「motion」に含みます。この検査では`--skip-reduced-motion`を使い、動きを減らす設定は別途Playwrightでキャラクターの座標固定とカード移動の非表示、MoonBitでHP補間の停止を検証します。

`editor/verification.json` に状態と表示サイズを定義し、ヘッドレス描画の画像と UI snapshot を vlmkit 0.23.2 に渡して、文字の衝突・画面外へのはみ出し・コントラストを検査します。キャプチャ用の状態生成は debug ビルドだけに含まれます。

## プロジェクト構成

```
examples/games/card_game/
├── lib/                  # ゲームロジックライブラリ
│   ├── cards.mbt         # カード定義（42枚）
│   ├── combat.mbt        # 戦闘システム（Fighter, StatusEffects, ダメージ計算）
│   ├── enemy.mbt         # 敵AI・エンカウンター定義（10体 + ボス2体）
│   ├── game.mbt          # バトルステート・カード実行ロジック
│   ├── run.mbt           # ラン進行（2 Act / 30フロア）
│   ├── relics.mbt        # レリック（12種）
│   ├── balance.mbt       # AI戦略（Aggressive/Defensive/Smart）
│   ├── economy.mbt       # Machinations経済モデル・ラン全体シミュレーション
│   ├── ml_balance.mbt    # ML用特徴量抽出・感度分析
│   ├── fun_metrics.mbt   # Fun指標（7次元）・StS面白さ定量化
│   ├── view.mbt          # 各ゲーム画面（SceneNode ツリー）
│   ├── components.mbt    # カード・ボタン・HPバー・説明部品
│   ├── layout.mbt        # 描画と入力が共有する矩形
│   ├── interaction.mbt   # マウス・タッチ・キーボードの制御
│   └── *_wbtest.mbt      # ホワイトボックステスト
├── headless/             # ヘッドレスランナー（moon run）
│   ├── main.mbt          # バランスチェック・ラン全体テスト
│   └── moon.pkg
├── main.mbt              # GUI エントリポイント
├── moon.pkg
└── moon.mod
```

## ゲームシステム

### Act 1 フロア構成（15フロア）

| フロア | 種別 | 内容 |
|--------|------|------|
| 1-3 | Easy | Jaw Worm, Two Louses |
| 4 | Elite | Red Slaver / Sentry Pair / Gremlin Nob |
| 5 | Rest | HP 25% 回復 |
| 6-8 | Normal | Cultist, Fungi Pair, Red Slaver |
| 9 | Rest | HP 25% 回復 |
| 10-11 | Normal | 同上 |
| 12 | Rest | HP 25% 回復 |
| 13 | Elite | 同上 |
| 14 | Rest | HP 25% 回復 |
| 15 | **Boss** | **The Guardian (240HP) / Hexaghost (250HP)** |

### カード一覧（42枚）

**スターター (3種)**

| カード | コスト | 種別 | 効果 |
|--------|--------|------|------|
| Strike | 1 | Attack | 6 ダメージ |
| Defend | 1 | Skill | 6 ブロック |
| Bash | 2 | Attack | 8 ダメージ, Vulnerable 2 |

**コモン Attack (7種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Cleave | 1 | 8 ダメージ (全体) |
| Pommel Strike | 1 | 9 ダメージ, 1枚ドロー |
| Twin Strike | 1 | 5×2 ダメージ |
| Iron Wave | 1 | 5 ダメージ + 6 ブロック |
| Anger | 0 | 6 ダメージ, 捨て札にコピー追加 |
| Headbutt | 1 | 9 ダメージ, 捨て札→山札トップ |
| Heavy Blade | 2 | 14 ダメージ, 筋力3倍適用 |

**コモン Skill (4種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Shrug It Off | 1 | 8 ブロック, 1枚ドロー |
| Armaments | 1 | 5 ブロック |
| True Grit | 1 | 7 ブロック, ランダム1枚消耗 |
| Flex | 0 | +2 一時筋力（ターン終了時失う） |

**アンコモン Attack (5種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Clothesline | 2 | 12 ダメージ, Weak 2 |
| Uppercut | 2 | 13 ダメージ, Weak 1 + Vulnerable 1 |
| Body Slam | 1 | ダメージ = 現在ブロック値 |
| Sword Boomerang | 1 | 3 ダメージ×3（ランダム対象） |
| Rampage | 1 | 8 ダメージ（使う度 +5） |

**アンコモン Skill (6種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Bloodletting | 0 | -3 HP, +2 エナジー |
| Offering | 0 | -6 HP, +2 エナジー, 3枚ドロー |
| Seeing Red | 1 | +2 エナジー |
| Battle Trance | 0 | 3枚ドロー |
| Shockwave | 2 | Weak 3 + Vulnerable 3 (全体) [消耗] |
| Disarm | 1 | 敵の筋力 -2 [消耗] |

**アンコモン Power (2種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Inflame | 1 | +2 筋力（永続） |
| Metallicize | 1 | ターン終了時 +3 ブロック |

**レア (11種)**

| カード | コスト | 種別 | 効果 |
|--------|--------|------|------|
| Bludgeon | 3 | Attack | 32 ダメージ |
| Whirlwind | X | Attack | 全敵に5ダメージ×X回（X=残エナジー） |
| Feed | 1 | Attack | 10 ダメージ, 撃破時+3最大HP [消耗] |
| Fiend Fire | 2 | Attack | 手札を全消耗, 1枚につき7ダメージ [消耗] |
| Limit Break | 1 | Skill | 筋力を2倍にする [消耗] |
| Impervious | 2 | Skill | 30 ブロック [消耗] |
| Demon Form | 3 | Power | ターン開始時 +2 筋力 |
| Barricade | 3 | Power | ブロックがターン間で維持 |
| Feel No Pain | 1 | Power | 消耗時 +3 ブロック |
| Corruption | 3 | Power | Skillのコスト0, 使用時に消耗 |

### 敵一覧

**Easy**

| 敵 | HP | パターン |
|----|-----|---------|
| Jaw Worm | 42 | Chomp(11) → Bellow(BLK6+STR3) → Thrash(7) |
| Green Louse | 14 | Curl Up(BLK4) → Bite(6) → Bite(6) |
| Red Louse | 13 | Bite(6) → Bite(6) → Grow(+3 STR) |

**Normal**

| 敵 | HP | パターン |
|----|-----|---------|
| Cultist | 50 | Ritual(+3 STR蓄積) → Dark Strike(6) → 繰り返し |
| Fungi Beast | 24 | Bite(6) → Grow(+3 STR) → Bite(6) → Vuln 2 |
| Red Slaver | 46 | Stab(13) → Stab(13) → Scrape(8) → Debuff(WK1+VU1) |

**Elite**

| 敵 | HP | 特殊能力 |
|----|-----|---------|
| Sentry ×2 | 39 | Bolt(9) → Bolt(9) → Beam(5×2) |
| Gremlin Nob | 85 | **Enrage**: プレイヤーが Skill/Power を使うと +2 STR |
| Red Slaver | 46 | Stab(13) → Scrape(8) → Debuff |

**Boss**

| 敵 | HP | パターン |
|----|-----|---------|
| The Guardian | 240 | Twin Slam(8×2) → Fierce Bash(32) → Whirlwind(5×4) → Charge Up(BLK9) → Roll(9) |
| Hexaghost | 250 | Activate → Divider(6×6) → Sear(6) → Tackle(5×2) → Inflame(+2 STR) → Inferno(6×2) |

### レリック

| レリック | 効果 |
|----------|------|
| Burning Blood | 戦闘終了時 HP 6 回復 |
| Vajra | 戦闘開始時 筋力 +1 |
| Anchor | 戦闘開始時 ブロック 10 |
| Orichalcum | ターン終了時ブロック 0 なら +6 ブロック |
| Bag of Marbles | 戦闘開始時 全敵に Vulnerable 1 |
| Lantern | ターン1で +1 エナジー |
| Pen Nib | 10回目の攻撃でダメージ2倍 |
| Meat on the Bone | 戦闘終了時 HP≤50% なら 12 回復 |
| **Red Skull** | **HP≤50%の間、筋力+3（リスク報酬）** |
| **Akabeko** | **各戦闘の最初の攻撃 +8 ダメージ** |
| **Ornamental Fan** | **3回目の攻撃ごとに +4 ブロック** |
| **Happy Flower** | **3ターンごとに +1 エナジー** |

**レリック獲得**: Elite/Boss 撃破時に未所持レリックから1つ自動獲得

## AI戦略

3つの AI 戦略が実装されており、バランスシミュレーションに使用する。

### Smart AI（メイン戦略）

1. **受けるダメージの計算**: 全敵のインテントから合計ダメージを算出
2. **ブロック判断**: 未ブロックダメージ > 5 のとき防御優先
3. **Nob 対策**: Gremlin Nob 存在時は Skill/Power を避ける（Enrage 防止）
4. **ターゲット選択**: HP が最も低い敵を優先（早期撃破）
5. **カード報酬**: デッキアーキタイプ（Strength/Block/Exhaust）に基づくシナジー評価

### Ensemble（混合戦略）

人間プレイヤーの多様な判断を近似するため、3戦略を混合して使用:
- 70% Smart + 20% Aggressive + 10% Defensive

## バランス分析フレームワーク

### Machinations 経済モデル (`economy.mbt`)

Joris Dormans の Machinations フレームワークに基づくリソースフロー分析:

```
[Energy Pool: 3] --gate--> [Card Play] --converter--> [Damage Pool]
                                |                         |
                                v                         v
                          [Block Pool] <--absorb-- [Enemy Damage]
                                |                         |
                                v (overflow)              v
                          [HP Pool: 80] <------------ [HP Drain]
```

- **DPE** (Damage Per Energy): エナジーあたりのダメージ効率
- **BPE** (Block Per Energy): エナジーあたりのブロック効率
- **Efficiency**: 基準値（Strike 6 DPE, Defend 5 BPE）に対する実効率

### 感度分析 (`ml_balance.mbt`)

有限差分法によるパラメータ感度: `sensitivity ≈ (win_rate(param+δ) - win_rate(base)) / δ`

摂動可能パラメータ:
- `PlayerHP` / `PlayerEnergy` — プレイヤー初期値
- `EnemyHP(EnemyId)` / `EnemyDamage(EnemyId)` — 敵のHP/ダメージ

### アーキタイプ検出

デッキ内カードのアフィニティスコアからビルドタイプを自動判定:
- **Strength**: Inflame, Demon Form, Twin Strike, Flex...
- **Block**: Barricade, Metallicize, Body Slam, Impervious...
- **Exhaust**: Feel No Pain, Offering, True Grit...
- **Balanced**: いずれの偏りもない場合

### ML 特徴量（20次元ベクトル）

ゲーム状態から以下の特徴量を抽出（将来の学習パイプライン用）:

| 領域 | 特徴量 |
|------|--------|
| Player (5) | HP%, Energy, Block, Strength, Weak |
| Deck (5) | Size, Hand size, Draw pile, Discard, Exhaust |
| Enemy (5) | Count, Total HP%, Max single HP%, Attacking?, Total intent dmg |
| Battle (5) | Turn, Cards played, Energy spent, Damage dealt, Block gained |

## ヘッドレステスト出力例

```
=== CARD GAME HEADLESS TEST ===

--- Balance Simulation (Smart AI, 50 runs each) ---
  [OK] Jaw Worm (Easy): smart=100% ensemble=100% avg_hp=72
  [OK] Two Louses (Easy): smart=100% ensemble=100% avg_hp=77
  [OK] Cultist (Normal): smart=100% ensemble=100% avg_hp=76
  [OK] Gremlin Nob (Elite): smart=100% ensemble=90% avg_hp=55
  [FAIL] The Guardian (Boss): smart=0% ensemble=0% avg_hp=0
  [FAIL] Hexaghost (Boss): smart=0% ensemble=0% avg_hp=0

--- Run Simulation (30 runs, Smart AI) ---
  Win rate: 50% (15/30)
  Avg floors: 15
  Avg deck size: 18

--- Sample Run Trace (seed=42) ---
  Floor 1: HP=80 Deck=10
  ...
  Floor 15: HP=80 Deck=18
  Result: DEFEAT (reached floor 15)

=== SOME CHECKS FAILED ===
```

**ボスはスターターデッキでは倒せない（0%）が、ラン全体ではデッキ構築により約50%勝利** — StS Act 1 の実際の勝率に近い。Boss 撃破にはビルドが噛み合う必要がある。

## Fun Metrics — プレイヤー体験の定量分析 (`fun_metrics.mbt`)

StS の面白さを構成する7つの仮説それぞれに計測可能な指標を定義し、シミュレーションから自動計測する。

### 指標と目標値（プレイヤー体験ゾーン）

各指標に「楽しいと感じるゾーン」を定義。ゾーン内 = プレイヤーが最も楽しめる範囲。

| # | 次元 | 指標 | ゾーン下限 | ゾーン上限 | 体験的根拠 |
|---|------|------|-----------|-----------|-----------|
| 1 | **緊張感** | tension_ratio | 15% | 35% | 3-4戦に1回「危なかった」がちょうどいい |
| | | lethal_proximity | 8 HP | 25 HP | 死にかけ→立て直しの記憶が残る |
| | | close_win_rate | 10% | 25% | 勝利の1/5がギリギリ = 印象に残る |
| 2 | **ドロー揺らぎ** | outcome_entropy | 0.70 | 0.95 | 実力で傾けられるが運も絡む |
| | | win_rate_variance | 0.01 | 0.05 | 「今回はいいドローだった」を感じる |
| 3 | **ビルド爆発力** | synergy_multiplier | 1.8x | 3.0x | "ビルド完成した"感覚が出る |
| | | power_curve_slope | 0.5 | 1.5 | フロアごとに強くなる実感 |
| 4 | **HP取引** | hp_trade_freq | 0.5 | 2.0 | 1-2回のHP vs パワー判断がランに含まれる |
| 5 | **敵の個性** | strategy_divergence | 0.02 | 0.15 | 敵ごとにプレイを変える楽しさ |
| 6 | **判断の重み** | decision_impact | 15% | 40% | 上手い人と下手な人で結果が変わる |
| 7 | **逆転可能性** | comeback_rate | 30% | 60% | 厳しいが手段はある→最後まで諦めない |

**ゾーン設計の思想**: 各軸の下限を下回ると「退屈/簡単すぎ」、上限を超えると「ストレス/運ゲー/作業」。
中央付近がプレイヤーの「フロー状態」に最も近い。

**重み付け**: 緊張感(20%) + 判断の重み(20%) が最重要。この2つが面白さの核。
ドロー揺らぎ(15%) + ビルド爆発力(15%) が次点。HP取引/敵個性/逆転は各10%。

### 現在のスコアカード

```
=== FUN SCORECARD ===

  1.緊張感    : ███████░░░ 74% [TOO_LOW]  (x20) ← Tension 7% < 目標15%
  2.ドロー揺らぎ: ███████░░░ 72% [TOO_HIGH] (x15) ← Entropy 0.97 > 目標0.95
  3.ビルド爆発力: ████████░░ 80% [IN_ZONE]  (x15) ← 1.9x ✓
  4.HP取引    : █████████░ 94% [IN_ZONE]  (x10) ← 1.1/run ✓
  5.敵の個性   : ███████░░░ 75% [IN_ZONE]  (x10) ← 分散0.137 ✓
  6.判断の重み  : ██████░░░░ 61% [TOO_HIGH] (x20) ← 44.9% > 目標40%
  7.逆転可能性  : ██░░░░░░░░ 20% [N/A]     (x10) ← 要Tension改善

  TOTAL: 69/100  B - 楽しいが改善の余地あり
```

**診断**:
- **ビルド爆発力/HP取引/敵の個性** (3軸) → IN_ZONE。コア体験は機能している
- **緊張感** → TOO_LOW。Normal戦が楽すぎてHP危険域に入らない
  - 改善案: Normal敵のHPかダメージを+15%程度
- **判断の重み** → TOO_HIGH。Smart AI が強すぎて差が出すぎ
  - 改善案: Aggressive AI にも最低限のブロック判断を追加
- **ドロー揺らぎ** → 僅かに高い（0.97 > 0.95）。勝率50%は実力の余地が少ない
  - 改善案: 勝率55-60%が理想。Normal敵は据え置き、Smart AIをもう少し強化
- **逆転可能性** → 計測不能（低HPバトル自体が少ない → Tension改善で自動解決）

## 設計思想

StS の面白さを構成する7つの仮説に基づいてモデル化:

1. **リソーストレードオフ**: HP が普遍的通貨。全ての判断が将来の HP と現在のアドバンテージのトレード
2. **シナジー爆発**: アーキタイプ構築により乗算的なスケーリング（Strength × マルチヒット等）
3. **失敗フィードバック**: 死因が明確で次に活かせる（デッキ構成ミス or 戦闘ミス）
4. **ターン内ランダム性**: ドロー順によるミクロな意思決定の変化
5. **敵パーソナリティ**: 各敵に固有の攻略パターン（Nob = Attack のみ、Cultist = 速攻）
6. **レリックによるゲーム変革**: パッシブ効果がデッキ戦略を根本的に変える
7. **抑制された序盤→OP ビルド**: スターター → 徐々に強化 → ボスを倒せるデッキへ
