// JS serialization boundary; statistical and profile analysis lives in MoonBit.
import {analyzePerformance} from '../diagnostics/performance.generated.js';

function analyze(operation, input) {
  const response = JSON.parse(analyzePerformance(operation, JSON.stringify(input)));
  if (!response.ok) throw new RangeError(response.error);
  return response.value;
}
export const summarizeNumericSamples = values => analyze('numeric', values);
export const mapCdpPerformanceMetrics = metrics => analyze('metrics', metrics);
export const summarizeBrowserMetrics = (before = {}, after = {}) => analyze('browser', {before, after});
export const summarizeChromeTraceEvents = events => analyze('trace', events);
export const summarizeCpuProfile = profile => analyze('cpu', profile);
export const cpuPerFrame = (before, after, frames) => analyze('perFrame', {before, after, frames});
