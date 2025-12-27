#!/bin/bash

# Agent OS Base Installation Script
# Installs Agent OS from GitHub repository to ~/agent-os

set -e

# Repository configuration
REPO_URL="https://github.com/buildermethods/agent-os"

# Installation paths
BASE_DIR="$HOME/agent-os"
TEMP_DIR=$(mktemp -d)
COMMON_FUNCTIONS_TEMP="$TEMP_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Bootstrap Functions (before common-functions.sh is available)
# -----------------------------------------------------------------------------

# S-L3 Fix: Minimal color codes for bootstrap (only if terminal supports colors)
if [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]]; then
    BLUE='\033[0;36m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    BLUE=''
    RED=''
    YELLOW=''
    NC=''
fi

# Bootstrap print functions
bootstrap_print() {
    echo -e "${BLUE}$1${NC}"
}

bootstrap_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Download common-functions.sh first
download_common_functions() {
    local functions_url="${REPO_URL}/raw/main/scripts/common-functions.sh"

    if curl -sL --fail "$functions_url" -o "$COMMON_FUNCTIONS_TEMP"; then
        # Source the common functions
        source "$COMMON_FUNCTIONS_TEMP"
        return 0
    else
        bootstrap_error "Failed to download common-functions.sh"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Initialize common functions
# -----------------------------------------------------------------------------

# M19 Fix: Check for curl BEFORE trying to download anything
if ! command -v curl &> /dev/null; then
    bootstrap_error "curl is required but not installed. Please install curl and try again."
    exit 1
fi

bootstrap_print "Initializing..."
download_common_functions

# Clean up temp directory on exit and restore cursor
# This trap runs on normal exit, errors, and interrupts (Ctrl+C)
# Ensures: 1) No orphan temp files, 2) Terminal cursor visible after exit
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    # Always restore cursor on exit (hidden during spinner animation)
    tput cnorm 2>/dev/null || true
}
trap cleanup EXIT

# -----------------------------------------------------------------------------
# Version Functions
# -----------------------------------------------------------------------------

# Get latest version from GitHub
get_latest_version() {
    local config_url="${REPO_URL}/raw/main/config.yml"
    curl -sL "$config_url" | grep "^version:" | sed 's/version: *//' | tr -d '\r\n'
}

# -----------------------------------------------------------------------------
# Download Functions
# -----------------------------------------------------------------------------

# Download file from GitHub
download_file() {
    local relative_path=$1
    local dest_path=$2
    local file_url="${REPO_URL}/raw/main/${relative_path}"

    mkdir -p "$(dirname "$dest_path")"

    if curl -sL --fail "$file_url" -o "$dest_path"; then
        # M15 Fix: Verify file was actually created and has content
        if [[ -f "$dest_path" ]] && [[ -s "$dest_path" ]]; then
            return 0
        else
            rm -f "$dest_path" 2>/dev/null || true
            return 1
        fi
    else
        return 1
    fi
}

# Define exclusion patterns for files not to download
# - base-install.sh: Self-reference, already running
# - old-versions/*: Historical versions, not needed for fresh install
# - .git*: Git metadata files
# - .github/*: GitHub-specific configuration
EXCLUSIONS=(
    "scripts/base-install.sh"
    "old-versions/*"
    ".git*"
    ".github/*"
)

# Check if a file should be excluded from download
# Args: $1=file path to check
# Returns: 0 if file should be excluded, 1 otherwise
# Supports exact match and wildcard (*) patterns
# AOS-0016 Fix: Improved documentation of wildcard matching behavior
# Pattern matching rules:
#   - Exact: "scripts/base-install.sh" matches only that file
#   - Prefix wildcard: "old-versions/*" matches any file starting with "old-versions/"
#   - Suffix wildcard: ".git*" matches .git, .github, .gitignore etc.
# Note: Only * at the END of a pattern is treated as a wildcard (prefix matching)
# For suffix wildcards like ".git*", the * must be at the end to match
should_exclude() {
    local file_path=$1

    # AOS-0016 Fix: Input validation - empty path never excluded
    if [[ -z "$file_path" ]]; then
        return 1
    fi

    for pattern in "${EXCLUSIONS[@]}"; do
        # Check exact match
        if [[ "$file_path" == "$pattern" ]]; then
            return 0
        fi
        # Check wildcard patterns (only trailing * supported for prefix matching)
        if [[ "$pattern" == *"*" ]]; then
            local prefix="${pattern%\*}"
            if [[ "$file_path" == "$prefix"* ]]; then
                return 0
            fi
        fi
    done

    return 1
}

