import {test, expect} from '@playwright/test';
import {spawn, spawnSync} from 'node:child_process';
import {mkdtempSync, mkdirSync, readFileSync, writeFileSync, existsSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, resolve, extname} from 'node:path';
import {createServer} from 'node:http';
import {readMoonWorkMembers} from '../../../scripts/moon-release-utils.mjs';

const root = resolve(import.meta.dirname, '../../..');

test('moon-installed CLI creates, develops, reloads and builds a standalone Web project', async ({page}) => {
  const temporary = mkdtempSync(join(tmpdir(), 'kagura-installed-'));
  const bin = join(temporary, 'bin');
  const project = join(temporary, 'my-game');
  const executable = join(bin, process.platform === 'win32' ? 'kagura.exe' : 'kagura');
  const env = {...process.env, KAGURA_ROOT: join(temporary, 'no-checkout')};
  let dev, devDone, staticServer;
  const run = (command, args, cwd) => {
    const result = spawnSync(command, args, {cwd, env, encoding: 'utf8'});
    expect(result.status, result.stdout + result.stderr).toBe(0);
    return result;
  };
  try {
    run('moon', ['install', './cmd/kagura', '--bin', bin], root);
    expect(run(executable, ['--help'], temporary).stdout).toContain('kagura new');
    mkdirSync(project);
    run(executable, ['new', '--web'], project);
    expect(existsSync(join(project, 'moon.work'))).toBe(false);
    expect(readFileSync(join(project, 'moon.mod'), 'utf8')).not.toContain(root);
    expect(spawnSync(executable, ['new', '--web'], {cwd: project, env}).status).not.toBe(0);

    // Release-only dependencies are not published yet. Test against the current
    // modules without putting this workspace or any path dependency in the template.
    const members = readMoonWorkMembers(root).filter(dir => dir !== '.' && !/^(cmd|benchmarks|experiments)/.test(dir));
    writeFileSync(join(project, 'moon.work'), 'members = ' + JSON.stringify(['.', ...members.map(dir => resolve(root, dir))], null, 2) + '\n');
    run('pnpm', ['install'], project);
    run('moon', ['check', '--target', 'js', '--deny-warn'], project);

    const reserve = createServer();
    await new Promise(resolve => reserve.listen(0, '127.0.0.1', resolve));
    const port = reserve.address().port;
    await new Promise(resolve => reserve.close(resolve));
    let log = '';
    dev = spawn(executable, ['dev', '--port', String(port)], {cwd: project, env, stdio: ['ignore', 'pipe', 'pipe']});
    dev.stdout.on('data', chunk => { log += chunk; });
    dev.stderr.on('data', chunk => { log += chunk; });
    devDone = new Promise(resolve => dev.on('close', code => resolve(code)));
    const url = `http://127.0.0.1:${port}/`;
    await expect.poll(async () => {
      if (dev.exitCode != null) throw new Error(log);
      try { return (await fetch(url)).status; } catch { return 0; }
    }, {timeout: 90_000}).toBe(200);
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(url);
    await expect.poll(() => page.evaluate(() => typeof globalThis.__kaguraWebRuntime?.frameProfile?.renderCommandsMs), {timeout: 30_000}).toBe('number');
    expect(errors).toEqual([]);
    const before = await page.locator('#app').screenshot();
    await page.keyboard.down('ArrowRight');
    await expect.poll(async () => (await page.locator('#app').screenshot()).equals(before)).toBe(false);
    await page.keyboard.up('ArrowRight');
    const source = join(project, 'main.mbt');
    const original = readFileSync(source, 'utf8');
    writeFileSync(source, original + '\nfn broken { unknown_function() }\n');
    await expect(page.locator('vite-error-overlay')).toBeVisible({timeout: 30_000});
    const reloaded = page.waitForEvent('load', {timeout: 30_000});
    writeFileSync(source, original.replace('0x64E4C0', '0xE4A264'));
    await reloaded.catch(error => { throw new Error(`${error.message}\n${log}`); });
    await expect.poll(() => page.evaluate(() => typeof globalThis.__kaguraWebRuntime?.frameProfile?.renderCommandsMs)).toBe('number');
    await page.screenshot({path: test.info().outputPath('scaffold-dev.png')});
    dev.kill('SIGTERM');
    await expect.poll(() => dev.exitCode).not.toBeNull();
    expect(await devDone).toBe(143);
    dev = null;

    run(executable, ['build'], project);
    const dist = join(project, 'dist');
    expect(existsSync(join(dist, 'index.html'))).toBe(true);
    staticServer = createServer((req, res) => {
      try {
        const pathname = req.url.split('?')[0].replace(/^\/game\//, '/').replace(/\/$/, '/index.html');
        const file = join(dist, pathname);
        res.setHeader('Content-Type', {'.html': 'text/html', '.js': 'text/javascript'}[extname(file)] ?? 'application/octet-stream');
        res.end(readFileSync(file));
      } catch { res.writeHead(404).end(); }
    });
    await new Promise(resolve => staticServer.listen(0, '127.0.0.1', resolve));
    await page.goto(`http://127.0.0.1:${staticServer.address().port}/game/`);
    await expect.poll(() => page.evaluate(() => typeof globalThis.__kaguraWebRuntime?.frameProfile?.renderCommandsMs)).toBe('number');
    expect(errors).toEqual([]);
    await page.screenshot({path: test.info().outputPath('scaffold-build.png')});
  } finally {
    if (dev) {
      dev.kill('SIGTERM');
      await Promise.race([devDone, new Promise(resolve => setTimeout(resolve, 10_000))]);
    }
    if (staticServer) await new Promise(resolve => {
      staticServer.close(resolve);
      staticServer.closeAllConnections();
    });
    rmSync(temporary, {recursive: true, force: true});
  }
});
