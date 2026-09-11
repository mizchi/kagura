import { join } from 'node:path';
import entries from '../examples/catalog.json' with { type: 'json' };
import { EXAMPLE_ROOT } from './example-dirs.mjs';

export const catalog = entries;
/** Catalog projects may be data-only. Moon module discovery remains separate for CI. */
export function catalogProjectDir(entry) {
  if (
    !['games', 'demos-2d', 'demos-3d', 'assets'].includes(entry.category) ||
    !/^[a-z][a-z0-9_]*$/.test(entry.id) ||
    !/^[a-zA-Z0-9_-]+\.kgrprj$/.test(entry.manifest)
  )
    throw Error('Invalid example catalog path');
  return join(EXAMPLE_ROOT.examples, entry.category, entry.id);
}
