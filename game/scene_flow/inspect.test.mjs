import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {inspectSceneFlow, inspectSceneDocuments} from './inspect.mjs';
import {decodeMoonScene} from '../../editor/studio/scene/moonbit.mjs';

const example = () => JSON.parse(readFileSync(new URL('./example.json', import.meta.url), 'utf8'));
test('portable inspection reports structure and exports a matching Mermaid diagram', () => {
  const result = inspectSceneFlow(example());
  assert.equal(result.report.valid, true);
  assert.deepEqual(result.report.issues, []);
  assert.match(result.mermaid, /s0 --> s1: start/);
  const broken = example();
  broken.scenes.push('unused');
  broken.transitions.push({from:'unused',event:'go',to:'play'});
  const report = inspectSceneFlow(broken).report;
  assert.ok(report.issues.some(i => i.code === 'unreachable-scene'));
  assert.ok(report.issues.some(i => i.code === 'dead-transition' && i.transition === 3));
});
test('malformed input fails at the typed boundary while invalid graphs remain inspectable', () => {
  for (const input of [null, {}, {...example(), transitions:[{from:'title',event:5,to:'play'}]}])
    assert.throws(() => inspectSceneFlow(input));
  const broken = example();
  broken.transitions[0].to = 'missing';
  assert.equal(inspectSceneFlow(broken).report.valid, false);
  assert.throws(() => inspectSceneFlow({...example(), scenes:Array(257).fill('x')}), /256/);
});
test('Arena source documents compile to the actual portal flow through MoonBit', () => {
  const scenes = ['training','second'].map(id => ({id, data:decodeMoonScene(readFileSync(
    new URL(`../../examples/games/arena3d/scenes/${id}.mbt`,import.meta.url), 'utf8'))}));
  const result = inspectSceneDocuments({entry:'training',game:'arena3d',scenes});
  assert.deepEqual(result.definition, {
    entry:'training',scenes:['training','second'],terminal:['second'],
    transitions:[{from:'training',event:'portal:portal',to:'second'}],
  });
  assert.deepEqual(result.report.issues, []);
});
test('CLI exports diagrams and rejects problems for CI', () => {
  const cli = new URL('../../scripts/scene-flow.mjs', import.meta.url);
  const run = (args, input) => spawnSync(process.execPath,[cli.pathname,...args],{input,encoding:'utf8'});
  const ok = run(['--mermaid','-'], JSON.stringify(example()));
  assert.equal(ok.status,0,ok.stderr);
  assert.match(ok.stdout,/stateDiagram-v2/);
  const broken = {...example(), scenes:[...example().scenes,'unused']};
  const bad = run(['--json','-'], JSON.stringify(broken));
  assert.equal(bad.status,1,bad.stderr);
  assert.ok(JSON.parse(bad.stdout).report.issues.some(i => i.code === 'unreachable-scene'));
  assert.equal(run(['-'],'{').status,2);
});
