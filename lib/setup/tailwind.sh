#!/bin/bash

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/../utils/colors.sh"

# Install and configure Tailwind CSS
setup_tailwind() {
    print_status "Installing Tailwind CSS with ${PACKAGE_MANAGER}..."

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add -D tailwindcss @tailwindcss/vite
    else
        npm install -D tailwindcss @tailwindcss/vite
    fi

    print_status "Configuring Tailwind CSS..."

    # Copy vite.config.ts from templates
    cp "$(dirname "${BASH_SOURCE[0]}")/./templates/vite.config.ts" .

    # Copy TypeScript configs
    cp "$(dirname "${BASH_SOURCE[0]}")/./templates/tsconfig.json" .
    cp "$(dirname "${BASH_SOURCE[0]}")/./templates/tsconfig.app.json" .

    # Update src/index.css with Tailwind directives
    cat > src/index.css << 'EOL'
@import 'tailwindcss';

body {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;

  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;

  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  -webkit-text-size-adjust: 100%;
}
EOL

    print_success "Tailwind CSS configured with path aliases"
}
