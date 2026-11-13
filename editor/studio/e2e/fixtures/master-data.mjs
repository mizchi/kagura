import "../../web/style.css";
import { installMasterDataEditor } from "../../master-data/editor.mjs";
import { openProject } from "../../projects/project.mjs";
import { masterDataAdapter as fathom } from "../../../../examples/games/dungeon_rpg/assets/master-data-adapter.mjs";
import fathomData from "../../../../examples/games/dungeon_rpg/assets/master-data.json";
const generic = {
  apiVersion: 1,
  schema: {
    id: "sample",
    version: 1,
    title: "Sample マスターデータ",
    tables: [
      {
        id: "items",
        label: "道具",
        primaryKey: "id",
        labelField: "name",
        columns: [
          { id: "id", label: "ID", type: "string", maxLength: 80 },
          {
            id: "name",
            label: "名前",
            type: "string",
            minLength: 1,
            maxLength: 40,
            default: "新しい道具",
          },
          {
            id: "power",
            label: "威力",
            type: "integer",
            min: 1,
            max: 100,
            step: 1,
            default: 5,
          },
          { id: "enabled", label: "使用可能", type: "boolean", default: true },
          {
            id: "role",
            label: "分類",
            type: "enum",
            options: ["weapon", "armor"],
            default: "weapon",
          },
          {
            id: "rarity",
            label: "希少度",
            type: "enum",
            options: ["normal", "rare"],
            nullable: true,
            default: null,
          },
          {
            id: "tradable",
            label: "取引可能",
            type: "boolean",
            nullable: true,
            default: null,
          },
        ],
      },
      {
        id: "encounters",
        label: "編成",
        primaryKey: "id",
        rowIds: ["boss"],
        columns: [
          { id: "id", label: "ID", type: "string", maxLength: 80 },
          { id: "item", label: "道具", type: "reference", table: "items" },
        ],
      },
    ],
  },
};
const genericData = {
  format: "kagura.master-data",
  version: 1,
  game: "sample",
  tables: {
    items: [
      {
        id: "sword",
        name: "剣",
        power: 10,
        enabled: true,
        role: "weapon",
        rarity: null,
        tradable: null,
      },
    ],
    encounters: [{ id: "boss", item: "sword" }],
  },
};
const isFathom = new URLSearchParams(location.search).get("game") === "fathom";
const adapter = isFathom ? fathom : generic,
  data = isFathom ? fathomData : genericData;
const manifest = {
  format: "kagura.project",
  version: 1,
  name: adapter.schema.title,
  scene: "scene.json",
  resources: { master: "data.json" },
  masterData: { adapter: "adapter.mjs", resource: "master" },
};
const files = new Map([
  ["project.kgrprj", new Blob([JSON.stringify(manifest)])],
  ["data.json", new Blob([JSON.stringify(data)])],
  [
    "adapter.mjs",
    new Blob(["export const masterDataAdapter=" + JSON.stringify(adapter)]),
  ],
]);
const store = {
  async read(key) {
    return { blob: files.get(key) };
  },
};
if (new URLSearchParams(location.search).get("writable") === "1")
  store.write = async (key, blob) => {
    files.set(key, blob);
  };
const project = await openProject(store, "project.kgrprj");
const editor = installMasterDataEditor({
  host: { project: () => project, subscribe: () => () => {} },
});
await editor.open();
globalThis.masterDataFixture = { editor, project };
