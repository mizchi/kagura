import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, writeFileSync, readFileSync, existsSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {emitExamplePage} from './web-demo-package.mjs';
import {getDemoPage, renderLandingHtml} from './web-demo-pages.mjs';

test('Pages packages a workspace release build and keeps every game URL relative to its subdirectory', t => {
  const root=mkdtempSync(join(tmpdir(),'kagura-pages-'));
  t.after(()=>rmSync(root,{recursive:true,force:true}));
  const exampleDir = join(root, 'example');
  const site = join(root, '_site');
  const build=join(exampleDir,'_build/js/release/build/mizchi/hacknslash_3d');
  mkdirSync(build,{recursive:true});
  mkdirSync(join(exampleDir,'assets/audio'),{recursive:true});
  writeFileSync(join(build,'hacknslash_3d.js'),'globalThis.runtimeReady=true;');
  writeFileSync(join(exampleDir,'assets/hunter-ui.mjs'),'// HUD');
  writeFileSync(join(exampleDir,'assets/audio/summon.ogg'),'audio');
  writeFileSync(join(exampleDir,'assets/font.ttf'),'font');
  emitExamplePage({demo: getDemoPage('hacknslash_3d'), exampleDir, site, cacheBust: 'build123'});
  const output=join(site,'hacknslash_3d');
  assert.equal(readFileSync(join(output,'hacknslash_3d.js'),'utf8'),'globalThis.runtimeReady=true;');
  assert.equal(readFileSync(join(output,'assets/audio/summon.ogg'),'utf8'),'audio');
  assert.equal(existsSync(join(output,'assets/hunter-ui.mjs')),true);
  const html=readFileSync(join(output,'index.html'),'utf8');
  assert.match(html,/data-kagura-presentation="fullscreen"/);
  assert.match(html,/"@kagura-web\/":"\.\.\/lib\/"/);
  assert.match(html,/src="\.\/assets\/hunter-ui.mjs"/);
  const loader=readFileSync(join(output,'loader.js'),'utf8');
  assert.match(loader,/\.\/hacknslash_3d.js\?v=build123/);
  assert.match(loader,/\.\/assets\/font.ttf/);
  assert.doesNotMatch(loader,/localhost|_build/);
});

test('playground describes the current hunter with saved builds, summons and configurable mouse slots', () => {
  const demo=getDemoPage('hacknslash_3d');
  assert.match(demo.summary,/summon/i);
  assert.match(demo.start,/save/i);
  assert.match(demo.controls.join('\n'),/Left \/ right click.*slots 1 \/ 2/i);
  const html=renderLandingHtml({demos:[demo]});
  assert.match(html,/href="\.\/hacknslash_3d\/"/);
  assert.match(html,/ASHEN HUNT/);
});
