import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, mkdtempSync, readdirSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {WEB_RUNTIME_FILES, copyWebRuntimeAssets} from './web-runtime-assets.mjs';
import {getDemoPage, renderDemoHtml} from './web-demo-pages.mjs';
import {WEB_RUNTIME_BUILDS, webRuntimeSourceHash, webRuntimeSourceFiles, WEB_HOST_SOURCE_DIR, webHostFiles} from './web-runtime-source.mjs';

test('distributed host code and declarations match their owning source packages',()=>{
  for(const file of webHostFiles())
    assert.equal(readFileSync(new URL('../assets/web/'+file,import.meta.url),'utf8'),readFileSync(join(WEB_HOST_SOURCE_DIR,file),'utf8'),file);
  for(const build of WEB_RUNTIME_BUILDS)
    assert.equal(readFileSync(new URL('../assets/web/'+build.output.replace(/\.js$/,'.d.ts'),import.meta.url),'utf8'),
      readFileSync(new URL('../'+build.moduleDir+'/'+build.package+'/exports.d.ts',import.meta.url),'utf8'));
});

test('source freshness and hot reload include typed transitive implementations',()=>{
  const runtime=webRuntimeSourceFiles(WEB_RUNTIME_BUILDS[0]);
  const inventory=webRuntimeSourceFiles(WEB_RUNTIME_BUILDS[1]);
  assert.ok(runtime.includes('core/anim3d/playback/timeline.mbt'));
  assert.ok(runtime.includes('core/statistics/intervals.mbt'));
  assert.ok(runtime.includes('platform_web/render/geometry.mbt'));
  assert.ok(inventory.includes('game/inventory/item_grid.mbt'));
  assert.ok(inventory.includes('game/inventory/preview.mbt'));
  assert.ok(!runtime.some(file=>file.endsWith('_wbtest.mbt')));
});

test('checked-in runtime matches the MoonBit sources without requiring a compiler in Node-only jobs',()=>{
  for (const build of WEB_RUNTIME_BUILDS) {
    const source=readFileSync(new URL('../assets/web/'+build.output,import.meta.url),'utf8');
    assert.ok(source.startsWith(`// Generated from ${build.moduleDir}/${build.package}/`));
    assert.ok(source.includes(`// Source SHA-256: ${webRuntimeSourceHash(build)}\n`),'Run just web-runtime-build');
  }
});

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
    assert.equal(JSON.parse(match[1]).imports['#kagura-web/'],libPrefix+'/');
    assert.ok(html.indexOf('type="importmap"')<html.indexOf('type="module"'));
  }
});
