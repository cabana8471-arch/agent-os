#!/bin/bash

# =============================================================================
# Agent OS Common Functions
# Shared utilities for Agent OS scripts
# =============================================================================

# Colors for output (only enable if terminal supports colors)
if [[ -t 1 ]] && [[ -n "${TERM:-}" ]] && [[ "${TERM}" != "dumb" ]]; then
    RED='\033[38;2;255;32;86m'
    GREEN='\033[38;2;0;234;179m'
    YELLOW='\033[38;2;255;185;0m'
    BLUE='\033[38;2;0;208;255m'
    PURPLE='\033[38;2;142;81;255m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    NC=''
fi

# -----------------------------------------------------------------------------
# Global Variables (set by scripts that source this file)
# -----------------------------------------------------------------------------
# These should be set by the calling script:
# BASE_DIR, PROJECT_DIR, DRY_RUN, VERBOSE

# -----------------------------------------------------------------------------
# Temporary File Tracking and Cleanup
# -----------------------------------------------------------------------------
# This module manages temporary files created during script execution.
# All temp files are automatically cleaned up on script exit (EXIT, INT, TERM).
# Usage: Call create_temp_file() to get a tracked temp file path.
#        Call remove_temp_file() to manually remove before exit.
# Array to track temporary files for cleanup (internal use only)
declare -a _AGENT_OS_TEMP_FILES=()

