import { defineConfig } from 'vite';
import { studioSidecarPlugin } from './sidecar.mjs';
import { moonbitWebRuntimePlugin } from '../../scripts/build-web-runtime.mjs';
export default defineConfig({
  base: './',
  server: { host: '127.0.0.1' },
  preview: { host: '127.0.0.1' },
  plugins: [moonbitWebRuntimePlugin(), studioSidecarPlugin()],
  optimizeDeps: {
    exclude: ['@gespenst/core', '@gespenst/websocket', '@gespenst/shell'],
  },
  worker: { format: 'es' },
});
