#!/bin/bash

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/../utils/colors.sh"

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

        # We're already in the right directory, no need to cd
    else
        print_status "Creating Vite project with TypeScript using ${PACKAGE_MANAGER}..."
        if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
            pnpm create vite "$PROJECT_NAME" --template react-ts
        else
            npm create vite@latest "$PROJECT_NAME" --template react-ts
        fi
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
