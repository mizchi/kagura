// Self-contained project adapter: no Studio DOM or game state is required.
const ids = ["rat", "skeleton", "slime", "lamp", "guardian", "spirit"];
const number = (id, label, min, max, step = 1) => ({
  id,
  label,
  type: step === 1 ? "integer" : "number",
  min,
  max,
  step,
});
const identity = { id: "id", label: "ID", type: "string", maxLength: 80 };
export const masterDataAdapter = {
  apiVersion: 1,
  parameters: {
    enemyHpScale: {
      table: "rules",
      row: "expedition",
      column: "enemy_hp_scale",
    },
    enemyDamageScale: {
      table: "rules",
      row: "expedition",
      column: "enemy_damage_scale",
    },
    encounterSteps: {
      table: "rules",
      row: "expedition",
      column: "encounter_steps",
    },
  },
  schema: {
    id: "dungeon_rpg",
    version: 1,
    title: "FATHOM マスターデータ",
    tables: [
      {
        id: "enemies",
        label: "敵",
        primaryKey: "id",
        labelField: "name",
        rowIds: ids,
        description:
          "名前・能力・行動を定義します。次のPlayで生成される敵に反映します。",
        lockedValues: Object.fromEntries(ids.map((id, kind) => [id, { kind }])),
        columns: [
          identity,
          { ...number("kind", "外見ID", 0, 5), readOnly: true },
          {
            id: "name",
            label: "名前",
            type: "string",
            minLength: 1,
            maxLength: 40,
          },
          number("hp", "HP", 1, 500),
          number("attack", "攻撃", 1, 100),
          number("armor", "防御", 0, 50),
          number("speed", "素早さ", 1, 30),
          { id: "sweeps", label: "奇数ラウンドに薙ぎ払い", type: "boolean" },
        ],
      },
      {
        id: "encounters",
        label: "遭遇編成",
        primaryKey: "id",
        rowIds: ["b1_a", "b1_b", "b2", "guardian"],
        description: "場面ごとの出現する敵を選びます。3体目は省略できます。",
        columns: [
          identity,
          {
            id: "context",
            label: "場面",
            type: "enum",
            options: ["b1_a", "b1_b", "b2", "guardian"],
            unique: true,
          },
          { id: "enemy1", label: "敵1", type: "reference", table: "enemies" },
          { id: "enemy2", label: "敵2", type: "reference", table: "enemies" },
          {
            id: "enemy3",
            label: "敵3",
            type: "reference",
            table: "enemies",
            nullable: true,
          },
        ],
      },
      {
        id: "rules",
        label: "遠征ルール",
        primaryKey: "id",
        rowIds: ["expedition"],
        description:
          "能力倍率・遭遇間隔・薙ぎ払いを調整します。遠征中の値は固定されます。",
        columns: [
          identity,
          number("enemy_hp_scale", "敵HP倍率", 0.5, 3, 0.05),
          number("enemy_damage_scale", "敵攻撃倍率", 0.5, 3, 0.05),
          number("encounter_steps", "B1遭遇間隔（歩）", 4, 16),
          number("sweep_damage", "薙ぎ払い基礎威力", 1, 30),
        ],
      },
    ],
  },
};
