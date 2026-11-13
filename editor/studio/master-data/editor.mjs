import {
  createMasterDataSession,
  validateDocument,
  applyParameters,
} from "../../../game/master-data/contract.mjs";
import { downloadBlob } from "../web/storage.mjs";
import "./style.css";

const node = (tag, text, className) => {
  const n = document.createElement(tag);
  if (text !== undefined) n.textContent = text;
  if (className) n.className = className;
  return n;
};
const button = (text, action) => {
  const n = node("button", text);
  n.type = "button";
  n.addEventListener("click", action);
  return n;
};

/** Full-width authoring surface. No table or field is specific to a game. */
export function installMasterDataEditor({ host, setStatus }) {
  let current,
    session,
    resourceRevision = 0,
    tableId,
    query = "",
    busy = false,
    generation = 0,
    disposed = false;
  const opener = button("マスターデータ", () => open().catch(showError));
  opener.className = "master-data-open";
  document.querySelector(".toolbar").append(opener);
  const dialog = node("dialog", undefined, "master-data-dialog");
  dialog.setAttribute("aria-labelledby", "master-data-title");
  const shell = node("div", undefined, "master-data-shell");
  const header = node("header"),
    heading = node("div");
  heading.append(node("small", "GAME DATA"));
  const title = node("h2", "マスターデータ");
  title.id = "master-data-title";
  const subtitle = node("p", "", "master-subtitle");
  heading.append(title, subtitle);
  const close = button("閉じる", () => dialog.close());
  close.setAttribute("aria-label", "マスターデータを閉じる");
  header.append(heading, close);
  const toolbar = node("div", undefined, "master-data-actions");
  const undo = button("元に戻す", () =>
    change(() => session.undo(session.snapshot().revision)),
  );
  const redo = button("やり直す", () =>
    change(() => session.redo(session.snapshot().revision)),
  );
  const search = node("input");
  search.type = "search";
  search.placeholder = "名前・IDで検索";
  search.setAttribute("aria-label", "マスターデータを検索");
  search.addEventListener("input", () => {
    query = search.value;
    renderTable();
  });
  const file = node("input");
  file.type = "file";
  file.accept = ".json,application/json";
  file.className = "master-file";
  file.setAttribute("aria-label", "マスターデータJSONを読み込む");
  const importButton = button("JSON読込", () => file.click());
  const exportButton = button("JSON書出", () => {
    try {
      downloadBlob(
        new Blob([JSON.stringify(session.document(), null, 2) + "\n"], {
          type: "application/json",
        }),
        `${session.adapter.schema.id}.master-data.json`,
      );
    } catch (error) {
      showError(error);
    }
  });
  const reload = button("編集を破棄", () => load(true).catch(showError));
  reload.title = "未反映の編集を破棄して、プロジェクトのデータを読み込みます";
  toolbar.append(undo, redo, search, importButton, exportButton, reload, file);
  const body = node("div", undefined, "master-data-body"),
    tabs = node("nav", undefined, "master-data-tabs");
  tabs.setAttribute("aria-label", "マスターテーブル");
  const content = node("section", undefined, "master-data-content");
  const tableHeading = node("h3"),
    description = node("p", "", "master-description");
  const scroller = node("div", undefined, "master-table-scroll");
  scroller.tabIndex = 0;
  scroller.setAttribute("role", "region");
  scroller.setAttribute("aria-label", "マスターデータの表");
  const rowActions = node("div", undefined, "master-row-actions");
  const add = button("行を追加", () => addRow());
  rowActions.append(add);
  const errors = node("div", undefined, "master-data-errors");
  errors.setAttribute("role", "alert");
  content.append(tableHeading, description, scroller, rowActions, errors);
  body.append(tabs, content);
  const footer = node("footer"),
    status = node("p", "", "master-data-status"),
    actions = node("div", undefined, "master-footer-actions");
  const apply = button("次のPlayに反映", () => commit(false));
  apply.className = "primary";
  const save = button("フォルダへ保存", () => commit(true));
  actions.append(save, apply);
  footer.append(status, actions);
  shell.append(header, toolbar, body, footer);
  dialog.append(shell);
  document.body.append(dialog);
  file.addEventListener("change", async () => {
    const selected = file.files[0];
    if (!selected) return;
    const owner = current,
      revision = session?.snapshot().revision;
    try {
      if (selected.size > 4 * 1024 * 1024)
        throw Error("JSONは4 MiB以下にしてください");
      let data = JSON.parse(await selected.text());
      if (owner !== current) throw Error("プロジェクトが変更されました");
      if (
        data?.schemaVersion === 1 &&
        data.game === session.adapter.schema.id &&
        data.parameters
      )
        data = applyParameters(
          session.adapter,
          session.snapshot().document,
          data.parameters,
        );
      const issues = validateDocument(session.adapter, data);
      if (issues.length)
        throw Error(
          "Invalid master data · " +
            issues
              .map((i) => i.message)
              .slice(0, 5)
              .join(" / "),
        );
      if (change(() => session.import(data, revision)))
        setStatus?.("Master data · JSONを読み込みました");
    } catch (error) {
      showError(error);
    } finally {
      file.value = "";
    }
  });
  function showError(error) {
    if (disposed) return;
    errors.textContent = error.message;
    setStatus?.("Error · " + error.message);
  }
  const selectedTable = () =>
    session.adapter.schema.tables.find((t) => t.id === tableId);
  function change(action) {
    try {
      action();
      renderTable();
      renderState();
      return true;
    } catch (error) {
      showError(error);
      return false;
    }
  }
  function renderState() {
    if (!session) return;
    const s = session.snapshot();
    undo.disabled = busy || !s.canUndo;
    redo.disabled = busy || !s.canRedo;
    apply.disabled = busy || !s.valid || !s.dirty;
    save.disabled = busy || !s.valid;
    save.hidden = !current.writable;
    exportButton.disabled = busy || !s.valid;
    importButton.disabled = busy;
    reload.disabled = busy || !s.dirty;
    const note = current.writable
      ? "フォルダへ保存できます。"
      : "サンプルの編集はプロジェクトを閉じるまで有効です。JSONを書き出せます。";
    status.textContent =
      (busy ? "処理中…" : s.dirty ? "未反映の編集があります。" : "反映済み。") +
      " 実行中のシーンは変わらず、次のPlayで読み込みます。" +
      note;
    errors.replaceChildren();
    if (s.issues.length) {
      errors.append(node("strong", `${s.issues.length}件を修正してください`));
      const list = node("ul");
      for (const i of s.issues.slice(0, 30))
        list.append(node("li", `${i.row ?? i.table ?? ""} ${i.message}`));
      errors.append(list);
    }
    for (const input of scroller.querySelectorAll("input,select,button"))
      input.disabled = busy || input.dataset.unset === "true";
  }
  function renderTabs() {
    tabs.replaceChildren();
    for (const t of session.adapter.schema.tables) {
      const b = button(t.label, () => {
        tableId = t.id;
        query = "";
        search.value = "";
        renderTabs();
        renderTable();
        renderState();
      });
      b.setAttribute("aria-current", t.id === tableId ? "page" : "false");
      b.append(
        node("span", String(session.snapshot().document.tables[t.id].length)),
      );
      tabs.append(b);
    }
  }
  function renderTable() {
    if (!session) return;
    const t = selectedTable(),
      s = session.snapshot();
    tableHeading.textContent = t.label;
    description.textContent = t.description ?? "テーブルの値を編集します。";
    add.hidden = !!t.rowIds || t.allowAdd === false;
    add.disabled = busy;
    const table = node("table");
    table.setAttribute("aria-label", `${t.label}マスターテーブル`);
    const head = node("thead"),
      headRow = node("tr");
    for (const c of t.columns) {
      const th = node("th", c.label);
      th.scope = "col";
      if (c.min !== undefined || c.max !== undefined)
        th.append(node("small", `${c.min ?? "−∞"} – ${c.max ?? "∞"}`));
      headRow.append(th);
    }
    if (!t.rowIds && t.allowRemove !== false)
      headRow.append(node("th", "操作"));
    head.append(headRow);
    table.append(head);
    const tbody = node("tbody");
    const rows = s.document.tables[t.id].filter(
      (r) =>
        !query ||
        Object.values(r).some((v) =>
          String(v).toLocaleLowerCase().includes(query.toLocaleLowerCase()),
        ),
    );
    for (const row of rows) {
      const tr = node("tr");
      tr.dataset.row = row[t.primaryKey];
      for (const c of t.columns) {
        const td = node(c.id === t.primaryKey ? "th" : "td");
        if (c.id === t.primaryKey) {
          td.scope = "row";
          td.append(node("code", row[c.id]));
          tr.append(td);
          continue;
        }
        if (c.readOnly) {
          td.textContent = String(row[c.id]);
          td.className = "master-readonly";
          tr.append(td);
          continue;
        }
        const input = node(
          ["enum", "reference"].includes(c.type) ? "select" : "input",
        );
        input.setAttribute("aria-label", `${c.label}（${row[t.primaryKey]}）`);
        const unset =
          c.nullable && c.type !== "reference" ? node("input") : undefined;
        if (unset) {
          unset.type = "checkbox";
          unset.checked = row[c.id] === null;
          unset.setAttribute(
            "aria-label",
            `${c.label}を未設定（${row[t.primaryKey]}）`,
          );
          input.dataset.unset = String(unset.checked);
          input.disabled = busy || unset.checked;
          unset.addEventListener("change", () =>
            change(() =>
              session.edit({
                revision: session.snapshot().revision,
                table: t.id,
                row: row[t.primaryKey],
                column: c.id,
                value: unset.checked ? null : nonNullDefault(c),
              }),
            ),
          );
        }
        const issue = s.issues.find(
          (i) =>
            i.table === t.id &&
            i.row === row[t.primaryKey] &&
            i.column === c.id,
        );
        if (issue) {
          input.setAttribute("aria-invalid", "true");
          input.title = issue.message;
        }
        if (c.type === "enum" || c.type === "reference") {
          const target = session.adapter.schema.tables.find(
            (t) => t.id === c.table,
          );
          const options =
            c.type === "enum"
              ? c.options.map((value) => [value, value])
              : s.document.tables[c.table].map((r) => [
                  r[target.primaryKey],
                  `${r[target.labelField ?? target.primaryKey]} (${r[target.primaryKey]})`,
                ]);
          if (c.nullable && c.type === "reference")
            options.unshift(["", "— なし —"]);
          for (const [value, label] of options) {
            const option = node("option", label);
            option.value = value;
            input.append(option);
          }
          input.value = row[c.id] ?? "";
        } else if (c.type === "boolean") {
          input.type = "checkbox";
          input.checked = row[c.id] === true;
        } else {
          input.type = ["number", "integer"].includes(c.type)
            ? "number"
            : "text";
          input.value = row[c.id] ?? "";
          if (c.maxLength) input.maxLength = c.maxLength;
          for (const k of ["min", "max", "step"])
            if (c[k] !== undefined) input[k] = c[k];
        }
        input.addEventListener("change", () => {
          const value =
            c.type === "boolean"
              ? input.checked
              : ["number", "integer"].includes(c.type)
                ? input.value === ""
                  ? null
                  : input.valueAsNumber
                : c.type === "reference" && c.nullable && input.value === ""
                  ? null
                  : input.value;
          try {
            session.edit({
              revision: session.snapshot().revision,
              table: t.id,
              row: row[t.primaryKey],
              column: c.id,
              value,
            });
            if (unset) {
              unset.checked = value === null;
              input.dataset.unset = String(unset.checked);
            }
            const error = session
              .snapshot()
              .issues.find(
                (i) =>
                  i.table === t.id &&
                  i.row === row[t.primaryKey] &&
                  i.column === c.id,
              );
            input.setAttribute("aria-invalid", String(!!error));
            input.title = error?.message ?? "";
            renderState();
          } catch (error) {
            showError(error);
          }
        });
        td.append(input);
        if (unset) {
          const label = node("label", undefined, "master-null");
          label.append(unset, document.createTextNode("未設定"));
          td.append(label);
        }
        tr.append(td);
      }
      if (!t.rowIds && t.allowRemove !== false) {
        const td = node("td");
        td.append(
          button("削除", () =>
            change(() =>
              session.remove(
                t.id,
                row[t.primaryKey],
                session.snapshot().revision,
              ),
            ),
          ),
        );
        tr.append(td);
      }
      tbody.append(tr);
    }
    table.append(tbody);
    scroller.replaceChildren(table);
    if (!rows.length) scroller.append(node("p", "一致する行がありません。"));
  }
  function nonNullDefault(c) {
    if (c.default !== undefined && c.default !== null) return c.default;
    if (c.type === "boolean") return false;
    if (c.type === "enum") return c.options[0];
    if (["number", "integer"].includes(c.type)) return c.min ?? 0;
    return "";
  }
  function addRow() {
    const t = selectedTable(),
      s = session.snapshot(),
      rows = s.document.tables[t.id];
    let i = 1;
    while (rows.some((r) => r[t.primaryKey] === `row_${i}`)) i++;
    const row = Object.fromEntries(
      t.columns.map((c) => {
        if (c.id === t.primaryKey) return [c.id, `row_${i}`];
        if (c.default !== undefined) return [c.id, c.default];
        const ref = session.adapter.schema.tables.find((t) => t.id === c.table);
        return [
          c.id,
          c.nullable
            ? null
            : c.type === "boolean"
              ? false
              : c.type === "enum"
                ? c.options[0]
                : c.type === "reference"
                  ? (s.document.tables[c.table][0]?.[ref.primaryKey] ?? "")
                  : ["number", "integer"].includes(c.type)
                    ? (c.min ?? 0)
                    : "",
        ];
      }),
    );
    change(() => session.add(t.id, row, s.revision));
    renderTabs();
  }
  async function load(force = false) {
    const project = host.project();
    if (!project?.manifest.masterData)
      throw Error(
        "このプロジェクトはマスターデータアダプターを定義していません",
      );
    if (project === current && session && !force) return;
    const ticket = ++generation,
      definition = project.manifest.masterData;
    const [module, resource] = await Promise.all([
      project
        .url(definition.adapter, "text/javascript")
        .then((url) => import(/* @vite-ignore */ url)),
      project.readResource(definition.resource),
    ]);
    if (disposed || ticket !== generation || host.project() !== project) return;
    if (resource.blob.size > 4 * 1024 * 1024)
      throw Error("マスターデータは4 MiB以下にしてください");
    const data = JSON.parse(await resource.blob.text());
    if (disposed || ticket !== generation || host.project() !== project) return;
    const next = createMasterDataSession(module.masterDataAdapter, data);
    current = project;
    session = next;
    resourceRevision = resource.revision;
    tableId = next.adapter.schema.tables[0].id;
    query = "";
    search.value = "";
    subtitle.textContent = next.adapter.schema.title;
    renderTabs();
    renderTable();
    renderState();
  }
  const inertBackground = new Map();
  dialog.addEventListener("close", () => {
    for (const [element, wasInert] of inertBackground) element.inert = wasInert;
    inertBackground.clear();
  });
  async function open() {
    await load();
    if (!disposed && current === host.project() && session) {
      if (!dialog.open) {
        for (const element of document.body.children) {
          if (element !== dialog && element instanceof HTMLElement) {
            inertBackground.set(element, element.inert);
            element.inert = true;
          }
        }
        dialog.showModal();
      }
    }
  }
  async function commit(persist) {
    if (busy || !session) return;
    busy = true;
    renderState();
    const project = current,
      revision = session.snapshot().revision;
    try {
      const data = session.document();
      if (host.project() !== project)
        throw Error("プロジェクトが変更されました");
      resourceRevision = await project.stageResource(
        project.manifest.masterData.resource,
        new Blob([JSON.stringify(data, null, 2) + "\n"], {
          type: "application/json",
        }),
        resourceRevision,
      );
      if (persist) await project.saveResources();
      if (current === project) {
        session.acknowledge(revision);
        setStatus?.(
          persist ? "Saved master data" : "Master data · 次のPlayで反映",
        );
      }
    } catch (error) {
      showError(error);
    } finally {
      busy = false;
      renderState();
    }
  }
  function refresh() {
    opener.disabled = !host.project()?.manifest.masterData;
    if (current && current !== host.project()) {
      generation++;
      dialog.close();
      current = session = undefined;
    }
  }
  const unsubscribe = host.subscribe(refresh);
  refresh();
  return {
    open,
    snapshot: () => session?.snapshot(),
    dispose() {
      disposed = true;
      generation++;
      unsubscribe();
      dialog.close();
      for (const [element, wasInert] of inertBackground)
        element.inert = wasInert;
      inertBackground.clear();
      dialog.remove();
      opener.remove();
    },
  };
}
