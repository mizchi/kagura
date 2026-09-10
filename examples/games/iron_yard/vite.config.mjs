import { defineConfig } from 'vite';
import { fileURLToPath } from 'node:url';
export default defineConfig({
  base:"./",
  root:fileURLToPath(new URL('.',import.meta.url)),
  resolve:{alias:{'@kagura-web':fileURLToPath(new URL('../../../lib/web',import.meta.url))}},
  server:{host:'127.0.0.1',port:5192,strictPort:true,fs:{allow:[fileURLToPath(new URL('../../../',import.meta.url))]}},
  build:{outDir:'dist',chunkSizeWarningLimit:1500},
});
