#!/bin/bash

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/../utils/colors.sh"

# Variables for package manager
PACKAGE_MANAGER=""
PKG_INSTALL=""
PKG_RUN=""
PKG_CREATE=""

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
        PKG_INSTALL="pnpm install "
        PKG_RUN="pnpm"
        PKG_CREATE="pnpm create vite"
    else
        PKG_INSTALL="npm install "
        PKG_RUN="npm run"
        PKG_CREATE="npm create vite@latest"
    fi
}