# Get all files from GitHub repo using the tree API
get_all_repo_files() {
    # Get the default branch (usually main or master)
    local branch="main"

    # Extract owner and repo name from URL
    # From: https://github.com/owner/repo to owner/repo
    local repo_path=$(echo "$REPO_URL" | sed 's|^https://github.com/||')

    print_verbose "Repository path: $repo_path"

    # Build API URL
    local tree_url="https://api.github.com/repos/${repo_path}/git/trees/${branch}?recursive=true"

    print_verbose "Fetching from: $tree_url"

    local response=$(curl -sL "$tree_url")

    # Check if we got a valid response
    if [[ -z "$response" ]]; then
        print_verbose "Empty response from GitHub API"
        return 1
    fi

    # M16 Fix: Debug: Show first 500 chars of response
    # Note: The response is safely quoted in substring expansion; print_verbose also quotes args
    print_verbose "Response preview: ${response:0:500}"

    if echo "$response" | grep -q '"message"'; then
        local error_msg=$(echo "$response" | grep -o '"message":"[^"]*"' | sed 's/"message":"//' | sed 's/"$//')
        print_verbose "GitHub API error: $error_msg"
        return 1
    fi

    # Check if we have tree data (use grep -c to avoid broken pipe)
    if [[ $(echo "$response" | grep -c '"tree"' 2>/dev/null || true) -eq 0 ]]; then
        print_verbose "No tree data in response"
        return 1
    fi

    # Use jq if available, otherwise use python
    if command -v jq &> /dev/null; then
        print_verbose "Using jq to parse JSON"
        echo "$response" | jq -r '.tree[] | select(.type=="blob") | .path' | while read -r file_path; do
            if ! should_exclude "$file_path"; then
                echo "$file_path"
            fi
        done
    elif command -v python3 &> /dev/null; then
        print_verbose "Using python to parse JSON"
        echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data.get('tree', []):
    if item.get('type') == 'blob':
        print(item.get('path', ''))
" | while read -r file_path; do
            if [[ -n "$file_path" ]] && ! should_exclude "$file_path"; then
                echo "$file_path"
            fi
        done
    else
        # AOS-0003 Fix: Improved fallback JSON parser with validation
        # S-M12 Fix: Show warning when using less reliable fallback parser
        print_warning "Neither jq nor python3 available. Using awk fallback (less reliable)."
        print_warning "For reliable parsing, install jq: brew install jq (macOS) or apt install jq (Linux)"
        print_verbose "Using sed/awk to parse JSON (less reliable)"

        # Parse JSON using sed and awk - less reliable but works for simple cases
        # AOS-0003 Fix: Capture output first to validate results aren't empty/corrupted
        local parsed_files
        parsed_files=$(echo "$response" | awk -F'"' '/"type":"blob"/{blob=1} blob && /"path":/{print $4; blob=0}')

        # AOS-0003 Fix: Validate that awk parsing produced reasonable output
        local parsed_count
        parsed_count=$(echo "$parsed_files" | grep -c '.' 2>/dev/null || echo "0")
        if [[ "$parsed_count" -eq 0 ]]; then
            print_error "awk fallback parser returned no files - JSON may contain escaped quotes"
            print_error "Please install jq or python3 for reliable JSON parsing"
            return 1
        fi

        # Only output valid paths
        echo "$parsed_files" | while read -r file_path; do
            if [[ -n "$file_path" ]] && ! should_exclude "$file_path"; then
                echo "$file_path"
            fi
        done
    fi
}

