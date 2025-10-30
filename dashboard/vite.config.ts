import { defineConfig } from 'vite';
import preact from '@preact/preset-vite';
import tailwindcss from '@tailwindcss/vite';
import viteCompression from 'vite-plugin-compression';

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
		preact(),
		tailwindcss(),
		viteCompression({
			algorithm: 'brotliCompress',
			deleteOriginFile: true,
		})
	],
});
