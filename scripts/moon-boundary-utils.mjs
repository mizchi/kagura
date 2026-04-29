import fs from "node:fs";
import path from "node:path";

import {
  DEFAULT_RELEASE_MODULE_DIRS,
  defaultRepoRoot,
  loadReleaseModules,
} from "./moon-release-utils.mjs";

export const DEFAULT_IMPORT_BOUNDARY_POLICY = Object.freeze({
  "mizchi/kagura": ["mizchi/kagura_core", "mizchi/kagura_engine"],
  "mizchi/kagura_core": [],
  "mizchi/kagura_engine": ["mizchi/kagura_core"],
  "mizchi/kagura_physics": ["mizchi/kagura_core"],
  "mizchi/kagura_game": [
    "mizchi/kagura_core",
    "mizchi/kagura_engine",
    "mizchi/kagura_physics",
  ],
  "mizchi/kagura_js_runtime": [],
});

function toPosix(value) {
  return value.replace(/\\/g, "/");
}

function repoRelative(repoRoot, filePath) {
  return toPosix(path.relative(repoRoot, filePath));
}

function findMoonPkgFiles(rootDir) {
  const results = [];
  if (!fs.existsSync(rootDir)) {
    return results;
  }
  const visit = (dir) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const entryPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        visit(entryPath);
      } else if (entry.isFile() && entry.name === "moon.pkg") {
        results.push(entryPath);
      }
    }
  };
  visit(rootDir);
  return results.sort();
}

export function parseMoonPkgImports(source) {
  const imports = [];
  const lines = source.split(/\r?\n/);
  let inImportBlock = false;
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    if (/^\s*import\s*\{/.test(line)) {
      inImportBlock = true;
    }
    if (!inImportBlock) {
      continue;
    }
    const quoted = /"([^"]+)"/g;
    let match = quoted.exec(line);
    while (match) {
      imports.push({ path: match[1], line: i + 1 });
      match = quoted.exec(line);
    }
    if (line.includes("}")) {
      inImportBlock = false;
    }
  }
  return imports;
}

function matchesModuleImport(importPath, moduleName) {
  return importPath === moduleName || importPath.startsWith(`${moduleName}/`);
}

function findReleaseTarget(importPath, releaseModules) {
  let best = null;
  for (const mod of releaseModules) {
    if (!matchesModuleImport(importPath, mod.name)) {
      continue;
    }
    if (!best || mod.name.length > best.name.length) {
      best = mod;
    }
  }
  return best;
}

export function validateModuleImportBoundaries({
  repoRoot = defaultRepoRoot(),
  moduleDirs = DEFAULT_RELEASE_MODULE_DIRS,
  policy = DEFAULT_IMPORT_BOUNDARY_POLICY,
} = {}) {
  const release = loadReleaseModules({ repoRoot, moduleDirs });
  const violations = [];
  const errors = [];

  for (const owner of release.modules) {
    const allowed = new Set([owner.name, ...(policy[owner.name] ?? [])]);
    if (!(owner.name in policy)) {
      errors.push(`${owner.name}: import boundary policy is missing`);
      continue;
    }

    for (const moonPkgPath of findMoonPkgFiles(owner.sourceDir)) {
      const source = fs.readFileSync(moonPkgPath, "utf8");
      for (const entry of parseMoonPkgImports(source)) {
        const target = findReleaseTarget(entry.path, release.modules);
        if (!target || allowed.has(target.name)) {
          continue;
        }
        const violation = {
          owner: owner.name,
          target: target.name,
          importPath: entry.path,
          file: repoRelative(repoRoot, moonPkgPath),
          line: entry.line,
        };
        violations.push(violation);
        errors.push(
          `${violation.file}:${violation.line}: ${violation.owner} must not import ${violation.importPath} (${violation.target})`,
        );
      }
    }
  }

  return { errors, violations, modules: release.modules };
}

export function formatBoundaryReport(result) {
  if (result.errors.length > 0) {
    return `Moon module boundary check failed:\n${result.errors.map((error) => `- ${error}`).join("\n")}\n`;
  }
  return `Moon module boundary check passed.\n`;
}
