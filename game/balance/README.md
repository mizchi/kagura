# プレイヤー体験を調べるバランス実験

`differentiable_ecs@0.2.2`のCMA-ESを使い、ゲームごとの設定候補をautoplayで比較する。FATHOMの遠征と、カードゲームの単体戦闘が同じ契約につながっている。

**正解手順や勝率最大化を目的としない。** 判断に対して反応が返るか、緊張から立て直せるか、消化作業や理不尽さにならないかを評価する。勝率は進行不能などを検出する補助指標。自動指標とJevの推論だけで、人間のやりごたえを確定しない。

調査の根拠・ゲーム別の判断は[設計ノート](../../docs/research/player-experience-balancing.md)にまとめた。

ループ・アーク単位の記録、提示履歴、区間ごとの比較は[体験の計測](../experience/README.md)を参照。FATHOMのバランス試行からも、明示した指標だけを接続できる。全体の構想は[評価フレームワーク案](../../docs/research/loop-arc-evaluation.md)にまとめた。

## 実行

```sh
just balance-tune dungeon_rpg --dry-run
just balance-tune dungeon_rpg --out output/balance/my-fathom
just balance-tune card_game --out output/balance/my-cards
just balance-tune-test

# FATHOMでJevもプレイし、記録から体験上の仮説を返す（APIを使用）
just balance-tune dungeon_rpg --jev-check 1 --max-requests 160

# 調整候補を画面付きで試す（別ターミナルでdevを起動）
just dungeon-rpg-dev
just dungeon-rpg-agent --watch --balance output/balance/my-fathom/profile.json
```

通常の探索は明示したローカル方針で行い、APIは呼ばない。`--jev-check`はFATHOM用の独立した追加観測で、探索の点数に混ぜない。`TYPESAFE_API_KEY`の扱いは[FATHOMのREADME](../../examples/games/dungeon_rpg/README.md)を参照。プレイヤー役のJevと体験レビューで同じリクエスト上限を共有する。モデルの変更で結果は変わりうる。

既定の上限は8世代・2000試行・120秒。基準値と未使用seedでの検証、Jevの追加遠征も試行数に含む。`--generations`、`--max-trials`、`--max-seconds`、`--seed`で制限できる。時間超過やCtrl-C、APIの上限では採用可能な候補を出力しない。出力ディレクトリは新規作成し、既存の証拠を上書きしない。

## 出力と読み方

| ファイル | 内容 |
| --- | --- |
| `experiment.jsonl` | 設定、予算、全試行、候補ごとの指標、探索・検証の区別、終了結果 |
| `summary.json` | 変更前後の指標、方針別・座席別の集計、勝率のWilson 95%区間、未評価のレビュー項目 |
| `profile.json` | 未使用seedでも総合損失が悪化しなかった候補。`accepted`の場合だけ出力 |
| `audit-*.jsonl` | `--jev-check`時のJevの操作記録。`dungeon-rpg-agent --replay FILE --watch`で再生可能 |

`accepted`は自動計測上の候補選出を意味する。面白さの承認ではない。`meetsGoals`は設定した数値範囲を満たしたかを表し、満たさない改善候補もその旨を残す。`reviewRequired: true`と、画面・実プレイで確かめる質問を必ず残す。

`rejected`は検証側で悪化、`unchanged`は改善候補なし、`incomplete`は未完了のプレイやフィードバック整合性の不合格、`limit`は実験予算の不足を表す。APIエラーや未完了プレイを勝利として扱わない。通常のゲームの既定値は自動で書き換えない。

Jevの体験レビューは`model-hypothesis`として記録する。勝敗を採点せず、緊張と回復、選択の結果が記録に表れているかを尋ねる。信頼度はモデル自身の推定で、体験の品質点ではない。機械的な記録から音・見た目・人の楽しさを推測させず、`not-observed`とする。

## ゲームを接続する

契約は[scripts/balance/contracts.d.mts](../../scripts/balance/contracts.d.mts)。実行側は描画やゲームルールを持たず、次のアダプターを受け取る。

```js
import {tune} from '../../scripts/balance/tune.mjs';
const result = await tune({
  experiment, // パラメータ範囲、方針、座席、探索seed、検証seed、指標とレビュー項目
  async runTrial({params, seed, policy, seat, signal}) {
    // 実ゲームの通常のルールで一回遊ぶ。abortにも応答する。
    return {status: 'victory', metrics: {pressure: .5, decisions: 20}};
  },
});
```

`runTrial`は`victory/defeat/draw/returned/limit`と、有限の名前付き指標を返す。指標の欠落・NaN・Infinityは失敗。無限ループを低い点数で補償することはできない。JavaScript側から呼ぶときは先に`moon -C game/balance build host --target js --release`が必要。

`goals`は目標の範囲、単位を合わせる`scale`、重みを明示する。範囲から外れた距離の二乗を加算し、範囲内では点数を上乗せしない。戦略差や先後差は`subtract: {cohort, metric}`で記述する。例として、`player@first`と`player@second`の勝率差を評価できる。平均50%だけでは先手有利を隠すので、両座席で同じseed・方針を試す。

`guards`は補償不能な条件。FATHOMではHP変化と表示用の命中・回復記録の不一致率が0であることを要求する。緊張感の数値が良くても、不整合のある候補は選ばない。

探索用seedと検証用seedの重複は拒否する。検証は探索終了後の基準値と選出候補だけで行い、検証値をCMA-ESへ戻さない。上限を設け、全試行を記録し、別seedで悪化した候補を出力しない。

## 実装の境界

- `game/balance/src/`：MoonBitのCMA-ES ask/tell。最適化本体は公開版`differentiable_ecs`を使用。
- `scripts/balance/`：非同期の試行、体験の代理指標、範囲評価、検証、Jevレビュー。ゲームに依存しない部分。
- `scripts/balance/adapters/`：ゲーム固有の方針・計測・仮の目標範囲。範囲は研究が保証した基準ではなく、試作の設定。
- `scripts/balance/experience.mjs`：FATHOMのラウンド単位の消耗・回復・表示記録の監査。画面・音の知覚は測らない。

FATHOMの数値は出発前だけ設定し、戦闘中の敵HPや確率を変更しない。カードゲームの実装範囲は単体戦闘で、遠征全体の調整ではない。ボードゲームには方針・座席・先後差の契約を提供するが、既存の全ゲームにアダプターを実装したわけではない。

今回は開発時の調整を実装している。プレイ中の継続的なDDAは、設定の告知、適用境界、難易度の振動防止、対戦時の公平性を別途設計してから接続する。毎回勝つプレイヤーに、失敗を強制するための補正は行わない。

## 検証と制約

```sh
just balance-tune-test
just dungeon-rpg-e2e
```

最適化の再現性、予算、未使用seed、先手差の検出、検証悪化の拒否、不正な表示記録の拒否を検証する。FATHOMでは実際の画面上で命中・回復数値と対象を比較し、デスクトップとスマートフォンで撮影する。演出の終了だけでゲームが進まないことも確認する。

少数seed・限定した方針の比較であり、人間の実力分布や主観的なやりごたえの推定ではない。やりごたえと、単なる長期化・被弾増加を混同しないため、レビュー項目と映像・実プレイを併用する。

ネイティブの最適化テストは、依存ライブラリに合わせmacOSのAccelerateを使用する。他のOSではLAPACK/BLASのリンク設定が必要。
