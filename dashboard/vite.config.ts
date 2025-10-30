import { defineConfig } from 'vite';
import preact from '@preact/preset-vite';
import tailwindcss from '@tailwindcss/vite';
import { viteSingleFile } from "vite-plugin-singlefile"
import viteCompression from 'vite-plugin-compression';

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
		preact(),
		tailwindcss(),
		viteSingleFile(),
		viteCompression({
			algorithm: 'gzip',
		})
	],
});
