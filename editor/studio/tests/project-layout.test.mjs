import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile, stat } from 'node:fs/promises';
import catalog from '../examples/catalog.json' with { type: 'json' };
import { findExampleDir, EXAMPLE_ROOT } from '../../../scripts/example-dirs.mjs';
import { validateProject } from '../projects/project.mjs';

test('all Studio projects use flat MoonBit roots and explicit conventional entries', async () => {
  for (const item of catalog) {
    const dir = findExampleDir(item.id, [EXAMPLE_ROOT.examples]);
    const mod = await readFile(dir + '/moon.mod', 'utf8');
    assert.doesNotMatch(mod, /source\s*=\s*"src"/, item.id);
    await assert.rejects(stat(dir + '/src'), { code: 'ENOENT' });
    const project = validateProject(JSON.parse(await readFile(dir + '/' + item.manifest)));
    assert.ok(!project.build.package.startsWith('src'), item.id);
    await stat(
      dir + (project.build.package === '.' ? '' : '/' + project.build.package) + '/moon.pkg',
    );
    for (const scene of Object.values(project.scenes ?? { main: project.scene })) {
      assert.ok(/^(scenes|editor)\//.test(scene), item.id + ': ' + scene);
      await stat(dir + '/' + scene);
    }
    if (project.editor.entry) assert.ok(project.editor.entry.startsWith('editor/'));
  }
});
