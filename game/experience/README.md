# ループとアークの計測

FATHOMの戦闘1ラウンドと地下2階への到達を、共通のイベント契約で計測する。操作・解決・次の判断機会を分け、到達・提示・人の理解も別々に記録する。[設計の背景](../../docs/research/loop-arc-evaluation.md)。

## 実行と比較

APIキーや描画環境なしで実行できる。Node 24+、MoonBit、justを使う。

```sh
just experience-run --policy attack --out output/experience/attack
just experience-run --policy tactical --out output/experience/tactical \
  --baseline output/experience/attack/report.json

# Studioで編集して書き出したデータも使える
just experience-run --master-data edited.master-data.json \
  --balance output/balance/candidate/profile.json \
  --out output/experience/edited

# 計測を含む既存のJev/autoplay記録を検証してから解析する
just experience-report path/to/trace.jsonl --out output/experience/review
```

既定はseed 731、最大400判断・120秒。`--seed`、`--max-decisions`、`--max-seconds`で変更できる。Ctrl-Cは中断として記録する。新規の出力先だけを使い、既存の証拠は上書きしない。`--no-build`は既存ビルドを使うテスト用の指定。

| 出力 | 内容 |
| --- | --- |
| `trace.jsonl` | 操作と観測、ゲームが出した計測イベントの原記録。通常のautoplay replayで検証できる |
| `recording.json` | 評価定義、実行条件、正規化イベント、開始時の提示履歴。Studioの入力 |
| `events.jsonl` | 正規化したイベント列。順序、原因ID、元の判断番号を持つ |
| `report.json` / `report.md` | 区間、指標、標本数、欠測、記録品質の問題。Markdownには解決ごとの資源も記載 |
| `ledger.json` | 提示履歴。次回の明示的な比較へ持ち越せる |
| `comparison.json` | `--baseline`指定時の記述的な差。未測定や証拠の種類が異なる値の差はnull |

試行間の差は因果効果の確定ではない。方針・seed・適用した数値・操作経路などの条件差を残す。勝敗を面白さの点数にしない。仕様・マスターデータ・バランス設定を記録し、後から違う設定を使って同じ結果に見せない。

## Studioで読む

上部の **体験レポート** → **記録を読込** で `recording.json` を選ぶ。**基準を読込** に別の `recording.json` を入れると比較できる。`report.json`はCLIの基準用で、Studioでは元の記録から再計算する。

- **指標**：値、単位、観測状態、証拠の種類、標本数/機会数、基準との差。
- **ループとアーク**：開始→解決→次の判断機会、到達→提示。イベントIDを選ぶと詳細へ移る。
- **イベント**：検索、100件ごとの表示、原因とpayloadの確認。指標の「証拠」からも絞り込める。

読み込みは32 MiBまで。形式や定義が不正・比較不可能な場合は、表示中の有効な記録を保ってエラーを出す。**レポートを書出** で計算結果を持ち出せる。ゲームの設定や実行状態は変更しない。現時点ではファイル経由の読込で、Studioから実行中の記録を自動収集する機能は含まない。

## 計測できる範囲

FATHOMは `Game.command` で要求・受理・拒否を記録し、ラウンドの開始・解決・次の判断機会を別イベントにする。解決イベントは、その区間の受理済みコマンドと多対多の原因IDでつながる。予約取消も数える。逃走による中断と、実験予算による途中終了は別の状態として残る。

`commandsPerResolution`は**ゲーム内コマンド数**。キーボードの物理的な入力数ではない。`decisionsPerResolution`はautoplayの判断番号から数える。6人分を選択した最後の判断で自動実行されるresolveはコマンドとして数え、同じ判断番号を二度は数えない。`causalCoverage`は全ての受理済みコマンドが解決に対応した割合で、HPや演出の正しさそのものを証明する指標ではない。既存のHP/表示記録の監査は別に維持する。

地下2階へ降りた時点は `arc.reached`。次のプレイヤー役の判断にその観測を渡したことを、別の `arc.exposed` として記録する。この証拠は `observation`、つまり方針やモデルへの入力であり、人が画面で気づいたという証拠にはしない。

表示の遅延は、同じ表示時計を持つ解決と `loop.feedback` がある場合だけ測る。FATHOMの現在の記録は表示時計を出さないため、遅延は `null / not-instrumented`。時計IDは同じ計測系の、一時停止を除いた表示時計を指す。壁時計やAPIの応答時間を代わりに入れない。

