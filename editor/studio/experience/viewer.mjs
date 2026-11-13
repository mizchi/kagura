import {
  analyzeExperience,
  compareExperience,
} from "../../../game/experience/index.mjs";
import { downloadBlob } from "../web/storage.mjs";
import "./style.css";

const labels = {
  resolvedCount: "解決回数",
  completedCount: "区切りまで記録したループ",
  commandsPerResolution: "解決あたりのコマンド数",
  decisionsPerResolution: "解決あたりの判断数",
  undoCommands: "予約取消のコマンド数",
  causalCoverage: "解決と入力の対応率",
  feedbackLatencyP50Ms: "反応までの時間・中央値",
  feedbackLatencyP95Ms: "反応までの時間・p95",
  understandingRate: "結果の理解",
  reachedCount: "到達回数",
  exposedCount: "提示を記録した回数",
  firstExposureCount: "初提示の回数",
  repeatExposureCount: "再提示の回数",
  recognitionRate: "気づいた割合",
  comprehensionRate: "理解した割合",
};
const statuses = {
  observed: "観測済み",
  "not-instrumented": "未計測",
  "not-applicable": "対象なし",
  censored: "途中終了",
  completed: "区切りまで記録",
  interrupted: "中断",
  first: "初提示",
  repeat: "再提示",
  unknown: "提示は未確認",
};
const value = (n) =>
  n === null ? "—" : Number.isInteger(n) ? String(n) : n.toFixed(3);
const units = {
  resolution: "回",
  loop: "区間",
  arc: "回",
  "command/resolution": "コマンド / 解決",
  "decision/resolution": "判断 / 解決",
  command: "コマンド",
  ratio: "%",
  ms: "ms",
};
const evidenceLabels = {
  mechanical: "ルール上の結果",
  rendered: "画面への提示",
  human: "人の回答",
  exposure: "提示の記録",
  simulation: "ゲーム内記録",
  observation: "プレイヤー役への入力",
};
const scaled = (m, n) => (n === null ? null : m.unit === "ratio" ? n * 100 : n);
const node = (tag, text, className) => {
  const e = document.createElement(tag);
  if (text !== undefined) e.textContent = text;
  if (className) e.className = className;
  return e;
};
const button = (text, action) => {
  const e = node("button", text);
  e.type = "button";
  e.addEventListener("click", action);
  return e;
};

