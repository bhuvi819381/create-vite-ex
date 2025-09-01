#!/bin/bash

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

# Remove unnecessary files
remove_unnecessary_files() {
    print_status "Removing unnecessary files..."

    # Remove files that are not needed
    rm -f src/App.css
    rm -f public/vite.svg

    print_success "Unnecessary files removed"
}

# Create directory structure
create_directories() {
    print_status "Creating directory structure..."

    mkdir -p src/components
    mkdir -p src/utils
    mkdir -p src/hooks
    mkdir -p src/types

    print_success "Directory structure created"
}
