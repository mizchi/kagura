import { readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { validateDocument } from "../../../../game/master-data/contract.mjs";
import { masterDataAdapter } from "../assets/master-data-adapter.mjs";
const root = new URL("../", import.meta.url);
const data = JSON.parse(
  await readFile(new URL("assets/master-data.json", root), "utf8"),
);
const issues = validateDocument(masterDataAdapter, data);
if (issues.length) throw Error(JSON.stringify(issues));
const generated =
  "// Generated from assets/master-data.json; run just dungeon-rpg-master-build.\n///|\nlet default_master_source : String =\n" +
  JSON.stringify(data, null, 2)
    .split("\n")
    .map((line) => "  #| " + line)
    .join("\n") +
  "\n";
const target = new URL("sim/master_data_generated.mbt", root);
if (process.argv.includes("--check")) {
  if ((await readFile(target, "utf8")) !== generated)
    throw Error("Generated master data is stale: " + fileURLToPath(target));
} else await writeFile(target, generated);
