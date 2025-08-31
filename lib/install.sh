#!/bin/bash

# Vite + TypeScript + Tailwind CSS Auto Setup Script
# Usage: ./setup-vite-project.sh [project-name]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Variables for package manager
PACKAGE_MANAGER=""
PKG_INSTALL=""
PKG_RUN=""
PKG_CREATE=""
USE_CURRENT_DIR=false

# Check dependencies and select package manager
check_dependencies() {
    print_status "Checking dependencies..."

    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js first."
        exit 1
    fi

    # Check available package managers
    HAS_NPM=false
    HAS_PNPM=false

    if command -v npm &> /dev/null; then
        HAS_NPM=true
    fi

    if command -v pnpm &> /dev/null; then
        HAS_PNPM=true
    fi

    if [ "$HAS_NPM" = false ] && [ "$HAS_PNPM" = false ]; then
        print_error "Neither npm nor pnpm is installed. Please install one of them first."
        exit 1
    fi

    print_success "Node.js is installed"
}

# Select package manager
select_package_manager() {
    print_status "Available package managers:"

    options=()
    if [ "$HAS_NPM" = true ]; then
        options+=("npm")
    fi
    if [ "$HAS_PNPM" = true ]; then
        options+=("pnpm")
    fi

    if [ ${#options[@]} -eq 1 ]; then
        PACKAGE_MANAGER=${options[0]}
        print_success "Using ${PACKAGE_MANAGER} (only available option)"
    else
        echo "1) npm"
        echo "2) pnpm"
        echo -n "Choose package manager (1 or 2): "
        read -r choice

        case $choice in
            1)
                PACKAGE_MANAGER="npm"
                ;;
            2)
                PACKAGE_MANAGER="pnpm"
                ;;
            *)
                print_error "Invalid choice. Please run the script again."
                exit 1
                ;;
        esac

        print_success "Using ${PACKAGE_MANAGER}"
    fi

    # Set package manager commands
    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        PKG_INSTALL="pnpm install @types/node"
        PKG_RUN="pnpm"
        PKG_CREATE="pnpm create vite"
    else
        PKG_INSTALL="npm install @types/node"
        PKG_RUN="npm run"
        PKG_CREATE="npm create vite@latest"
    fi
}

