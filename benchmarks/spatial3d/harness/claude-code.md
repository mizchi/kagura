# Claude Code サブエージェント条件（batched, no tools）

`results/*/claude-*.batched.responses.jsonl` はこの手順で取った。API キーなしで
Claude Code だけで回せる。測りたいモデルで Claude Code のセッションを開き、
そのセッションに以下を実行させる。サブエージェントはモデルを指定せずに起動するので、
セッションのモデルを継承する。

## 手順

1. `batches/<dataset>/` の各ファイルについて、`general-purpose` サブエージェントを
   1 つずつバックグラウンドで起動する。プロンプトは下記のとおりで、`<PATH>` には
   絶対パスを入れる。同時に動かせるのは 20 個までなので、終わったものから順に次を起動する。
2. 全部終わったら、各サブエージェントの transcript（Agent ツールが返す `output_file`）を
   まとめて渡す。

   ```bash
   node harness/extract-claude-code.mjs --out /tmp/replies <output_file>...
   ```

   1 行 1 transcript で、使われたモデル・ツール・回答数が出る。どれか 1 つでも
   `INVALID`（`Read` 1 回以外のツールを使った）なら、その結果は無効。
3. 回答を取り込んで採点する。

   ```bash
   node import.mjs --dataset <dataset> --model <model-id> \
     --harness "claude-code-subagent batched, no tools" \
     --out results/<dataset>/<model-id>.batched.responses.jsonl /tmp/replies/*.txt
   node score.mjs results/<dataset>/<model-id>.batched.responses.jsonl
   ```

サブエージェントの effort はセッションの設定に従う。結果の `settings` に残すこと。

## サブエージェントのプロンプト

### v1

v1 のバッチファイルには回答形式の行が無いので、形式をプロンプトに書いている。

```
You are a test subject in a 3D spatial-reasoning benchmark. Use the Read tool exactly once to read this file:
<PATH>
After that, use NO tools at all (no Bash, no code, no other file reads, no searching the repository) — computing with tools or looking at any answer key invalidates the measurement. Solve every problem by reasoning in your head only. Work carefully through each problem.

Your final reply must end with one line per problem, in file order, of the form:
<id>: YES   or   <id>: NO   (pair problems)
<id>: A-C, B-D   or   <id>: NONE   (scene problems)
Then a last line: TOOLS_USED_AFTER_READ: none
```

### v2 / v3

```
You are a test subject in a 3D spatial-reasoning benchmark. Use the Read tool exactly once to read this file:
<PATH>
After that, use NO tools at all (no Bash, no code, no other file reads, no searching the repository) — computing with tools or looking at any answer key invalidates the measurement. Solve every problem by reasoning in your head only, carefully.
End your final reply with the answer lines in the format the file specifies (one line per problem, in order), then a last line: TOOLS_USED_AFTER_READ: none
```
