import { defineConfig } from 'vite';
import { studioSidecarPlugin } from './sidecar.mjs';
export default defineConfig({
  base: './',
  server: { host: '127.0.0.1' },
  preview: { host: '127.0.0.1' },
  plugins: [studioSidecarPlugin()],
  optimizeDeps: {
    exclude: ['@gespenst/core', '@gespenst/websocket', '@gespenst/shell'],
  },
  worker: { format: 'es' },
});
