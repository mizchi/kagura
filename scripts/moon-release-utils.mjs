import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { manifestPathFor, readModuleManifest } from "./moon-mod-manifest.mjs";

export const DEFAULT_RELEASE_MODULE_DIRS = Object.freeze([
  ".",
  "modules/kagura_core",
  "modules/platform",
  "modules/ui",
  "modules/kagura_engine",
  "modules/native_runtime",
  "modules/physics",
  "modules/game",
  "modules/js_runtime",
]);

export const DEFAULT_RELEASE_DEP_POLICY = Object.freeze({
  "mizchi/kagura": ["mizchi/kagura_core", "mizchi/kagura_platform", "mizchi/kagura_engine"],
  "mizchi/kagura_core": [],
  "mizchi/kagura_platform": ["mizchi/kagura_core"],
  "mizchi/kagura_ui": ["mizchi/kagura_core"],
  "mizchi/kagura_engine": ["mizchi/kagura_core", "mizchi/kagura_platform"],
  "mizchi/kagura_native_runtime": ["mizchi/kagura_engine"],
  "mizchi/physics": ["mizchi/kagura_core"],
  "mizchi/kagura_game": [
    "mizchi/kagura_core",
    "mizchi/kagura_platform",
    "mizchi/kagura_engine",
    "mizchi/physics",
  ],
  "mizchi/kagura_js_runtime": [],
});

const REQUIRED_MANIFEST_FIELDS = Object.freeze([
  "name",
  "version",
  "description",
  "repository",
  "license",
  "source",
]);

const PREBUILD_KEY = "--moonbit-unstable-prebuild";
const NATIVE_PREBUILD_SUPPORT_FILES = Object.freeze([
  "moon-prebuild-native-link-flags.cjs",
  "moon-native-cc.sh",
  "moon-native-cc.cmd",
  "moon-native-cc-win.cjs",
  "setup-wgpu-native.sh",
  "setup-windows-native.sh",
]);

export function defaultRepoRoot() {
  return path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
}

function cloneJson(value) {
  return JSON.parse(JSON.stringify(value));
}

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function toPosix(value) {
  return value.replace(/\\/g, "/");
}

