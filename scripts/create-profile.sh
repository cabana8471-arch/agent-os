#!/bin/bash

# =============================================================================
# Agent OS Create Profile Script
# Creates a new profile for Agent OS
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# Validate HOME is set before proceeding
if [[ -z "${HOME:-}" ]]; then
    echo "Error: HOME environment variable is not set" >&2
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$HOME/agent-os"
PROFILES_DIR="$BASE_DIR/profiles"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Default Values
# -----------------------------------------------------------------------------

PROFILE_NAME=""
INHERIT_FROM=""
COPY_FROM=""
DRY_RUN="false"
VERBOSE="false"

# -----------------------------------------------------------------------------
# Validation Functions
# -----------------------------------------------------------------------------

validate_installation() {
    # Check base installation
    validate_base_installation

    if [[ ! -d "$PROFILES_DIR" ]]; then
        print_error "Profiles directory not found at $PROFILES_DIR"
        exit 1
    fi
}

# Validate that a profile name doesn't contain path traversal attempts
# Returns 0 if valid, 1 if invalid
validate_profile_name() {
    local name=$1

    # Check for empty name
    if [[ -z "$name" ]]; then
        print_error "Profile name cannot be empty"
        return 1
    fi

    # Check for reserved profile names that should not be overwritten
    local reserved_names=("default" "_internal" "_template" "_base" "_system")
    for reserved in "${reserved_names[@]}"; do
        if [[ "$name" == "$reserved" ]]; then
            print_error "Profile name '$name' is reserved and cannot be used"
            return 1
        fi
    done

    # Check for names starting with underscore (reserved convention)
    if [[ "$name" == _* ]]; then
        print_error "Profile names starting with '_' are reserved for internal use"
        return 1
    fi

    # Check for path traversal attempts
    if [[ "$name" == *".."* ]] || [[ "$name" == *"/"* ]] || [[ "$name" == *"\\"* ]]; then
        print_error "Profile name contains invalid characters (path traversal attempt detected)"
        return 1
    fi

    # M15 Fix: Whitelist pattern - only allow alphanumeric, hyphens, and underscores (not at start)
    if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        print_error "Profile name must start with a letter and contain only letters, numbers, hyphens, and underscores"
        return 1
    fi

    # M12 Fix: Check that resolved path stays within profiles directory
    # Only create test directory if it doesn't already exist (avoid race conditions)
    local resolved_path
    local created_test_dir=false
    if [[ ! -d "$PROFILES_DIR/$name" ]]; then
        if mkdir -p "$PROFILES_DIR/$name" 2>/dev/null; then
            created_test_dir=true
        else
            print_error "Failed to create test directory for profile validation"
            return 1
        fi
    fi
    resolved_path=$(cd "$PROFILES_DIR/$name" 2>/dev/null && pwd)
    if [[ "$resolved_path" != "$PROFILES_DIR/$name" ]]; then
        # Clean up only if WE created the directory
        if [[ "$created_test_dir" == true ]]; then
            rmdir "$PROFILES_DIR/$name" 2>/dev/null || true
        fi
        print_error "Profile name resolves to invalid path"
        return 1
    fi
    # Clean up only if WE created the directory for testing
    if [[ "$created_test_dir" == true ]]; then
        rmdir "$resolved_path" 2>/dev/null || true
    fi

    return 0
}

