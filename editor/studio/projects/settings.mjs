/** Versioned project settings, shared by the loader, build CLI and runtime host. */
function fields(value, keys, label) {
  if (
    !value ||
    typeof value !== 'object' ||
    Array.isArray(value) ||
    Object.keys(value).some((key) => !keys.includes(key))
  )
    throw Error('Invalid ' + label + ' fields');
}
function identifier(value) {
  if (typeof value !== 'string' || !/^[a-z][a-z0-9_.-]{0,119}$/.test(value))
    throw Error('Invalid project settings ID');
}
function version(value) {
  if (!Number.isSafeInteger(value) || value < 1 || value > 2147483647)
    throw Error('Invalid settings version');
}
export function validateSettings(input, path) {
  if (input.id !== undefined || input.game !== undefined) {
    identifier(input.id);
    identifier(input.game);
  }
  for (const key of ['save', 'sceneSchema']) {
    if (input[key] === undefined) continue;
    const name = key === 'save' ? 'namespace' : 'id';
    fields(input[key], [name, 'version'], key);
    identifier(input[key][name]);
    version(input[key].version);
    if (key === 'save' && !input.id) throw Error('Save namespace requires project identity');
  }
  if (input.editor?.apiVersion !== undefined) version(input.editor.apiVersion);
  const runtime = input.runtime;
  if (runtime !== undefined) {
    fields(runtime, ['kind', 'apiVersion', 'entry', 'targets'], 'runtime');
    version(runtime.apiVersion);
    if (!['script', 'extension', 'native'].includes(runtime.kind))
      throw Error('Unsupported runtime kind');
    if (
      !Array.isArray(runtime.targets) ||
      !runtime.targets.length ||
      runtime.targets.some((t) => !['js', 'native'].includes(t)) ||
      new Set(runtime.targets).size !== runtime.targets.length
    )
      throw Error('Invalid runtime targets');
    if (!runtime.targets.includes(runtime.kind === 'native' ? 'native' : 'js'))
      throw Error('Runtime target does not support its entry');
    if (runtime.kind === 'script') {
      if (!path(runtime.entry).endsWith('.js'))
        throw Error('Runtime entry must be a classic .js script');
    } else if (runtime.entry !== undefined) throw Error('Only script runtimes have an entry');
    if (runtime.kind === 'extension' && !input.editor)
      throw Error('Extension runtime requires an editor');
    if (input.resources?.runtime !== undefined && input.resources.runtime !== runtime.entry)
      throw Error('Conflicting legacy runtime resource');
  }
  if (input.build !== undefined) {
    fields(input.build, ['package', 'artifact', 'scenePackage', 'editorMode'], 'build');
    if (
      input.build.editorMode !== undefined &&
      !['debug', 'release'].includes(input.build.editorMode)
    )
      throw Error('Invalid editor build mode');
    const packagePath = (value) => {
      if (value === '.') return;
      path(value);
      if (!/^[A-Za-z0-9_][A-Za-z0-9_/-]*$/.test(value)) throw Error('Invalid build package');
    };
    packagePath(input.build.package);
    if (input.build.scenePackage !== undefined) packagePath(input.build.scenePackage);
    if (runtime?.kind === 'script' || input.build.artifact !== undefined) {
      path(input.build.artifact);
      if (!input.build.artifact.endsWith('.js')) throw Error('Build artifact must be JavaScript');
    }
  }
  if (input.display !== undefined) {
    fields(input.display, ['width', 'height'], 'display');
    for (const value of [input.display.width, input.display.height])
      if (!Number.isInteger(value) || value < 1 || value > 8192)
        throw Error('Invalid display dimensions');
  }
}
export function runtimeEntry(manifest) {
  return manifest.runtime ? manifest.runtime.entry : manifest.resources?.runtime;
}
/** Reject before replacing an open project; migrations must be explicit, never silent writes. */
export function assertProjectCompatibility(manifest, extension) {
  if (
    manifest.editor?.apiVersion !== undefined &&
    manifest.editor.apiVersion !== extension.apiVersion
  )
    throw Error('Incompatible editor API version');
  if (manifest.runtime && manifest.runtime.apiVersion !== 1)
    throw Error('Incompatible runtime API version');
  if (manifest.game && extension.game && manifest.game !== extension.game)
    throw Error('Project game does not match editor');
  if (
    manifest.sceneSchema &&
    (manifest.sceneSchema.id !== extension.sceneSchema?.id ||
      manifest.sceneSchema.version !== extension.sceneSchema?.version)
  )
    throw Error('Incompatible scene schema; migration is required');
}
/** A detached data snapshot; no file handles, credentials or mutable editor state enter the game. */
export function runtimeSettings(manifest, fallbackDisplay = { width: 640, height: 480 }) {
  return structuredClone({
    ...(manifest.id ? { id: manifest.id, game: manifest.game } : {}),
    ...(manifest.save ? { save: manifest.save } : {}),
    ...(manifest.sceneSchema ? { sceneSchema: manifest.sceneSchema } : {}),
    display: manifest.display ?? { width: fallbackDisplay.width, height: fallbackDisplay.height },
  });
}

/** Conventional source layout. Explicit manifest paths always take precedence. */
export function projectBuild(manifest, game = manifest.game) {
  const artifact = manifest.build?.artifact ?? (game ? game + '.js' : undefined);
  const scenePackage =
    manifest.build?.scenePackage ?? (manifest.scene?.endsWith('.mbt') ? 'scenes' : undefined);
  return {
    package: manifest.build?.package ?? '.',
    ...(manifest.build?.editorMode ? { editorMode: manifest.build.editorMode } : {}),
    ...(artifact ? { artifact } : {}),
    ...(scenePackage ? { scenePackage } : {}),
  };
}
