const escape = (value) =>
  String(value ?? "—")
    .replace(/[\\`*_{}\[\]<>()#!|]/g, "\\$&")
    .replace(/\r?\n/g, " ");
const number = (value) =>
  value === null
    ? "未測定"
    : Number.isInteger(value)
      ? String(value)
      : value.toFixed(3);

/** Text artifact; all labels and evidence links are escaped as data. */
export function renderExperienceMarkdown(
  report,
  { comparison, events = [] } = {},
) {
  const names = new Map(
    [...report.spec.loops, ...report.spec.arcs].map((t) => [t.id, t.label]),
  );
  const lines = [
    `# ${escape(report.spec.id)} · 体験の計測`,
    "",
    `実行: ${escape(report.run.id)} / 集団: ${escape(report.run.cohort)} / 記録品質: ${report.valid ? "有効" : "要確認"} / 終了: ${report.termination}`,
    "",
    "操作・解決・提示・人の理解を別々に扱います。観測していない時間や理解は未測定です。数値は面白さの点数ではありません。",
    "",
    "## 指標",
    "",
    "| 対象 | 指標 | 値 | 単位 | 状態 | 標本数 / 機会数 | 証拠 |",
    "| --- | --- | ---: | --- | --- | ---: | --- |",
  ];
  for (const m of report.measures)
    lines.push(
      `| ${escape(names.get(m.targetId))} | ${escape(m.id)} | ${number(m.value)} | ${escape(m.unit)} | ${m.status} | ${m.sampleCount} / ${m.eligibleCount} | ${escape(m.evidenceKind)} |`,
    );
  lines.push(
    "",
    "## 戦闘などのループ",
    "",
    "| 区間 | 状態 | コマンド数 | 開始 → 解決 → 次の判断機会 |",
    "| --- | --- | ---: | --- |",
  );
  for (const l of report.loops)
    lines.push(
      `| ${escape(l.instance)} | ${l.status} | ${l.commands.length} | ${escape(l.start)} → ${escape(l.resolution)} → ${escape(l.ready)} |`,
    );
  lines.push(
    "",
    "## 発見などのアーク",
    "",
    "| 区間 | 提示履歴との関係 | 到達 | 提示の証拠 |",
    "| --- | --- | --- | --- |",
  );
  for (const a of report.arcs)
    lines.push(
      `| ${escape(a.instance)} | ${a.exposure} | ${escape(a.reached)} | ${escape(a.exposed.join(", ") || null)} |`,
    );
  const resolved = events.filter((e) => e.type === "loop.resolved");
  if (resolved.length) {
    lines.push(
      "",
      "## 解決ごとの資源",
      "",
      "順序はイベント番号、時刻は未計測です。被害・回復は機械的な結果で、心理的な緊張の実測ではありません。",
      "",
      "| イベント | 判断番号 | 被害 | 回復 | HP | MP | 回復薬 | 灯り |",
      "| --- | ---: | ---: | ---: | --- | --- | ---: | ---: |",
    );
    for (const e of resolved) {
      const d = e.data;
      lines.push(
        `| ${escape(e.id)} | ${e.decisionIndex ?? "—"} | ${d.damage ?? "—"} | ${d.healing ?? "—"} | ${escape(d.hp?.join("/"))} | ${escape(d.mp?.join("/"))} | ${d.potions ?? "—"} | ${d.torch ?? "—"} |`,
      );
    }
  }
  if (comparison) {
    lines.push(
      "",
      "## 基準との差",
      "",
      `記述的な比較です。異なる条件: ${escape(comparison.conditionsDiffer.join(", ") || "なし")}。選択方法やseedが違う比較から因果を確定しません。`,
      "",
      "| 対象 | 指標 | 基準 | 今回 | 差 |",
      "| --- | --- | ---: | ---: | ---: |",
    );
    for (const m of comparison.measures)
      lines.push(
        `| ${escape(names.get(m.targetId))} | ${escape(m.id)} | ${number(m.before)} | ${number(m.after)} | ${number(m.delta)} |`,
      );
  }
  if (report.issues.length) {
    lines.push("", "## 記録品質の問題", "");
    for (const i of report.issues)
      lines.push(
        `- ${escape(i.code)} / ${escape(i.eventId)} / ${escape(i.detail)}`,
      );
  }
  lines.push(
    "",
    "元の位置はイベントIDで events.jsonl、判断番号で trace.jsonl に対応します。ループのcompletedは構造上の区切りを示し、人の理解完了を意味しません。",
    "",
  );
  return lines.join("\n");
}
