import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, mkdtempSync, readdirSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {WEB_RUNTIME_FILES, copyWebRuntimeAssets} from './web-runtime-assets.mjs';
import {getDemoPage, renderDemoHtml} from './web-demo-pages.mjs';

test('runtime distribution includes the transitive browser module dependencies', t => {
  const directory=mkdtempSync(join(tmpdir(),'kagura-runtime-'));
  t.after(()=>rmSync(directory,{recursive:true,force:true}));
  copyWebRuntimeAssets(directory);
  assert.deepEqual(readdirSync(directory).sort(), [...WEB_RUNTIME_FILES].sort());
  for(const file of WEB_RUNTIME_FILES){
    const source=readFileSync(join(directory,file),'utf8');
    for(const match of source.matchAll(/from\s+['"]\.\/([^'"]+)['"]/g)) {
      assert.ok(WEB_RUNTIME_FILES.includes(match[1]), `${file} imports missing ${match[1]}`);
    }
  }
});

test('game import maps resolve reusable controls in dev, gallery and embedded deployments', () => {
  for(const libPrefix of ['./assets/web','../lib','./runtime/lib']){
    const html=renderDemoHtml({demo:getDemoPage('hacknslash_3d'),scriptTag:'<script type="module" src="game.js"></script>',libPrefix});
    const match=html.match(/<script type="importmap">([^<]+)<\/script>/);
    assert.ok(match);
    assert.equal(JSON.parse(match[1]).imports['@kagura-web/'],libPrefix+'/');
    assert.ok(html.indexOf('type="importmap"')<html.indexOf('type="module"'));
  }
});
