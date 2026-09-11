import { defineConfig } from '../../../../../editor/studio/node_modules/vite/dist/node/index.js';
import { fileURLToPath } from 'node:url';
export default defineConfig({
  publicDir: false,
  build: {
    outDir: fileURLToPath(new URL('./dist', import.meta.url)),
    emptyOutDir: true,
    lib: {
      entry: fileURLToPath(new URL('./extension.mjs', import.meta.url)),
      formats: ['es'],
      fileName: () => 'extension.mjs',
    },
    rolldownOptions: { output: { codeSplitting: false } },
  },
});
