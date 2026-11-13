const key = (value) =>
  typeof value === "string" &&
  /^[a-zA-Z][a-zA-Z0-9_.-]{0,79}$/.test(value) &&
  !["constructor", "prototype"].includes(value);
const object = (value) =>
  value !== null && typeof value === "object" && !Array.isArray(value);
const unique = (values) => new Set(values).size === values.length;
const clone = (value) => structuredClone(value);
function freeze(value) {
  if (value && typeof value === "object") {
    Object.values(value).forEach(freeze);
    Object.freeze(value);
  }
  return value;
}
function check(condition, message) {
  if (!condition) throw Error(message);
}

/** Rendering-independent table contract. Adapters may add pure cross-table
 * validation; they never own editor controls, history or persistence. */
export function validateAdapter(adapter) {
  check(
    adapter?.apiVersion === 1 && object(adapter.schema),
    "Invalid master data adapter",
  );
  const s = adapter.schema;
  check(
    key(s.id) &&
      Number.isInteger(s.version) &&
      s.version > 0 &&
      typeof s.title === "string" &&
      s.title.length > 0 &&
      Array.isArray(s.tables) &&
      s.tables.length > 0 &&
      s.tables.length <= 64 &&
      unique(s.tables.map((t) => t.id)),
    "Invalid master data schema",
  );
  for (const t of s.tables) {
    check(
      key(t.id) &&
        typeof t.label === "string" &&
        key(t.primaryKey) &&
        Array.isArray(t.columns) &&
        t.columns.length > 0 &&
        t.columns.length <= 64 &&
        unique(t.columns.map((c) => c.id)),
      "Invalid table schema",
    );
    check(
      t.columns.some(
        (c) => c.id === t.primaryKey && c.type === "string" && !c.nullable,
      ),
      "Invalid primary key schema",
    );
    for (const c of t.columns) {
      check(
        key(c.id) &&
          typeof c.label === "string" &&
          [
            "string",
            "integer",
            "number",
            "boolean",
            "enum",
            "reference",
          ].includes(c.type),
        "Invalid column schema",
      );
      for (const p of ["min", "max", "step", "minLength", "maxLength"])
        if (c[p] !== undefined)
          check(Number.isFinite(c[p]), "Invalid bounds schema");
      check(
        (c.min ?? -Infinity) <= (c.max ?? Infinity) &&
          (c.step === undefined || c.step > 0),
        "Invalid bounds schema",
      );
      if (c.type === "enum")
        check(
          Array.isArray(c.options) &&
            c.options.length > 0 &&
            unique(c.options) &&
            c.options.every((v) => typeof v === "string"),
          "Invalid enum schema",
        );
      if (c.type === "reference")
        check(
          s.tables.some((t) => t.id === c.table),
          "Invalid reference schema",
        );
    }
    if (t.rowIds)
      check(
        Array.isArray(t.rowIds) && unique(t.rowIds) && t.rowIds.every(key),
        "Invalid fixed rows schema",
      );
    check(
      Number.isInteger(t.minRows ?? 0) &&
        (t.minRows ?? 0) >= 0 &&
        Number.isInteger(t.maxRows ?? 10000) &&
        (t.maxRows ?? 10000) >= (t.minRows ?? 0),
      "Invalid row count schema",
    );
  }
  check(
    adapter.validate === undefined || typeof adapter.validate === "function",
    "Invalid adapter validation",
  );
  const bindings = adapter.parameters ?? {};
  check(object(bindings), "Invalid parameter bindings");
  for (const [name, b] of Object.entries(bindings)) {
    const t = s.tables.find((t) => t.id === b?.table),
      c = t?.columns.find((c) => c.id === b.column);
    check(
      key(name) &&
        key(b.row) &&
        c &&
        ["number", "integer"].includes(c.type) &&
        Number.isFinite(c.min) &&
        Number.isFinite(c.max),
      "Invalid parameter binding schema",
    );
  }
  check(
    unique(
      Object.values(bindings).map((b) =>
        JSON.stringify([b.table, b.row, b.column]),
      ),
    ),
    "Duplicate parameter binding schema",
  );
  return Object.freeze({
    apiVersion: 1,
    schema: freeze(clone(s)),
    parameters: freeze(clone(bindings)),
    validate: adapter.validate,
  });
}

