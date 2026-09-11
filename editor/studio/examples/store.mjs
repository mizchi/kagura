import { packagedPath } from './files.mjs';
import { projectPath } from '../projects/project.mjs';
/** Published examples use the same directory-scoped project API as local folders. */
export async function exampleStore(id, base = new URL('./examples/', location.href)) {
  if (!/^[a-z][a-z0-9_]*$/.test(id)) throw Error('Invalid example ID');
  const root = new URL(id + '/', base);
  const response = await fetch(new URL('files.json', root));
  if (!response.ok) throw Error('Example is not built. Run just studio-examples-build');
  const paths = new Set((await response.json()).map(projectPath));
  return {
    async read(path) {
      projectPath(path);
      if (!paths.has(path)) throw Error('Unknown example resource: ' + path);
      const response = await fetch(new URL(packagedPath(path), root));
      if (!response.ok) throw Error('Missing example resource: ' + path);
      return { blob: await response.blob() };
    },
    async list() {
      return { objects: [...paths].map((key) => ({ key })), cursor: null };
    },
  };
}
