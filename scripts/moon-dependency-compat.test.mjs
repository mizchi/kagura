import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, dirname} from 'node:path';
import {patchMoonDependencies} from './moon-dependency-compat.mjs';

test('repairs known published dependencies and is idempotent', t => {
  const cache = mkdtempSync(join(tmpdir(), 'kagura-moon-compat-'));
  t.after(() => rmSync(cache, {recursive: true, force: true}));
  function file(path, source) {
    const dest = join(cache, path);
    mkdirSync(dirname(dest), {recursive: true});
    writeFileSync(dest, source);
    return dest;
  }
  file('mizchi/crater-layout/moon.mod', 'name = "mizchi/crater-layout"\nversion = "0.19.0"\n');
  const layout = file('mizchi/crater-layout/types/types.mbt', 'pub type Float = @values.Float\n');
  file('mizchi/differentiable_ecs/moon.mod', 'name = "mizchi/differentiable_ecs"\nversion = "0.2.1"\n');
  const optimizer = file('mizchi/differentiable_ecs/src/optimizer/moon.pkg', 'import {\n "moonbitlang/core/math",\n}\n');
  file('other/lib/moon.mod', 'name = "other/lib"\nversion = "0.19.0"\n');
  const untouched = file('other/lib/types.mbt', 'pub type Float = @values.Float\n');
  patchMoonDependencies(cache);
  assert.equal(readFileSync(layout, 'utf8'), 'pub type CssFloat = @values.CssFloat\n');
  assert.match(readFileSync(optimizer, 'utf8'), /"moonbitlang\/core\/cmp"/);
  assert.equal(readFileSync(untouched, 'utf8'), 'pub type Float = @values.Float\n');
  const first = readFileSync(optimizer, 'utf8');
  patchMoonDependencies(cache);
  assert.equal(readFileSync(optimizer, 'utf8'), first);
});