# Get project name from argument or prompt user
get_project_name() {
    if [ -n "$1" ]; then
        PROJECT_NAME="$1"
    else
        echo -n "Enter project name (or '.' for current directory): "
        read PROJECT_NAME
    fi

    if [ -z "$PROJECT_NAME" ]; then
        print_error "Project name cannot be empty"
        exit 1
    fi

    # Handle current directory setup
    if [ "$PROJECT_NAME" = "." ]; then
        # Check if current directory is empty or has only safe files
        if [ "$(ls -A . 2>/dev/null | grep -v -E '^\.(git|gitignore|DS_Store)

# Create Vite project with TypeScript
create_vite_project() {
    if [ "$USE_CURRENT_DIR" = true ]; then
        print_status "Setting up Vite project with TypeScript in current directory using ${PACKAGE_MANAGER}..."

        # Use Vite's built-in current directory support
        if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
            pnpm create vite . --template react-ts
        else
            npm create vite@latest . --template react-ts
        fi
    else
        print_status "Creating Vite project with TypeScript using ${PACKAGE_MANAGER}..."
        $PKG_CREATE "$PROJECT_NAME" --template react-ts
        cd "$PROJECT_NAME"
    fi
    print_success "Vite project created"
}

# Install dependencies
install_dependencies() {
    print_status "Installing project dependencies with ${PACKAGE_MANAGER}..."
    $PKG_INSTALL
    print_success "Dependencies installed"
}

# Install and configure Tailwind CSS
setup_tailwind() {
    print_status "Installing Tailwind CSS with ${PACKAGE_MANAGER}..."

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add -D tailwindcss @tailwindcss/vite
    else
        npm install -D tailwindcss @tailwindcss/vite
    fi

    print_status "Configuring Tailwind CSS..."

    # Update vite.config.ts with Tailwind plugin and path aliases
    cat > vite.config.ts << 'EOL'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { resolve } from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@assets': resolve(__dirname, './src/assets'),
      '@utils': resolve(__dirname, './src/utils'),
      '@hooks': resolve(__dirname, './src/hooks'),
      '@types': resolve(__dirname, './src/types'),
    },
  },
})
EOL

    # Update tsconfig.json to support path aliases
    cat > tsconfig.json << 'EOL'
{
  "files": [],
  "references": [
    {
      "path": "./tsconfig.app.json"
    },
    {
      "path": "./tsconfig.node.json"
    }
  ],
  "compilerOptions": {
    "strict": true,
    "forceConsistentCasingInFileNames": true
  }
}
EOL

    # Update tsconfig.app.json for path aliases
    cat > tsconfig.app.json << 'EOL'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@assets/*": ["./src/assets/*"],
      "@utils/*": ["./src/utils/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@types/*": ["./src/types/*"]
    },

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"]
}
EOL

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

# Remove unnecessary files
remove_unnecessary_files() {
    print_status "Removing unnecessary files..."

    # Remove files that are not needed
    rm -f src/App.css
    rm -f public/vite.svg

    print_success "Unnecessary files removed"
}

# Create a sample component with Tailwind classes
create_sample_component() {
    print_status "Creating sample component"

    # Create components directory
    mkdir -p src/components

    # Create a sample component using path alias
    cat > src/components/Welcome.tsx << 'EOL'
import { useState } from 'react'
import reactLogo from '@/assets/react.svg'

function Welcome() {

  return (
  <div>Welcome To your Project.</div>
  )
}

export default Welcome
EOL

    cat > src/App.tsx << 'EOL'

import Welcome from '@components/Welcome'


function App() {


  return (
  <div className="min-h-screen flex items-center justify-center bg-gray-900 text-white"><Welcome /></div>
  )
}

export default App
EOL

    print_success "Sample component created with Tailwind styling and path aliases"
}

# Install Prettier
install_prettier() {
    print_status "Installing Prettier..."

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add -D prettier prettier-plugin-tailwindcss
    else
        npm install -D prettier prettier-plugin-tailwindcss
    fi

    print_success "Prettier installed"
}

# Create Prettier configuration files
create_prettier_config() {
    print_status "Creating Prettier configuration files..."

    # Create .prettierrc
    cat > .prettierrc << 'EOL'
{
  plugins: ["prettier-plugin-tailwindcss"],
  "semi": false,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "bracketSameLine": false,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "quoteProps": "as-needed"
}
EOL

    # Create .prettierignore
    cat > .prettierignore << 'EOL'
# Dependencies
node_modules/
.pnpm-store/

# Production builds
dist/
build/
out/

# Cache directories
.cache/
.temp/
.tmp/

# Log files
*.log
logs/

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Package manager files
package-lock.json
yarn.lock
pnpm-lock.yaml

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Generated files
coverage/
.nyc_output/

# Config files (optional - remove if you want to format these)
tailwind.config.js
vite.config.ts
tsconfig.json
tsconfig.*.json
EOL

    print_success "Prettier configuration files created"
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

## Development

- **Dev Server**: http://localhost:5173
- **Hot Module Replacement**: Enabled
- **TypeScript**: Strict mode enabled
- **Tailwind CSS**: JIT mode for optimal performance
- **Package Manager**: ${PACKAGE_MANAGER}

## Project Structure

\`\`\`
$PROJECT_NAME/
├── public/          # Static assets
├── src/
│   ├── assets/      # Project assets
│   ├── App.tsx      # Main App component
│   ├── main.tsx     # Entry point
│   └── index.css    # Global styles with Tailwind
├── index.html       # HTML template
├── package.json     # Dependencies and scripts
├── tailwind.config.js # Tailwind configuration
├── tsconfig.json    # TypeScript configuration
└── vite.config.ts   # Vite configuration
\`\`\`

## Available Scripts

- \`${PKG_RUN} dev\` - Start development server
- \`${PKG_RUN} build\` - Build for production
- \`${PKG_RUN} build:watch\` - Build with watch mode
- \`${PKG_RUN} preview\` - Preview production build
- \`${PKG_RUN} preview:host\` - Preview with network access
- \`${PKG_RUN} format\` - Format code with Prettier
- \`${PKG_RUN} format:check\` - Check code formatting

## Path Aliases

This project includes pre-configured path aliases for cleaner imports:

\`\`\`typescript
import Component from '@components/Component'  // ./src/components/Component
import utils from '@utils/helpers'             // ./src/utils/helpers
import type { User } from '@types/user'        // ./src/types/user
import logo from '@assets/logo.svg'            // ./src/assets/logo.svg
import useCustomHook from '@hooks/useCustom'   // ./src/hooks/useCustom
\`\`\`

## Package Manager Notes

This project uses **${PACKAGE_MANAGER}**. If you prefer to use a different package manager:

$(if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
echo "- To use npm: Delete \`pnpm-lock.yaml\` and run \`npm install\`"
else
echo "- To use pnpm: Delete \`package-lock.json\` and run \`pnpm install\`"
fi)

Created with the Vite + TypeScript + Tailwind CSS setup script.
EOL

    print_success "Configuration files created"
}

# Main execution function
main() {
    echo "🚀 Vite + TypeScript + Tailwind CSS Setup Script"
    echo "================================================"

    check_dependencies
    select_package_manager
    get_project_name "$1"

    print_status "Setting up project: $PROJECT_NAME"

    create_vite_project
    install_dependencies
    install_prettier
    setup_tailwind
    create_prettier_config
    remove_unnecessary_files
    create_sample_component
    create_config_files

    echo ""
    print_success "Project setup complete! 🎉"
    echo ""
    echo "Next steps:"
    echo "  1. cd $PROJECT_NAME"
    echo "  2. ${PKG_RUN} dev"
    echo ""
    echo "Your development server will be available at: http://localhost:5173"
    echo ""
    print_status "Package manager: ${PACKAGE_MANAGER}"
    print_status "Happy coding! 💻"
}

# Run main function with all arguments
main "$@" | wc -l)" -gt 0 ]; then
            print_warning "Current directory is not empty"
            echo -n "Continue anyway? (y/N): "
            read -r confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                print_error "Setup cancelled"
                exit 1
            fi
        fi
        USE_CURRENT_DIR=true
        PROJECT_NAME=$(basename "$PWD")
    else
        USE_CURRENT_DIR=false
        if [ -d "$PROJECT_NAME" ]; then
            print_error "Directory '$PROJECT_NAME' already exists"
            exit 1
        fi
    fi
}

# Create Vite project with TypeScript
create_vite_project() {
    print_status "Creating Vite project with TypeScript using ${PACKAGE_MANAGER}..."
    $PKG_CREATE "$PROJECT_NAME" --template react-ts
    cd "$PROJECT_NAME"
    print_success "Vite project created"
}

# Install dependencies
install_dependencies() {
    print_status "Installing project dependencies with ${PACKAGE_MANAGER}..."
    $PKG_INSTALL
    print_success "Dependencies installed"
}

# Install and configure Tailwind CSS
setup_tailwind() {
    print_status "Installing Tailwind CSS with ${PACKAGE_MANAGER}..."

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add -D tailwindcss @tailwindcss/vite
    else
        npm install -D tailwindcss @tailwindcss/vite
    fi

    print_status "Configuring Tailwind CSS..."

    # Update vite.config.ts with Tailwind plugin and path aliases
    cat > vite.config.ts << 'EOL'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { resolve } from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@assets': resolve(__dirname, './src/assets'),
      '@utils': resolve(__dirname, './src/utils'),
      '@hooks': resolve(__dirname, './src/hooks'),
      '@types': resolve(__dirname, './src/types'),
    },
  },
})
EOL

    # Update tsconfig.json to support path aliases
    cat > tsconfig.json << 'EOL'
{
  "files": [],
  "references": [
    {
      "path": "./tsconfig.app.json"
    },
    {
      "path": "./tsconfig.node.json"
    }
  ],
  "compilerOptions": {
    "strict": true,
    "forceConsistentCasingInFileNames": true
  }
}
EOL

    # Update tsconfig.app.json for path aliases
    cat > tsconfig.app.json << 'EOL'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@assets/*": ["./src/assets/*"],
      "@utils/*": ["./src/utils/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@types/*": ["./src/types/*"]
    },

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"]
}
EOL

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

# Remove unnecessary files
remove_unnecessary_files() {
    print_status "Removing unnecessary files..."

    # Remove files that are not needed
    rm -f src/App.css
    rm -f public/vite.svg

    print_success "Unnecessary files removed"
}

# Create a sample component with Tailwind classes
create_sample_component() {
    print_status "Creating sample component"

    # Create components directory
    mkdir -p src/components

    # Create a sample component using path alias
    cat > src/components/Welcome.tsx << 'EOL'
import { useState } from 'react'
import reactLogo from '@/assets/react.svg'

function Welcome() {

  return (
  <div>Welcome To your Project.</div>
  )
}

export default Welcome
EOL

    cat > src/App.tsx << 'EOL'

import Welcome from '@components/Welcome'


function App() {


  return (
  <div className="min-h-screen flex items-center justify-center bg-gray-900 text-white"><Welcome /></div>
  )
}

export default App
EOL

    print_success "Sample component created with Tailwind styling and path aliases"
}

# Install Prettier
install_prettier() {
    print_status "Installing Prettier..."

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add -D prettier prettier-plugin-tailwindcss
    else
        npm install -D prettier prettier-plugin-tailwindcss
    fi

    print_success "Prettier installed"
}

# Create Prettier configuration files
create_prettier_config() {
    print_status "Creating Prettier configuration files..."

    # Create .prettierrc
    cat > .prettierrc << 'EOL'
{
  plugins: ["prettier-plugin-tailwindcss"],
  "semi": false,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "bracketSameLine": false,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "quoteProps": "as-needed"
}
EOL

    # Create .prettierignore
    cat > .prettierignore << 'EOL'
# Dependencies
node_modules/
.pnpm-store/

# Production builds
dist/
build/
out/

# Cache directories
.cache/
.temp/
.tmp/

# Log files
*.log
logs/

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Package manager files
package-lock.json
yarn.lock
pnpm-lock.yaml

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Generated files
coverage/
.nyc_output/

# Config files (optional - remove if you want to format these)
tailwind.config.js
vite.config.ts
tsconfig.json
tsconfig.*.json
EOL

    print_success "Prettier configuration files created"
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

## Development

- **Dev Server**: http://localhost:5173
- **Hot Module Replacement**: Enabled
- **TypeScript**: Strict mode enabled
- **Tailwind CSS**: JIT mode for optimal performance
- **Package Manager**: ${PACKAGE_MANAGER}

## Project Structure

\`\`\`
$PROJECT_NAME/
├── public/          # Static assets
├── src/
│   ├── assets/      # Project assets
│   ├── App.tsx      # Main App component
│   ├── main.tsx     # Entry point
│   └── index.css    # Global styles with Tailwind
├── index.html       # HTML template
├── package.json     # Dependencies and scripts
├── tailwind.config.js # Tailwind configuration
├── tsconfig.json    # TypeScript configuration
└── vite.config.ts   # Vite configuration
\`\`\`

## Available Scripts

- \`${PKG_RUN} dev\` - Start development server
- \`${PKG_RUN} build\` - Build for production
- \`${PKG_RUN} build:watch\` - Build with watch mode
- \`${PKG_RUN} preview\` - Preview production build
- \`${PKG_RUN} preview:host\` - Preview with network access
- \`${PKG_RUN} format\` - Format code with Prettier
- \`${PKG_RUN} format:check\` - Check code formatting

## Path Aliases

This project includes pre-configured path aliases for cleaner imports:

\`\`\`typescript
import Component from '@components/Component'  // ./src/components/Component
import utils from '@utils/helpers'             // ./src/utils/helpers
import type { User } from '@types/user'        // ./src/types/user
import logo from '@assets/logo.svg'            // ./src/assets/logo.svg
import useCustomHook from '@hooks/useCustom'   // ./src/hooks/useCustom
\`\`\`

## Package Manager Notes

This project uses **${PACKAGE_MANAGER}**. If you prefer to use a different package manager:

$(if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
echo "- To use npm: Delete \`pnpm-lock.yaml\` and run \`npm install\`"
else
echo "- To use pnpm: Delete \`package-lock.json\` and run \`pnpm install\`"
fi)

Created with the Vite + TypeScript + Tailwind CSS setup script.
EOL

    print_success "Configuration files created"
}

# Main execution function
main() {
    echo "🚀 Vite + TypeScript + Tailwind CSS Setup Script"
    echo "================================================"

    check_dependencies
    select_package_manager
    get_project_name "$1"

    print_status "Setting up project: $PROJECT_NAME"

    create_vite_project
    install_dependencies
    install_prettier
    setup_tailwind
    create_prettier_config
    remove_unnecessary_files
    create_sample_component
    create_config_files

    echo ""
    print_success "Project setup complete! 🎉"
    echo ""
    echo "Next steps:"
    echo "  1. cd $PROJECT_NAME"
    echo "  2. ${PKG_RUN} dev"
    echo ""
    echo "Your development server will be available at: http://localhost:5173"
    echo ""
    print_status "Package manager: ${PACKAGE_MANAGER}"
    print_status "Happy coding! 💻"
}

# Run main function with all arguments
main "$@"
