import { execFileSync } from 'node:child_process';
import { resolve } from 'node:path';
/** Image-only vlmkit diff. Missing/error output is never interpreted as no change. */
export function diffPng(baseline, current, { elements, ignore = [] } = {}) {
  const args = ['exec', 'vlmkit', 'diff', 'png', baseline, current,
    '--threshold', '0', '--no-heatmap', '--json'];
  if (elements) args.push('--elements-json', elements);
  for (const [x, y, width, height] of ignore) args.push('--ignore-region', `${x},${y},${width}x${height}`);
  const diff = JSON.parse(execFileSync('pnpm', args, { cwd: resolve(import.meta.dirname, '..'), encoding: 'utf8' }));
  if (!Number.isInteger(diff.diffPixels) || diff.diffPixels < 0 || !Number.isInteger(diff.totalPixels) || diff.totalPixels <= 0) {
    throw Error('vlmkit returned no pixel measurement');
  }
  if (diff.sizeDelta?.width !== 0 || diff.sizeDelta?.height !== 0) throw Error('Compared frame dimensions differ');
  return diff;
}