export function parameterSpecs(input, document) {
  const a = validateAdapter(input);
  check(validateDocument(a, document).length === 0, "Invalid master data");
  return Object.entries(a.parameters).map(([name, b]) => {
    const t = a.schema.tables.find((t) => t.id === b.table),
      c = t.columns.find((c) => c.id === b.column),
      row = document.tables[b.table].find((r) => r[t.primaryKey] === b.row);
    check(row, "Invalid parameter binding row");
    return {
      name,
      min: c.min,
      max: c.max,
      step: c.step ?? 1,
      initial: row[b.column],
    };
  });
}

export function applyParameters(input, document, parameters) {
  const a = validateAdapter(input);
  check(object(parameters), "Invalid parameters");
  const next = clone(document);
  for (const [name, value] of Object.entries(parameters)) {
    const b = a.parameters[name];
    check(b, "Unknown parameter: " + name);
    const t = a.schema.tables.find((t) => t.id === b.table),
      row = next.tables[b.table].find((r) => r[t.primaryKey] === b.row);
    check(row, "Invalid parameter binding row");
    row[b.column] = value;
  }
  check(validateDocument(a, next).length === 0, "Invalid parameter values");
  return next;
}

export function validateDocument(adapter, document) {
  const { schema: s, validate } = validateAdapter(adapter),
    issues = [];
  const issue = (code, message, table, row, column) =>
    issues.push({
      code,
      message,
      ...(table ? { table } : {}),
      ...(row !== undefined ? { row } : {}),
      ...(column ? { column } : {}),
    });
  if (
    !object(document) ||
    document.format !== "kagura.master-data" ||
    document.version !== s.version ||
    document.game !== s.id ||
    !object(document.tables)
  ) {
    issue("document", "マスターデータの形式・バージョン・ゲームが一致しません");
    return issues;
  }
  if (
    Object.keys(document).some(
      (k) => !["format", "version", "game", "tables"].includes(k),
    )
  )
    issue("unknown", "未定義のドキュメント項目があります");
  for (const id of Object.keys(document.tables))
    if (!s.tables.some((t) => t.id === id))
      issue("unknown", `未定義のテーブル: ${id}`, id);
  const references = new Map(
    s.tables.map((t) => [
      t.id,
      new Set(
        Array.isArray(document.tables[t.id])
          ? document.tables[t.id].map((r) => r?.[t.primaryKey])
          : [],
      ),
    ]),
  );
  for (const t of s.tables) {
    const rows = document.tables[t.id];
    if (!Array.isArray(rows)) {
      issue("table", `${t.label}がありません`, t.id);
      continue;
    }
    if (rows.length < (t.minRows ?? 0) || rows.length > (t.maxRows ?? 10000))
      issue("rows", `${t.label}の行数が範囲外です`, t.id);
    if (
      t.rowIds &&
      (rows.length !== t.rowIds.length ||
        rows.some((r) => !t.rowIds.includes(r?.[t.primaryKey])))
    )
      issue("rows", `${t.label}の固定IDが一致しません`, t.id);
    const seen = new Map(
      t.columns
        .filter((c) => c.unique || c.id === t.primaryKey)
        .map((c) => [c.id, new Set()]),
    );
    for (let i = 0; i < rows.length; i++) {
      const r = rows[i],
        row = String(object(r) ? (r[t.primaryKey] ?? i) : i);
      if (!object(r)) {
        issue("row", "行はオブジェクトで指定してください", t.id, row);
        continue;
      }
      for (const k of Object.keys(r))
        if (!t.columns.some((c) => c.id === k))
          issue("unknown", `未定義の列: ${k}`, t.id, row, k);
      for (const c of t.columns) {
        const v = r[c.id];
        let valid = true;
        if (v === null && c.nullable) continue;
        switch (c.type) {
          case "string":
            valid =
              typeof v === "string" &&
              v.length >= (c.minLength ?? 0) &&
              v.length <= (c.maxLength ?? 4096);
            break;
          case "integer":
          case "number": {
            valid =
              Number.isFinite(v) &&
              (c.type !== "integer" || Number.isSafeInteger(v)) &&
              v >= (c.min ?? -Infinity) &&
              v <= (c.max ?? Infinity);
            if (valid && c.step !== undefined) {
              const n = (v - (c.min ?? 0)) / c.step;
              valid = Math.abs(n - Math.round(n)) < 1e-7;
            }
            break;
          }
          case "boolean":
            valid = typeof v === "boolean";
            break;
          case "enum":
            valid = c.options.includes(v);
            break;
          case "reference": {
            valid = typeof v === "string" && references.get(c.table).has(v);
            if (!valid) {
              issue(
                "reference",
                `${c.label}の参照先がありません: ${String(v)}`,
                t.id,
                row,
                c.id,
              );
              continue;
            }
          }
        }
        if (c.id === t.primaryKey) valid = valid && key(v);
        if (!valid)
          issue(
            "value",
            `${c.label}の型・値・範囲を確認してください`,
            t.id,
            row,
            c.id,
          );
        if (seen.has(c.id)) {
          if (seen.get(c.id).has(v))
            issue("duplicate", `${c.label}が重複しています`, t.id, row, c.id);
          seen.get(c.id).add(v);
        }
        if (
          t.lockedValues?.[row] &&
          Object.hasOwn(t.lockedValues[row], c.id) &&
          v !== t.lockedValues[row][c.id]
        )
          issue("locked", `${c.label}は固定値です`, t.id, row, c.id);
      }
    }
  }
  if (!issues.length && validate) {
    const extra = validate(freeze(clone(document)));
    check(Array.isArray(extra), "Adapter validate must return issues");
    issues.push(...extra);
  }
  return issues;
}