人間の認識・理解には、`source: human` の明示的な回答イベントとbooleanの回答値が必要。回答していない人を不正解と数えない。イベントを出した、描画した、人が理解した、を相互に代用しない。

## 提示履歴

履歴は `subjectId / scope / knowledgeKey / contentVersion` で識別する。ゲーム内の地図既読フラグや周回番号から独立している。到達だけでは履歴に追加しない。同じ記録とその出力履歴を再解析しても、初提示が再提示へ変わったり、履歴が二重追加されたりしない。

```sh
just experience-run --subject tester-a --out output/experience/first
just experience-run --subject tester-a --knowledge output/experience/first/ledger.json \
  --out output/experience/repeat
```

`--knowledge`は`--subject`を必須にする。未指定の参加者IDは実行ごとに新規作成し、別の人の履歴を暗黙に共有しない。この履歴が示すのは過去の提示であり、記憶や理解の実測ではない。ローカル方針に記憶を追加する機能でもない。敵HPの倍率だけの変更は、同じ階層を新しい発見にしない。

## ゲームを接続する契約

[型定義](index.d.mts)と[純粋な抽出器](index.mjs)が共通契約。DOM・乱数・現在時刻・ゲーム名に依存しない。アダプターはゲーム固有の出来事をこの契約へ対応付け、評価定義とイベント列を作る。別ゲームも同じrecording形式ならStudioで読める。

```js
import {analyzeExperience, compareExperience, projectMetrics} from './index.mjs';

const report = analyzeExperience(recording);
const comparison = compareExperience(baselineReport, report);
const metrics = projectMetrics(report, [{
  targetId: 'combat-round', metricId: 'causalCoverage',
  as: 'loopCausalCoverage', minSamples: 8,
}]);
```

`ExperienceSpec`はループ・アークのID、意図、知識の単位、関係を宣言する。ゲーム固有の条件判定はアダプターが担当する。共通層では表示文言を解析しない。関係は保持するが、入れ子の区間を足した全体時間や排他的な所要時間の集計はまだ行わない。

`ExperienceEvent`の`sequence`は記録順序で、経過時間ではない。`causes`は先行するIDを参照する。ゲームの同期処理では解決後に受理を記録する場合もあるので、区間を抽出してから対応を結ぶ。欠落、重複、存在しない区間への結果、後戻りする時計などは診断に残す。FATHOMの内部バッファは8192件で、取りこぼしを`dropped`で伝える。autoplayは判断ごとに差分を読み出す。

結果の数値には状態・単位・標本数・機会数・証拠のIDを残す。開始だけの区間は、終了条件に応じて中断または打ち切りになる。`completed`は構造上の区切りまで記録できたという意味で、人の理解を推定した値ではない。抽出器は最大100,000イベントを受け付ける。

標本数の単位は指標によって異なる。戦闘ラウンド数や回答を得た区間数を、人間の参加人数として数えない。現状の比較は記述的なもので、プレイヤー集団への一般化や因果効果の推定は行わない。

### 難易度調整へ渡す

`projectMetrics`は記録品質が有効で実行が完了し、要求した指標が観測済み・標本数を満たし・機会数に対して欠測がない場合だけ有限の数値を返す。未計測を0で埋めない。FATHOMのバランスアダプターには`experienceMetrics`として明示的に接続できる。

```js
const adapter = createAdapter({experienceMetrics: [{
  targetId: 'combat-round', metricId: 'commandsPerResolution',
  as: 'loopCommands', minSamples: 8,
}]});
```

既定の目的関数や採用条件は変更していない。新しい指標を使う場合は、対象集団、範囲、意味を別途決める。`captureExperience: true`の試行には既存の機械的な証拠とtraceに加え、`loopArc`レポートも残す。Jevのレビューを人の認識データへ混ぜない。

## 検証と今後の範囲

```sh
just experience-test
just dungeon-rpg-e2e
just experience-e2e
# 別ターミナルでStudioを起動してから
just studio-dev
just experience-ui
```

現在の実装は、イベント契約、区間、因果対応、操作/判断の負担、初提示/再提示、欠測、記述的比較、明示的な調整用射影、Studioでの記録閲覧まで。

同一局面からの分岐と選択による結果の差、物理入力の負担、画面での反応時間、人間への理解質問、意味のある停止と強制待ちの区別は追加計測が必要。これらの値を既存ログから作ったり、現時点で測定できたと扱ったりしない。
