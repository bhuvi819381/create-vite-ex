#!/bin/bash

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

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

    USE_CURRENT_DIR=false

    if [ "$PROJECT_NAME" = "." ]; then
        USE_CURRENT_DIR=true
        PROJECT_NAME=$(basename "$PWD")
        print_warning "Setting up in current directory"
    fi

    if [ "$USE_CURRENT_DIR" = false ]; then
        if [ -d "$PROJECT_NAME" ]; then
            print_error "Directory '$PROJECT_NAME' already exists"
            exit 1
        fi
    fi
}
