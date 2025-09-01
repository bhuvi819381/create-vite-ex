#!/bin/bash

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/../utils/colors.sh"

# Install Prettier
install_prettier() {
    print_status "Installing Prettier..."

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm add -D prettier prettier-plugin-tailwindcss @types/node
    else
        npm install -D prettier prettier-plugin-tailwindcss @types/node
    fi

    print_success "Prettier installed"
}

# Create Prettier configuration files
create_prettier_config() {
    print_status "Creating Prettier configuration files..."

    # Copy Prettier config from templates
    cp "$(dirname "${BASH_SOURCE[0]}")/./templates/.prettierrc" .
    cp "$(dirname "${BASH_SOURCE[0]}")/./templates/.prettierignore" .

    print_success "Prettier configuration files created"
}
