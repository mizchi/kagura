import test from "node:test";
import assert from "node:assert/strict";
import {
  validateAdapter,
  validateDocument,
  createMasterDataSession,
  parameterSpecs,
  applyParameters,
} from "./contract.mjs";

const adapter = {
  apiVersion: 1,
  schema: {
    id: "sample",
    version: 1,
    title: "Sample",
    tables: [
      {
        id: "items",
        label: "Items",
        primaryKey: "id",
        labelField: "name",
        minRows: 1,
        maxRows: 10,
        columns: [
          { id: "id", label: "ID", type: "string", maxLength: 80 },
          {
            id: "name",
            label: "Name",
            type: "string",
            minLength: 1,
            maxLength: 30,
          },
          {
            id: "power",
            label: "Power",
            type: "integer",
            min: 1,
            max: 100,
            step: 1,
            default: 5,
          },
          { id: "enabled", label: "Enabled", type: "boolean", default: true },
          {
            id: "role",
            label: "Role",
            type: "enum",
            options: ["weapon", "armor"],
            default: "weapon",
          },
        ],
      },
      {
        id: "encounters",
        label: "Encounters",
        primaryKey: "id",
        minRows: 1,
        maxRows: 10,
        columns: [
          { id: "id", label: "ID", type: "string", maxLength: 80 },
          { id: "item", label: "Item", type: "reference", table: "items" },
        ],
      },
    ],
  },
};
const data = {
  format: "kagura.master-data",
  version: 1,
  game: "sample",
  tables: {
    items: [
      { id: "sword", name: "Sword", power: 10, enabled: true, role: "weapon" },
    ],
    encounters: [{ id: "boss", item: "sword" }],
  },
};
test("schema contracts reject unknown types and unresolved reference tables", () => {
  assert.equal(validateAdapter(adapter).schema.id, "sample");
  const a = structuredClone(adapter);
  a.schema.tables[1].columns[1].table = "missing";
  assert.throws(() => validateAdapter(a), /schema/);
  assert.throws(
    () => validateAdapter({ ...adapter, apiVersion: 2 }),
    /adapter/,
  );
});
test("documents validate types, keys, steps, finite numbers and references as a whole", () => {
  assert.deepEqual(validateDocument(adapter, data), []);
  for (const [column, value] of [
    ["power", NaN],
    ["power", 1.5],
    ["power", 101],
    ["enabled", "yes"],
    ["role", "unknown"],
    ["name", ""],
  ]) {
    const d = structuredClone(data);
    d.tables.items[0][column] = value;
    const issues = validateDocument(adapter, d);
    assert.ok(issues.some((i) => i.table === "items" && i.column === column));
  }
  const d = structuredClone(data);
  d.tables.items = [];
  assert.ok(validateDocument(adapter, d).some((i) => i.code === "reference"));
  d.tables.items = [...data.tables.items, ...data.tables.items];
  assert.ok(validateDocument(adapter, d).some((i) => i.code === "duplicate"));
});
test("drafts may be invalid while edits are grouped; undo, import and revision guards preserve state", () => {
  const s = createMasterDataSession(adapter, data);
  s.edit({
    revision: 0,
    table: "items",
    row: "sword",
    column: "power",
    value: 101,
  });
  assert.equal(s.snapshot().valid, false);
  assert.throws(() => s.document(), /invalid/i);
  assert.throws(
    () =>
      s.edit({
        revision: 0,
        table: "items",
        row: "sword",
        column: "power",
        value: 5,
      }),
    /stale/i,
  );
  s.undo(1);
  assert.equal(s.document().tables.items[0].power, 10);
  s.redo(2);
  assert.equal(s.snapshot().valid, false);
  const before = s.snapshot();
  assert.throws(
    () => s.import({ ...data, version: 9 }, before.revision),
    /invalid/i,
  );
  assert.deepEqual(s.snapshot(), before);
  s.edit({
    revision: before.revision,
    table: "items",
    row: "sword",
    column: "power",
    value: 20,
  });
  assert.equal(s.document().tables.items[0].power, 20);
  assert.equal(data.tables.items[0].power, 10);
  assert.throws(
    () =>
      s.edit({
        revision: s.snapshot().revision,
        table: "items",
        row: "sword",
        column: "id",
        value: "other",
      }),
    /read.only/i,
  );
});
test("row deletion reports references until repaired, and snapshots are detached", () => {
  const s = createMasterDataSession(adapter, data);
  s.add(
    "items",
    { id: "shield", name: "Shield", power: 3, role: "armor", enabled: true },
    0,
  );
  s.remove("items", "sword", 1);
  assert.equal(s.snapshot().valid, false);
  s.edit({
    revision: 2,
    table: "encounters",
    row: "boss",
    column: "item",
    value: "shield",
  });
  assert.equal(s.snapshot().valid, true);
  assert.throws(() => s.snapshot().document.tables.items.push({}), TypeError);
});
test("tuning bindings derive limits from columns and apply profiles without replacing other master rows", () => {
  const a = {
    ...adapter,
    parameters: { power: { table: "items", row: "sword", column: "power" } },
  };
  assert.deepEqual(parameterSpecs(a, data), [
    { name: "power", min: 1, max: 100, step: 1, initial: 10 },
  ]);
  const changed = applyParameters(a, data, { power: 30 });
  assert.equal(changed.tables.items[0].power, 30);
  assert.equal(changed.tables.items[0].name, "Sword");
  assert.deepEqual(data.tables.items[0].power, 10);
  assert.throws(() => applyParameters(a, data, { power: 0 }), /invalid/i);
  assert.throws(() => applyParameters(a, data, { unknown: 4 }), /parameter/i);
});