# Download all files from the repository
# M17 & M18 Fix: Standardized return pattern:
# - Outputs file count to stdout (always)
# - Returns 0 if any files downloaded, 1 if none downloaded
download_all_files() {
    local dest_base=$1
    local file_count=0

    print_verbose "Fetching repository file list..."

    # Get list of all files (excluding our exclusion list)
    local all_files=$(get_all_repo_files)

    # M17 Fix: Check for empty result from get_all_repo_files
    if [[ -z "$all_files" ]]; then
        print_verbose "No files returned from repository"
        echo "0"
        return 1
    fi

    # Download each file (using process substitution to avoid subshell variable issue)
    while IFS= read -r file_path; do
        if [[ -n "$file_path" ]]; then
            local dest_file="${dest_base}/${file_path}"

            # Create directory if needed
            local dir_path=$(dirname "$dest_file")
            [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

            if download_file "$file_path" "$dest_file"; then
                ((file_count++)) || true
                print_verbose "  Downloaded: ${file_path}"
            else
                print_verbose "  Failed to download: ${file_path}"
            fi
        fi
    done <<< "$all_files"

    echo "$file_count"
    # M18 Fix: Return success (0) if at least one file downloaded, failure (1) otherwise
    [[ $file_count -gt 0 ]]
}

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Print status message without newline
print_status_no_newline() {
    echo -ne "${BLUE}$1${NC}"
}

# Animated spinner for long-running operations
spinner() {
    local delay=0.5
    while true; do
        for dot_count in "" "." ".." "..."; do
            echo -ne "\r${BLUE}Installing Agent OS files${dot_count}${NC}   "
            sleep $delay
        done
    done
}

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

# Install all files from repository
# Uses background spinner for visual feedback during download
install_all_files() {
    if [[ "$DRY_RUN" != "true" ]]; then
        # Start spinner in background
        # Initialize spinner_pid to empty - will be set if spinner starts
        spinner_pid=""
        if [[ "$VERBOSE" != "true" ]]; then
            # Hide cursor before starting spinner
            tput civis 2>/dev/null || true
            spinner &
            spinner_pid=$!
        else
            print_status "Installing Agent OS files..."
        fi
    fi

    # Download all files (excluding those in exclusion list)
    local file_count
    file_count=$(download_all_files "$BASE_DIR")
    local download_status=$?

    # Stop spinner if running
    # AOS-0005 Fix: Validate PID is numeric before attempting to kill
    if [[ -n "$spinner_pid" ]] && [[ "$spinner_pid" =~ ^[0-9]+$ ]]; then
        # H1 Fix: Quote PID to prevent killing wrong process if unset/corrupted
        kill "$spinner_pid" 2>/dev/null
        wait "$spinner_pid" 2>/dev/null
        spinner_pid=""  # Reset after kill to prevent issues with multiple calls
        # Clear the line and restore cursor
        echo -ne "\r\033[K"
        tput cnorm 2>/dev/null || true  # Show cursor again
    elif [[ -n "$spinner_pid" ]]; then
        # AOS-0005 Fix: Log warning if PID is non-numeric (indicates a bug)
        print_verbose "Warning: spinner_pid '$spinner_pid' is not numeric - skipping kill"
        spinner_pid=""
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $download_status -eq 0 && $file_count -gt 0 ]]; then
            echo "✓ Installed $file_count files to ~/agent-os"
        else
            print_error "No files were downloaded"
            return 1
        fi
    fi

    # Make scripts executable
    if [[ -d "$BASE_DIR/scripts" ]]; then
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Overwrite Functions
# -----------------------------------------------------------------------------

# Prompt for overwrite choice
prompt_overwrite_choice() {
    local current_version=$1
    local latest_version=$2

    echo ""
    echo -e "${YELLOW}=== ⚠️  Existing Installation Detected ===${NC}"
    echo ""

    echo "You already have a base installation of Agent OS"

    if [[ -n "$current_version" ]]; then
        echo -e "  Your installed version: ${YELLOW}$current_version${NC}"
    else
        echo "  Your installed version: (unknown)"
    fi

    if [[ -n "$latest_version" ]]; then
        echo -e "  Latest available version: ${YELLOW}$latest_version${NC}"
    else
        echo "  Latest available version: (unable to determine)"
    fi

    echo ""
    print_status "What would you like to do?"
    echo ""

    echo -e "${YELLOW}1) Full update${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/agent-os/profiles/default/*"
    echo "    - ~/agent-os/scripts/*"
    echo "    - ~/agent-os/CHANGELOG.md"
    echo ""
    echo "    Updates your version number in ~/agent-os/config.yml but doesn't change anything else in this file."
    echo ""
    echo "    Everything else in your ~/agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}2) Update default profile only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/agent-os/profiles/default/*"
    echo ""
    echo "    Everything else in your ~/agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}3) Update scripts only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/agent-os/scripts/*"
    echo ""
    echo "    Everything else in your ~/agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}4) Update config.yml only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/agent-os/config.yml"
    echo ""
    echo "    Everything else in your ~/agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}5) Delete & reinstall fresh${NC}"
    echo ""
    echo "    - Makes a backup of your current ~/agent-os folder at ~/agent-os.backup"
    echo "    - Deletes your current ~/agent-os folder and all of its contents."
    echo "    - Installs a fresh ~/agent-os base installation"
    echo ""

    echo -e "${YELLOW}6) Cancel and abort${NC}"
    echo ""

    read -p "Enter your choice (1-6): " choice < /dev/tty

    case $choice in
        1)
            echo ""
            print_status "Performing full update..."
            full_update "$latest_version"
            ;;
        2)
            echo ""
            print_status "Updating default profile..."
            create_backup
            overwrite_profile
            ;;
        3)
            echo ""
            print_status "Updating scripts..."
            create_backup
            overwrite_scripts
            ;;
        4)
            echo ""
            print_status "Updating config.yml..."
            create_backup
            overwrite_config
            ;;
        5)
            echo ""
            print_status "Deleting & reinstalling fresh..."
            overwrite_all
            ;;
        6)
            echo ""
            print_warning "Installation cancelled"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Installation cancelled."
            exit 1
            ;;
    esac
}

