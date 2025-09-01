#!/usr/bin/env node
import { spawn } from 'child_process';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Point to the new main.sh instead of install.sh
const scriptPath = join(__dirname, '../lib/main.sh');
const projectName = process.argv[2];

const child = spawn('bash', [scriptPath, projectName], {
  stdio: 'inherit',
  cwd: process.cwd()
});
