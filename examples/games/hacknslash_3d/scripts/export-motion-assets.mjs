import { spawnSync } from "node:child_process";
import { writeFile } from "node:fs/promises";
import { fileURLToPath, pathToFileURL } from "node:url";
import { resolveBuildArtifact } from "../../../../scripts/moon-build-artifact-utils.mjs";
import { validateMotionAsset } from "../../../../editor/studio/motions/contract.mjs";
const root = new URL("../", import.meta.url);
const result = spawnSync(
  "moon",
  ["build", "motion_api", "--target", "js", "--release"],
  { cwd: root, stdio: "inherit" },
);
if (result.status !== 0) process.exit(result.status ?? 1);
const artifact = resolveBuildArtifact(
  fileURLToPath(new URL("_build/js/release/build/motion_api.js", root)),
);
if (!artifact) throw Error("Missing motion API build");
const { export_asset } = await import(pathToFileURL(artifact));
const asset = validateMotionAsset(JSON.parse(export_asset()));
await writeFile(
  new URL("motions/enemies.kgrmotion", root),
  JSON.stringify(asset) + "\n",
);
console.log(
  `${asset.models.length} models / ${asset.clips.length} clips exported from game assets`,
);
