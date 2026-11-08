import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, existsSync, rmSync, realpathSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { publishMoonModule, runPreparedCheck } from "./publish-moon-module.mjs";

function fixture(t) {
  const root = realpathSync(mkdtempSync(join(tmpdir(), "kagura-publish-test-")));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const module = join(root, "module");
  mkdirSync(module);
  const moon = join(root, "moon");
  const mooncake = join(root, "mooncake");
  const log = join(module, "commands.jsonl");
  writeFileSync(moon, `#!/usr/bin/env node
import {spawnSync} from 'node:child_process';
import {appendFileSync,existsSync,writeFileSync,unlinkSync} from 'node:fs';
import {join} from 'node:path';
const args=process.argv.slice(2);
appendFileSync(${JSON.stringify(log)},JSON.stringify(args)+'\\n');
if(args[0]==='publish') {
  const result=spawnSync(process.env.MOONCAKE_OVERRIDE,['--read-args-from-stdin'],{
    input:JSON.stringify({directory:process.cwd(),dryRun:args.includes('--dry-run')}),
    stdio:['pipe','inherit','inherit'],env:process.env});
  process.exit(result.status??1);
}
if(args[0]==='-C' && args[2]==='fmt') {
  writeFileSync(join(args[1],'moon.mod'),'name = "test/legacy"\\n');
  unlinkSync(join(args[1],'moon.mod.json'));
  process.exit(0);
}
if(args[0]==='check') {
  if(existsSync(join(process.cwd(),'.mooncakes/test/legacy/moon.mod.json'))) process.exit(1);
  if(!args.includes('--dry-run')) {
    if(existsSync(join(process.cwd(),'fail-check'))) process.exit(7);
    writeFileSync(join(process.cwd(),'checked'),'yes');
  }
  process.exit(0);
}
process.exit(9);
`, { mode: 0o755 });
  writeFileSync(mooncake, `#!/usr/bin/env node
import {spawnSync} from 'node:child_process';
import {readFileSync,mkdirSync,writeFileSync,existsSync} from 'node:fs';
import {join} from 'node:path';
const payload=JSON.parse(readFileSync(0,'utf8'));
writeFileSync(join(payload.directory,'payload.json'),JSON.stringify(payload));
const extracted=join(payload.directory,'extracted');
mkdirSync(join(extracted,'.mooncakes/test/legacy'),{recursive:true});
writeFileSync(join(extracted,'moon.mod'),'name = "test/published"\\n');
writeFileSync(join(extracted,'.mooncakes/test/legacy/moon.mod.json'),'{}');
if(existsSync(join(payload.directory,'fail-check'))) writeFileSync(join(extracted,'fail-check'),'yes');
const result=spawnSync(process.env.MOON_OVERRIDE,['check','--no-mbti','--target-dir',join(extracted,'target')],{
  cwd:extracted,env:process.env,stdio:'inherit'});
if(result.status===0) writeFileSync(join(payload.directory,'validated'),'yes');
process.exit(result.status??1);
`, { mode: 0o755 });
  return { root, module, moon, mooncake, log };
}

test("publish preserves stdin and validates fresh dependencies after manifest migration", (t) => {
  const f = fixture(t);
  assert.equal(publishMoonModule(f.module, { moon: f.moon, mooncake: f.mooncake, dryRun: true }), 0);
  assert.deepEqual(JSON.parse(readFileSync(join(f.module, "payload.json"))), { directory: f.module, dryRun: true });
  assert.ok(existsSync(join(f.module, "validated")));
  const commands = readFileSync(f.log, "utf8").trim().split("\n").map(JSON.parse);
  assert.ok(commands.some((args) => args[0] === "-C" && args[2] === "fmt"));
  assert.deepEqual(commands.at(-1), ["check", "--no-mbti", "--target-dir", join(f.module, "extracted/target")]);
});

test("publish propagates compiler failures and removes temporary adapters", (t) => {
  const f = fixture(t);
  writeFileSync(join(f.module, "fail-check"), "yes");
  let adapter;
  const status = publishMoonModule(f.module, { moon: f.moon, mooncake: f.mooncake, run(command, args, options) {
    adapter = options.env.MOONCAKE_OVERRIDE;
    return { status: 7 };
  } });
  assert.equal(status, 7);
  assert.equal(existsSync(adapter), false);
  assert.equal(publishMoonModule(f.module, { moon: f.moon, mooncake: f.mooncake }), 7);
  assert.equal(existsSync(join(f.module, "validated")), false);
});

test("prepared checks retain target and stop before compilation if preparation fails", () => {
  let called = false;
  assert.throws(() => runPreparedCheck("moon", ["check", "--target", "native"], {
    cwd: "/fixture", prepare(directory, options) {
      assert.equal(directory, "/fixture");
      assert.equal(options.target, "native");
      throw Error("preparation failed");
    }, run() { called = true; },
  }), /preparation failed/);
  assert.equal(called, false);
});
