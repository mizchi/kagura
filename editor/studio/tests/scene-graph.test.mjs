import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildSceneGraph } from '../runtime/scene-graph.mjs';

const birdVisual = {
  id: 'world/body',
  name: 'Bird body',
  kind: 'rect',
  generated: false,
  subject: 'bird',
  children: [],
};
const world = {
  id: 'world',
  name: 'world',
  kind: 'group',
  generated: false,
  children: [
    birdVisual,
    {
      id: 'world/pipes',
      name: 'pipes',
      kind: 'group',
      generated: true,
      children: [
        { id: 'world/pipes/@0', name: 'pipe', kind: 'rect', generated: true, children: [] },
      ],
    },
  ],
};
const inspection = {
  subjects: [
    {
      id: 'bird',
      name: 'Bird',
      fields: [
        { id: 'y', label: 'Y', kind: 'number', value: 12, access: 'runtime', unit: 'px' },
        { id: 'speed', label: 'Speed', kind: 'number', value: 3, access: 'readonly', unit: 'px/tick' },
      ],
    },
  ],
};

test('runtime graph keeps the draw tree and lifts matching subjects from game state', () => {
  const graph = buildSceneGraph({
    sceneId: 'training',
    scenes: [
      { id: 'training', path: 'scenes/training.mbt', entry: true },
      { id: 'second', path: 'scenes/second.mbt' },
    ],
    hierarchy: [world],
    inspection,
    selection: { kind: 'subject', id: 'bird' },
  });
  assert.equal(graph.activeScene, 'training');
  assert.equal(graph.scenes.length, 2);
  assert.equal(graph.subjects[0].id, 'bird');
  assert.equal(graph.subjects[0].origin, 'state');
  assert.deepEqual(graph.subjects[0].visuals, ['world/body']);
  assert.equal(graph.subjects[0].selected, true);
  assert.equal(graph.subjects[0].fields[0].value, 12);
  assert.equal(graph.view[0].id, 'world');
  assert.equal(graph.view[0].children[0].subject, 'bird');
  assert.equal(graph.view[0].children[0].origin, 'state');
  assert.equal(graph.view[0].children[1].generated, true);
  assert.equal(graph.selection.kind, 'subject');
  assert.equal(graph.selection.id, 'bird');
});

test('unmatched subjects stay listed and the editor never invents a subject from a path', () => {
  const graph = buildSceneGraph({
    hierarchy: [{ id: 'hud', name: 'HUD', kind: 'group', generated: false, children: [] }],
    inspection,
  });
  assert.equal(graph.subjects[0].id, 'bird');
  assert.deepEqual(graph.subjects[0].visuals, []);
  assert.equal(graph.view[0].subject, undefined);
  assert.equal(graph.view[0].origin, 'definition');
});

test('authoring documents project as definition nodes when the game is not playing', () => {
  const graph = buildSceneGraph({
    document: {
      name: 'Arena',
      nodes: [
        { id: 'hero', name: 'Hero', parent: '', asset: 'primitive.box' },
        { id: 'sword', name: 'Sword', parent: 'hero', asset: 'primitive.box' },
      ],
    },
    selection: { kind: 'node', id: 'sword' },
  });
  assert.equal(graph.subjects.length, 0);
  assert.equal(graph.view[0].id, 'hero');
  assert.equal(graph.view[0].origin, 'definition');
  assert.equal(graph.view[0].kind, 'primitive.box');
  assert.equal(graph.view[0].children[0].id, 'sword');
  assert.equal(graph.view[0].children[0].selected, true);
  assert.equal(graph.selection.kind, 'node');
});