# Cleanup function to remove all tracked temporary files
_agent_os_cleanup() {
    if [[ ${#_AGENT_OS_TEMP_FILES[@]} -gt 0 ]]; then
        for temp_file in "${_AGENT_OS_TEMP_FILES[@]}"; do
            rm -f "$temp_file" 2>/dev/null || true
        done
    fi
    _AGENT_OS_TEMP_FILES=()
}

# Register cleanup trap (will be called on EXIT, INT, TERM)
trap _agent_os_cleanup EXIT INT TERM

# Create a tracked temporary file
# Usage: local temp=$(create_temp_file)
# Note: There's a theoretical race condition between mktemp and array add where
# an interrupt could leave an orphan temp file. In practice, the OS will clean
# /tmp on reboot, and temp files are small. This is an acceptable trade-off
# for code simplicity versus adding complex signal blocking.
create_temp_file() {
    local temp_file
    temp_file=$(mktemp) || {
        print_error "Failed to create temporary file"
        return 1
    }
    _AGENT_OS_TEMP_FILES+=("$temp_file")
    echo "$temp_file"
}

# Remove a specific temporary file from tracking and delete it
# Usage: remove_temp_file "$temp_file"
remove_temp_file() {
    local file_to_remove=$1
    rm -f "$file_to_remove" 2>/dev/null || true
    # Remove from tracking array (only if array has elements)
    if [[ ${#_AGENT_OS_TEMP_FILES[@]} -gt 0 ]]; then
        local new_array=()
        for temp_file in "${_AGENT_OS_TEMP_FILES[@]}"; do
            if [[ "$temp_file" != "$file_to_remove" ]]; then
                new_array+=("$temp_file")
            fi
        done
        if [[ ${#new_array[@]} -gt 0 ]]; then
            _AGENT_OS_TEMP_FILES=("${new_array[@]}")
        else
            _AGENT_OS_TEMP_FILES=()
        fi
    fi
}

# -----------------------------------------------------------------------------
# Output Functions
# -----------------------------------------------------------------------------
# Note: These functions use echo -e for ANSI color escape sequences.
# This is bash-specific; for POSIX sh compatibility, use printf instead.
# Agent OS requires bash 4.0+, so echo -e is safe here.

# Print colored output
# Usage: print_color "$COLOR" "message text"
# Note: Uses $* to join all arguments as a single string for proper color wrapping
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Print section header
print_section() {
    echo ""
    print_color "$BLUE" "=== $1 ==="
    echo ""
}

# Print status message
print_status() {
    print_color "$BLUE" "$1"
}

# Print success message
print_success() {
    print_color "$GREEN" "✓ $1"
}

# Print warning message
print_warning() {
    print_color "$YELLOW" "⚠️  $1"
}

# Print error message
print_error() {
    print_color "$RED" "✗ $1"
}

# Print verbose message (only in verbose mode)
# Uses default pattern to handle potentially unset VERBOSE variable
print_verbose() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[VERBOSE] $1" >&2
    fi
}

# -----------------------------------------------------------------------------
# String Normalization Functions
# -----------------------------------------------------------------------------

# Normalize input to lowercase, replace spaces/underscores with hyphens, remove punctuation
# Usage: local name=$(normalize_name "My Profile Name")
# Returns: "my-profile-name"
# Note: Only alphanumeric characters and hyphens are preserved in output.
#       Empty input returns empty string.
normalize_name() {
    local input=$1
    echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[ _]/-/g' | sed 's/[^a-z0-9-]//g'
}

# -----------------------------------------------------------------------------
# Improved YAML Parsing Functions (More Robust)
# -----------------------------------------------------------------------------
# Limitations:
# - Only supports simple key: value and key: [array] formats
# - Nested structures (indented blocks) are not fully parsed
# - Multi-line strings (| or >) are not supported
# - Anchors (&) and aliases (*) are not supported
# - Use jq or yq for complex YAML processing

# Normalize YAML line (handle tabs, trim spaces, etc.)
# Converts tabs to 4 spaces and removes trailing whitespace
normalize_yaml_line() {
    echo "$1" | sed 's/\t/    /g' | sed 's/[[:space:]]*$//'
}

# Get indentation level (counts spaces/tabs at beginning)
# Usage: local indent=$(get_indent_level "    key: value")
# Returns: number of leading spaces (tabs converted to 4 spaces)
# Note: Empty lines return 0
get_indent_level() {
    local line="$1"
    local normalized=$(echo "$line" | sed 's/\t/    /g')
    local spaces=$(echo "$normalized" | sed 's/[^ ].*//')
    echo "${#spaces}"
}

# Get a simple value from YAML (handles key: value format)
# More robust: handles quotes, different spacing, tabs, inline comments
# Args: $1=file path, $2=key name, $3=default value
# Returns: the value or default if not found
get_yaml_value() {
    local file=$1
    local key=$2
    local default=$3

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    # Escape special regex characters in key for safe pattern matching
    local escaped_key
    escaped_key=$(printf '%s' "$key" | sed -e 's/[.[\*^$()+?{|\\]/\\&/g')

    # Look for the key with flexible spacing and handle quotes
    local value
    value=$(awk -v key="$escaped_key" '
        BEGIN { found=0 }
        {
            # Normalize tabs to spaces
            gsub(/\t/, "    ")
            # Remove leading/trailing spaces
            gsub(/^[[:space:]]+/, "")
            gsub(/[[:space:]]+$/, "")
        }
        # Match key: value (with or without spaces around colon)
        $0 ~ "^" key "[[:space:]]*:" {
            # Extract value after colon
            sub("^" key "[[:space:]]*:[[:space:]]*", "")

            # Remove inline comments (but not if inside quotes)
            # Simple approach: if value starts with quote, find matching quote first
            if (/^["'"'"']/) {
                # Quoted value - find the closing quote
                quote = substr($0, 1, 1)
                # Find closing quote (not escaped)
                if (match($0, quote ".*" quote)) {
                    # Extract just the quoted portion
                    $0 = substr($0, 1, RLENGTH)
                }
            } else {
                # Unquoted value - remove comment
                sub(/[[:space:]]+#.*$/, "")
            }

            # Remove quotes (single or double) if present
            gsub(/^["'"'"']/, "")
            gsub(/["'"'"']$/, "")

            # Print value (even if empty - caller handles empty)
            print $0
            found=1
            exit
        }
        END { if (!found) exit 1 }
    ' "$file" 2>/dev/null)

    if [[ $? -eq 0 && -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Get array values from YAML (handles - item format under a key)
# More robust: handles variable indentation
get_yaml_array() {
    local file=$1
    local key=$2

    if [[ ! -f "$file" ]]; then
        return
    fi

    awk -v key="$key" '
        BEGIN {
            found=0
            key_indent=-1
            array_indent=-1
        }
        {
            # Normalize tabs to spaces
            gsub(/\t/, "    ")

            # S-M7 Note: Get current line indentation
            # match() returns position of first non-space (1-indexed) or 0 if all spaces
            # Edge case: if line is all spaces, treat as max indent (length + 1)
            # Subtract 1 to convert to 0-indexed indent count
            indent = match($0, /[^ ]/)
            if (indent == 0) indent = length($0) + 1
            indent = indent - 1

            # Store original line for processing
            line = $0
            # Remove leading spaces for pattern matching
            gsub(/^[[:space:]]+/, "")
        }

        # Found the key
        !found && $0 ~ "^" key "[[:space:]]*:" {
            found = 1
            key_indent = indent
            next
        }

        # Process array items under the key
        found {
            # If we hit a line with same or less indentation as key, stop
            if (indent <= key_indent && $0 != "" && $0 !~ /^[[:space:]]*$/) {
                exit
            }

            # Look for array items (- item)
            if ($0 ~ /^-[[:space:]]/) {
                # Set array indent from first item
                if (array_indent == -1) {
                    array_indent = indent
                }

                # Only process items at the expected indentation
                if (indent == array_indent) {
                    sub(/^-[[:space:]]*/, "")
                    # Remove quotes if present
                    gsub(/^["'\'']/, "")
                    gsub(/["'\'']$/, "")
                    print
                }
            }
        }
    ' "$file"
}

# -----------------------------------------------------------------------------
# File Operations Functions
# -----------------------------------------------------------------------------

# Create directory if it doesn't exist (unless in dry-run mode)
# Returns: 0 on success (or dry-run), 1 on failure
# Note: Uses DRY_RUN default to handle potentially unset variable
ensure_dir() {
    local dir=$1

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        if [[ ! -d "$dir" ]]; then
            print_verbose "Would create directory: $dir"
        fi
        return 0
    else
        if [[ ! -d "$dir" ]]; then
            if ! mkdir -p "$dir"; then
                print_error "Failed to create directory: $dir"
                return 1
            fi
            print_verbose "Created directory: $dir"
        fi
        return 0
    fi
}

# Copy file with dry-run support
# Preserves file permissions and verifies source exists
# Args: $1=source file, $2=destination file
# Output: Prints destination path to stdout on success
# Returns: 0 on success, 1 on failure
# S-M9 Note: This function uses a hybrid pattern - it both returns exit codes AND prints
# the destination path. Callers should use: result=$(copy_file src dst) && [[ -n "$result" ]]
# or: if copy_file src dst >/dev/null; then ... fi
copy_file() {
    local source=$1
    local dest=$2

    # Verify source file exists
    if [[ ! -f "$source" ]]; then
        print_error "Source file not found: $source"
        return 1
    fi

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo "$dest"
    else
        local dest_dir
        dest_dir="$(dirname "$dest")"

        # Ensure directory exists
        if ! ensure_dir "$dest_dir"; then
            print_error "Failed to create directory: $dest_dir"
            return 1
        fi

        # Verify directory is writable before attempting copy
        if [[ ! -w "$dest_dir" ]]; then
            print_error "Destination directory is not writable: $dest_dir"
            return 1
        fi

        # Use -p to preserve permissions (mode, ownership, timestamps)
        if ! cp -p "$source" "$dest"; then
            print_error "Failed to copy: $source -> $dest"
            return 1
        fi
        print_verbose "Copied: $source -> $dest"
        echo "$dest"
    fi
}

# Write content to file with dry-run support
# Uses atomic write pattern (temp file + mv) to prevent corruption
# Args: $1=content, $2=destination file
# Returns: 0 on success, 1 on failure
# Note: Uses DRY_RUN default to handle potentially unset variable
write_file() {
    local content=$1
    local dest=$2

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo "$dest"
        return 0
    fi

    # Ensure directory exists - fail explicitly if cannot create
    local dest_dir_path
    dest_dir_path="$(dirname "$dest")"
    if ! ensure_dir "$dest_dir_path"; then
        print_error "Failed to create directory: $dest_dir_path"
        return 1
    fi

    # Verify directory actually exists and is writable
    if [[ ! -d "$dest_dir_path" ]]; then
        print_error "Directory does not exist after creation attempt: $dest_dir_path"
        return 1
    fi

    if [[ ! -w "$dest_dir_path" ]]; then
        print_error "Directory is not writable: $dest_dir_path"
        return 1
    fi

    # Create temp file in the same directory as destination for atomic mv
    # M2 Fix: Reuse dest_dir_path instead of duplicate dirname call
    # S-H2 Note: Race condition exists between mktemp and array add where an interrupt
    # could leave orphan temp file. This is acceptable as: (1) OS cleans /tmp on reboot,
    # (2) temp files are small, (3) complex signal blocking would add fragility.
    local temp_file
    temp_file=$(mktemp "${dest_dir_path}/.tmp.XXXXXX") || {
        print_error "Failed to create temporary file for: $dest"
        return 1
    }
    # H1 Fix: Track temp file for cleanup in case of interruption
    _AGENT_OS_TEMP_FILES+=("$temp_file")

    # Write content to temp file
    if ! printf '%s\n' "$content" > "$temp_file"; then
        rm -f "$temp_file" 2>/dev/null
        print_error "Failed to write content to temporary file"
        return 1
    fi

    # Atomic move to destination
    if ! mv "$temp_file" "$dest"; then
        rm -f "$temp_file" 2>/dev/null
        print_error "Failed to move temporary file to: $dest"
        return 1
    fi
    # H1 Fix: Remove from tracking array after successful move
    remove_temp_file "$temp_file"

    print_verbose "Wrote file: $dest"
    return 0
}

# Check if file should be skipped during update
# Args: $1=file path, $2=overwrite_all flag, $3=overwrite_type flag, $4=file type
# Returns: 0 if file should be skipped, 1 if file should be updated
# Note: Return value is inverted from typical convention (0=skip, 1=don't skip)
#       for use in if statements: if should_skip_file ...; then skip; fi
should_skip_file() {
    local file=$1
    local overwrite_all=$2
    local overwrite_type=$3
    local file_type=$4

    if [[ "$overwrite_all" == "true" ]]; then
        return 1  # Don't skip
    fi

    if [[ ! -f "$file" ]]; then
        return 1  # Don't skip - file doesn't exist
    fi

    # Check specific overwrite flags
    case "$file_type" in
        "agent")
            [[ "$overwrite_type" == "true" ]] && return 1
            ;;
        "command")
            [[ "$overwrite_type" == "true" ]] && return 1
            ;;
        "standard")
            [[ "$overwrite_type" == "true" ]] && return 1
            ;;
    esac

    return 0  # Skip file
}

# -----------------------------------------------------------------------------
# Profile Functions
# -----------------------------------------------------------------------------

# Error codes for get_profile_file
readonly PROFILE_FILE_OK=0
readonly PROFILE_FILE_NOT_FOUND=1
readonly PROFILE_FILE_EXCLUDED=2
readonly PROFILE_FILE_CIRCULAR_REF=3
readonly PROFILE_FILE_TOO_DEEP=4

# Maximum depth for profile inheritance chain
readonly MAX_PROFILE_INHERITANCE_DEPTH=10

# Get the effective profile path considering inheritance
# Args: $1=profile name, $2=file path (relative to profile), $3=base directory
# Output: file path on stdout (empty string on non-OK returns)
# Returns:
#   0 (PROFILE_FILE_OK) - file found, path printed to stdout
#   1 (PROFILE_FILE_NOT_FOUND) - file not found in any profile
#   2 (PROFILE_FILE_EXCLUDED) - file was excluded via exclude_inherited_files
#   3 (PROFILE_FILE_CIRCULAR_REF) - circular inheritance detected
#   4 (PROFILE_FILE_TOO_DEEP) - inheritance chain too deep
# Note: Callers should check return code OR use [[ -f "$result" ]] to verify success
get_profile_file() {
    local profile=$1
    local file_path=$2
    local base_dir=$3

    local current_profile=$profile
    local visited_profiles=""
    local depth=0

    while true; do
        # M20 Fix: Increment depth BEFORE check for clearer semantics
        # This ensures depth=1 at first iteration, matching human expectation of "level 1"
        ((depth++)) || true

        # Check for inheritance depth limit
        if [[ $depth -gt $MAX_PROFILE_INHERITANCE_DEPTH ]]; then
            print_error "Profile inheritance chain too deep (max $MAX_PROFILE_INHERITANCE_DEPTH levels)"
            print_error "This may indicate a configuration problem. Check profile-config.yml files."
            return $PROFILE_FILE_TOO_DEEP
        fi

        # Check for circular inheritance
        # S-L1 Note: Space-delimited string pattern safe here - profile names validated
        # by create-profile.sh to not contain spaces ([a-zA-Z][a-zA-Z0-9_-]*)
        if [[ " $visited_profiles " == *" $current_profile "* ]]; then
            print_warning "Circular inheritance detected at profile: $current_profile"
            return $PROFILE_FILE_CIRCULAR_REF
        fi
        visited_profiles="$visited_profiles $current_profile"

        local profile_dir="$base_dir/profiles/$current_profile"
        local full_path="$profile_dir/$file_path"

        # Check for profile config first (needed for exclusion check)
        local profile_config="$profile_dir/profile-config.yml"

        # Check if file exists in current profile
        # NOTE: Local files are ALWAYS used regardless of exclude_inherited_files
        # The exclusion list only applies to files inherited from parent profiles
        if [[ -f "$full_path" ]]; then
            echo "$full_path"
            return $PROFILE_FILE_OK
        fi

        # Check for inheritance
        if [[ ! -f "$profile_config" ]]; then
            # No profile config means this is likely the default profile
            echo ""
            return $PROFILE_FILE_NOT_FOUND
        fi

        local inherits_from=$(get_yaml_value "$profile_config" "inherits_from" "default")

        if [[ "$inherits_from" == "false" || -z "$inherits_from" ]]; then
            echo ""
            return $PROFILE_FILE_NOT_FOUND
        fi

        # Check if file is excluded during inheritance
        local excluded="false"
        while read pattern; do
            if [[ -n "$pattern" ]] && match_pattern "$file_path" "$pattern"; then
                excluded="true"
                break
            fi
        done < <(get_yaml_array "$profile_config" "exclude_inherited_files")

        if [[ "$excluded" == "true" ]]; then
            echo ""
            return $PROFILE_FILE_EXCLUDED
        fi

        current_profile=$inherits_from
    done
}

# Get all files from profile considering inheritance
get_profile_files() {
    local profile=$1
    local base_dir=$2
    local subdir=$3

    local current_profile=$profile
    # S-H3 Note: visited_profiles uses space-delimited string; safe because profile names
    # are validated to not contain spaces (validate_profile_name uses [a-zA-Z][a-zA-Z0-9_-]*)
    local visited_profiles=""
    # S-H3 Fix: Use associative array for all_files to handle paths with spaces
    declare -A seen_files
    local excluded_patterns=""

    # First, collect exclusion patterns and file overrides
    while true; do
        if [[ " $visited_profiles " == *" $current_profile "* ]]; then
            break
        fi
        visited_profiles="$visited_profiles $current_profile"

        local profile_dir="$base_dir/profiles/$current_profile"
        local profile_config="$profile_dir/profile-config.yml"

        # Add exclusion patterns from this profile
        if [[ -f "$profile_config" ]]; then
            local patterns=$(get_yaml_array "$profile_config" "exclude_inherited_files")
            # M5 Fix: Only append if patterns is non-empty, and handle first append without leading newline
            if [[ -n "$patterns" ]]; then
                if [[ -z "$excluded_patterns" ]]; then
                    excluded_patterns="$patterns"
                else
                    excluded_patterns="$excluded_patterns"$'\n'"$patterns"
                fi
            fi

            local inherits_from=$(get_yaml_value "$profile_config" "inherits_from" "default")
            if [[ "$inherits_from" == "false" || -z "$inherits_from" ]]; then
                break
            fi
            current_profile=$inherits_from
        else
            break
        fi
    done

    # Now collect files starting from the base profile
    local profiles_to_process=""
    current_profile=$profile
    visited_profiles=""

    while true; do
        if [[ " $visited_profiles " == *" $current_profile "* ]]; then
            break
        fi
        visited_profiles="$visited_profiles $current_profile"
        profiles_to_process="$current_profile $profiles_to_process"

        local profile_dir="$base_dir/profiles/$current_profile"
        local profile_config="$profile_dir/profile-config.yml"

        if [[ -f "$profile_config" ]]; then
            local inherits_from=$(get_yaml_value "$profile_config" "inherits_from" "default")
            if [[ "$inherits_from" == "false" || -z "$inherits_from" ]]; then
                break
            fi
            current_profile=$inherits_from
        else
            break
        fi
    done

    # Process profiles from base to specific
    # Using process substitution to avoid subshell variable scope issues
    for proc_profile in $profiles_to_process; do
        local profile_dir="$base_dir/profiles/$proc_profile"
        local search_dir="$profile_dir"

        if [[ -n "$subdir" ]]; then
            search_dir="$profile_dir/$subdir"
        fi

        if [[ -d "$search_dir" ]]; then
            # Use process substitution instead of pipe to preserve variable scope
            while IFS= read -r file; do
                local relative_path="${file#$profile_dir/}"

                # Check if excluded (skip loop if no patterns to check)
                local excluded="false"
                if [[ -n "$excluded_patterns" ]]; then
                    while IFS= read -r pattern; do
                        if [[ -n "$pattern" ]] && match_pattern "$relative_path" "$pattern"; then
                            excluded="true"
                            break
                        fi
                    done <<< "$excluded_patterns"
                fi

                if [[ "$excluded" != "true" ]]; then
                    # S-H3 Fix: Check if already seen using associative array (handles paths with spaces)
                    if [[ -z "${seen_files[$relative_path]:-}" ]]; then
                        seen_files["$relative_path"]=1
                        # Output file path; ignore echo failures (extremely rare)
                        echo "$relative_path" || true
                    fi
                fi
            # S-M11 Note: Suppress find stderr to ignore permission errors on unreadable dirs.
            # This is intentional as profile dirs may have mixed permissions.
            done < <(find "$search_dir" -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) 2>/dev/null)
        fi
    done | sort -u
}

# Match file path against pattern (supports wildcards)
# Supports: * (matches anything except /), ** (matches anything including /)
# Args: $1=path to match, $2=glob pattern
# Returns: 0 if matches, 1 if not
# S-M8 Note: Escaping chain order matters to avoid double-escaping:
#   1. Escape regex metacharacters (. ^ $ [ ] ( ) { } | +)
#   2. Convert ? to . (single char match)
#   3. Convert ** to placeholder, then * to [^/]*, then placeholder to .*
# This ensures patterns like "*.md" work correctly
# AOS-0030 Fix: Added input validation for empty arguments
match_pattern() {
    local path=$1
    local pattern=$2

    # AOS-0030 Fix: Handle empty arguments gracefully
    # Empty path never matches any pattern
    if [[ -z "$path" ]]; then
        return 1
    fi
    # Empty pattern never matches anything
    if [[ -z "$pattern" ]]; then
        return 1
    fi

    # Escape special regex characters except * and ?
    # Order matters: escape backslash first, then other metacharacters
    local regex="$pattern"

    # Escape regex metacharacters (except *)
    regex=$(printf '%s' "$regex" | sed -e 's/\./\\./g' \
                                       -e 's/\^/\\^/g' \
                                       -e 's/\$/\\$/g' \
                                       -e 's/\[/\\[/g' \
                                       -e 's/\]/\\]/g' \
                                       -e 's/(/\\(/g' \
                                       -e 's/)/\\)/g' \
                                       -e 's/{/\\{/g' \
                                       -e 's/}/\\}/g' \
                                       -e 's/|/\\|/g' \
                                       -e 's/+/\\+/g' \
                                       -e 's/?/./g')

    # Convert ** to a placeholder, then * to [^/]*, then placeholder to .*
    # This ensures ** matches path separators while * does not
    regex=$(printf '%s' "$regex" | sed -e 's/\*\*/__DOUBLE_STAR__/g' \
                                       -e 's/\*/[^\/]*/g' \
                                       -e 's/__DOUBLE_STAR__/.*/g')

    if [[ "$path" =~ ^${regex}$ ]]; then
        return 0
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Template Processing Functions
# -----------------------------------------------------------------------------

# Replace Playwright tool with expanded tool list
# M3 Note: Uses Bash native string replacement (${var//pattern/replacement}) which is safe for
# special characters in the replacement string. The playwright_tools list contains only known-safe
# characters (letters, numbers, underscores, commas, spaces). This avoids sed/regex escaping issues.
replace_playwright_tools() {
    local tools=$1

    local playwright_tools="mcp__playwright__browser_close, mcp__playwright__browser_console_messages, mcp__playwright__browser_handle_dialog, mcp__playwright__browser_evaluate, mcp__playwright__browser_file_upload, mcp__playwright__browser_fill_form, mcp__playwright__browser_install, mcp__playwright__browser_press_key, mcp__playwright__browser_type, mcp__playwright__browser_navigate, mcp__playwright__browser_navigate_back, mcp__playwright__browser_network_requests, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, mcp__playwright__browser_drag, mcp__playwright__browser_hover, mcp__playwright__browser_select_option, mcp__playwright__browser_tabs, mcp__playwright__browser_wait_for, mcp__ide__getDiagnostics, mcp__ide__executeCode, mcp__playwright__browser_resize"

    # Use Bash string replacement to avoid sed special character issues
    echo "${tools//Playwright/$playwright_tools}"
}

# Process conditional compilation tags ({{IF}}, {{UNLESS}}, {{ENDIF}}, {{ENDUNLESS}})
# Ignores {{orchestrated_standards}} and other placeholders
#
# Limitations:
#   - Nesting is supported but deeply nested conditions (>10 levels) may behave unexpectedly
#   - Same-line opening and closing tags are not supported
#   - Conditionals must be on their own lines
process_conditionals() {
    local content=$1
    local use_claude_code_subagents=$2
    local standards_as_claude_code_skills=$3
    local compiled_single_command=${4:-"false"}  # Default to false if not provided

    local result=""
    local nesting_level=0
    local should_include=true
    local stack_should_include=()
    local stack_tag_type=()  # Track IF vs UNLESS for validation
    local tag_mismatch_detected=false  # M4 Fix: Track tag mismatches for error reporting

    while IFS= read -r line; do
        # Check for IF tags
        if [[ "$line" =~ \{\{IF[[:space:]]+([a-z_]+)\}\} ]]; then
            local flag_name="${BASH_REMATCH[1]}"

            # Evaluate condition
            local condition_met=false
            case "$flag_name" in
                "use_claude_code_subagents")
                    [[ "$use_claude_code_subagents" == "true" ]] && condition_met=true
                    ;;
                "standards_as_claude_code_skills")
                    [[ "$standards_as_claude_code_skills" == "true" ]] && condition_met=true
                    ;;
                "compiled_single_command")
                    [[ "$compiled_single_command" == "true" ]] && condition_met=true
                    ;;
                *)
                    print_warning "Unknown conditional flag: $flag_name"
                    ;;
            esac

            # Push current should_include onto stack
            stack_should_include+=("$should_include")
            stack_tag_type+=("IF")

            # Update should_include based on parent's state AND current condition
            if [[ "$should_include" == true ]] && [[ "$condition_met" == true ]]; then
                should_include=true
            else
                should_include=false
            fi

            ((nesting_level++)) || true
            continue
        fi

        # Check for UNLESS tags
        if [[ "$line" =~ \{\{UNLESS[[:space:]]+([a-z_]+)\}\} ]]; then
            local flag_name="${BASH_REMATCH[1]}"

            # Evaluate condition (opposite of IF)
            local condition_met=false
            case "$flag_name" in
                "use_claude_code_subagents")
                    [[ "$use_claude_code_subagents" != "true" ]] && condition_met=true
                    ;;
                "standards_as_claude_code_skills")
                    [[ "$standards_as_claude_code_skills" != "true" ]] && condition_met=true
                    ;;
                "compiled_single_command")
                    [[ "$compiled_single_command" != "true" ]] && condition_met=true
                    ;;
                *)
                    print_warning "Unknown conditional flag: $flag_name"
                    ;;
            esac

            # Push current should_include onto stack
            stack_should_include+=("$should_include")
            stack_tag_type+=("UNLESS")

            # Update should_include based on parent's state AND current condition
            if [[ "$should_include" == true ]] && [[ "$condition_met" == true ]]; then
                should_include=true
            else
                should_include=false
            fi

            ((nesting_level++)) || true
            continue
        fi

        # Check for ENDIF tags
        if [[ "$line" =~ \{\{ENDIF[[:space:]]+([a-z_]+)\}\} ]]; then
            local flag_name="${BASH_REMATCH[1]}"
            ((nesting_level--))

            # Validate tag matching
            if [[ ${#stack_tag_type[@]} -gt 0 ]]; then
                local last_type_index=$((${#stack_tag_type[@]} - 1))
                local expected_type="${stack_tag_type[$last_type_index]}"
                if [[ "$expected_type" != "IF" ]]; then
                    print_warning "Mismatched template tags: {{ENDIF $flag_name}} closes {{UNLESS ...}}"
                    tag_mismatch_detected=true  # M4 Fix: Track mismatch
                fi
                # S-M3 Fix: Use temporary variable for array slice to avoid bash edge cases
                local temp_type_array=("${stack_tag_type[@]:0:$last_type_index}")
                stack_tag_type=("${temp_type_array[@]}")
            fi

            # Pop should_include from stack
            if [[ ${#stack_should_include[@]} -gt 0 ]]; then
                local last_index=$((${#stack_should_include[@]} - 1))
                should_include="${stack_should_include[$last_index]}"
                # S-M3 Fix: Use temporary variable for array slice
                local temp_include_array=("${stack_should_include[@]:0:$last_index}")
                stack_should_include=("${temp_include_array[@]}")
            else
                should_include=true
            fi

            continue
        fi

        # Check for ENDUNLESS tags
        if [[ "$line" =~ \{\{ENDUNLESS[[:space:]]+([a-z_]+)\}\} ]]; then
            local flag_name="${BASH_REMATCH[1]}"
            ((nesting_level--))

            # Validate tag matching
            if [[ ${#stack_tag_type[@]} -gt 0 ]]; then
                local last_type_index=$((${#stack_tag_type[@]} - 1))
                local expected_type="${stack_tag_type[$last_type_index]}"
                if [[ "$expected_type" != "UNLESS" ]]; then
                    print_warning "Mismatched template tags: {{ENDUNLESS $flag_name}} closes {{IF ...}}"
                    tag_mismatch_detected=true  # M4 Fix: Track mismatch
                fi
                # S-M3 Fix: Use temporary variable for array slice to avoid bash edge cases
                local temp_type_array=("${stack_tag_type[@]:0:$last_type_index}")
                stack_tag_type=("${temp_type_array[@]}")
            fi

            # Pop should_include from stack
            if [[ ${#stack_should_include[@]} -gt 0 ]]; then
                local last_index=$((${#stack_should_include[@]} - 1))
                should_include="${stack_should_include[$last_index]}"
                # S-M3 Fix: Use temporary variable for array slice
                local temp_include_array=("${stack_should_include[@]:0:$last_index}")
                stack_should_include=("${temp_include_array[@]}")
            else
                should_include=true
            fi

            continue
        fi

        # Include line if should_include is true
        if [[ "$should_include" == true ]]; then
            if [[ -z "$result" ]]; then
                result="$line"
            else
                result="$result"$'\n'"$line"
            fi
        fi
    done <<< "$content"

    # Check for unclosed conditionals
    if [[ $nesting_level -ne 0 ]]; then
        print_warning "Unclosed conditional block detected (nesting level: $nesting_level)"
    fi

    echo "$result"

    # M4 Fix: Return error code if tag mismatch was detected
    if [[ "$tag_mismatch_detected" == true ]]; then
        return 1
    fi
    return 0
}

# Maximum recursion depth for workflow processing
readonly MAX_WORKFLOW_RECURSION_DEPTH=20

# Process workflow replacements recursively
# Args: $1=content, $2=base_dir, $3=profile, $4=processed_files (space-separated), $5=depth (optional)
# Uses global: EFFECTIVE_LAZY_LOAD_WORKFLOWS - when "true", returns file references instead of embedding content
process_workflows() {
    local content=$1
    local base_dir=$2
    local profile=$3
    local processed_files=$4
    local depth=${5:-0}

    # Check recursion depth limit
    if [[ $depth -ge $MAX_WORKFLOW_RECURSION_DEPTH ]]; then
        print_error "Maximum workflow recursion depth ($MAX_WORKFLOW_RECURSION_DEPTH) exceeded"
        print_error "This may indicate circular references or deeply nested workflows"
        echo "$content"
        return 1
    fi

    # Process each workflow reference
    local workflow_refs=$(echo "$content" | grep -o '{{workflows/[^}]*}}' | sort -u)

    while IFS= read -r workflow_ref; do
        if [[ -z "$workflow_ref" ]]; then
            continue
        fi

        local workflow_path=$(echo "$workflow_ref" | sed 's/{{workflows\///' | sed 's/}}//')

        # Get workflow file
        local workflow_file=$(get_profile_file "$profile" "workflows/${workflow_path}.md" "$base_dir")

        if [[ -f "$workflow_file" ]]; then
            # LAZY LOADING MODE: Return file reference instead of embedding content
            # This dramatically reduces context window usage (~75% reduction)
            if [[ "${EFFECTIVE_LAZY_LOAD_WORKFLOWS:-false}" == "true" ]]; then
                # Create a reference that agents can read on-demand
                local workflow_reference="@agent-os/workflows/${workflow_path}.md"

                # Use perl for safe replacement (use single quotes to prevent @ interpolation)
                local temp_content=$(create_temp_file)
                local temp_ref=$(create_temp_file)
                echo "$content" > "$temp_content"
                echo "$workflow_reference" > "$temp_ref"
                local perl_result
                perl_result=$(perl -e '
                    use strict;
                    use warnings;

                    my $pattern = $ARGV[0];
                    my $ref_file = $ARGV[1];
                    my $content_file = $ARGV[2];

                    # Read replacement reference
                    open(my $fh, "<", $ref_file) or die $!;
                    my $replacement = do { local $/; <$fh> };
                    close($fh);
                    chomp $replacement;

                    # Read content
                    open($fh, "<", $content_file) or die $!;
                    my $content = do { local $/; <$fh> };
                    close($fh);

                    # Do the replacement
                    my $escaped_pattern = quotemeta($pattern);
                    $content =~ s/$escaped_pattern/$replacement/g;

                    print $content;
                ' "$workflow_ref" "$temp_ref" "$temp_content" 2>/dev/null)
                local perl_exit=$?
                if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
                    print_warning "Perl replacement failed for lazy workflow: $workflow_ref (exit=$perl_exit)"
                else
                    content="$perl_result"
                fi
                remove_temp_file "$temp_content"
                remove_temp_file "$temp_ref"
            else
                # EMBEDDED MODE (default): Include full workflow content inline
                # Avoid infinite recursion via circular reference
                if [[ " $processed_files " == *" $workflow_path "* ]]; then
                    print_warning "Circular workflow reference detected: $workflow_path"
                    continue
                fi

                local workflow_content=$(cat "$workflow_file")

                # Recursively process nested workflows
                workflow_content=$(process_workflows "$workflow_content" "$base_dir" "$profile" "$processed_files $workflow_path" "$((depth + 1))")

                # Create tracked temp files for safe replacement
                local temp_content=$(create_temp_file)
                local temp_replacement=$(create_temp_file)
                echo "$content" > "$temp_content"
                echo "$workflow_content" > "$temp_replacement"

                # Use perl to do the replacement without escaping newlines
                local perl_result
                perl_result=$(perl -e '
                    use strict;
                    use warnings;

                    my $ref = $ARGV[0];
                    my $replacement_file = $ARGV[1];
                    my $content_file = $ARGV[2];

                    # Read replacement content
                    open(my $fh, "<", $replacement_file) or die $!;
                    my $replacement = do { local $/; <$fh> };
                    close($fh);

                    # Read main content
                    open($fh, "<", $content_file) or die $!;
                    my $content = do { local $/; <$fh> };
                    close($fh);

                    # Do the replacement - use quotemeta on entire reference
                    my $pattern = quotemeta($ref);
                    $content =~ s/$pattern/$replacement/g;

                    print $content;
                ' "$workflow_ref" "$temp_replacement" "$temp_content" 2>/dev/null)
                local perl_exit=$?
                if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
                    print_warning "Perl replacement failed for workflow: $workflow_ref (exit=$perl_exit)"
                else
                    content="$perl_result"
                fi

                remove_temp_file "$temp_content"
                remove_temp_file "$temp_replacement"
            fi
        else
            # Instead of printing warning to stderr, insert it into the content
            local warning_msg="⚠️ This workflow file was not found in your Agent OS base installation at ~/agent-os/profiles/$profile/workflows/${workflow_path}.md"
            # Use perl for safer replacement with special characters
            # Use temp files to avoid shell interpolation issues
            local temp_content=$(create_temp_file)
            local temp_replacement=$(create_temp_file)
            echo "$content" > "$temp_content"
            printf '%s\n%s' "$workflow_ref" "$warning_msg" > "$temp_replacement"
            local perl_result
            perl_result=$(perl -e '
                use strict;
                use warnings;

                my $ref = $ARGV[0];
                my $replacement_file = $ARGV[1];
                my $content_file = $ARGV[2];

                # Read replacement content
                open(my $fh, "<", $replacement_file) or die "Cannot open replacement file: $!";
                my $replacement = do { local $/; <$fh> };
                close($fh);
                chomp $replacement;

                # Read main content
                open($fh, "<", $content_file) or die "Cannot open content file: $!";
                my $content = do { local $/; <$fh> };
                close($fh);

                # Do the replacement - use quotemeta to escape special chars
                my $pattern = quotemeta($ref);
                $content =~ s/$pattern/$replacement/g;

                print $content;
            ' "$workflow_ref" "$temp_replacement" "$temp_content" 2>/dev/null)
            local perl_exit=$?
            remove_temp_file "$temp_content"
            remove_temp_file "$temp_replacement"
            if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
                print_warning "Perl replacement failed for workflow not found: $workflow_ref (exit=$perl_exit)"
                continue
            fi
            content="$perl_result"
        fi
    done <<< "$workflow_refs"

    # H3/H5 Fix: Validate all workflow refs were processed
    # Check if any {{workflows/...}} tags remain unprocessed
    # H5 Fix: Separate grep execution from count to properly detect errors
    local remaining_refs=0
    local grep_output
    if grep_output=$(echo "$content" | grep -c '{{workflows/[^}]*}}' 2>/dev/null); then
        remaining_refs="$grep_output"
    fi
    # remaining_refs is 0 if no matches (grep returns 1), or the count if matches found
    if [[ $remaining_refs -gt 0 ]]; then
        print_warning "process_workflows: $remaining_refs workflow reference(s) may not have been fully processed"
        print_verbose "Remaining workflow tags detected in output - this may indicate a subshell scope issue"
    fi

    echo "$content"
}

# Process protocol replacements
# Args: $1=content, $2=base_dir, $3=profile
# Similar to workflows but for protocol files in profiles/default/protocols/
process_protocols() {
    local content=$1
    local base_dir=$2
    local profile=$3

    # Process each protocol reference
    local protocol_refs=$(echo "$content" | grep -o '{{protocols/[^}]*}}' | sort -u)

    while IFS= read -r protocol_ref; do
        if [[ -z "$protocol_ref" ]]; then
            continue
        fi

        local protocol_path=$(echo "$protocol_ref" | sed 's/{{protocols\///' | sed 's/}}//')

        # Get protocol file
        local protocol_file=$(get_profile_file "$profile" "protocols/${protocol_path}.md" "$base_dir")

        if [[ -f "$protocol_file" ]]; then
            # Protocols are always referenced (not embedded) to keep context lean
            local protocol_reference="@agent-os/protocols/${protocol_path}.md"

            # Use perl for safe replacement
            local temp_content=$(create_temp_file)
            local temp_ref=$(create_temp_file)
            echo "$content" > "$temp_content"
            echo "$protocol_reference" > "$temp_ref"
            local perl_result
            perl_result=$(perl -e '
                use strict;
                use warnings;

                my $pattern = $ARGV[0];
                my $ref_file = $ARGV[1];
                my $content_file = $ARGV[2];

                # Read replacement reference
                open(my $fh, "<", $ref_file) or die $!;
                my $replacement = do { local $/; <$fh> };
                close($fh);
                chomp $replacement;

                # Read content
                open($fh, "<", $content_file) or die $!;
                my $content = do { local $/; <$fh> };
                close($fh);

                # Do the replacement
                my $escaped_pattern = quotemeta($pattern);
                $content =~ s/$escaped_pattern/$replacement/g;

                print $content;
            ' "$protocol_ref" "$temp_ref" "$temp_content" 2>/dev/null)
            local perl_exit=$?
            remove_temp_file "$temp_content"
            remove_temp_file "$temp_ref"
            if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
                print_warning "Perl replacement failed for protocol: $protocol_ref (exit=$perl_exit)"
            else
                content="$perl_result"
            fi
        else
            # Protocol not found - insert warning
            local warning_msg="⚠️ This protocol file was not found: ~/agent-os/profiles/$profile/protocols/${protocol_path}.md"
            # Use temp files to avoid shell interpolation issues
            local temp_content=$(create_temp_file)
            local temp_replacement=$(create_temp_file)
            echo "$content" > "$temp_content"
            printf '%s\n%s' "$protocol_ref" "$warning_msg" > "$temp_replacement"
            local perl_result
            perl_result=$(perl -e '
                use strict;
                use warnings;

                my $ref = $ARGV[0];
                my $replacement_file = $ARGV[1];
                my $content_file = $ARGV[2];

                # Read replacement content
                open(my $fh, "<", $replacement_file) or die "Cannot open replacement file: $!";
                my $replacement = do { local $/; <$fh> };
                close($fh);
                chomp $replacement;

                # Read main content
                open($fh, "<", $content_file) or die "Cannot open content file: $!";
                my $content = do { local $/; <$fh> };
                close($fh);

                # Do the replacement - use quotemeta to escape special chars
                my $pattern = quotemeta($ref);
                $content =~ s/$pattern/$replacement/g;

                print $content;
            ' "$protocol_ref" "$temp_replacement" "$temp_content" 2>/dev/null)
            local perl_exit=$?
            remove_temp_file "$temp_content"
            remove_temp_file "$temp_replacement"
            if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
                print_warning "Perl replacement failed for protocol not found: $protocol_ref (exit=$perl_exit)"
                continue
            fi
            content="$perl_result"
        fi
    done <<< "$protocol_refs"

    echo "$content"
}

# Process standards replacements
# S-M2 Note: This function uses pipes with while loops. Variable scope is lost in subshells,
# but this is acceptable here because we only output via echo, not modifying shared state.
# The echo output is collected by the final | sort -u.
process_standards() {
    local content=$1
    local base_dir=$2
    local profile=$3
    local standards_patterns=$4

    local standards_list=""

    echo "$standards_patterns" | while read pattern; do
        if [[ -z "$pattern" ]]; then
            continue
        fi

        local base_path=$(echo "$pattern" | sed 's/\*//')

        if [[ "$pattern" == *"*"* ]]; then
            # Wildcard pattern - find all files
            local search_dir="standards/$base_path"
            get_profile_files "$profile" "$base_dir" "$search_dir" | while read file; do
                # Exclude _index.md files (metadata only, not needed in agent context)
                if [[ "$file" == standards/* ]] && [[ "$file" == *.md ]] && [[ "$file" != *"_index.md" ]]; then
                    echo "@agent-os/$file"
                fi
            done
        else
            # Specific file
            local file_path="standards/${pattern}.md"
            local full_file=$(get_profile_file "$profile" "$file_path" "$base_dir")
            if [[ -f "$full_file" ]]; then
                echo "@agent-os/$file_path"
            fi
        fi
    done | sort -u
}

# Process PHASE tag replacements in command files
# Embeds the content of referenced files with H1 headers
process_phase_tags() {
    local content=$1
    local base_dir=$2
    local profile=$3
    local mode=$4  # "embed" or empty (no processing)

    # If no mode specified, return content unchanged
    if [[ -z "$mode" ]]; then
        echo "$content"
        return 0
    fi

    # Find all PHASE tags: {{PHASE X: @agent-os/commands/path/to/file.md}}
    local phase_refs=$(echo "$content" | grep -o '{{PHASE [^}]*}}' | sort -u)

    if [[ -z "$phase_refs" ]]; then
        echo "$content"
        return 0
    fi

    while IFS= read -r phase_ref; do
        if [[ -z "$phase_ref" ]]; then
            continue
        fi

        if [[ "$mode" == "embed" ]]; then
            # CASE A: Embed the file content with H1 header
            # Extract: {{PHASE 1: @agent-os/commands/plan-product/1-product-concept.md}}
            # To get: PHASE 1, plan-product/1-product-concept.md, "Product Concept"

            local phase_label=$(echo "$phase_ref" | sed 's/{{//' | sed 's/:.*$//')  # "PHASE 1"
            local file_ref=$(echo "$phase_ref" | sed 's/.*@agent-os\/commands\///' | sed 's/}}$//')  # "plan-product/1-product-concept.md"
            local file_name=$(basename "$file_ref" .md)  # "1-product-concept"

            # Convert "1-product-concept" to "Product Concept"
            local title=$(echo "$file_name" | sed 's/^[0-9]*-//' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

            # Get the actual file path in the profile
            # Insert /single-agent/ into the path: create-tasks/1-file.md -> create-tasks/single-agent/1-file.md
            local cmd_name=$(dirname "$file_ref")
            local filename=$(basename "$file_ref")
            local source_file=$(get_profile_file "$profile" "commands/$cmd_name/single-agent/$filename" "$base_dir")

            if [[ -f "$source_file" ]]; then
                # Read the file content
                local file_content=$(cat "$source_file")

                # Process the file content through the compilation pipeline
                # (conditionals, workflows, standards) before embedding
                # Set compiled_single_command=true to exclude content wrapped in {{UNLESS compiled_single_command}}
                file_content=$(process_conditionals "$file_content" "${EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS:-true}" "${EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS:-true}" "true")
                file_content=$(process_workflows "$file_content" "$base_dir" "$profile" "")
                file_content=$(process_protocols "$file_content" "$base_dir" "$profile")

                # Process standards replacements in the embedded file
                local standards_refs=$(echo "$file_content" | grep -o '{{standards/[^}]*}}' | sort -u)
                while IFS= read -r standards_ref; do
                    if [[ -z "$standards_ref" ]]; then
                        continue
                    fi

                    local standards_pattern=$(echo "$standards_ref" | sed 's/{{standards\///' | sed 's/}}//')
                    local standards_list=$(process_standards "$file_content" "$base_dir" "$profile" "$standards_pattern")

                    # Create tracked temp files for the replacement
                    local temp_file_content=$(create_temp_file)
                    local temp_standards=$(create_temp_file)
                    echo "$file_content" > "$temp_file_content"
                    echo "$standards_list" > "$temp_standards"

                    # Use perl to replace without escaping newlines
                    local perl_result
                    perl_result=$(perl -e '
                        use strict;
                        use warnings;

                        my $ref = $ARGV[0];
                        my $standards_file = $ARGV[1];
                        my $content_file = $ARGV[2];

                        # Read standards list
                        open(my $fh, "<", $standards_file) or die $!;
                        my $standards = do { local $/; <$fh> };
                        close($fh);
                        chomp $standards;

                        # Read content
                        open($fh, "<", $content_file) or die $!;
                        my $content = do { local $/; <$fh> };
                        close($fh);

                        # Do the replacement - use quotemeta on entire reference
                        my $pattern = quotemeta($ref);
                        $content =~ s/$pattern/$standards/g;

                        print $content;
                    ' "$standards_ref" "$temp_standards" "$temp_file_content" 2>/dev/null)
                    local perl_exit=$?
                    remove_temp_file "$temp_file_content"
                    remove_temp_file "$temp_standards"
                    if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
                        print_warning "Perl replacement failed for standards: $standards_ref (exit=$perl_exit)"
                    else
                        file_content="$perl_result"
                    fi
                done <<< "$standards_refs"

                # Create the replacement text with H1 header
                local replacement="# $phase_label: $title"$'\n\n'"$file_content"

                # Replace the tag with the embedded content
                local temp_content=$(create_temp_file)
                local temp_replacement=$(create_temp_file)
                echo "$content" > "$temp_content"
                echo "$replacement" > "$temp_replacement"

                local perl_result
                perl_result=$(perl -e '
                    use strict;
                    use warnings;

                    my $ref = $ARGV[0];
                    my $replacement_file = $ARGV[1];
                    my $content_file = $ARGV[2];

                    # Read replacement
                    open(my $fh, "<", $replacement_file) or die $!;
                    my $replacement = do { local $/; <$fh> };
                    close($fh);
                    chomp $replacement;

                    # Read content
                    open($fh, "<", $content_file) or die $!;
                    my $content = do { local $/; <$fh> };
                    close($fh);

                    # Do the replacement - use quotemeta on the tag
                    my $pattern = quotemeta($ref);
                    $content =~ s/$pattern/$replacement/g;

                    print $content;
                ' "$phase_ref" "$temp_replacement" "$temp_content" 2>/dev/null)
                local perl_exit=$?
                remove_temp_file "$temp_content"
                remove_temp_file "$temp_replacement"
                if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
                    print_warning "Perl replacement failed for PHASE tag: $phase_ref (exit=$perl_exit)"
                else
                    content="$perl_result"
                fi
            else
                print_verbose "Warning: File not found for PHASE tag: $file_ref"
            fi
        fi

    done <<< "$phase_refs"

    echo "$content"
}

# Compile agent file with all replacements
compile_agent() {
    local source_file=$1
    local dest_file=$2
    local base_dir=$3
    local profile=$4
    local role_data=$5
    local phase_mode=${6:-""}  # Optional: "embed" to embed PHASE content, or empty for no processing

    local content=$(cat "$source_file")

    # Process role replacements if provided
    if [[ -n "$role_data" ]]; then
        # M2 Note: Process each role replacement using delimiter-based format
        # Format: <<<KEY>>>\nvalue content\n<<<END>>>
        # Limitation: If value content contains the literal string "<<<END>>>",
        # parsing will terminate prematurely. This is acceptable because:
        # 1. This pattern is unlikely in normal content
        # 2. The delimiter syntax is internal to the compile pipeline
        # 3. Adding escape handling would significantly complicate the parser
        local temp_role_data=$(create_temp_file)
        echo "$role_data" > "$temp_role_data"

        # Parse the delimiter-based format
        while IFS= read -r line; do
            if [[ "$line" =~ ^'<<<'(.+)'>>>'$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local value=""

                # Read until we hit <<<END>>>
                while IFS= read -r value_line; do
                    if [[ "$value_line" == "<<<END>>>" ]]; then
                        break
                    fi
                    if [[ -n "$value" ]]; then
                        value="${value}"$'\n'"${value_line}"
                    else
                        value="${value_line}"
                    fi
                done

                if [[ -n "$key" ]]; then
                    # Create tracked temp files for the replacement
                    local temp_content=$(create_temp_file)
                    local temp_value=$(create_temp_file)
                    echo "$content" > "$temp_content"
                    echo "$value" > "$temp_value"

                    # Use perl to replace without escaping newlines
                    local perl_result
                    perl_result=$(perl -e '
                        use strict;
                        use warnings;

                        my $key = $ARGV[0];
                        my $value_file = $ARGV[1];
                        my $content_file = $ARGV[2];

                        # Read value
                        open(my $fh, "<", $value_file) or die $!;
                        my $value = do { local $/; <$fh> };
                        close($fh);
                        chomp $value;

                        # Read content
                        open($fh, "<", $content_file) or die $!;
                        my $content = do { local $/; <$fh> };
                        close($fh);

                        # Do the replacement - use quotemeta on entire pattern (no role. prefix)
                        my $pattern = quotemeta("{{" . $key . "}}");
                        $content =~ s/$pattern/$value/g;

                        print $content;
                    ' "$key" "$temp_value" "$temp_content" 2>/dev/null)
                    local perl_exit=$?
                    remove_temp_file "$temp_content"
                    remove_temp_file "$temp_value"
                    if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
                        print_warning "Perl replacement failed for role key: $key (exit=$perl_exit)"
                    else
                        content="$perl_result"
                    fi
                fi
            fi
        done < "$temp_role_data"

        remove_temp_file "$temp_role_data"
    fi

    # Process conditional compilation tags
    # Uses global variables: EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS, EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS
    # compiled_single_command=false for main file (will be true for embedded PHASE files)
    content=$(process_conditionals "$content" "${EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS:-true}" "${EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS:-true}" "false")

    # Process workflow replacements
    content=$(process_workflows "$content" "$base_dir" "$profile" "")

    # Process protocol replacements
    content=$(process_protocols "$content" "$base_dir" "$profile")

    # Process standards replacements
    local standards_refs=$(echo "$content" | grep -o '{{standards/[^}]*}}' | sort -u)

    while IFS= read -r standards_ref; do
        if [[ -z "$standards_ref" ]]; then
            continue
        fi

        local standards_pattern=$(echo "$standards_ref" | sed 's/{{standards\///' | sed 's/}}//')
        local standards_list=$(process_standards "$content" "$base_dir" "$profile" "$standards_pattern")

        # Create tracked temp files for the replacement
        local temp_content=$(create_temp_file)
        local temp_standards=$(create_temp_file)
        echo "$content" > "$temp_content"
        echo "$standards_list" > "$temp_standards"

        # Use perl to replace without escaping newlines
        local perl_result
        perl_result=$(perl -e '
            use strict;
            use warnings;

            my $ref = $ARGV[0];
            my $standards_file = $ARGV[1];
            my $content_file = $ARGV[2];

            # Read standards list
            open(my $fh, "<", $standards_file) or die $!;
            my $standards = do { local $/; <$fh> };
            close($fh);
            chomp $standards;

            # Read content
            open($fh, "<", $content_file) or die $!;
            my $content = do { local $/; <$fh> };
            close($fh);

            # Do the replacement - use quotemeta on entire reference
            my $pattern = quotemeta($ref);
            $content =~ s/$pattern/$standards/g;

            print $content;
        ' "$standards_ref" "$temp_standards" "$temp_content" 2>/dev/null)
        local perl_exit=$?
        remove_temp_file "$temp_content"
        remove_temp_file "$temp_standards"
        if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
            print_warning "Perl replacement failed for standards: $standards_ref (exit=$perl_exit)"
        else
            content="$perl_result"
        fi
    done <<< "$standards_refs"

    # Process PHASE tag replacements
    content=$(process_phase_tags "$content" "$base_dir" "$profile" "$phase_mode")

    # Replace Playwright in tools
    # H2 Fix: Use perl with temp files instead of sed to handle special characters safely
    if echo "$content" | grep -q "^tools:.*Playwright"; then
        local tools_line=$(echo "$content" | grep "^tools:")
        local new_tools_line=$(replace_playwright_tools "$tools_line")
        # Use temp files to avoid shell interpolation issues with special characters
        local temp_content=$(create_temp_file)
        local temp_replacement=$(create_temp_file)
        echo "$content" > "$temp_content"
        echo "$new_tools_line" > "$temp_replacement"
        local perl_result
        perl_result=$(perl -e '
            use strict;
            use warnings;

            my $replacement_file = $ARGV[0];
            my $content_file = $ARGV[1];

            # Read replacement line
            open(my $fh, "<", $replacement_file) or die $!;
            my $replacement = do { local $/; <$fh> };
            close($fh);
            chomp $replacement;

            # Read content
            open($fh, "<", $content_file) or die $!;
            my $content = do { local $/; <$fh> };
            close($fh);

            # Replace tools line (^tools:.*$ pattern)
            $content =~ s/^tools:.*$/$replacement/m;

            print $content;
        ' "$temp_replacement" "$temp_content" 2>/dev/null)
        local perl_exit=$?
        remove_temp_file "$temp_content"
        remove_temp_file "$temp_replacement"
        if [[ $perl_exit -ne 0 ]] || [[ -z "$perl_result" ]]; then
            print_warning "Perl replacement failed for Playwright tools (exit=$perl_exit)"
        else
            content="$perl_result"
        fi
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "$dest_file"
    else
        ensure_dir "$(dirname "$dest_file")"
        echo "$content" > "$dest_file"
        print_verbose "Compiled agent: $dest_file"
    fi
}

# Compile command file with all replacements
# AOS-0031 Fix: Added phase_mode parameter validation
compile_command() {
    local source_file=$1
    local dest_file=$2
    local base_dir=$3
    local profile=$4
    local phase_mode=${5:-""}  # Optional: "embed" to embed PHASE content, or empty for no processing

    # AOS-0031 Fix: Validate phase_mode parameter (only "embed" or empty allowed)
    if [[ -n "$phase_mode" ]] && [[ "$phase_mode" != "embed" ]]; then
        print_warning "compile_command: invalid phase_mode '$phase_mode' (expected 'embed' or empty)"
        print_verbose "Ignoring invalid phase_mode and proceeding without PHASE embedding"
        phase_mode=""
    fi

    compile_agent "$source_file" "$dest_file" "$base_dir" "$profile" "" "$phase_mode"
}

# -----------------------------------------------------------------------------
# Version Functions
# -----------------------------------------------------------------------------

# Parse a semantic version string into components
# Args: $1=version string (e.g., "2.1.3" or "2.1.0-beta")
# Output: "major minor patch prerelease" on stdout
# M18 Fix: Enhanced edge case handling with warnings
parse_semver() {
    local version=$1
    local original_version=$1  # M18: Keep original for warning message

    # Handle empty version
    if [[ -z "$version" ]]; then
        print_verbose "parse_semver: empty version string, defaulting to 0.0.0"
        echo "0 0 0 "
        return
    fi

    # Extract prerelease suffix if present (e.g., "-beta", "-rc1")
    local prerelease=""
    if [[ "$version" == *-* ]]; then
        prerelease="${version#*-}"
        version="${version%%-*}"
    fi

    # M18 Fix: Validate version format (should be X.Y.Z pattern)
    if [[ ! "$version" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
        print_warning "parse_semver: invalid version format '$original_version', using defaults for non-numeric parts"
    fi

    # Parse major.minor.patch
    local major minor patch
    major=$(echo "$version" | cut -d'.' -f1)
    minor=$(echo "$version" | cut -d'.' -f2)
    patch=$(echo "$version" | cut -d'.' -f3)

    # Default missing components to 0
    major=${major:-0}
    minor=${minor:-0}
    patch=${patch:-0}

    # Ensure numeric values (with warning if conversion happens)
    if [[ ! "$major" =~ ^[0-9]+$ ]]; then
        print_verbose "parse_semver: major component '$major' is not numeric, defaulting to 0"
        major=0
    fi
    if [[ ! "$minor" =~ ^[0-9]+$ ]]; then
        print_verbose "parse_semver: minor component '$minor' is not numeric, defaulting to 0"
        minor=0
    fi
    if [[ ! "$patch" =~ ^[0-9]+$ ]]; then
        print_verbose "parse_semver: patch component '$patch' is not numeric, defaulting to 0"
        patch=0
    fi

    echo "$major $minor $patch $prerelease"
}

# Compare two semantic versions
# Args: $1=version1, $2=version2
# Returns: 0 if v1 == v2, 1 if v1 > v2, 2 if v1 < v2
compare_semver() {
    local v1=$1
    local v2=$2

    # Parse both versions
    local v1_parts v2_parts
    read -r v1_major v1_minor v1_patch v1_pre <<< "$(parse_semver "$v1")"
    read -r v2_major v2_minor v2_patch v2_pre <<< "$(parse_semver "$v2")"

    # Compare major
    if [[ $v1_major -gt $v2_major ]]; then return 1; fi
    if [[ $v1_major -lt $v2_major ]]; then return 2; fi

    # Compare minor
    if [[ $v1_minor -gt $v2_minor ]]; then return 1; fi
    if [[ $v1_minor -lt $v2_minor ]]; then return 2; fi

    # Compare patch
    if [[ $v1_patch -gt $v2_patch ]]; then return 1; fi
    if [[ $v1_patch -lt $v2_patch ]]; then return 2; fi

    # Compare prerelease (release > prerelease, alpha < beta < rc)
    # Empty prerelease means release version (higher than any prerelease)
    if [[ -z "$v1_pre" ]] && [[ -n "$v2_pre" ]]; then return 1; fi
    if [[ -n "$v1_pre" ]] && [[ -z "$v2_pre" ]]; then return 2; fi
    if [[ "$v1_pre" > "$v2_pre" ]]; then return 1; fi
    if [[ "$v1_pre" < "$v2_pre" ]]; then return 2; fi

    return 0  # versions are equal
}

# Compare versions (returns 0 if compatible, 1 if not)
# Compatible means same major version
check_version_compatibility() {
    local base_version=$1
    local project_version=$2

    # Parse both versions
    local base_major project_major
    read -r base_major _ _ _ <<< "$(parse_semver "$base_version")"
    read -r project_major _ _ _ <<< "$(parse_semver "$project_version")"

    if [[ "$base_major" != "$project_major" ]]; then
        return 1
    fi

    return 0
}

# Check if project needs migration to 2.1.0
check_needs_migration() {
    local project_version=$1

    # Empty or missing version needs migration
    if [[ -z "$project_version" ]]; then
        return 0  # needs migration
    fi

    # Compare with 2.1.0 threshold
    compare_semver "$project_version" "2.1.0"
    local cmp_result=$?

    # If project version < 2.1.0, needs migration
    if [[ $cmp_result -eq 2 ]]; then
        return 0  # needs migration
    fi

    return 1  # no migration needed
}

# -----------------------------------------------------------------------------
# Installation Check Functions
# -----------------------------------------------------------------------------

# Check if Agent OS is installed in project
is_agent_os_installed() {
    local project_dir=$1

    if [[ -f "$project_dir/agent-os/config.yml" ]]; then
        return 0
    else
        return 1
    fi
}

# Get project installation config
get_project_config() {
    local project_dir=$1
    local key=$2

    get_yaml_value "$project_dir/agent-os/config.yml" "$key" ""
}

# -----------------------------------------------------------------------------
# Validation Functions (Common to both scripts)
# -----------------------------------------------------------------------------

# Validate base installation exists
validate_base_installation() {
    if [[ ! -d "$BASE_DIR" ]]; then
        print_error "Agent OS base installation not found at ~/agent-os/"
        echo ""
        print_status "Please run the base installation first:"
        echo "  curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash"
        echo ""
        exit 1
    fi

    if [[ ! -f "$BASE_DIR/config.yml" ]]; then
        print_error "Base installation config.yml not found"
        exit 1
    fi

    print_verbose "Base installation found at: $BASE_DIR"
}

# Check if current directory is the base installation directory
check_not_base_installation() {
    if [[ -f "$PROJECT_DIR/agent-os/config.yml" ]]; then
        if grep -q "base_install: true" "$PROJECT_DIR/agent-os/config.yml"; then
            echo ""
            print_error "Cannot install Agent OS in base installation directory"
            echo ""
            echo "It appears you are in the location of your Agent OS base installation (your home directory)."
            echo "To install Agent OS in a project, move to your project's root folder:"
            echo ""
            echo "  cd path/to/project"
            echo ""
            echo "And then run:"
            echo ""
            echo "  ~/agent-os/scripts/project-install.sh"
            echo ""
            exit 1
        fi
    fi
}

# Pre-flight validation: check disk space, permissions, and required tools
# Args: $1=target directory (optional, defaults to PROJECT_DIR)
# Returns: 0 if all checks pass, exits on failure
preflight_check() {
    local target_dir="${1:-$PROJECT_DIR}"

    print_verbose "Running pre-flight checks..."

    # Check if target directory is writable
    if [[ ! -w "$target_dir" ]]; then
        print_error "Target directory is not writable: $target_dir"
        echo "Please check your permissions and try again."
        exit 1
    fi

    # Check disk space (require at least 10MB free)
    local required_space_kb=10240  # 10MB in KB
    local available_space_kb

    # Get available space (works on both Linux and macOS)
    if command -v df &>/dev/null; then
        available_space_kb=$(df -k "$target_dir" 2>/dev/null | awk 'NR==2 {print $4}')
        if [[ -n "$available_space_kb" ]] && [[ "$available_space_kb" -lt "$required_space_kb" ]]; then
            print_error "Insufficient disk space. Required: 10MB, Available: $((available_space_kb / 1024))MB"
            exit 1
        fi
        print_verbose "Disk space check passed: ${available_space_kb}KB available"
    else
        print_verbose "Could not check disk space (df not available)"
    fi

    # Check for required tools
    local required_tools=("perl" "awk" "sed" "find" "grep")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Required tools not found: ${missing_tools[*]}"
        echo "Please install the missing tools and try again."
        exit 1
    fi
    print_verbose "All required tools are available"

    # Check if we can create files in target directory
    local test_file="$target_dir/.agent-os-preflight-test-$$"
    if ! touch "$test_file" 2>/dev/null; then
        print_error "Cannot create files in target directory: $target_dir"
        exit 1
    fi
    rm -f "$test_file" 2>/dev/null

    print_verbose "Pre-flight checks passed"
    return 0
}

# -----------------------------------------------------------------------------
# Argument Parsing Helpers
# -----------------------------------------------------------------------------

# Parse boolean flag value
# Outputs: "value shift_count" (e.g., "true 1" or "false 2")
# S-L2 Pattern: This function returns TWO values via stdout: the boolean value
# and how many args to shift. Callers use read to capture both:
#   read -r value shift_count <<< "$(parse_bool_flag "$current" "$next")"
# The shift_count is 1 if no explicit value given (flag alone = true),
# or 2 if explicit true/false was provided after the flag.
parse_bool_flag() {
    local current_value=$1
    local next_value=$2

    if [[ "$next_value" == "true" ]] || [[ "$next_value" == "false" ]]; then
        echo "$next_value 2"
    else
        echo "true 1"
    fi
    return 0
}

# Normalize a command line flag by replacing underscores with hyphens
# Args: $1=flag string
# Returns: normalized flag on stdout
normalize_flag() {
    local flag=$1
    # Replace all underscores with hyphens
    echo "${flag//\_/-}"
}

# -----------------------------------------------------------------------------
# Configuration Loading Helpers
# -----------------------------------------------------------------------------

# Load base installation configuration
load_base_config() {
    BASE_VERSION=$(get_yaml_value "$BASE_DIR/config.yml" "version" "2.1.0")
    BASE_PROFILE=$(get_yaml_value "$BASE_DIR/config.yml" "profile" "default")
    BASE_CLAUDE_CODE_COMMANDS=$(get_yaml_value "$BASE_DIR/config.yml" "claude_code_commands" "true")
    BASE_USE_CLAUDE_CODE_SUBAGENTS=$(get_yaml_value "$BASE_DIR/config.yml" "use_claude_code_subagents" "true")
    BASE_AGENT_OS_COMMANDS=$(get_yaml_value "$BASE_DIR/config.yml" "agent_os_commands" "false")
    BASE_STANDARDS_AS_CLAUDE_CODE_SKILLS=$(get_yaml_value "$BASE_DIR/config.yml" "standards_as_claude_code_skills" "true")
    BASE_LAZY_LOAD_WORKFLOWS=$(get_yaml_value "$BASE_DIR/config.yml" "lazy_load_workflows" "false")

    # Check for old config flags to set variables for validation
    MULTI_AGENT_MODE=$(get_yaml_value "$BASE_DIR/config.yml" "multi_agent_mode" "")
    SINGLE_AGENT_MODE=$(get_yaml_value "$BASE_DIR/config.yml" "single_agent_mode" "")
    MULTI_AGENT_TOOL=$(get_yaml_value "$BASE_DIR/config.yml" "multi_agent_tool" "")
}

# Load project installation configuration
load_project_config() {
    PROJECT_VERSION=$(get_project_config "$PROJECT_DIR" "version")
    PROJECT_PROFILE=$(get_project_config "$PROJECT_DIR" "profile")
    PROJECT_CLAUDE_CODE_COMMANDS=$(get_project_config "$PROJECT_DIR" "claude_code_commands")
    PROJECT_USE_CLAUDE_CODE_SUBAGENTS=$(get_project_config "$PROJECT_DIR" "use_claude_code_subagents")
    PROJECT_AGENT_OS_COMMANDS=$(get_project_config "$PROJECT_DIR" "agent_os_commands")
    PROJECT_STANDARDS_AS_CLAUDE_CODE_SKILLS=$(get_project_config "$PROJECT_DIR" "standards_as_claude_code_skills")
    PROJECT_LAZY_LOAD_WORKFLOWS=$(get_project_config "$PROJECT_DIR" "lazy_load_workflows")

    # Check for old config flags to set variables for validation
    MULTI_AGENT_MODE=$(get_project_config "$PROJECT_DIR" "multi_agent_mode")
    SINGLE_AGENT_MODE=$(get_project_config "$PROJECT_DIR" "single_agent_mode")
    MULTI_AGENT_TOOL=$(get_project_config "$PROJECT_DIR" "multi_agent_tool")
}

# Validate configuration
validate_config() {
    local claude_code_commands=$1
    local use_claude_code_subagents=$2
    local agent_os_commands=$3
    local standards_as_claude_code_skills=$4
    local profile=$5
    local print_warnings=${6:-true}  # Default to true if not provided

    # Validate at least one output is enabled
    if [[ "$claude_code_commands" != "true" ]] && [[ "$agent_os_commands" != "true" ]]; then
        print_error "At least one of 'claude_code_commands' or 'agent_os_commands' must be true"
        exit 1
    fi

    # Validate subagents require Claude Code
    if [[ "$use_claude_code_subagents" == "true" ]] && [[ "$claude_code_commands" != "true" ]]; then
        if [[ "$print_warnings" == "true" ]]; then
            print_warning "use_claude_code_subagents requires claude_code_commands to be true"
            print_warning "Ignoring subagent setting"
        fi
    fi

    # Validate standards as skills require Claude Code
    if [[ "$standards_as_claude_code_skills" == "true" ]] && [[ "$claude_code_commands" != "true" ]]; then
        if [[ "$print_warnings" == "true" ]]; then
            print_warning "standards_as_claude_code_skills requires claude_code_commands to be true"
            print_warning "Treating standards_as_claude_code_skills as false"
        fi
        # Set global variable to override the effective value
        EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS="false"
    fi

    # Validate profile exists
    if [[ ! -d "$BASE_DIR/profiles/$profile" ]]; then
        print_error "Profile not found: $profile"
        exit 1
    fi
}

# Create or update project config.yml
# Returns: 0 on success, 1 on failure
write_project_config() {
    local version=$1
    local profile=$2
    local claude_code_commands=$3
    local use_claude_code_subagents=$4
    local agent_os_commands=$5
    local standards_as_claude_code_skills=$6
    local lazy_load_workflows=${7:-false}
    local dest="$PROJECT_DIR/agent-os/config.yml"

    local config_content="version: $version
last_compiled: $(date '+%Y-%m-%d %H:%M:%S')

# ================================================
# Compiled with the following settings:
#
# To change these settings, run ~/agent-os/scripts/project-update.sh to re-compile your project with the new settings.
# ================================================
profile: $profile
claude_code_commands: $claude_code_commands
use_claude_code_subagents: $use_claude_code_subagents
agent_os_commands: $agent_os_commands
standards_as_claude_code_skills: $standards_as_claude_code_skills
lazy_load_workflows: $lazy_load_workflows"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "$dest"
        return 0
    fi

    # Write file and check return value
    if ! write_file "$config_content" "$dest" >/dev/null; then
        print_error "Failed to write project config: $dest"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Claude Code Skills Functions
# -----------------------------------------------------------------------------

# Convert filename to human-readable name with acronym handling
# Returns lowercase with acronyms in uppercase
# Example: "api-design.md" -> "API design"
#          "frontend/css.md" -> "frontend CSS"
#          "rest-api-conventions.md" -> "REST API conventions"
# AOS-0012 Fix: Graceful degradation if perl not available - returns lowercase without acronym handling
convert_filename_to_human_name() {
    local filename=$1

    # List of common acronyms to preserve in uppercase
    local acronyms=("API" "CSS" "HTML" "SQL" "REST" "JSON" "XML" "HTTP" "HTTPS" "URL" "URI" "CLI" "GUI" "IDE" "SDK" "JWT")

    # Remove .md extension
    local name=$(echo "$filename" | sed 's/\.md$//')

    # Replace hyphens, underscores, and slashes with spaces
    name=$(echo "$name" | sed 's|[-_/]| |g')

    # Convert to lowercase first
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    # AOS-0012 Fix: Check if perl is available before attempting acronym replacement
    if ! command -v perl &> /dev/null; then
        print_verbose "perl not available - skipping acronym replacement in convert_filename_to_human_name"
        echo "$name"
        return 0
    fi

    # Replace known acronyms with uppercase version
    # Match all case variations: lowercase, Capitalized, UPPERCASE
    for acronym in "${acronyms[@]}"; do
        local lowercase=$(echo "$acronym" | tr '[:upper:]' '[:lower:]')
        local capitalized=$(echo "$lowercase" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

        # Replace all variations with the uppercase acronym
        # Use Perl for portable word boundary matching (\b works consistently across platforms)
        # AOS-0012 Fix: Capture perl errors and continue gracefully
        local result
        if result=$(echo "$name" | perl -pe "s/\\b$lowercase\\b/$acronym/g" 2>/dev/null); then
            name="$result"
        fi
        if result=$(echo "$name" | perl -pe "s/\\b$capitalized\\b/$acronym/g" 2>/dev/null); then
            name="$result"
        fi
        if result=$(echo "$name" | perl -pe "s/\\b$acronym\\b/$acronym/g" 2>/dev/null); then
            name="$result"
        fi
    done

    echo "$name"
}

# Convert filename to human-readable name with title case and acronym handling
# Returns title case with acronyms in uppercase
# Example: "api-design.md" -> "API Design"
#          "frontend/css.md" -> "Frontend CSS"
#          "rest-api-conventions.md" -> "REST API Conventions"
# AOS-0012 Fix: Graceful degradation if perl not available - returns title case without acronym handling
convert_filename_to_human_name_capitalized() {
    local filename=$1

    # List of common acronyms to preserve in uppercase
    local acronyms=("API" "CSS" "HTML" "SQL" "REST" "JSON" "XML" "HTTP" "HTTPS" "URL" "URI" "CLI" "GUI" "IDE" "SDK" "JWT")

    # Remove .md extension
    local name=$(echo "$filename" | sed 's/\.md$//')

    # Replace hyphens, underscores, and slashes with spaces
    name=$(echo "$name" | sed 's|[-_/]| |g')

    # Capitalize first letter of each word
    name=$(echo "$name" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')

    # AOS-0012 Fix: Check if perl is available before attempting acronym replacement
    if ! command -v perl &> /dev/null; then
        print_verbose "perl not available - skipping acronym replacement in convert_filename_to_human_name_capitalized"
        echo "$name"
        return 0
    fi

    # Replace known acronyms with uppercase version
    # Match all case variations: lowercase, Capitalized, UPPERCASE
    for acronym in "${acronyms[@]}"; do
        local lowercase=$(echo "$acronym" | tr '[:upper:]' '[:lower:]')
        local capitalized=$(echo "$lowercase" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

        # Replace all variations with the uppercase acronym
        # Use Perl for portable word boundary matching (\b works consistently across platforms)
        # AOS-0012 Fix: Capture perl errors and continue gracefully
        local result
        if result=$(echo "$name" | perl -pe "s/\\b$lowercase\\b/$acronym/g" 2>/dev/null); then
            name="$result"
        fi
        if result=$(echo "$name" | perl -pe "s/\\b$capitalized\\b/$acronym/g" 2>/dev/null); then
            name="$result"
        fi
        if result=$(echo "$name" | perl -pe "s/\\b$acronym\\b/$acronym/g" 2>/dev/null); then
            name="$result"
        fi
    done
    echo "$name"
}

# Create a Claude Code Skill from a standards file
# Args: $1=standards file path (relative to profile, e.g., "standards/frontend/css.md")
#       $2=dest base directory (project directory)
#       $3=base directory (~/agent-os)
#       $4=profile name
create_standard_skill() {
    local standards_file=$1
    local dest_base=$2
    local base_dir=$3
    local profile=$4

    # Remove "standards/" prefix and ".md" extension for skill directory name
    # Convert path separators to hyphens
    # Example: "standards/frontend/css.md" -> "frontend-css"
    local skill_name=$(echo "$standards_file" | sed 's|^standards/||' | sed 's|\.md$||' | sed 's|/|-|g')

    # Get human-readable name from the full path (excluding "standards/")
    # Example: "standards/frontend/css.md" -> "frontend CSS" (lowercase)
    local path_without_standards=$(echo "$standards_file" | sed 's|^standards/||')
    local human_name=$(convert_filename_to_human_name "$path_without_standards")
    local human_name_capitalized=$(convert_filename_to_human_name_capitalized "$path_without_standards")

    # Create skill directory (directly in .claude/skills/, not in agent-os subfolder)
    local skill_dir="$dest_base/.claude/skills/$skill_name"
    ensure_dir "$skill_dir"

    # Get the skill template from the profile
    # M6 Fix: Check return code and handle empty template path
    local template_file
    template_file=$(get_profile_file "$profile" "claude-code-skill-template.md" "$base_dir")
    local get_result=$?
    if [[ $get_result -ne 0 ]] || [[ -z "$template_file" ]] || [[ ! -f "$template_file" ]]; then
        print_error "Skill template not found for profile: $profile (claude-code-skill-template.md)"
        return 1
    fi

    # Prepend agent-os/ to the standards file path for the file reference
    local standard_file_path_with_prefix="agent-os/$standards_file"

    # Read template and replace placeholders
    local skill_content=$(cat "$template_file")
    skill_content=$(echo "$skill_content" | sed "s|{{standard_name_humanized}}|$human_name|g")
    skill_content=$(echo "$skill_content" | sed "s|{{standard_name_humanized_capitalized}}|$human_name_capitalized|g")
    skill_content=$(echo "$skill_content" | sed "s|{{standard_file_path}}|$standard_file_path_with_prefix|g")

    # M6 Fix: Write SKILL.md using write_file for atomic operations
    # AOS-0001 Fix: Arguments were reversed - write_file expects (content, dest)
    local skill_file="$skill_dir/SKILL.md"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "$skill_file"
    else
        # Use write_file for atomic write protection
        # Correct order: write_file "$content" "$destination"
        if ! write_file "$skill_content" "$skill_file"; then
            print_warning "Failed to create skill file: $skill_file"
            return 1
        fi
        print_verbose "Created skill: $skill_file"
    fi
}

# Install Claude Code Skills from standards files
install_claude_code_skills() {
    # Only install skills if both flags are enabled
    if [[ "$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS" != "true" ]] || [[ "$EFFECTIVE_CLAUDE_CODE_COMMANDS" != "true" ]]; then
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing Claude Code Skills..."
    fi

    local skills_count=0

    # Get all standards files for the current profile
    while read file; do
        if [[ "$file" == standards/* ]] && [[ "$file" == *.md ]]; then
            # Create skill from this standards file
            create_standard_skill "$file" "$PROJECT_DIR" "$BASE_DIR" "$EFFECTIVE_PROFILE"

            # Track the skill file for dry run
            local skill_name=$(echo "$file" | sed 's|^standards/||' | sed 's|\.md$||' | sed 's|/|-|g')
            local skill_file="$PROJECT_DIR/.claude/skills/$skill_name/SKILL.md"
            if [[ "$DRY_RUN" == "true" ]]; then
                INSTALLED_FILES+=("$skill_file")
            fi
            ((skills_count++)) || true
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "standards")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $skills_count -gt 0 ]]; then
            echo "✓ Installed $skills_count Claude Code Skills"
            echo -e "${YELLOW}  👉 Be sure to run the /improve-skills command next using Claude Code${NC}"
        fi
    fi
}

# Install improve-skills command (only when Skills are enabled)
install_improve_skills_command() {
    # Only install if both Claude Code commands AND Skills are enabled
    if [[ "$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS" != "true" ]] || [[ "$EFFECTIVE_CLAUDE_CODE_COMMANDS" != "true" ]]; then
        return 0
    fi

    local target_dir="$PROJECT_DIR/.claude/commands/agent-os"
    mkdir -p "$target_dir"

    # Find the improve-skills command file
    local source_file=$(get_profile_file "$EFFECTIVE_PROFILE" "commands/improve-skills/improve-skills.md" "$BASE_DIR")

    if [[ -f "$source_file" ]]; then
        local dest="$target_dir/improve-skills.md"

        # Compile the command (with workflow and standards injection)
        local compiled=$(compile_command "$source_file" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE")

        if [[ "$DRY_RUN" == "true" ]]; then
            INSTALLED_FILES+=("$dest")
        fi
    fi
}