export function normalizeModuleDir(value) {
  const normalized = path.posix.normalize(toPosix(value));
  if (normalized === "." || normalized === "") {
    return ".";
  }
  return normalized.replace(/^\.\//, "").replace(/\/$/, "");
}

function normalizeRepoRelative(repoRoot, filePath) {
  const rel = path.relative(repoRoot, filePath);
  if (rel === "") {
    return ".";
  }
  return normalizeModuleDir(toPosix(rel));
}

function moduleRoot(repoRoot, moduleDir) {
  return moduleDir === "." ? repoRoot : path.join(repoRoot, moduleDir);
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function copyRecursive(sourcePath, destPath) {
  const stat = fs.statSync(sourcePath);
  if (stat.isDirectory()) {
    fs.mkdirSync(destPath, { recursive: true });
    for (const entry of fs.readdirSync(sourcePath)) {
      copyRecursive(path.join(sourcePath, entry), path.join(destPath, entry));
    }
    return;
  }
  if (stat.isFile()) {
    fs.mkdirSync(path.dirname(destPath), { recursive: true });
    fs.copyFileSync(sourcePath, destPath);
  }
}

function copyIfExists(sourcePath, destPath) {
  if (!fs.existsSync(sourcePath)) {
    return false;
  }
  copyRecursive(sourcePath, destPath);
  return true;
}

function collectReadmeFiles(mod) {
  const readmes = new Set();
  if (typeof mod.manifest.readme === "string" && mod.manifest.readme !== "") {
    readmes.add(mod.manifest.readme);
  }
  for (const fileName of ["README.md", "README.mbt.md"]) {
    if (fs.existsSync(path.join(mod.root, fileName))) {
      readmes.add(fileName);
    }
  }
  return [...readmes];
}

function stageModuleFiles(mod, destDir) {
  const stagedFiles = [];
  fs.rmSync(destDir, { recursive: true, force: true });
  fs.mkdirSync(destDir, { recursive: true });

  const sourceName = mod.manifest.source;
  const sourcePath = path.join(mod.root, sourceName);
  const destSourcePath = path.join(destDir, sourceName);
  copyRecursive(sourcePath, destSourcePath);
  stagedFiles.push(sourceName);

  for (const readme of collectReadmeFiles(mod)) {
    if (copyIfExists(path.join(mod.root, readme), path.join(destDir, readme))) {
      stagedFiles.push(readme);
    }
  }
  return stagedFiles;
}

function resolveWorkspaceDepDir(repoRoot, moduleDir, depPath) {
  const absolutePath = path.resolve(moduleRoot(repoRoot, moduleDir), depPath);
  return normalizeRepoRelative(repoRoot, absolutePath);
}

function depPolicySet(depPolicy, moduleName) {
  if (depPolicy instanceof Map) {
    return new Set(depPolicy.get(moduleName) ?? []);
  }
  return new Set(depPolicy?.[moduleName] ?? []);
}

function isPathDep(spec) {
  return isObject(spec) && typeof spec.path === "string";
}

function hasPathDeps(manifest) {
  if (!isObject(manifest.deps)) {
    return false;
  }
  return Object.values(manifest.deps).some(isPathDep);
}

function isInsideDir(parent, child) {
  const relative = path.relative(parent, child);
  return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

function rewriteExternalPrebuild(mod, manifest) {
  const prebuildPath = manifest[PREBUILD_KEY];
  if (typeof prebuildPath !== "string" || prebuildPath === "") {
    return null;
  }
  const sourcePath = path.resolve(mod.root, prebuildPath);
  const stagedPath = isInsideDir(mod.root, sourcePath)
    ? normalizeModuleDir(toPosix(path.relative(mod.root, sourcePath)))
    : `scripts/${path.basename(prebuildPath)}`;
  manifest[PREBUILD_KEY] = stagedPath;
  const supportFiles = [];
  const addSupportFile = (filePath) => {
    if (!supportFiles.includes(filePath)) {
      supportFiles.push(filePath);
    }
  };
  addSupportFile(sourcePath);
  if (path.basename(prebuildPath) === "moon-prebuild-native-link-flags.cjs") {
    const sourceDir = path.dirname(sourcePath);
    for (const fileName of NATIVE_PREBUILD_SUPPORT_FILES) {
      const candidate = path.join(sourceDir, fileName);
      addSupportFile(candidate);
    }
  }
  return {
    from: prebuildPath,
    to: stagedPath,
    supportFiles,
  };
}

export function safePackageDirName(name) {
  return name.replace(/^@/, "").replace(/[^A-Za-z0-9._-]+/g, "__");
}

export function readMoonWorkMembers(repoRoot = defaultRepoRoot()) {
  const workPath = path.join(repoRoot, "moon.work");
  if (!fs.existsSync(workPath)) {
    return [];
  }
  const source = fs.readFileSync(workPath, "utf8");
  const match = source.match(/members\s*=\s*\[([\s\S]*?)\]/m);
  if (!match) {
    return [];
  }
  const members = [];
  const quotedString = /"([^"]+)"/g;
  let item = quotedString.exec(match[1]);
  while (item) {
    members.push(normalizeModuleDir(item[1]));
    item = quotedString.exec(match[1]);
  }
  return members;
}

export function loadReleaseModules({
  repoRoot = defaultRepoRoot(),
  moduleDirs = DEFAULT_RELEASE_MODULE_DIRS,
} = {}) {
  const modules = moduleDirs.map((dir) => {
    const normalizedDir = normalizeModuleDir(dir);
    const root = moduleRoot(repoRoot, normalizedDir);
    const manifestPath = manifestPathFor(root);
    const manifest = readModuleManifest(root);
    return {
      dir: normalizedDir,
      root,
      manifestPath,
      manifest,
      name: typeof manifest.name === "string" ? manifest.name : "",
      version: typeof manifest.version === "string" ? manifest.version : "",
      sourceDir: typeof manifest.source === "string"
        ? path.join(root, manifest.source)
        : "",
      repoRoot,
    };
  });

  const byName = new Map();
  const byDir = new Map();
  for (const mod of modules) {
    byDir.set(mod.dir, mod);
    if (mod.name && !byName.has(mod.name)) {
      byName.set(mod.name, mod);
    }
  }
  return { modules, byName, byDir };
}

export function createPublishManifest(mod, byDir) {
  const manifest = cloneJson(mod.manifest);
  const conversions = [];
  const prebuild = rewriteExternalPrebuild(mod, manifest);
  if (!isObject(manifest.deps)) {
    return {
      module: { name: mod.name, dir: mod.dir },
      manifest,
      conversions,
      prebuild,
    };
  }

  for (const [name, spec] of Object.entries(manifest.deps)) {
    if (!isPathDep(spec)) {
      continue;
    }
    const targetDir = resolveWorkspaceDepDir(mod.repoRoot, mod.dir, spec.path);
    const target = byDir.get(targetDir);
    if (!target) {
      throw new Error(
        `${mod.name || mod.dir}: dependency ${name} points to ${targetDir}, which is not a release module`,
      );
    }
    manifest.deps[name] = target.version;
    conversions.push({
      name,
      from: spec.path,
      targetDir,
      version: target.version,
    });
  }
  return { module: { name: mod.name, dir: mod.dir }, manifest, conversions, prebuild };
}

export function validateReleaseWorkspace({
  repoRoot = defaultRepoRoot(),
  moduleDirs = DEFAULT_RELEASE_MODULE_DIRS,
  depPolicy = DEFAULT_RELEASE_DEP_POLICY,
} = {}) {
  const errors = [];
  const warnings = [];
  let loaded;

  try {
    loaded = loadReleaseModules({ repoRoot, moduleDirs });
  } catch (error) {
    return {
      errors: [error.message],
      warnings,
      modules: [],
      byName: new Map(),
      byDir: new Map(),
      preparedManifests: [],
    };
  }

  const { modules, byName, byDir } = loaded;
  const moonWorkMembers = new Set(readMoonWorkMembers(repoRoot));
  for (const dir of moduleDirs.map(normalizeModuleDir)) {
    if (!moonWorkMembers.has(dir)) {
      errors.push(`moon.work is missing release member ${dir}`);
    }
  }

  const seenNames = new Map();
  for (const mod of modules) {
    if (seenNames.has(mod.name)) {
      errors.push(
        `duplicate release module name ${mod.name} in ${seenNames.get(mod.name)} and ${mod.dir}`,
      );
    }
    seenNames.set(mod.name, mod.dir);

    for (const field of REQUIRED_MANIFEST_FIELDS) {
      if (typeof mod.manifest[field] !== "string" || mod.manifest[field] === "") {
        errors.push(`${mod.dir}/moon.mod.json is missing string field ${field}`);
      }
    }
    if (mod.sourceDir && !fs.existsSync(mod.sourceDir)) {
      errors.push(`${mod.dir}/moon.mod.json source directory does not exist: ${mod.manifest.source}`);
    }
    if (typeof mod.manifest.readme === "string") {
      const readmePath = path.join(mod.root, mod.manifest.readme);
      if (!fs.existsSync(readmePath)) {
        errors.push(`${mod.dir}/moon.mod.json readme does not exist: ${mod.manifest.readme}`);
      }
    }

    const prebuildPath = mod.manifest["--moonbit-unstable-prebuild"];
    if (prebuildPath !== undefined) {
      if (typeof prebuildPath !== "string" || prebuildPath === "") {
        errors.push(`${mod.dir}/moon.mod.json has invalid --moonbit-unstable-prebuild`);
      } else if (!fs.existsSync(path.resolve(mod.root, prebuildPath))) {
        errors.push(`${mod.dir}/moon.mod.json prebuild script does not exist: ${prebuildPath}`);
      }
    }

    const deps = mod.manifest.deps ?? {};
    if (!isObject(deps)) {
      errors.push(`${mod.dir}/moon.mod.json deps must be an object when present`);
      continue;
    }

    const allowedDeps = depPolicySet(depPolicy, mod.name);
    for (const [depName, spec] of Object.entries(deps)) {
      let target = null;
      if (isPathDep(spec)) {
        const targetDir = resolveWorkspaceDepDir(repoRoot, mod.dir, spec.path);
        target = byDir.get(targetDir) ?? null;
        if (!target) {
          errors.push(
            `${mod.name}: dependency ${depName} points to ${targetDir}, which is not a release module`,
          );
          continue;
        }
        if (depName !== target.name) {
          errors.push(
            `${mod.name}: dependency key ${depName} does not match release module ${target.name}`,
          );
        }
      } else if (byName.has(depName)) {
        target = byName.get(depName);
        if (typeof spec !== "string") {
          errors.push(`${mod.name}: release dependency ${depName} must be a version string or path dep`);
          continue;
        }
        if (spec !== target.version) {
          errors.push(
            `${mod.name}: release dependency ${depName} uses ${spec}, expected ${target.version}`,
          );
        }
      } else if (isObject(spec)) {
        errors.push(`${mod.name}: dependency ${depName} uses an unsupported object spec`);
      }

      if (target && !allowedDeps.has(target.name)) {
        errors.push(`${mod.name}: dependency on ${target.name} is not allowed by release policy`);
      }
    }
  }

  const preparedManifests = [];
  if (errors.length === 0) {
    for (const mod of modules) {
      const prepared = createPublishManifest(mod, byDir);
      if (hasPathDeps(prepared.manifest)) {
        errors.push(`${mod.name}: publish manifest still contains local path dependencies`);
      }
      const prebuildPath = prepared.manifest[PREBUILD_KEY];
      if (typeof prebuildPath === "string" && prebuildPath.startsWith("..")) {
        errors.push(`${mod.name}: publish manifest prebuild path is outside the staged module`);
      }
      preparedManifests.push(prepared);
    }
  }

  return {
    errors,
    warnings,
    modules,
    byName,
    byDir,
    preparedManifests,
  };
}

export function writePreparedManifests({
  repoRoot = defaultRepoRoot(),
  outDir,
  moduleDirs = DEFAULT_RELEASE_MODULE_DIRS,
  depPolicy = DEFAULT_RELEASE_DEP_POLICY,
  moduleFilter = [],
} = {}) {
  if (!outDir) {
    throw new Error("outDir is required");
  }

  const validation = validateReleaseWorkspace({ repoRoot, moduleDirs, depPolicy });
  if (validation.errors.length > 0) {
    return { validation, outDir, summary: { modules: [] }, written: [] };
  }

  const filter = new Set(moduleFilter);
  const selected = validation.modules.filter((mod) => {
    return filter.size === 0 || filter.has(mod.name) || filter.has(mod.dir);
  });

  const summary = { modules: [] };
  fs.mkdirSync(outDir, { recursive: true });
  for (const mod of selected) {
    const prepared = createPublishManifest(mod, validation.byDir);
    const outputDir = safePackageDirName(mod.name);
    const destDir = path.join(outDir, outputDir);
    const stagedFiles = stageModuleFiles(mod, destDir);
    writeJson(path.join(destDir, "moon.mod.json"), prepared.manifest);
    if (prepared.prebuild) {
      const prebuildDir = path.posix.dirname(prepared.prebuild.to);
      for (const supportFile of prepared.prebuild.supportFiles) {
        if (!fs.existsSync(supportFile)) {
          continue;
        }
        const stagedFile = path.posix.join(prebuildDir, path.basename(supportFile));
        const destFile = path.join(destDir, stagedFile);
        fs.mkdirSync(path.dirname(destFile), { recursive: true });
        fs.copyFileSync(supportFile, destFile);
        stagedFiles.push(stagedFile);
      }
    }
    writeJson(path.join(destDir, "release-module.json"), {
      name: mod.name,
      sourceDir: mod.dir,
      conversions: prepared.conversions,
      prebuild: prepared.prebuild,
      stagedFiles,
    });
    summary.modules.push({
      name: mod.name,
      sourceDir: mod.dir,
      outputDir,
      conversions: prepared.conversions,
      stagedFiles,
    });
  }
  writeJson(path.join(outDir, "release-manifests.json"), summary);
  return { validation, outDir, summary, written: summary.modules };
}

export function formatValidationReport(result) {
  const lines = [];
  if (result.errors.length > 0) {
    lines.push("Moon release validation failed:");
    for (const error of result.errors) {
      lines.push(`- ${error}`);
    }
  } else {
    lines.push("Moon release validation passed.");
    for (const prepared of result.preparedManifests) {
      const suffix = prepared.conversions.length === 0
        ? "no workspace deps"
        : prepared.conversions
            .map((entry) => `${entry.name}@${entry.version}`)
            .join(", ");
      lines.push(`- ${prepared.module.name} (${prepared.module.dir}): ${suffix}`);
    }
  }
  if (result.warnings.length > 0) {
    lines.push("Warnings:");
    for (const warning of result.warnings) {
      lines.push(`- ${warning}`);
    }
  }
  return `${lines.join("\n")}\n`;
}

export function formatPreparedManifestReport(result, { dryRun = false } = {}) {
  const lines = [];
  const validation = dryRun ? result : result.validation;
  if (validation.errors.length > 0) {
    return formatValidationReport(validation);
  }
  lines.push(dryRun ? "Moon release staging is ready." : `Wrote Moon release staging to ${result.outDir}.`);
  const modules = dryRun
    ? validation.preparedManifests.map((prepared) => ({
        name: prepared.module.name,
        sourceDir: prepared.module.dir,
        conversions: prepared.conversions,
      }))
    : result.summary.modules;
  for (const mod of modules) {
    const suffix = mod.conversions.length === 0
      ? "no workspace deps"
      : mod.conversions.map((entry) => `${entry.name}@${entry.version}`).join(", ");
    lines.push(`- ${mod.name} (${mod.sourceDir}): ${suffix}`);
  }
  return `${lines.join("\n")}\n`;
}