/** Generic recording viewer. It owns UI state; all evaluation stays in the pure reducer. */
export function installExperienceViewer({ setStatus } = {}) {
  let recording,
    report,
    baseline,
    comparison,
    tab = "metrics",
    query = "",
    evidenceFilter,
    selected,
    page = 0,
    disposed = false;
  const opener = button("体験レポート", open);
  opener.className = "experience-open";
  document.querySelector(".toolbar").append(opener);
  const dialog = node("dialog", undefined, "experience-dialog");
  dialog.setAttribute("aria-labelledby", "experience-title");
  // Keep Studio's scene undo/save/frame shortcuts outside this modal surface.
  dialog.addEventListener("keydown", (event) => event.stopPropagation());
  dialog.addEventListener(
    "keydown",
    (event) => {
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopPropagation();
        dialog.close();
      }
    },
    true,
  );
  const shell = node("div", undefined, "experience-shell"),
    header = node("header"),
    heading = node("div");
  const title = node("h2", "体験レポート");
  title.id = "experience-title";
  heading.append(
    node("small", "LOOPS & ARCS"),
    title,
    node("p", "選択・反応・発見を、記録から確かめる。"),
  );
  header.append(
    heading,
    button("閉じる", () => dialog.close()),
  );
  const actions = node("div", undefined, "experience-actions");
  function picker(label, description, isBaseline) {
    const file = node("input");
    file.type = "file";
    file.accept = ".json,application/json";
    file.hidden = true;
    file.setAttribute("aria-label", description);
    const trigger = button(label, () => file.click());
    let generation = 0;
    file.addEventListener("change", async () => {
      const chosen = file.files[0],
        ticket = ++generation;
      if (!chosen) return;
      try {
        if (chosen.size > 32 * 1024 * 1024)
          throw Error("記録は32 MiB以下にしてください");
        const data = JSON.parse(await chosen.text());
        if (disposed || ticket !== generation) return;
        load(data, { baseline: isBaseline });
      } catch (error) {
        showError(error);
      } finally {
        file.value = "";
      }
    });
    actions.append(trigger, file);
  }
  picker("記録を読込", "今回の体験記録JSON", false);
  picker("基準を読込", "基準の体験記録JSON", true);
  const clear = button("基準を解除", () => {
    baseline = comparison = undefined;
    render();
  });
  const exportButton = button("レポートを書出", () =>
    downloadBlob(
      new Blob([JSON.stringify(report, null, 2) + "\n"], {
        type: "application/json",
      }),
      "experience-report.json",
    ),
  );
  actions.append(clear, exportButton);
  const tabs = node("nav", undefined, "experience-tabs");
  tabs.setAttribute("aria-label", "体験レポートの表示");
  for (const [id, label] of [
    ["metrics", "指標"],
    ["intervals", "ループとアーク"],
    ["events", "イベント"],
  ]) {
    const b = button(label, () => {
      tab = id;
      render();
    });
    b.dataset.tab = id;
    tabs.append(b);
  }
  const summary = node(
    "p",
    "recording.jsonを読み込むと、指標と区間を再生成します。",
    "experience-summary",
  );
  summary.setAttribute("role", "status");
  const content = node("div", undefined, "experience-content"),
    errorBox = node("p", "", "experience-error");
  errorBox.setAttribute("role", "alert");
  const footer = node(
    "footer",
    "未計測は0に置き換えません。構造の完了と、人の理解を分けて読みます。",
  );
  shell.append(header, actions, tabs, summary, errorBox, content, footer);
  dialog.append(shell);
  document.body.append(dialog);

  function showError(error) {
    if (!disposed) {
      errorBox.textContent = `読込エラー · ${error.message}${report ? "。表示中の記録を保持しました。" : ""}`;
      setStatus?.("Error · " + error.message);
    }
  }
  function load(data, { baseline: isBaseline = false } = {}) {
    if (data?.format !== "kagura.experience-recording" || data.version !== 1)
      throw Error("recording.jsonを選んでください");
    const next = analyzeExperience(data);
    const nextComparison = isBaseline
      ? report
        ? compareExperience(next, report)
        : undefined
      : baseline
        ? compareExperience(baseline, next)
        : undefined;
    if (isBaseline) baseline = next;
    else {
      recording = structuredClone(data);
      report = next;
      selected = undefined;
      page = 0;
      query = "";
      evidenceFilter = undefined;
    }
    comparison = nextComparison;
    errorBox.textContent = "";
    render();
    return next;
  }
  function open() {
    if (!dialog.open) dialog.showModal();
  }
  function table(caption, columns) {
    const scroll = node("div", undefined, "experience-table-scroll"),
      t = node("table");
    t.setAttribute("aria-label", caption);
    const h = node("thead"),
      row = node("tr");
    for (const title of columns) {
      const th = node("th", title);
      th.scope = "col";
      row.append(th);
    }
    h.append(row);
    const body = node("tbody");
    t.append(h, body);
    scroll.append(t);
    content.append(scroll);
    return body;
  }
  function cell(row, text) {
    const c = node("td", text);
    row.append(c);
    return c;
  }
  function eventLink(row, id) {
    const td = cell(row);
    if (id)
      td.append(
        button(id, () => {
          tab = "events";
          query = id;
          evidenceFilter = undefined;
          selected = id;
          page = 0;
          render();
        }),
      );
    else td.textContent = "—";
  }
  function renderMetrics() {
    const body = table("体験指標", [
      "対象 / 指標",
      "今回",
      "状態 / 証拠",
      "標本 / 機会",
      ...(comparison ? ["基準", "差"] : []),
      "記録",
    ]);
    const names = new Map(
      [...report.spec.loops, ...report.spec.arcs].map((t) => [t.id, t.label]),
    );
    for (const m of report.measures) {
      const row = node("tr"),
        label = labels[m.id] ?? m.id,
        c = cell(row);
      c.append(
        node("small", names.get(m.targetId)),
        node("strong", label),
        node("code", m.id),
      );
      cell(
        row,
        m.value === null
          ? "未計測"
          : `${value(scaled(m, m.value))} ${units[m.unit] ?? m.unit}`,
      );
      cell(
        row,
        `${statuses[m.status]} · ${m.sources.length ? m.sources.map((s) => evidenceLabels[s] ?? s).join(", ") : (evidenceLabels[m.evidenceKind] ?? m.evidenceKind)}`,
      );
      cell(row, `${m.sampleCount} / ${m.eligibleCount}`);
      if (comparison) {
        const diff = comparison.measures.find(
          (p) => p.targetId === m.targetId && p.id === m.id,
        );
        cell(row, value(scaled(m, diff.before)));
        cell(
          row,
          diff.delta === null
            ? "—"
            : `${diff.delta > 0 ? "+" : ""}${value(scaled(m, diff.delta))}${m.unit === "ratio" ? " ポイント" : ""}`,
        );
      }
      const evidence = cell(row);
      if (m.evidenceEventIds.length) {
        const b = button(`${m.evidenceEventIds.length}件`, () => {
          tab = "events";
          query = "";
          evidenceFilter = new Set(m.evidenceEventIds);
          selected = m.evidenceEventIds[0];
          page = 0;
          render();
        });
        b.setAttribute("aria-label", `${names.get(m.targetId)} ${label}の証拠`);
        evidence.append(b);
      } else evidence.textContent = "—";
      body.append(row);
    }
  }
  function renderIntervals() {
    content.append(
      node(
        "p",
        "イベントの順序を表示します。区間の長さは経過時間を表しません。",
        "experience-note",
      ),
    );
    const body = table("体験の区間", [
      "区間 / 種類",
      "状態",
      "コマンド",
      "開始 / 到達",
      "解決 / 提示",
      "次の判断機会",
    ]);
    for (const l of report.loops) {
      const row = node("tr");
      cell(row, l.instance + " · ループ");
      cell(row, statuses[l.status]);
      cell(row, l.commands.length);
      eventLink(row, l.start);
      eventLink(row, l.resolution);
      eventLink(row, l.ready);
      body.append(row);
    }
    for (const a of report.arcs) {
      const row = node("tr");
      cell(row, a.instance + " · アーク");
      cell(row, statuses[a.exposure]);
      cell(row, "—");
      eventLink(row, a.reached);
      eventLink(row, a.exposed[0]);
      cell(row, "—");
      body.append(row);
    }
  }
  function renderEvents() {
    const filter = node("div", undefined, "experience-filter"),
      search = node("input");
    search.type = "search";
    search.value = query;
    search.placeholder = "イベントID・区間で検索";
    search.setAttribute("aria-label", "体験イベントを検索");
    search.addEventListener("input", () => {
      query = search.value;
      evidenceFilter = undefined;
      page = 0;
      renderEventRows();
    });
    const count = node("span"),
      previous = button("前の100件", () => {
        page--;
        renderEventRows();
      }),
      next = button("次の100件", () => {
        page++;
        renderEventRows();
      });
    filter.append(search, count, previous, next);
    content.append(filter);
    const body = table("体験イベント", [
      "順序 / 判断",
      "イベントID",
      "種類",
      "区間",
      "原因",
    ]);
    const details = node("pre", "", "experience-detail");
    details.setAttribute("aria-label", "イベントの詳細");
    content.append(details);
    function renderEventRows() {
      const rows = recording.events.filter(
        (e) =>
          (!evidenceFilter || evidenceFilter.has(e.id)) &&
          (!query || `${e.id} ${e.type} ${e.instance ?? ""}`.includes(query)),
      );
      const visible = rows.slice(page * 100, (page + 1) * 100);
      body.replaceChildren();
      count.textContent = `${rows.length}件 · ${page + 1}ページ`;
      previous.disabled = page === 0;
      next.disabled = (page + 1) * 100 >= rows.length;
      if (!visible.some((e) => e.id === selected)) selected = visible[0]?.id;
      for (const e of visible) {
        const row = node("tr");
        cell(row, `${e.sequence} / ${e.decisionIndex ?? "—"}`);
        const c = cell(row);
        c.append(
          button(e.id, () => {
            selected = e.id;
            details.textContent = JSON.stringify(e, null, 2);
          }),
        );
        cell(row, e.type);
        cell(row, e.instance ?? "—");
        cell(row, e.causes?.join(", ") || "—");
        body.append(row);
      }
      details.textContent = selected
        ? JSON.stringify(
            recording.events.find((e) => e.id === selected),
            null,
            2,
          )
        : "該当するイベントはありません。";
    }
    renderEventRows();
  }
  function render() {
    clear.disabled = !baseline;
    exportButton.disabled = !report;
    for (const b of tabs.children)
      b.setAttribute("aria-current", b.dataset.tab === tab ? "page" : "false");
    content.replaceChildren();
    if (!report) {
      content.append(
        node("p", "CLIで生成したrecording.jsonを読み込んでください。"),
      );
      return;
    }
    summary.textContent =
      `${report.spec.id} · ${report.run.cohort} · ループ${report.loops.length} / アーク${report.arcs.length} · ${report.valid ? "記録品質：有効" : `記録品質：${report.issues.length}件を要確認`}` +
      (comparison
        ? ` · 比較条件の差：${comparison.conditionsDiffer.join(", ") || "なし"}`
        : "");
    if (report.issues.length) {
      const list = node("ul", undefined, "experience-issues");
      for (const i of report.issues.slice(0, 20))
        list.append(node("li", `${i.code} / ${i.eventId}`));
      content.append(list);
    }
    if (tab === "metrics") renderMetrics();
    else if (tab === "intervals") renderIntervals();
    else renderEvents();
  }
  render();
  return {
    open,
    load,
    dispose() {
      disposed = true;
      dialog.close();
      dialog.remove();
      opener.remove();
    },
  };
}
