#!/bin/bash

# Vite + TypeScript + Tailwind CSS Auto Setup Script
# Usage: ./main.sh [project-name]

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all utilities and setup modules
source "$SCRIPT_DIR/utils/colors.sh"
source "$SCRIPT_DIR/utils/validation.sh"
source "$SCRIPT_DIR/utils/file-operations.sh"
source "$SCRIPT_DIR/setup/dependencies.sh"
source "$SCRIPT_DIR/setup/project.sh"
source "$SCRIPT_DIR/setup/tailwind.sh"
source "$SCRIPT_DIR/setup/prettier.sh"
source "$SCRIPT_DIR/setup/cleanup.sh"

# Main execution function
main() {
    echo "🚀 Vite + TypeScript + Tailwind CSS Setup Script"
    echo "================================================"

    # Step 1: Check dependencies and select package manager
    check_dependencies
    select_package_manager

    # Step 2: Get and validate project name
    get_project_name "$1"

    print_status "Setting up project: $PROJECT_NAME"

    # Step 3: Create and setup project
    create_vite_project
    install_dependencies
    install_prettier
    setup_tailwind
    create_prettier_config
    remove_unnecessary_files
    create_directories
    create_sample_components
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