# Create backup of existing installation
# Removes any previous backup and creates a new one at ~/agent-os.backup
# Note: Only one backup is kept at a time; multiple updates will overwrite
#
# AOS-0050 Fix: Existence check before deletion
# We check if the backup directory exists before attempting to remove it.
# While rm -rf with a non-existent path is safe, explicit checks:
#   - Make intent clearer in the code
#   - Avoid unnecessary filesystem operations
#   - Provide consistent pattern across all backup-related code
create_backup() {
    # Remove previous backup if exists (AOS-0050: explicit existence check)
    if [[ -d "$BASE_DIR.backup" ]]; then
        rm -rf "$BASE_DIR.backup"
    fi
    cp -R "$BASE_DIR" "$BASE_DIR.backup"
    echo "✓ Backed up existing installation to ~/agent-os.backup"
    echo ""
}

# Full update - updates profile, scripts, CHANGELOG.md, and version number in config.yml
# AOS-0002 Fix: Download to temp directory first, verify, then swap to prevent data loss
full_update() {
    local latest_version=$1

    # Create backup first
    create_backup

    # Update default profile - download to temp first to verify success before deletion
    print_status "Updating default profile..."

    # AOS-0002 Fix: Create temp directory for safe download
    local temp_download
    temp_download=$(mktemp -d) || {
        print_error "Failed to create temporary download directory"
        return 1
    }

    local file_count=0
    local all_files=$(get_all_repo_files | grep "^profiles/default/")
    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${temp_download}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"
                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Downloaded: ${file_path}"
                fi
            fi
        done <<< "$all_files"
    fi

    # AOS-0002 Fix: Verify download succeeded before replacing existing profile
    if [[ $file_count -gt 0 ]] && [[ -d "$temp_download/profiles/default" ]]; then
        # Download succeeded - safe to replace
        rm -rf "$BASE_DIR/profiles/default"
        mv "$temp_download/profiles/default" "$BASE_DIR/profiles/"
        rm -rf "$temp_download"
        echo "✓ Updated default profile ($file_count files)"
    else
        # Download failed - keep existing profile, clean up temp
        rm -rf "$temp_download"
        print_error "Download failed, keeping existing profile (backup at ~/agent-os.backup)"
        return 1
    fi
    echo ""

    # Update scripts
    print_status "Updating scripts..."
    rm -rf "$BASE_DIR/scripts"
    file_count=0
    all_files=$(get_all_repo_files | grep "^scripts/")
    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"
                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Downloaded: ${file_path}"
                fi
            fi
        done <<< "$all_files"
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi
    echo "✓ Updated scripts ($file_count files)"
    echo ""

    # Update CHANGELOG.md
    print_status "Updating CHANGELOG.md..."
    if download_file "CHANGELOG.md" "$BASE_DIR/CHANGELOG.md"; then
        echo "✓ Updated CHANGELOG.md"
    fi
    echo ""

    # Update version number in config.yml (without overwriting the entire file)
    print_status "Updating version number in config.yml..."
    if [[ -f "$BASE_DIR/config.yml" ]] && [[ -n "$latest_version" ]]; then
        # AOS-0017 Fix: Validate version format before updating (semver pattern)
        if [[ ! "$latest_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
            print_warning "Invalid version format: $latest_version (expected semver like 1.2.3)"
            print_warning "Skipping version update - config.yml unchanged"
        else
            # Use sed to update only the version line
            # Note: sed -i.bak creates backup for macOS compatibility (BSD sed requires suffix)
            # We immediately remove the backup since we have ~/agent-os.backup
            sed -i.bak "s/^version:.*/version: $latest_version/" "$BASE_DIR/config.yml"
            rm -f "$BASE_DIR/config.yml.bak"  # Clean up sed backup file
            echo "✓ Updated version to $latest_version in config.yml"
        fi
    fi
    echo ""

    print_success "Full update completed!"
}

# Overwrite everything
overwrite_all() {
    # Backup existing installation
    if [[ -d "$BASE_DIR.backup" ]]; then
        rm -rf "$BASE_DIR.backup"
    fi
    mv "$BASE_DIR" "$BASE_DIR.backup"
    echo "✓ Backed up existing installation to ~/agent-os.backup"
    echo ""

    # Perform fresh installation
    perform_fresh_installation
}

# Overwrite only profile
overwrite_profile() {
    # Remove existing default profile
    rm -rf "$BASE_DIR/profiles/default"

    # Download only profile files
    local file_count=0

    # Get all files and filter for profiles/default
    local all_files=$(get_all_repo_files | grep "^profiles/default/")

    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Downloaded: ${file_path}"
                fi
            fi
        done <<< "$all_files"
    fi

    echo "✓ Updated default profile ($file_count files)"
    echo ""
    print_success "Default profile has been updated!"
}

# Overwrite only scripts
overwrite_scripts() {
    # Remove existing scripts
    rm -rf "$BASE_DIR/scripts"

    # Download only script files
    local file_count=0

    # Get all files and filter for scripts/
    local all_files=$(get_all_repo_files | grep "^scripts/")

    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Downloaded: ${file_path}"
                fi
            fi
        done <<< "$all_files"

        # Make scripts executable
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi

    echo "✓ Updated scripts ($file_count files)"
    echo ""
    print_success "Scripts have been updated!"
}

# Overwrite only config
overwrite_config() {
    # Download new config.yml
    if download_file "config.yml" "$BASE_DIR/config.yml"; then
        print_verbose "  Downloaded: config.yml"
    fi

    echo "✓ Updated config.yml"
    echo ""
    print_success "Config has been updated!"
}

# -----------------------------------------------------------------------------
# Main Installation Functions
# -----------------------------------------------------------------------------

# Perform fresh installation
perform_fresh_installation() {
    echo ""
    print_status "Configuration:"
    echo -e "  Repository: ${YELLOW}${REPO_URL}${NC}"
    echo -e "  Target: ${YELLOW}~/agent-os${NC}"
    echo ""

    # Create base directory
    ensure_dir "$BASE_DIR"
    echo "✓ Created base directory: ~/agent-os"
    echo ""

    # Install all files from repository
    if ! install_all_files; then
        print_error "Installation failed"
        exit 1
    fi

    echo ""
    print_success "Agent OS has been successfully installed!"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo ""
    echo -e "${GREEN}1) Customize your profile's standards in ~/agent-os/profiles/default/standards${NC}"
    echo ""
    echo -e "${GREEN}2) Navigate to a project directory${NC}"
    echo -e "   ${YELLOW}cd path/to/project-directory${NC}"
    echo ""
    echo -e "${GREEN}3) Install Agent OS in your project by running:${NC}"
    echo -e "   ${YELLOW}~/agent-os/scripts/project-install.sh${NC}"
    echo ""
    echo -e "${GREEN}Visit the docs for guides on how to use Agent OS: https://buildermethods.com/agent-os${NC}"
    echo ""
}

# Check for existing installation
check_existing_installation() {
    if [[ -d "$BASE_DIR" ]]; then
        # Get current version if available
        local current_version=""
        if [[ -f "$BASE_DIR/config.yml" ]]; then
            current_version=$(get_yaml_value "$BASE_DIR/config.yml" "version" "")
        fi

        # Get latest version from GitHub
        local latest_version=$(get_latest_version)

        # Prompt for overwrite choice
        prompt_overwrite_choice "$current_version" "$latest_version"
    else
        # Fresh installation
        perform_fresh_installation
    fi
}

# -----------------------------------------------------------------------------
# Global Variables
# -----------------------------------------------------------------------------

VERBOSE=false
DRY_RUN=false

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    print_section "Agent OS Base Installation"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -v, --verbose    Show verbose output"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done

    # Check for curl
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed. Please install curl and try again."
        exit 1
    fi

    # Check for existing installation or perform fresh install
    check_existing_installation
}

# Run main function
main "$@"
