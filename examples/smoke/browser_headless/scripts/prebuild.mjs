// Combined prebuild: kagura native link flags + V8 bridge
import { execSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "..");

// Run kagura prebuild and capture output
const kaguraOut = execSync(
  `node ${path.resolve(root, "../../scripts/moon-prebuild-native-link-flags.cjs")}`,
  { cwd: root, encoding: "utf-8" }
).trim();
const kaguraVars = JSON.parse(kaguraOut).vars || {};

// Run V8 prebuild and capture output
const v8Out = execSync(
  `node ${path.resolve(__dirname, "mizchi-v8-consumer-prebuild.mjs")}`,
  { cwd: root, encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }
).trim();
// V8 prebuild may have cargo output before JSON; extract last line
const v8Lines = v8Out.split("\n");
const v8Json = v8Lines[v8Lines.length - 1];
const v8Vars = JSON.parse(v8Json).vars || {};

// Merge
const merged = { vars: { ...kaguraVars, ...v8Vars } };
process.stdout.write(JSON.stringify(merged));
