#!/bin/bash

# =============================================================================
# Agent OS Project Installation Script
# Installs Agent OS into a project's codebase
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
PROJECT_DIR="$(pwd)"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Default Values
# -----------------------------------------------------------------------------

DRY_RUN="false"
VERBOSE="false"
PROFILE=""
CLAUDE_CODE_COMMANDS=""
USE_CLAUDE_CODE_SUBAGENTS=""
AGENT_OS_COMMANDS=""
STANDARDS_AS_CLAUDE_CODE_SKILLS=""
LAZY_LOAD_WORKFLOWS=""
RE_INSTALL="false"
OVERWRITE_ALL="false"
OVERWRITE_STANDARDS="false"
OVERWRITE_COMMANDS="false"
OVERWRITE_AGENTS="false"
INSTALLED_FILES=()

# -----------------------------------------------------------------------------
# Help Function
# -----------------------------------------------------------------------------

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Install Agent OS into the current project directory.

Options:
    --profile PROFILE                        Use specified profile (default: from config.yml)
    --claude-code-commands [BOOL]            Install Claude Code commands (default: from config.yml)
    --use-claude-code-subagents [BOOL]       Use Claude Code subagents (default: from config.yml)
    --agent-os-commands [BOOL]               Install agent-os commands (default: from config.yml)
    --standards-as-claude-code-skills [BOOL] Use Claude Code Skills for standards (default: from config.yml)
    --lazy-load-workflows [BOOL]             Use file references instead of embedding workflows (default: from config.yml)
    --re-install                             Delete and reinstall Agent OS
    --overwrite-all                          Overwrite all existing files during update
    --overwrite-standards                    Overwrite existing standards during update
    --overwrite-commands                     Overwrite existing commands during update
    --overwrite-agents                       Overwrite existing agents during update
    --dry-run                                Show what would be done without doing it
    --verbose                                Show detailed output
    -h, --help                               Show this help message

Note: Flags accept both hyphens and underscores (e.g., --use-claude-code-subagents or --use_claude_code_subagents)

Examples:
    $0
    $0 --profile rails
    $0 --claude-code-commands true --use-claude-code-subagents true
    $0 --agent-os-commands true --dry-run

EOF
    exit 0
}

# -----------------------------------------------------------------------------
# Parse Command Line Arguments
# -----------------------------------------------------------------------------

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        # Normalize flag by replacing ALL underscores with hyphens (global substitution)
        local flag="${1//\_/-}"

        case $flag in
            --profile)
                PROFILE="$2"
                shift 2
                ;;
            --claude-code-commands)
                read CLAUDE_CODE_COMMANDS shift_count <<< "$(parse_bool_flag "$CLAUDE_CODE_COMMANDS" "$2")"
                shift $shift_count
                ;;
            --use-claude-code-subagents)
                read USE_CLAUDE_CODE_SUBAGENTS shift_count <<< "$(parse_bool_flag "$USE_CLAUDE_CODE_SUBAGENTS" "$2")"
                shift $shift_count
                ;;
            --agent-os-commands)
                read AGENT_OS_COMMANDS shift_count <<< "$(parse_bool_flag "$AGENT_OS_COMMANDS" "$2")"
                shift $shift_count
                ;;
            --standards-as-claude-code-skills)
                read STANDARDS_AS_CLAUDE_CODE_SKILLS shift_count <<< "$(parse_bool_flag "$STANDARDS_AS_CLAUDE_CODE_SKILLS" "$2")"
                shift $shift_count
                ;;
            --lazy-load-workflows)
                read LAZY_LOAD_WORKFLOWS shift_count <<< "$(parse_bool_flag "$LAZY_LOAD_WORKFLOWS" "$2")"
                shift $shift_count
                ;;
            --re-install)
                RE_INSTALL="true"
                shift
                ;;
            --overwrite-all)
                OVERWRITE_ALL="true"
                shift
                ;;
            --overwrite-standards)
                OVERWRITE_STANDARDS="true"
                shift
                ;;
            --overwrite-commands)
                OVERWRITE_COMMANDS="true"
                shift
                ;;
            --overwrite-agents)
                OVERWRITE_AGENTS="true"
                shift
                ;;
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
# Configuration Functions
# -----------------------------------------------------------------------------

