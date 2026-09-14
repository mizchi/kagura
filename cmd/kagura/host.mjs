// Filesystem/process boundary shared by the Node entry and installed executable.
import {constants as fsConstants, copyFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, renameSync, rmSync, rmdirSync, writeFileSync} from 'node:fs';
import {basename, dirname, isAbsolute, join, resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {runProcess} from './process.mjs';

export function createWebProject(destination, files, runtime) {
  const output = resolve(destination);
  const entries = Object.entries({...files, ...runtime});
  for (const [name, content] of entries) {
    if (typeof content !== 'string' || isAbsolute(name) || name.includes('\\') ||
        name.split('/').some(part => !part || part === '..' || part === '.')) {
      throw new Error(`Invalid template path: ${name}`);
    }
  }
  if (existsSync(output) && readdirSync(output).length) throw new Error(`Directory is not empty: ${output}`);
  mkdirSync(dirname(output), {recursive: true});
  const staging = mkdtempSync(join(dirname(output), '.kagura-new-'));
  try {
    for (const [name, content] of entries) {
      const file = join(staging, name);
      mkdirSync(dirname(file), {recursive: true});
      writeFileSync(file, content, {flag: 'wx'});
    }
    if (existsSync(output)) {
      // Keep the directory inode: replacing it breaks a caller whose cwd is here.
      if (readdirSync(output).length) throw new Error(`Directory is not empty: ${output}`);
      const written = [], createdDirectories = [];
      function prepareDirectory(directory) {
        if (existsSync(directory)) return;
        prepareDirectory(dirname(directory));
        mkdirSync(directory);
        createdDirectories.push(directory);
      }
      try {
        for (const [name] of entries) {
          const file = join(output, name);
          prepareDirectory(dirname(file));
          copyFileSync(join(staging, name), file, fsConstants.COPYFILE_EXCL);
          written.push(file);
        }
      } catch (error) {
        for (const file of written.reverse()) rmSync(file, {force: true});
        for (const directory of createdDirectories.reverse()) {
          try { rmdirSync(directory); } catch { /* Preserve concurrently added files. */ }
        }
        throw error;
      }
    } else {
      renameSync(staging, output);
    }
  } finally { rmSync(staging, {recursive: true, force: true}); }
  return output;
}

function scaffoldProject(selector) {
  let directory = resolve(selector ?? process.cwd());
  do {
    const marker = join(directory, 'kagura.json');
    if (existsSync(marker)) {
      const config = JSON.parse(readFileSync(marker, 'utf8'));
      if (config.schemaVersion !== 1 || config.template !== 'web') throw new Error(`Unsupported kagura.json: ${marker}`);
      return directory;
    }
    if (selector) return null;
    const parent = dirname(directory);
    if (parent === directory) return null;
    directory = parent;
  } while (true);
}

export async function executeRequest(request, {files = {}, runtime = {}, checkoutRoot} = {}) {
  if (Number(process.versions.node.split('.')[0]) < 24) throw new Error('Node.js 24 or later is required.');
  if (!request.ok) {
    console.error(`kagura: ${request.error}\nRun kagura --help for usage.`);
    return 2;
  }
  if (request.command === 'new') {
    const output = createWebProject(request.directory, files, runtime);
    console.log(`Created ${output}\n\nNext: cd ${JSON.stringify(output)}\n      pnpm install\n      kagura dev`);
    return 0;
  }
  const isServer = request.command === 'dev' || request.command === 'studio';
  const port = request.port ?? (process.env.PORT == null ? (request.command === 'studio' ? 5190 : 8080) : Number(process.env.PORT));
  if (isServer && (!Number.isInteger(port) || port < 1 || port > 65535)) throw new Error('PORT must be an integer from 1 to 65535');
  const project = request.command === 'studio' ? null : scaffoldProject(request.project);
  if (project) {
    if (!existsSync(join(project, 'node_modules/vite/bin/vite.js'))) throw new Error(`Run pnpm install in ${project} first.`);
    const args = request.command === 'dev'
      ? ['run', 'dev', '--port', String(port), '--host', request.host]
      : ['run', 'build', ...(request.outDir == null ? [] : ['--outDir', resolve(request.outDir)])];
    return runProcess(process.platform === 'win32' ? 'pnpm.cmd' : 'pnpm', args, {cwd: project});
  }
  const root = process.env.KAGURA_ROOT ?? checkoutRoot;
  if (!root || !existsSync(join(root, 'scripts/dev-server.mjs'))) {
    throw new Error('No Kagura project found. Use kagura new --web. For checkout examples or Studio, set KAGURA_ROOT to the Kagura checkout.');
  }
  if (request.command === 'studio') {
    return runProcess(process.execPath, [join(root, 'editor/studio/scripts/dev.mjs')], {
      cwd: join(root, 'editor/studio'), env: {...process.env, PORT: String(port), HOST: request.host},
    });
  }
  const {resolveWebProject} = await import(pathToFileURL(join(root, 'scripts/web-project.mjs')));
  const example = resolveWebProject(request.project);
  if (request.command === 'dev') {
    return runProcess(process.execPath, [join(root, 'scripts/dev-server.mjs'), example.directory], {
      cwd: root, env: {...process.env, PORT: String(port), HOST: request.host},
    });
  }
  const {buildGame} = await import(pathToFileURL(join(root, 'scripts/build-game.mjs')));
  const output = buildGame({project: example, ...(request.outDir == null ? {} : {outDir: resolve(request.outDir)})});
  console.log(`Built ${example.name}: ${output}`);
  return 0;
}
