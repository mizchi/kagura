// One publication/versioning catalog. Examples, editors and development-only
// workspace members consume these modules but have independent versions.
export const PUBLISH_MODULE_DIRS = Object.freeze([
  'core/mesh3d', 'core/geom', 'core/anim3d', 'core', 'core/pathfind',
  'platform', 'engine/ui', 'engine/audio', 'engine/text', 'engine/atlas',
  'engine/asset_loader', 'engine/renderer2d', 'engine', 'engine/widget2d',
  '.', 'platform_web', 'platform_native', 'platform_web/runtime_hooks',
  'game/machinations', 'game',
]);


export const RELEASE_DEP_POLICY = Object.freeze({
  'mizchi/mesh3d': [],
  'mizchi/geom': [],
  'mizchi/anim3d': ['mizchi/geom', 'mizchi/mesh3d'],
  'mizchi/kagura_core': ['mizchi/anim3d', 'mizchi/mesh3d', 'mizchi/geom'],
  'mizchi/pathfind': [],
  'mizchi/kagura_platform': ['mizchi/kagura_core'],
  'mizchi/kagura_ui': ['mizchi/kagura_core'],
  'mizchi/kagura_audio': [],
  'mizchi/text': [],
  'mizchi/atlas': ['mizchi/kagura_platform'],
  'mizchi/kagura_asset_loader': ['mizchi/kagura_platform', 'mizchi/atlas'],
  'mizchi/renderer2d': ['mizchi/atlas', 'mizchi/kagura_core', 'mizchi/geom'],
  'mizchi/kagura_engine': ['mizchi/kagura_core', 'mizchi/kagura_platform', 'mizchi/kagura_audio',
    'mizchi/kagura_ui', 'mizchi/text', 'mizchi/mesh3d', 'mizchi/renderer2d', 'mizchi/geom', 'mizchi/atlas', 'mizchi/anim3d'],
  'mizchi/widget2d': ['mizchi/text'],
  'mizchi/kagura': ['mizchi/kagura_core', 'mizchi/kagura_platform', 'mizchi/kagura_engine'],
  'mizchi/kagura_platform_web': ['mizchi/kagura_platform', 'mizchi/kagura_core', 'mizchi/anim3d'],
  'mizchi/native_runtime_hooks': ['mizchi/kagura_core', 'mizchi/kagura_engine', 'mizchi/text', 'mizchi/atlas',
    'mizchi/renderer2d', 'mizchi/kagura_platform', 'mizchi/kagura_audio'],
  'mizchi/web_runtime_hooks': ['mizchi/native_runtime_hooks', 'mizchi/kagura_platform_web', 'mizchi/kagura_core',
    'mizchi/kagura_engine', 'mizchi/text', 'mizchi/atlas', 'mizchi/renderer2d', 'mizchi/kagura_platform', 'mizchi/kagura_audio'],
  'mizchi/machinations': [],
  'mizchi/kagura_game': ['mizchi/kagura_core', 'mizchi/kagura_platform', 'mizchi/kagura_engine',
    'mizchi/kagura_ui', 'mizchi/kagura_audio', 'mizchi/geom', 'mizchi/anim3d'],
});
