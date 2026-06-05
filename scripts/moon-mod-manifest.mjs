// Read a module manifest regardless of format.
//
// The MoonBit toolchain migrated workspace members from the legacy JSON
// `moon.mod.json` to the new text-based `moon.mod`. Tooling that used to
// `JSON.parse(moon.mod.json)` can call `readModuleManifest(root)` instead: it
// prefers `moon.mod`, falls back to `moon.mod.json`, and always returns the
// same normalized shape the JSON manifest used:
//
//   { name, version, description, repository, license, readme,
//     source, "--moonbit-unstable-prebuild", deps: { "<name>": "<version>" },
//     keywords, warnings, "preferred-target", ... }
//
// In `moon.mod`, dependencies live in the `import { "name@version", ... }`
// block and the `@version` is ignored for local workspace members (resolved
// via `moon.work`). We surface them as plain version-string deps, so there are
// no `{path, version}` entries to convert — local resolution is the workspace's
// job, not the manifest's.

import fs from "node:fs";
import path from "node:path";

// --- moon.mod (text format) parsing ------------------------------------------

function stripQuotes(token) {
  const t = token.trim().replace(/,+$/, "").trim();
  if (t.startsWith('"') && t.endsWith('"')) {
    return t.slice(1, -1);
  }
  return t;
}

function extractBlock(source, opener) {
  // opener is e.g. 'import {' or 'options(' — returns the inner text or null.
  const open = opener.endsWith("{") ? "{" : "(";
  const close = open === "{" ? "}" : ")";
  const head = source.indexOf(opener);
  if (head === -1) {
    return null;
  }
  let depth = 0;
  const start = source.indexOf(open, head);
  for (let i = start; i < source.length; i += 1) {
    const ch = source[i];
    if (ch === open) {
      depth += 1;
    } else if (ch === close) {
      depth -= 1;
      if (depth === 0) {
        return source.slice(start + 1, i);
      }
    }
  }
  return null;
}

function parseImports(source) {
  const inner = extractBlock(source, "import {");
  const deps = {};
  if (!inner) {
    return deps;
  }
  for (const match of inner.matchAll(/"([^"]+)"/g)) {
    const spec = match[1];
    const at = spec.lastIndexOf("@");
    if (at > 0) {
      deps[spec.slice(0, at)] = spec.slice(at + 1);
    } else {
      deps[spec] = "";
    }
  }
  return deps;
}

function parseOptions(source) {
  const inner = extractBlock(source, "options(");
  const options = {};
  if (!inner) {
    return options;
  }
  // Match `key: "value"` and `"quoted-key": "value"` (skip array values like exclude: [...]).
  for (const match of inner.matchAll(/(?:"([^"]+)"|([A-Za-z0-9_-]+))\s*:\s*"([^"]*)"/g)) {
    const key = match[1] ?? match[2];
    options[key] = match[3];
  }
  return options;
}

export function parseMoonMod(source) {
  const manifest = {};
  // Top-level scalar string fields: `key = "value"` (one per line).
  for (const match of source.matchAll(/^([A-Za-z0-9_-]+)\s*=\s*"([^"]*)"\s*$/gm)) {
    manifest[match[1]] = match[2];
  }
  // Top-level string arrays: `keywords = [ "a", "b" ]` (possibly multi-line).
  const keywordsBlock = source.match(/^keywords\s*=\s*\[([\s\S]*?)\]/m);
  if (keywordsBlock) {
    manifest.keywords = [...keywordsBlock[1].matchAll(/"([^"]+)"/g)].map((m) => m[1]);
  }

  const deps = parseImports(source);
  if (Object.keys(deps).length > 0) {
    manifest.deps = deps;
  }

  const options = parseOptions(source);
  if (options.source !== undefined) {
    manifest.source = options.source;
  }
  if (options["--moonbit-unstable-prebuild"] !== undefined) {
    manifest["--moonbit-unstable-prebuild"] = options["--moonbit-unstable-prebuild"];
  }

  // Normalize the renamed field so old consumers keep working.
  if (manifest.warnings !== undefined && manifest["warn-list"] === undefined) {
    manifest["warn-list"] = manifest.warnings;
  }
  if (manifest.preferred_target !== undefined && manifest["preferred-target"] === undefined) {
    manifest["preferred-target"] = manifest.preferred_target;
  }

  return manifest;
}

// --- public API --------------------------------------------------------------

export function manifestPathFor(root) {
  const moonMod = path.join(root, "moon.mod");
  if (fs.existsSync(moonMod)) {
    return moonMod;
  }
  return path.join(root, "moon.mod.json");
}

export function readModuleManifest(root) {
  const moonMod = path.join(root, "moon.mod");
  if (fs.existsSync(moonMod)) {
    return parseMoonMod(fs.readFileSync(moonMod, "utf8"));
  }
  const jsonPath = path.join(root, "moon.mod.json");
  return JSON.parse(fs.readFileSync(jsonPath, "utf8"));
}
