/** A shared authoring resource. Runtime-specific level data belongs to a game extension. */
export interface ExampleLaunch {
  example: string;
  /** Only parameters actually consumed by the example affect its runtime. Applied on Play. */
  query: Record<string, string | number | boolean>;
}
export interface ExampleCatalogEntry {
  id: string;
  title: string;
  category: 'games' | 'demos-2d' | 'demos-3d';
  manifest: string;
  controls: string[];
  width: number;
  height: number;
  preview: 'webgpu' | 'native' | 'asset';
}
