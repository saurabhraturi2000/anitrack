import { copyFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const distDir = path.resolve(__dirname, '..', 'dist');

await copyFile(
  path.join(distDir, 'index.html'),
  path.join(distDir, '404.html'),
);

await writeFile(path.join(distDir, '.nojekyll'), '');
