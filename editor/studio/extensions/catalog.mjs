// Bundled examples are lazy game-owned extensions, not special cases in the host.
export const editorExtensions = {
  'kagura.example2d': () => import('../scene2d/editor.mjs'),
  'flappy-bird': () => import('../../../examples/games/flappy_bird/editor/editor.mjs'),
  'arena3d': () => import('../../../examples/games/arena3d/editor/editor.mjs'),
  'fps-demo': () => import('../../../examples/games/fps_demo/editor/editor.mjs'),
  'kagura.scene': () => import('./core.mjs'),
  'kagura.example': () => import('../examples/extension.mjs'),
  'hacknslash-3d': () => import('../../../examples/games/hacknslash_3d/editor/editor.mjs'),
  'iron-yard': () => import('../../../examples/games/iron_yard/editor/ui/extension.mjs'),
};
export const defaultEditor = 'kagura.scene';