load_configuration() {
    # Load base configuration using common function
    load_base_config

    # Set effective values (command line overrides base config)
    EFFECTIVE_PROFILE="${PROFILE:-$BASE_PROFILE}"
    EFFECTIVE_CLAUDE_CODE_COMMANDS="${CLAUDE_CODE_COMMANDS:-$BASE_CLAUDE_CODE_COMMANDS}"
    EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS="${USE_CLAUDE_CODE_SUBAGENTS:-$BASE_USE_CLAUDE_CODE_SUBAGENTS}"
    EFFECTIVE_AGENT_OS_COMMANDS="${AGENT_OS_COMMANDS:-$BASE_AGENT_OS_COMMANDS}"
    EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS="${STANDARDS_AS_CLAUDE_CODE_SKILLS:-$BASE_STANDARDS_AS_CLAUDE_CODE_SKILLS}"
    EFFECTIVE_LAZY_LOAD_WORKFLOWS="${LAZY_LOAD_WORKFLOWS:-$BASE_LAZY_LOAD_WORKFLOWS}"
    EFFECTIVE_VERSION="$BASE_VERSION"

    # Validate configuration using common function (may override EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS if dependency not met)
    validate_config "$EFFECTIVE_CLAUDE_CODE_COMMANDS" "$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS" "$EFFECTIVE_AGENT_OS_COMMANDS" "$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS" "$EFFECTIVE_PROFILE"

    print_verbose "Configuration loaded:"
    print_verbose "  Profile: $EFFECTIVE_PROFILE"
    print_verbose "  Claude Code commands: $EFFECTIVE_CLAUDE_CODE_COMMANDS"
    print_verbose "  Use Claude Code subagents: $EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS"
    print_verbose "  Agent OS commands: $EFFECTIVE_AGENT_OS_COMMANDS"
    print_verbose "  Standards as Claude Code Skills: $EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS"
    print_verbose "  Lazy load workflows: $EFFECTIVE_LAZY_LOAD_WORKFLOWS"
}

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

