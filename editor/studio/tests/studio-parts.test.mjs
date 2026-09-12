import { test } from 'node:test';
import assert from 'node:assert/strict';
import { STUDIO_PARTS, partById, partByRole, isWorkspacePane, paneTabRank, isInspectorChrome } from '../web/studio-parts.mjs';

test('studio parts name hierarchy, inspector, debugger, terminal and agent by role', () => {
  assert.deepEqual(
    STUDIO_PARTS.map((part) => [part.id, part.role]),
    [
      ['hierarchy', 'scene-graph'],
      ['inspector', 'authoring'],
      ['debugger', 'runtime'],
      ['terminal', 'shell'],
      ['agent', 'chat'],
    ],
  );
  assert.equal(partByRole('runtime').title, 'Debugger');
  assert.equal(partById('inspector').title, 'Inspector');
  assert.equal(partById('terminal').title, 'Terminal');
  assert.equal(partById('agent').title, 'Agent');
  assert.equal(isWorkspacePane('studio.terminal'), true);
  assert.equal(isWorkspacePane('studio.agent'), true);
  assert.equal(isWorkspacePane('console'), false);
  assert.equal(isWorkspacePane('studio.storage'), false);
  assert.ok(paneTabRank('console') < paneTabRank('studio.agent'));
  assert.ok(paneTabRank('studio.agent') < paneTabRank('studio.terminal'));
  assert.ok(paneTabRank('studio.terminal') < paneTabRank('studio.storage'));
  assert.ok(paneTabRank('studio.project') < paneTabRank('creator'));
  assert.equal(isInspectorChrome({ classList: { contains: (name) => name === 'part-tabs' } }), true);
  assert.equal(isInspectorChrome({ classList: { contains: () => false } }), false);
});
