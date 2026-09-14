import {test, expect} from '@playwright/test';
import {spawn} from 'node:child_process';
import {createServer} from 'node:http';
import {readFileSync, writeFileSync, mkdtempSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, resolve, extname} from 'node:path';

const root = resolve(import.meta.dirname, '../../..');
const cli = join(root, 'cmd/kagura/main.mjs');

function launch(args, cwd = root) {
  const child = spawn(process.execPath, [cli, ...args], {cwd, stdio: ['ignore', 'pipe', 'pipe']});
  let log = '';
  child.stdout.on('data', chunk => { log += chunk; });
  child.stderr.on('data', chunk => { log += chunk; });
  const done = new Promise((resolve, reject) => {
    child.on('error', reject);
    child.on('close', (code, signal) => resolve({code, signal}));
  });
  return {child, done, log: () => log, async stop() {
    if (child.exitCode === null) child.kill('SIGTERM');
    await expect.poll(() => child.exitCode, {timeout: 15_000}).not.toBeNull();
    await done;
  }};
}

async function freePort() {
  const server = createServer();
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const port = server.address().port;
  await new Promise(resolve => server.close(resolve));
  return port;
}

async function ready(process, url) {
  await expect.poll(async () => {
    if (process.child.exitCode !== null) throw new Error(process.log());
    try { return (await fetch(url)).status; } catch { return 0; }
  }, {timeout: 210_000, intervals: [200, 500, 1000]}).toBe(200);
}

test('dev serves the current game, reports an occupied port, and stops watchers', async ({page}) => {
  const port = await freePort();
  const url = `http://127.0.0.1:${port}/`;
  const server = launch(['dev', '--port', String(port)], join(root, 'examples/demos-2d/ui_demo'));
  try {
    await ready(server, url);
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(url);
    await expect(page.locator('#app')).toBeVisible();
    await expect.poll(() => page.evaluate(() => typeof globalThis.__kaguraWebRuntime?.frameProfile?.renderCommandsMs === 'number'), {timeout: 30_000}).toBe(true);
    expect(errors).toEqual([]);
    const collision = launch(['dev', 'ui_demo', '--port', String(port)]);
    try {
      await expect.poll(() => collision.child.exitCode, {timeout: 30_000}).toBe(1);
      expect(collision.log()).toMatch(/already in use/);
    } finally { await collision.stop(); }
    await page.screenshot({path: test.info().outputPath('dev.png')});
  } finally { await server.stop(); }
  expect((await server.done).code).toBe(143);
  await expect.poll(async () => { try { await fetch(url); return false; } catch { return true; } }).toBe(true);
});

for (const name of ['ui_demo', 'hacknslash_3d']) test(`build ${name} runs from a static subdirectory`, async ({page}) => {
  const temporary = mkdtempSync(join(tmpdir(), 'kagura-e2e-'));
  const output = join(temporary, 'game');
  let server;
  try {
    const build = launch(['build', name, '--out-dir', output]);
    try {
      await expect.poll(() => build.child.exitCode, {timeout: 90_000}).toBe(0);
      expect(build.log()).toContain(`Built ${name}`);
    } finally { await build.stop(); }
    server = createServer((req, res) => {
      try {
        const path = join(temporary, req.url.split('?')[0].replace(/\/$/, '/index.html'));
        const types = {'.html': 'text/html', '.js': 'text/javascript', '.ttf': 'font/ttf'};
        res.setHeader('Content-Type', types[extname(path)] ?? 'application/octet-stream');
        res.end(readFileSync(path));
      } catch { res.writeHead(404).end(); }
    });
    await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(`http://127.0.0.1:${server.address().port}/game/`);
    await expect.poll(() => page.evaluate(() => typeof globalThis.__kaguraWebRuntime?.frameProfile?.renderCommandsMs === 'number'), {timeout: 30_000}).toBe(true);
    expect(errors).toEqual([]);
    await page.screenshot({path: test.info().outputPath('build.png')});
  } finally {
    if (server) await new Promise(resolve => server.close(resolve));
    rmSync(temporary, {recursive: true, force: true});
  }
});

test('dev fails instead of serving a project whose initial compile fails', async () => {
  const project = mkdtempSync(join(tmpdir(), 'kagura-broken-'));
  writeFileSync(join(project, 'moon.mod'), 'name = "test/broken"\n');
  writeFileSync(join(project, 'moon.pkg'), 'pkgtype(kind: "executable")\n');
  writeFileSync(join(project, 'main.mbt'), 'fn main { missing_function() }\n');
  const server = launch(['dev', project, '--port', String(await freePort())]);
  try {
    await expect.poll(() => server.child.exitCode, {timeout: 30_000}).not.toBeNull();
    expect(server.child.exitCode).toBeGreaterThan(0);
    expect(server.log()).toContain(`Initial MoonBit build failed (exit ${server.child.exitCode})`);
    expect(server.log()).not.toContain('Serving');
  } finally {
    await server.stop();
    rmSync(project, {recursive: true, force: true});
  }
});

test('studio starts the editor on the requested port and shuts down', async ({page}) => {
  const port = await freePort();
  const url = `http://127.0.0.1:${port}/`;
  const server = launch(['studio', '--port', String(port)], tmpdir());
  try {
    await ready(server, url);
    await page.goto(url);
    await expect.poll(() => page.evaluate(() => !!globalThis.kagura?.workspace), {timeout: 30_000}).toBe(true);
    await expect(page.locator('canvas').first()).toBeVisible();
    await page.screenshot({path: test.info().outputPath('studio.png')});
  } finally { await server.stop(); }
  expect((await server.done).code).toBe(143);
  await expect.poll(async () => { try { await fetch(url); return false; } catch { return true; } }).toBe(true);
});
