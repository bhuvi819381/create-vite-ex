#!/bin/bash

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/../utils/colors.sh"

# Create sample components
create_sample_components() {
    print_status "Creating sample components..."

    # Copy components from templates
    cp "$(dirname "${BASH_SOURCE[0]}")/./templates/components/App.tsx" src/
    cp "$(dirname "${BASH_SOURCE[0]}")/./templates/components/Welcome.tsx" src/components/

    print_success "Sample components created"
}

# Create additional configuration files
create_config_files() {
    print_status "Creating additional configuration files..."

    # Create .gitignore if it doesn't exist
    if [ ! -f ".gitignore" ]; then
        cat > .gitignore << 'EOL'
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

node_modules
dist
dist-ssr
*.local

# Editor directories and files
.vscode/*
!.vscode/extensions.json
.idea
.DS_Store
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
EOL
    fi

    # Create README with setup instructions
    cat > README.md << EOL
# $PROJECT_NAME

A modern React application built with:
- ⚡ [Vite](https://vitejs.dev/) - Fast build tool
- ⚛️ [React 18](https://reactjs.org/) - UI library
- 🔷 [TypeScript](https://www.typescriptlang.org/) - Type safety
- 🎨 [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS
- 📦 Package Manager: **${PACKAGE_MANAGER}**

## Quick Start

\`\`\`bash
# Install dependencies
${PKG_INSTALL}

# Start development server
${PKG_RUN} dev

# Build for production
${PKG_RUN} build

# Preview production build
${PKG_RUN} preview
\`\`\`

Created with create-vite-ex.
EOL

    print_success "Configuration files created"
}
