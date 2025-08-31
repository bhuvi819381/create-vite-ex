#!/usr/bin/env node

import { spawn } from 'child_process';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

// Get current directory (ES module equivalent of __dirname)
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Get the setup script path
const scriptPath = join(__dirname, '../lib/install.sh');

// Get project name from command line arguments
const projectName = process.argv[2];

// Execute the bash script
const child = spawn('bash', [scriptPath, projectName], {
  stdio: 'inherit',
  cwd: process.cwd()
});

child.on('close', (code) => {
  process.exit(code);
});

child.on('error', (err) => {
  console.error('Error executing setup script:', err.message);
  process.exit(1);
});