/** Drafts can temporarily violate references. Only document() returns an
 * applicable, fully validated document. Every mutation uses a revision token. */
export function createMasterDataSession(input, document) {
  const adapter = validateAdapter(input);
  check(
    validateDocument(adapter, document).length === 0,
    "Invalid initial master data",
  );
  let draft = clone(document),
    revision = 0,
    baseline = JSON.stringify(document);
  const undo = [],
    redo = [];
  const guard = (expected) =>
    check(expected === revision, "Stale master data revision");
  function replace(next) {
    undo.push(draft);
    if (undo.length > 40) undo.shift();
    redo.length = 0;
    draft = next;
    revision++;
  }
  function table(id) {
    const t = adapter.schema.tables.find((t) => t.id === id);
    check(t, "Unknown table");
    return t;
  }
  const session = {
    adapter,
    snapshot() {
      const issues = validateDocument(adapter, draft);
      return freeze({
        revision,
        document: clone(draft),
        issues,
        valid: !issues.length,
        dirty: JSON.stringify(draft) !== baseline,
        canUndo: !!undo.length,
        canRedo: !!redo.length,
      });
    },
    document() {
      check(
        validateDocument(adapter, draft).length === 0,
        "Invalid master data draft",
      );
      return freeze(clone(draft));
    },
    edit({ revision: expected, table: id, row, column, value }) {
      guard(expected);
      const t = table(id),
        c = t.columns.find((c) => c.id === column);
      check(c, "Unknown column");
      check(column !== t.primaryKey && !c.readOnly, "Read-only column");
      const index = draft.tables[id].findIndex((r) => r[t.primaryKey] === row);
      check(index >= 0, "Unknown row");
      const next = clone(draft);
      next.tables[id][index][column] = clone(value);
      replace(next);
    },
    add(id, row, expected) {
      guard(expected);
      const t = table(id);
      check(!t.rowIds && t.allowAdd !== false, "Read-only row set");
      check(
        object(row) &&
          key(row[t.primaryKey]) &&
          !draft.tables[id].some((r) => r[t.primaryKey] === row[t.primaryKey]),
        "Invalid row ID",
      );
      const next = clone(draft);
      next.tables[id].push(clone(row));
      replace(next);
    },
    remove(id, row, expected) {
      guard(expected);
      const t = table(id);
      check(!t.rowIds && t.allowRemove !== false, "Read-only row set");
      const next = clone(draft),
        index = next.tables[id].findIndex((r) => r[t.primaryKey] === row);
      check(index >= 0, "Unknown row");
      next.tables[id].splice(index, 1);
      replace(next);
    },
    import(next, expected) {
      guard(expected);
      check(
        validateDocument(adapter, next).length === 0,
        "Invalid imported master data",
      );
      replace(clone(next));
    },
    undo(expected) {
      guard(expected);
      check(undo.length, "Nothing to undo");
      redo.push(draft);
      draft = undo.pop();
      revision++;
    },
    redo(expected) {
      guard(expected);
      check(redo.length, "Nothing to redo");
      undo.push(draft);
      draft = redo.pop();
      revision++;
    },
    acknowledge(expected) {
      guard(expected);
      baseline = JSON.stringify(session.document());
    },
  };
  return Object.freeze(session);
}