# Validate that a profile exists in the profiles directory
validate_profile_exists() {
    local profile=$1

    if [[ -z "$profile" ]]; then
        return 1
    fi

    if [[ ! -d "$PROFILES_DIR/$profile" ]]; then
        print_error "Profile '$profile' does not exist"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Profile Functions
# -----------------------------------------------------------------------------

# Get list of all available profiles in the profiles directory
# Output: Space-separated list of profile names
# Returns: 0 on success, 1 if profiles directory not found
get_available_profiles() {
    local profiles=()

    # Check if profiles directory exists
    if [[ ! -d "$PROFILES_DIR" ]]; then
        print_error "Profiles directory not found: $PROFILES_DIR"
        return 1
    fi

    # Find all directories in profiles/
    for dir in "$PROFILES_DIR"/*; do
        if [[ -d "$dir" ]]; then
            profiles+=("$(basename "$dir")")
        fi
    done

    echo "${profiles[@]}"
}

# -----------------------------------------------------------------------------
# Profile Name Input
# -----------------------------------------------------------------------------

get_profile_name() {
    local valid=false

    while [[ "$valid" == "false" ]]; do
        echo ""
        echo ""
        echo ""
        print_status "Enter a name for the new profile:"
        echo "Example names: 'rails', 'python', 'react', 'wordpress'"
        echo ""

        read -p "$(echo -e "${BLUE}Profile name: ${NC}")" profile_input

        # Normalize the name
        PROFILE_NAME=$(normalize_name "$profile_input")

        # Validate the profile name (includes path traversal check)
        if ! validate_profile_name "$PROFILE_NAME"; then
            continue
        fi

        # Check if profile already exists
        if [[ -d "$PROFILES_DIR/$PROFILE_NAME" ]]; then
            print_error "Profile '$PROFILE_NAME' already exists"
            echo "Please choose a different name"
            continue
        fi

        valid=true
        print_success "Profile name set to: $PROFILE_NAME"
    done
}

# -----------------------------------------------------------------------------
# Inheritance Selection
# -----------------------------------------------------------------------------

# Interactive selection of profile to inherit from
# Sets INHERIT_FROM global variable with selected profile name (or empty)
# User can select from available profiles or choose not to inherit
select_inheritance() {
    # M27 Fix: Use while loop instead of word splitting for safety with special chars
    local profiles=()
    while IFS= read -r profile; do
        [[ -n "$profile" ]] && profiles+=("$profile")
    done < <(get_available_profiles | tr ' ' '\n')

    if [[ ${#profiles[@]} -eq 0 ]]; then
        print_warning "No existing profiles found to inherit from"
        INHERIT_FROM=""
        return
    fi

    echo ""
    echo ""
    echo ""

    if [[ ${#profiles[@]} -eq 1 ]]; then
        # Only one profile exists
        print_status "Should this profile inherit from the '${profiles[0]}' profile?"
        echo ""
        read -p "$(echo -e "${BLUE}Inherit from '${profiles[0]}'? (y/n): ${NC}")" inherit_choice

        if [[ "$inherit_choice" == "y" ]] || [[ "$inherit_choice" == "Y" ]]; then
            INHERIT_FROM="${profiles[0]}"
            print_success "Profile will inherit from: $INHERIT_FROM"
        else
            INHERIT_FROM=""
            print_status "Profile will not inherit from any profile"
        fi
    else
        # Multiple profiles exist
        print_status "Select a profile to inherit from:"
        echo ""
        echo "  1) Don't inherit from any profile"

        local index=2
        for profile in "${profiles[@]}"; do
            echo "  $index) $profile"
            ((index++)) || true
        done

        echo ""

        # M16 Fix: Retry loop for invalid input with explicit selection reset
        local max_attempts=3
        local attempt=0
        local selection=""  # Initialize selection before loop
        while [[ $attempt -lt $max_attempts ]]; do
            selection=""  # Reset selection at start of each iteration
            read -p "$(echo -e "${BLUE}Enter selection (1-$((${#profiles[@]}+1))): ${NC}")" selection

            if [[ "$selection" == "1" ]]; then
                INHERIT_FROM=""
                print_status "Profile will not inherit from any profile"
                break
            elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 2 ]] && [[ "$selection" -le $((${#profiles[@]}+1)) ]]; then
                INHERIT_FROM="${profiles[$((selection-2))]}"
                print_success "Profile will inherit from: $INHERIT_FROM"
                break
            else
                ((attempt++)) || true
                if [[ $attempt -lt $max_attempts ]]; then
                    print_warning "Invalid selection. Please enter a number between 1 and $((${#profiles[@]}+1)). (Attempt $attempt of $max_attempts)"
                else
                    print_error "Too many invalid attempts. Exiting."
                    exit 1
                fi
            fi
        done
    fi
}

# -----------------------------------------------------------------------------
# Copy Selection
# -----------------------------------------------------------------------------

# Interactive selection of profile to copy from (alternative to inheritance)
# Sets COPY_FROM global variable with selected profile name (or empty)
# Only offered if user chose not to inherit from any profile
select_copy_source() {
    # M13 Note: Only ask about copying if not inheriting
    # This design ensures COPY_FROM and INHERIT_FROM are mutually exclusive:
    # - If user chose to inherit, skip copy selection entirely
    # - If user chose not to inherit, offer copy option
    if [[ -n "$INHERIT_FROM" ]]; then
        COPY_FROM=""
        return
    fi

    # M27 Fix: Use mapfile instead of word splitting for safety with special chars
    local profiles=()
    while IFS= read -r profile; do
        [[ -n "$profile" ]] && profiles+=("$profile")
    done < <(get_available_profiles | tr ' ' '\n')

    if [[ ${#profiles[@]} -eq 0 ]]; then
        print_warning "No existing profiles found to copy from"
        COPY_FROM=""
        return
    fi

    echo ""
    echo ""
    echo ""

    if [[ ${#profiles[@]} -eq 1 ]]; then
        # Only one profile exists
        print_status "Do you want to copy the contents from the '${profiles[0]}' profile?"
        echo ""
        read -p "$(echo -e "${BLUE}Copy from '${profiles[0]}'? (y/n): ${NC}")" copy_choice

        if [[ "$copy_choice" == "y" ]] || [[ "$copy_choice" == "Y" ]]; then
            COPY_FROM="${profiles[0]}"
            print_success "Will copy contents from: $COPY_FROM"
        else
            COPY_FROM=""
            print_status "Will create empty profile structure"
        fi
    else
        # Multiple profiles exist
        print_status "Select a profile to copy from:"
        echo ""
        echo "  1) Don't copy from any profile"

        local index=2
        for profile in "${profiles[@]}"; do
            echo "  $index) $profile"
            ((index++)) || true
        done

        echo ""

        # M16 Fix: Retry loop for invalid input with explicit selection reset
        local max_attempts=3
        local attempt=0
        local selection=""  # Initialize selection before loop
        while [[ $attempt -lt $max_attempts ]]; do
            selection=""  # Reset selection at start of each iteration
            read -p "$(echo -e "${BLUE}Enter selection (1-$((${#profiles[@]}+1))): ${NC}")" selection

            if [[ "$selection" == "1" ]]; then
                COPY_FROM=""
                print_status "Will create empty profile structure"
                break
            elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 2 ]] && [[ "$selection" -le $((${#profiles[@]}+1)) ]]; then
                COPY_FROM="${profiles[$((selection-2))]}"
                print_success "Will copy contents from: $COPY_FROM"
                break
            else
                ((attempt++)) || true
                if [[ $attempt -lt $max_attempts ]]; then
                    print_warning "Invalid selection. Please enter a number between 1 and $((${#profiles[@]}+1)). (Attempt $attempt of $max_attempts)"
                else
                    print_error "Too many invalid attempts. Exiting."
                    exit 1
                fi
            fi
        done
    fi
}

# -----------------------------------------------------------------------------
# Help Function
# -----------------------------------------------------------------------------

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Create a new Agent OS profile interactively.

Options:
    --dry-run     Preview what would be created without doing it
    --verbose     Show detailed output
    -h, --help    Show this help message

Examples:
    $0
    $0 --dry-run
    $0 --verbose

EOF
    exit 0
}

# -----------------------------------------------------------------------------
# Parse Command Line Arguments
# -----------------------------------------------------------------------------

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Profile Creation
# -----------------------------------------------------------------------------

create_profile_structure() {
    local profile_path="$PROFILES_DIR/$PROFILE_NAME"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY RUN] Would create profile structure..."
    else
        print_status "Creating profile structure..."
    fi

    if [[ -n "$COPY_FROM" ]]; then
        # M28 Fix: Validate that the source profile exists before copying
        # validate_profile_exists already prints error, so no need for additional error message
        if ! validate_profile_exists "$COPY_FROM"; then
            exit 1
        fi

        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY RUN] Would copy from profile: $COPY_FROM"
            print_status "[DRY RUN] Would create: $profile_path/"
            print_status "[DRY RUN] Would create: $profile_path/profile-config.yml"
            print_success "[DRY RUN] Profile would be copied and configured"
        else
            # Copy from existing profile
            print_status "Copying from profile: $COPY_FROM"
            cp -rp "$PROFILES_DIR/$COPY_FROM" "$profile_path"

            # M17 Note: Update profile-config.yml using heredoc
            # Atomic writes not needed for new profile creation (no existing file to corrupt)
            cat > "$profile_path/profile-config.yml" << EOF
inherits_from: false

# Profile configuration for $PROFILE_NAME
# Copied from: $COPY_FROM
EOF

            print_success "Profile copied and configured"
        fi

    else
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY RUN] Would create: $profile_path/"
            print_status "[DRY RUN] Would create: $profile_path/standards/"
            print_status "[DRY RUN] Would create: $profile_path/workflows/implementation/"
            print_status "[DRY RUN] Would create: $profile_path/workflows/planning/"
            print_status "[DRY RUN] Would create: $profile_path/workflows/specification/"
            print_status "[DRY RUN] Would create: $profile_path/profile-config.yml"
            print_success "[DRY RUN] Profile structure would be created"
        else
            # Create new structure
            mkdir -p "$profile_path"

            # Create standard directories
            mkdir -p "$profile_path/standards/"
            mkdir -p "$profile_path/workflows/implementation"
            mkdir -p "$profile_path/workflows/planning"
            mkdir -p "$profile_path/workflows/specification"

            # M17 Note: Create profile-config.yml using heredoc
            # Atomic writes not needed for new profile creation (no existing file to corrupt)
            if [[ -n "$INHERIT_FROM" ]]; then
                cat > "$profile_path/profile-config.yml" << EOF
inherits_from: $INHERIT_FROM

# Uncomment and modify to exclude specific inherited files:
# exclude_inherited_files:
#   - standards/backend/api/*
#   - standards/backend/database/migrations.md
#   - workflows/implementation/specific-workflow.md
EOF
            else
                cat > "$profile_path/profile-config.yml" << EOF
inherits_from: false

# Profile configuration for $PROFILE_NAME
EOF
            fi

            print_success "Profile structure created"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    # Parse command line arguments
    parse_arguments "$@"

    clear
    echo ""
    echo -e "${BLUE}=== Agent OS - Create Profile Utility ===${NC}"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}(DRY RUN MODE - No files will be created)${NC}"
    fi
    echo ""

    # Validate installation
    validate_installation

    # Get profile name
    get_profile_name

    # Select inheritance
    select_inheritance

    # Select copy source (if not inheriting)
    select_copy_source

    # Create the profile
    create_profile_structure

    # Success message
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""
    if [[ "$DRY_RUN" == "true" ]]; then
        print_success "[DRY RUN] Profile '$PROFILE_NAME' would be created!"
    else
        print_success "Profile '$PROFILE_NAME' has been successfully created!"
    fi
    echo ""
    print_status "Location: $PROFILES_DIR/$PROFILE_NAME"

    if [[ -n "$INHERIT_FROM" ]]; then
        echo ""
        print_status "This profile inherits from: $INHERIT_FROM"
    elif [[ -n "$COPY_FROM" ]]; then
        echo ""
        print_status "This profile was copied from: $COPY_FROM"
    fi

    echo ""
    print_status "Next steps:"
    echo "  1. Customize standards, workflows, and configurations in your profile"
    echo "  2. Install Agent OS in a project using this profile with: ~/agent-os/scripts/project-install.sh --profile $PROFILE_NAME"
    echo ""
    echo -e "${GREEN}Visit the docs on customizing your profile: https://buildermethods.com/agent-os/profiles${NC}"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""
}

# Run main function
main "$@"