# Install standards files
# M4 Note: OVERWRITE_STANDARDS flag is not checked here because:
# 1. Fresh installation always writes all files (no existing files to overwrite)
# 2. Reinstallation deletes existing files first, then does fresh install
# 3. Update operations use project-update.sh which calls should_skip_file() to check overwrite flags
install_standards() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing standards"
    fi

    local standards_count=0

    while read file; do
        if [[ "$file" == standards/* ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            local dest="$PROJECT_DIR/agent-os/$file"

            if [[ -f "$source" ]]; then
                local installed_file=$(copy_file "$source" "$dest")
                if [[ -n "$installed_file" ]]; then
                    INSTALLED_FILES+=("$installed_file")
                    ((standards_count++)) || true
                fi
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "standards")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $standards_count -gt 0 ]]; then
            echo "✓ Installed $standards_count standards in agent-os/standards"
        fi
    fi
}

# Install and compile single-agent mode commands
# Install Claude Code commands with delegation (multi-agent files)
install_claude_code_commands_with_delegation() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing Claude Code commands (with delegation to subagents)..."
    fi

    local commands_count=0
    local target_dir="$PROJECT_DIR/.claude/commands/agent-os"

    if [[ "$DRY_RUN" != "true" ]]; then
        mkdir -p "$target_dir"
    fi

    while read file; do
        # Process multi-agent command files OR orchestrate-tasks special case
        if [[ "$file" == commands/*/multi-agent/* ]] || [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                # Extract command name from path (e.g., commands/create-spec/multi-agent/create-spec.md -> create-spec)
                local cmd_name=$(echo "$file" | cut -d'/' -f2)
                local dest="$target_dir/${cmd_name}.md"

                # Compile with workflow and standards injection (includes conditional compilation)
                local compiled=$(compile_command "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((commands_count++)) || true
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "commands")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $commands_count -gt 0 ]]; then
            echo "✓ Installed $commands_count Claude Code commands (with delegation)"
        fi
    fi
}

# Install Claude Code commands without delegation (single-agent files with injection)
install_claude_code_commands_without_delegation() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing Claude Code commands (without delegation)..."
    fi

    local commands_count=0

    while read file; do
        # Process single-agent command files OR orchestrate-tasks special case
        if [[ "$file" == commands/*/single-agent/* ]] || [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                # Handle orchestrate-tasks specially (flat destination)
                if [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
                    local dest="$PROJECT_DIR/.claude/commands/agent-os/orchestrate-tasks.md"
                    # Compile without PHASE embedding for orchestrate-tasks
                    local compiled=$(compile_command "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE" "")
                    if [[ "$DRY_RUN" == "true" ]]; then
                        INSTALLED_FILES+=("$dest")
                    fi
                    ((commands_count++)) || true
                else
                    # Only install non-numbered files (e.g., plan-product.md, not 1-product-concept.md)
                    local filename=$(basename "$file")
                    if [[ ! "$filename" =~ ^[0-9]+-.*\.md$ ]]; then
                        # Extract command name (e.g., commands/plan-product/single-agent/plan-product.md -> plan-product.md)
                        local cmd_name=$(echo "$file" | sed 's|commands/\([^/]*\)/single-agent/.*|\1|')
                        local dest="$PROJECT_DIR/.claude/commands/agent-os/$cmd_name.md"

                        # Compile with PHASE embedding (mode="embed")
                        local compiled=$(compile_command "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE" "embed")
                        if [[ "$DRY_RUN" == "true" ]]; then
                            INSTALLED_FILES+=("$dest")
                        fi
                        ((commands_count++)) || true
                    fi
                fi
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "commands")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $commands_count -gt 0 ]]; then
            echo "✓ Installed $commands_count Claude Code commands (without delegation)"
        fi
    fi
}

# Install Claude Code static agents
install_claude_code_agents() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing Claude Code agents..."
    fi

    local agents_count=0
    local target_dir="$PROJECT_DIR/.claude/agents/agent-os"

    if [[ "$DRY_RUN" != "true" ]]; then
        mkdir -p "$target_dir"
    fi

    while read file; do
        # Include all agent files (flatten structure - no subfolders in output)
        if [[ "$file" == agents/*.md ]] && [[ "$file" != agents/templates/* ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                # Get just the filename (flatten directory structure)
                local filename=$(basename "$file")
                local dest="$target_dir/$filename"

                # Compile with workflow and standards injection
                local compiled=$(compile_agent "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE" "")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((agents_count++)) || true
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "agents")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $agents_count -gt 0 ]]; then
            echo "✓ Installed $agents_count Claude Code agents"
        fi
    fi
}

# Install agent-os commands (single-agent files with injection)
install_agent_os_commands() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing agent-os commands..."
    fi

    local commands_count=0

    while read file; do
        # Process single-agent command files OR orchestrate-tasks special case
        if [[ "$file" == commands/*/single-agent/* ]] || [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                # Handle orchestrate-tasks specially (preserve folder structure)
                if [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
                    local dest="$PROJECT_DIR/agent-os/commands/orchestrate-tasks/orchestrate-tasks.md"
                else
                    # Extract command name and preserve numbering
                    local cmd_path=$(echo "$file" | sed 's|commands/\([^/]*\)/single-agent/\(.*\)|\1/\2|')
                    local dest="$PROJECT_DIR/agent-os/commands/$cmd_path"
                fi

                # Compile with workflow and standards injection and PHASE embedding
                local compiled=$(compile_command "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE" "embed")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((commands_count++)) || true
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "commands")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $commands_count -gt 0 ]]; then
            echo "✓ Installed $commands_count agent-os commands"
        fi
    fi
}

# Create agent-os folder structure
create_agent_os_folder() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing agent-os folder"
    fi

    # Create the main agent-os folder
    ensure_dir "$PROJECT_DIR/agent-os"

    # Create the configuration file
    local config_file=$(write_project_config "$EFFECTIVE_VERSION" "$EFFECTIVE_PROFILE" \
        "$EFFECTIVE_CLAUDE_CODE_COMMANDS" "$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS" \
        "$EFFECTIVE_AGENT_OS_COMMANDS" "$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS" \
        "$EFFECTIVE_LAZY_LOAD_WORKFLOWS")
    # Track config file consistently (in dry-run, write_project_config returns dest path)
    if [[ "$DRY_RUN" == "true" && -n "$config_file" ]]; then
        INSTALLED_FILES+=("$config_file")
    elif [[ "$DRY_RUN" != "true" ]]; then
        # In non-dry-run mode, track the expected config path for consistency
        INSTALLED_FILES+=("$PROJECT_DIR/agent-os/config.yml")
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        echo "✓ Created agent-os folder"
        echo "✓ Created agent-os project configuration"
    fi
}

# Perform fresh installation
perform_installation() {
    # Show dry run warning at the top if applicable
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN - No files will be actually created"
        echo ""
    fi

    # Display configuration at the top
    echo ""
    print_status "Configuration:"
    echo -e "  Profile: ${YELLOW}$EFFECTIVE_PROFILE${NC}"
    echo -e "  Claude Code commands: ${YELLOW}$EFFECTIVE_CLAUDE_CODE_COMMANDS${NC}"
    echo -e "  Use Claude Code subagents: ${YELLOW}$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS${NC}"
    echo -e "  Standards as Claude Code Skills: ${YELLOW}$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS${NC}"
    echo -e "  Lazy load workflows: ${YELLOW}$EFFECTIVE_LAZY_LOAD_WORKFLOWS${NC}"
    echo -e "  Agent OS commands: ${YELLOW}$EFFECTIVE_AGENT_OS_COMMANDS${NC}"
    echo ""

    # In dry run mode, just collect files silently
    if [[ "$DRY_RUN" == "true" ]]; then
        # Collect files without output
        create_agent_os_folder
        install_standards

        # Install Claude Code files if enabled
        if [[ "$EFFECTIVE_CLAUDE_CODE_COMMANDS" == "true" ]]; then
            if [[ "$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS" == "true" ]]; then
                install_claude_code_commands_with_delegation
                install_claude_code_agents
            else
                install_claude_code_commands_without_delegation
            fi
            install_claude_code_skills
            install_improve_skills_command
        fi

        # Install agent-os commands if enabled
        if [[ "$EFFECTIVE_AGENT_OS_COMMANDS" == "true" ]]; then
            install_agent_os_commands
        fi

        echo ""
        print_status "The following files would be created:"
        for file in "${INSTALLED_FILES[@]}"; do
            # Make paths relative to project root
            local relative_path="${file#$PROJECT_DIR/}"
            echo "  - $relative_path"
        done
    else
        # Normal installation with output
        create_agent_os_folder
        echo ""

        install_standards
        echo ""

        # Install Claude Code files if enabled
        if [[ "$EFFECTIVE_CLAUDE_CODE_COMMANDS" == "true" ]]; then
            if [[ "$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS" == "true" ]]; then
                install_claude_code_commands_with_delegation
                echo ""
                install_claude_code_agents
                echo ""
            else
                install_claude_code_commands_without_delegation
                echo ""
            fi
            install_claude_code_skills
            install_improve_skills_command
            echo ""
        fi

        # Install agent-os commands if enabled
        if [[ "$EFFECTIVE_AGENT_OS_COMMANDS" == "true" ]]; then
            install_agent_os_commands
            echo ""
        fi
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        # M22 Note: Files listed above are what WOULD be created - we collected paths
        # without actually creating files. The copy_file/compile_* functions return
        # destination paths even in dry-run mode for display purposes.

        # M21 Fix: Timeout handling and REPLY initialization explained:
        # - REPLY="" before read prevents "unbound variable" error with set -u
        # - read -t 60 times out after 60 seconds (for CI/CD environments)
        # - If timeout occurs, REPLY remains empty, so the [[ $REPLY =~ ^[Yy]$ ]] check fails safely
        REPLY=""
        if ! read -t 60 -p "Proceed with actual installation? (y/n): " -n 1 -r; then
            echo
            print_warning "Input timeout - defaulting to 'no'"
            return
        fi
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # M5 Fix: Reset state and perform actual installation
            # Note: We call perform_installation non-recursively since we reset DRY_RUN
            # The exit status is implicitly passed through the function return
            DRY_RUN="false"
            INSTALLED_FILES=()
            perform_installation
            # Exit status from perform_installation propagates to caller
        fi
    else
        print_success "Agent OS has been successfully installed in your project!"
        echo ""
        echo -e "${GREEN}Visit the docs for guides on how to use Agent OS: https://buildermethods.com/agent-os${NC}"
        echo ""
    fi
}

# Global variable to track backup directory for cleanup on success
# Used by cleanup_reinstall_backup and rollback_reinstall_from_backup
_REINSTALL_BACKUP_DIR=""
# S-H5 Fix: Track if reinstall completed successfully to determine cleanup action
# true=cleanup backup, false=rollback from backup
_REINSTALL_SUCCESS="false"

# Remove backup directory after successful reinstallation
# Called when reinstall completes without errors; no rollback needed
cleanup_reinstall_backup() {
    if [[ -n "$_REINSTALL_BACKUP_DIR" ]] && [[ -d "$_REINSTALL_BACKUP_DIR" ]]; then
        rm -rf "$_REINSTALL_BACKUP_DIR"
        print_verbose "Removed backup directory: $_REINSTALL_BACKUP_DIR"
    fi
}

# S-H5 Fix: Combined cleanup handler for EXIT trap
# Handles both success (cleanup) and failure/interrupt (rollback) cases
cleanup_reinstall_on_exit() {
    if [[ "$_REINSTALL_SUCCESS" == "true" ]]; then
        # Success: just remove backup
        cleanup_reinstall_backup
    elif [[ -n "$_REINSTALL_BACKUP_DIR" ]] && [[ -d "$_REINSTALL_BACKUP_DIR" ]]; then
        # Failure/interrupt: rollback and cleanup
        rollback_reinstall_from_backup
    fi
}

# Restore from backup on failure
# Called when reinstallation fails or is interrupted after backup was created
# Restores: agent-os/, .claude/agents/agent-os/, .claude/commands/agent-os/, skills
rollback_reinstall_from_backup() {
    if [[ -n "$_REINSTALL_BACKUP_DIR" ]] && [[ -d "$_REINSTALL_BACKUP_DIR" ]]; then
        print_warning "Re-installation failed! Rolling back from backup..."

        # H3 Fix: Track restore failures and notify user
        local restore_failed=false
        local restored_count=0
        local failed_items=""

        # Restore backed up directories with error tracking
        if [[ -d "$_REINSTALL_BACKUP_DIR/agent-os" ]]; then
            if cp -rp "$_REINSTALL_BACKUP_DIR/agent-os" "$PROJECT_DIR/" 2>/dev/null; then
                ((restored_count++))
            else
                restore_failed=true
                failed_items="${failed_items}agent-os, "
            fi
        fi
        if [[ -d "$_REINSTALL_BACKUP_DIR/.claude/agents/agent-os" ]]; then
            mkdir -p "$PROJECT_DIR/.claude/agents"
            if cp -rp "$_REINSTALL_BACKUP_DIR/.claude/agents/agent-os" "$PROJECT_DIR/.claude/agents/" 2>/dev/null; then
                ((restored_count++))
            else
                restore_failed=true
                failed_items="${failed_items}.claude/agents/agent-os, "
            fi
        fi
        if [[ -d "$_REINSTALL_BACKUP_DIR/.claude/commands/agent-os" ]]; then
            mkdir -p "$PROJECT_DIR/.claude/commands"
            if cp -rp "$_REINSTALL_BACKUP_DIR/.claude/commands/agent-os" "$PROJECT_DIR/.claude/commands/" 2>/dev/null; then
                ((restored_count++))
            else
                restore_failed=true
                failed_items="${failed_items}.claude/commands/agent-os, "
            fi
        fi
        if [[ -d "$_REINSTALL_BACKUP_DIR/.claude/skills" ]]; then
            mkdir -p "$PROJECT_DIR/.claude/skills"
            # Only restore Agent OS skills
            for skill_dir in "$_REINSTALL_BACKUP_DIR/.claude/skills"/*; do
                if [[ -d "$skill_dir" ]]; then
                    if cp -rp "$skill_dir" "$PROJECT_DIR/.claude/skills/" 2>/dev/null; then
                        ((restored_count++))
                    else
                        restore_failed=true
                        failed_items="${failed_items}$(basename "$skill_dir"), "
                    fi
                fi
            done
        fi

        # Notify user of restore status
        if [[ "$restore_failed" == true ]]; then
            print_error "PARTIAL RESTORE: Some items could not be restored: ${failed_items%, }"
            print_error "Backup preserved at: $_REINSTALL_BACKUP_DIR"
            print_error "You may need to manually restore from backup"
        else
            rm -rf "$_REINSTALL_BACKUP_DIR"
            print_error "Rollback complete. Previous installation restored ($restored_count items)."
        fi
    fi
}

# Handle re-installation
handle_reinstallation() {
    print_section "Re-installation"

    print_warning "This will DELETE your current agent-os/ folder and reinstall from scratch."
    echo ""

    # Check for Claude Code files
    if [[ -d "$PROJECT_DIR/.claude/agents/agent-os" ]] || [[ -d "$PROJECT_DIR/.claude/commands/agent-os" ]] || [[ -d "$PROJECT_DIR/.claude/skills" ]]; then
        print_warning "This will also DELETE:"
        [[ -d "$PROJECT_DIR/.claude/agents/agent-os" ]] && echo "  - .claude/agents/agent-os/"
        [[ -d "$PROJECT_DIR/.claude/commands/agent-os" ]] && echo "  - .claude/commands/agent-os/"
        [[ -d "$PROJECT_DIR/.claude/skills" ]] && echo "  - .claude/skills/ (Agent OS skills)"
        echo ""
    fi

    # Timeout after 60 seconds to prevent hanging in CI/CD environments
    # Initialize REPLY to avoid unbound variable error with set -u if read times out
    REPLY=""
    if ! read -t 60 -p "Are you sure you want to proceed? (y/n): " -n 1 -r; then
        echo
        print_warning "Input timeout - re-installation cancelled"
        exit 0
    fi
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Re-installation cancelled"
        exit 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Create backup for rollback capability using mktemp for uniqueness
        # This prevents race conditions when multiple reinstalls run simultaneously
        _REINSTALL_BACKUP_DIR=$(mktemp -d "$PROJECT_DIR/.agent-os-reinstall-backup.XXXXXX") || {
            print_error "Failed to create backup directory"
            exit 1
        }
        # S-H5 Fix: Set up EXIT trap for cleanup on both success and failure/interrupt
        # This replaces ERR trap for more comprehensive handling
        trap 'cleanup_reinstall_on_exit' EXIT
        print_verbose "Created backup directory: $_REINSTALL_BACKUP_DIR"

        # Backup existing directories before deletion
        if [[ -d "$PROJECT_DIR/agent-os" ]]; then
            cp -rp "$PROJECT_DIR/agent-os" "$_REINSTALL_BACKUP_DIR/" 2>/dev/null || true
        fi
        if [[ -d "$PROJECT_DIR/.claude/agents/agent-os" ]]; then
            mkdir -p "$_REINSTALL_BACKUP_DIR/.claude/agents"
            cp -rp "$PROJECT_DIR/.claude/agents/agent-os" "$_REINSTALL_BACKUP_DIR/.claude/agents/" 2>/dev/null || true
        fi
        if [[ -d "$PROJECT_DIR/.claude/commands/agent-os" ]]; then
            mkdir -p "$_REINSTALL_BACKUP_DIR/.claude/commands"
            cp -rp "$PROJECT_DIR/.claude/commands/agent-os" "$_REINSTALL_BACKUP_DIR/.claude/commands/" 2>/dev/null || true
        fi

        # Backup Agent OS skills
        if [[ -d "$PROJECT_DIR/.claude/skills" ]]; then
            # Get list of skills that belong to Agent OS (from standards)
            if [[ -f "$PROJECT_DIR/agent-os/config.yml" ]]; then
                local project_profile
                project_profile=$(get_yaml_value "$PROJECT_DIR/agent-os/config.yml" "profile" "default")
                mkdir -p "$_REINSTALL_BACKUP_DIR/.claude/skills"
                while read file; do
                    if [[ "$file" == standards/* ]] && [[ "$file" == *.md ]]; then
                        local skill_name=$(echo "$file" | sed 's|^standards/||' | sed 's|\.md$||' | sed 's|/|-|g')
                        if [[ -d "$PROJECT_DIR/.claude/skills/$skill_name" ]]; then
                            cp -rp "$PROJECT_DIR/.claude/skills/$skill_name" "$_REINSTALL_BACKUP_DIR/.claude/skills/" 2>/dev/null || true
                        fi
                    fi
                done < <(get_profile_files "$project_profile" "$BASE_DIR" "standards")
            fi
        fi

        print_verbose "Backup created at: $_REINSTALL_BACKUP_DIR"

        # AOS-0004 Fix: Verify backup contains expected directories before deletion
        local backup_valid=true
        if [[ -d "$PROJECT_DIR/agent-os" ]] && [[ ! -d "$_REINSTALL_BACKUP_DIR/agent-os" ]]; then
            print_warning "Backup verification failed: agent-os directory not in backup"
            backup_valid=false
        fi
        if [[ -d "$PROJECT_DIR/.claude/agents/agent-os" ]] && [[ ! -d "$_REINSTALL_BACKUP_DIR/.claude/agents/agent-os" ]]; then
            print_warning "Backup verification failed: .claude/agents/agent-os not in backup"
            backup_valid=false
        fi
        if [[ -d "$PROJECT_DIR/.claude/commands/agent-os" ]] && [[ ! -d "$_REINSTALL_BACKUP_DIR/.claude/commands/agent-os" ]]; then
            print_warning "Backup verification failed: .claude/commands/agent-os not in backup"
            backup_valid=false
        fi

        if [[ "$backup_valid" != "true" ]]; then
            print_error "Backup verification failed - aborting reinstall to prevent data loss"
            print_error "Backup location: $_REINSTALL_BACKUP_DIR"
            rm -rf "$_REINSTALL_BACKUP_DIR"
            exit 1
        fi
        print_verbose "Backup verification passed"

        print_status "Removing existing installation..."
        rm -rf "$PROJECT_DIR/agent-os"
        rm -rf "$PROJECT_DIR/.claude/agents/agent-os"
        rm -rf "$PROJECT_DIR/.claude/commands/agent-os"

        # Remove Agent OS skills (individual skill directories)
        if [[ -d "$PROJECT_DIR/.claude/skills" ]] && [[ -f "$_REINSTALL_BACKUP_DIR/agent-os/config.yml" ]]; then
            local project_profile
            project_profile=$(get_yaml_value "$_REINSTALL_BACKUP_DIR/agent-os/config.yml" "profile" "default")
            while read file; do
                if [[ "$file" == standards/* ]] && [[ "$file" == *.md ]]; then
                    local skill_name=$(echo "$file" | sed 's|^standards/||' | sed 's|\.md$||' | sed 's|/|-|g')
                    if [[ -d "$PROJECT_DIR/.claude/skills/$skill_name" ]]; then
                        rm -rf "$PROJECT_DIR/.claude/skills/$skill_name"
                    fi
                fi
            done < <(get_profile_files "$project_profile" "$BASE_DIR" "standards")
        fi

        echo "✓ Existing installation removed"
        echo ""
    fi

    perform_installation

    # S-H5 Fix: Mark reinstallation successful - EXIT trap will handle cleanup
    if [[ "$DRY_RUN" != "true" ]]; then
        _REINSTALL_SUCCESS="true"
        # Note: cleanup_reinstall_on_exit will be called by EXIT trap
    fi
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    print_section "Agent OS Project Installation"

    # Parse command line arguments
    parse_arguments "$@"

    # Check if we're trying to install in the base installation directory
    check_not_base_installation

    # Validate base installation using common function
    validate_base_installation

    # Run pre-flight checks (disk space, permissions, required tools)
    preflight_check

    # Load configuration
    load_configuration

    # Check if Agent OS is already installed
    if is_agent_os_installed "$PROJECT_DIR"; then
        if [[ "$RE_INSTALL" == "true" ]]; then
            handle_reinstallation
        else
            # Delegate to update script
            print_status "Agent OS is already installed. Running update..."
            local update_script="$BASE_DIR/scripts/project-update.sh"
            if [[ ! -f "$update_script" ]]; then
                print_error "Update script not found: $update_script"
                exit 1
            fi
            exec "$update_script" "$@"
        fi
    else
        # Fresh installation
        perform_installation
    fi
}

# Run main function
main "$@"
