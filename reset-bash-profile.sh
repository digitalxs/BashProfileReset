#!/bin/bash
# reset-bash-profile.sh - Script to reset bash profile to Debian 12 defaults
# Usage: sudo ./reset-bash-profile.sh [username] [options]
# Author: Luis Miguel P. Freitas - 2025
# Contact me at: luis@digitalxs.ca or https://digitalxs.ca
# YOU ARE ABSOLUTELY FREE TO USE THIS SCRIPT AS YOU WANT. IT'S YOUR RESPONSIBILITY ALONE!

# Script version
VERSION="1.4.1"

# Define colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BACKUP_LOCATION=""
FORCE_MODE=false
VERBOSE_MODE=false
DRY_RUN=false
RESTORE_MODE=false
RESTORE_PATH=""
LIST_BACKUPS=false

# Function to display script usage
show_usage() {
    echo -e "${BLUE}Reset Bash Profile Script v${VERSION}${NC}"
    echo "Resets bash profile to Debian 12 defaults"
    echo ""
    echo -e "${YELLOW}Usage:${NC} $0 [username] [options]"
    echo -e "${YELLOW}Example:${NC} $0 johndoe --backup-dir /backups"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -h, --help                 Show this help message"
    echo "  -v, --verbose              Enable verbose output"
    echo "  -f, --force                Skip confirmations"
    echo "  -d, --dry-run              Show what would be done without making changes"
    echo "  -b, --backup-dir PATH      Specify custom backup directory (default: ~/bash_backup_TIMESTAMP)"
    echo "  -r, --restore PATH         Restore from a backup directory"
    echo "  -l, --list-backups         List available backups for the specified user"
    echo "  --version                  Show script version"
    echo ""
    echo -e "${YELLOW}Notes:${NC}"
    echo "  - This script requires root privileges"
    echo "  - Creates a backup of all existing bash configuration files before resetting"
    echo "  - Custom bash configuration can be manually restored from the backup"
}

# Function to display version
show_version() {
    echo "Reset Bash Profile Script v${VERSION}"
}

# Function to display messages
log() {
    local level=$1
    local message=$2
    
    case "$level" in
        "info")
            if [ "$VERBOSE_MODE" = true ] || [ "$DRY_RUN" = true ]; then
                echo -e "[${BLUE}INFO${NC}] $message"
            fi
            ;;
        "success")
            echo -e "[${GREEN}SUCCESS${NC}] $message"
            ;;
        "warning")
            echo -e "[${YELLOW}WARNING${NC}] $message" >&2
            ;;
        "error")
            echo -e "[${RED}ERROR${NC}] $message" >&2
            ;;
        *)
            echo -e "$message"
            ;;
    esac
}

# Function to check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log "error" "Please run as root (use sudo)"
        exit 1
    fi
}

# Function to validate username
validate_user() {
    local username=$1
    
    # Check if username is provided
    if [ -z "$username" ]; then
        log "error" "No username provided"
        show_usage
        exit 1
    fi
    
    # Check if user exists
    if ! id "$username" >/dev/null 2>&1; then
        log "error" "User '$username' does not exist"
        exit 1
    fi
}

# Function to get user home directory
get_home_dir() {
    local username=$1
    local home_dir=$(getent passwd "$username" | cut -d: -f6)
    
    # Check if home directory exists
    if [ ! -d "$home_dir" ]; then
        log "error" "Home directory for user '$username' does not exist or is not accessible"
        exit 1
    fi
    
    echo "$home_dir"
}

# Function to create a secure backup
create_backup() {
    local username=$1
    local home_dir=$2
    local backup_files=".bashrc .profile .bash_logout .bash_aliases .bash_history .bash_functions .bashrc_help .inputrc .config/starship.toml"
    local backup_dir
    
    # Determine backup directory
    if [ -n "$BACKUP_LOCATION" ]; then
        if [[ "$BACKUP_LOCATION" == /* ]]; then
            # Absolute path
            backup_dir="${BACKUP_LOCATION}/bash_backup_${username}_$(date +%Y%m%d_%H%M%S)"
        else
            # Relative path (to home directory)
            backup_dir="${home_dir}/${BACKUP_LOCATION}/bash_backup_${username}_$(date +%Y%m%d_%H%M%S)"
        fi
    else
        backup_dir="${home_dir}/bash_backup_$(date +%Y%m%d_%H%M%S)"
    fi
    
    log "info" "Creating backup directory: $backup_dir"
    
    if [ "$DRY_RUN" = false ]; then
        # Create backup directory with secure permissions
        mkdir -p "$backup_dir"
        if [ $? -ne 0 ]; then
            log "error" "Failed to create backup directory: $backup_dir"
            exit 1
        fi
        
        # Set proper permissions for backup directory
        chown "$username:$username" "$backup_dir"
        chmod 700 "$backup_dir"
    fi
    
    # Backup existing files
    log "info" "Backing up existing files..."
    
    # First check what files exist to give a summary
    local found_files=()
    for file in $backup_files; do
        if [ -e "$home_dir/$file" ]; then
            found_files+=("$file")
        fi
    done
    
    if [ ${#found_files[@]} -eq 0 ]; then
        log "warning" "No bash profile files found to backup"
    else
        log "info" "Found ${#found_files[@]} files to backup: ${found_files[*]}"
    fi
    
    # Now actually perform the backup
    for file in $backup_files; do
        if [ -e "$home_dir/$file" ]; then
            # Create directory structure if needed
            local dir_path=$(dirname "$file")
            if [ "$dir_path" != "." ] && [ "$DRY_RUN" = false ]; then
                mkdir -p "$backup_dir/$dir_path" 2>/dev/null
            fi
            
            # Copy the file with its attributes
            if [ "$DRY_RUN" = false ]; then
                if [ -L "$home_dir/$file" ]; then
                    # If it's a symlink, copy the symlink itself
                    cp -P "$home_dir/$file" "$backup_dir/$file" 2>/dev/null
                else
                    # Regular file
                    cp -p "$home_dir/$file" "$backup_dir/$file" 2>/dev/null
                fi
                
                if [ $? -ne 0 ]; then
                    log "warning" "Could not backup $file"
                else
                    log "info" "Backed up $file"
                fi
            else
                log "info" "Would backup: $file"
            fi
        fi
    done
    
    # Create metadata file with information about the backup
    if [ "$DRY_RUN" = false ]; then
        {
            echo "Backup created: $(date)"
            echo "User: $username"
            echo "Original home directory: $home_dir"
            echo "Hostname: $(hostname)"
            echo "Script version: $VERSION"
            echo "Files backed up:"
            for file in "${found_files[@]}"; do
                echo "- $file"
            done
        } > "$backup_dir/backup_info.txt"
        
        # Set proper permissions for the metadata file
        chown "$username:$username" "$backup_dir/backup_info.txt"
        chmod 600 "$backup_dir/backup_info.txt"
        
        log "success" "Backup completed successfully: $backup_dir"
    else
        log "info" "Would create backup metadata file: backup_info.txt"
    fi
    
    echo "$backup_dir"
}

# Function to reset bash profile
reset_profile() {
    local username=$1
    local home_dir=$2
    local backup_dir=$3
    local default_files=".bashrc .profile .bash_logout"
    
    log "info" "Resetting bash profile for user: $username"
    
    # Verify that default files exist in /etc/skel/
    local missing_defaults=false
    for file in $default_files; do
        if [ ! -f "/etc/skel/$file" ]; then
            log "warning" "Default file /etc/skel/$file not found"
            missing_defaults=true
        fi
    done
    
    if [ "$missing_defaults" = true ]; then
        if [ "$FORCE_MODE" = false ]; then
            read -p "Some default files are missing. Continue anyway? (y/n): " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                log "info" "Operation cancelled by user"
                exit 0
            fi
        else
            log "warning" "Some default files are missing, continuing anyway (force mode)"
        fi
    fi
    
    # Check for and remove files or symlinks
    for file in $default_files .bash_aliases .bash_functions .bashrc_help; do
        if [ -e "$home_dir/$file" ]; then
            if [ -L "$home_dir/$file" ]; then
                log "info" "Removing symlink: $file"
                if [ "$DRY_RUN" = false ]; then
                    rm "$home_dir/$file"
                fi
            elif [ -f "$home_dir/$file" ]; then
                log "info" "Removing file: $file"
                if [ "$DRY_RUN" = false ]; then
                    rm "$home_dir/$file"
                fi
            fi
        fi
    done
    
    # Copy default files
    log "info" "Copying default files from /etc/skel/..."
    for file in $default_files; do
        if [ -f "/etc/skel/$file" ]; then
            log "info" "Copying $file"
            if [ "$DRY_RUN" = false ]; then
                cp "/etc/skel/$file" "$home_dir/" 2>/dev/null
                if [ $? -ne 0 ]; then
                    log "warning" "Could not copy $file"
                fi
            fi
        fi
    done
    
    # Set permissions
    if [ "$DRY_RUN" = false ]; then
        log "info" "Setting correct permissions..."
        for file in $default_files; do
            if [ -f "$home_dir/$file" ]; then
                chown "$username:$username" "$home_dir/$file"
                chmod 644 "$home_dir/$file"
                log "info" "Set permissions for $file"
            fi
        done
    else
        log "info" "Would set permissions (owner: $username, mode: 644) for bash profile files"
    fi
    
    if [ "$DRY_RUN" = false ]; then
        log "success" "Bash profile reset completed successfully!"
    else
        log "success" "Dry run completed. No changes were made."
    fi
}

# Function to restore from backup
restore_from_backup() {
    local username=$1
    local home_dir=$2
    local restore_path=$3
    
    # Verify backup directory exists
    if [ ! -d "$restore_path" ]; then
        log "error" "Backup directory does not exist: $restore_path"
        exit 1
    fi
    
    # Check if it looks like a valid backup
    if [ ! -f "$restore_path/backup_info.txt" ]; then
        log "warning" "This doesn't appear to be a valid backup (missing backup_info.txt)"
        if [ "$FORCE_MODE" = false ]; then
            read -p "Continue anyway? (y/n): " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                log "info" "Restore cancelled by user"
                exit 0
            fi
        fi
    else
        log "info" "Restoring from backup: $restore_path"
        log "info" "Backup info:"
        cat "$restore_path/backup_info.txt"
    fi
    
    # Get list of files to restore
    local files_to_restore=$(find "$restore_path" -type f -not -path "*/\.*" -not -name "backup_info.txt" | sed "s|^$restore_path/||")
    
    if [ -z "$files_to_restore" ]; then
        log "warning" "No files found to restore"
        exit 1
    fi
    
    # Confirm restore
    if [ "$FORCE_MODE" = false ] && [ "$DRY_RUN" = false ]; then
        log "info" "The following files will be restored:"
        for file in $files_to_restore; do
            echo "  - $file"
        done
        read -p "Continue with restore? (y/n): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log "info" "Restore cancelled by user"
            exit 0
        fi
    fi
    
    # Restore files
    log "info" "Restoring files from backup..."
    for file in $files_to_restore; do
        # Create directory structure if needed
        local dir_path=$(dirname "$file")
        if [ "$dir_path" != "." ] && [ ! -d "$home_dir/$dir_path" ] && [ "$DRY_RUN" = false ]; then
            mkdir -p "$home_dir/$dir_path" 2>/dev/null
        fi
        
        if [ "$DRY_RUN" = false ]; then
            if [ -L "$restore_path/$file" ]; then
                # If it's a symlink, copy the symlink itself
                cp -P "$restore_path/$file" "$home_dir/$file" 2>/dev/null
            else
                # Regular file
                cp -p "$restore_path/$file" "$home_dir/$file" 2>/dev/null
            fi
            
            if [ $? -ne 0 ]; then
                log "warning" "Could not restore $file"
            else
                # Set proper ownership
                chown "$username:$username" "$home_dir/$file"
                log "info" "Restored $file"
            fi
        else
            log "info" "Would restore: $file"
        fi
    done
    
    if [ "$DRY_RUN" = false ]; then
        log "success" "Restore from backup completed successfully!"
    else
        log "success" "Dry run of restore completed. No changes were made."
    fi
}

# Function to list available backups
list_user_backups() {
    local username=$1
    local home_dir=$2
    
    log "info" "Searching for bash profile backups for user: $username"
    
    # Look for backups in home directory
    local home_backups=$(find "$home_dir" -maxdepth 1 -type d -name "bash_backup_*" 2>/dev/null | sort -r)
    
    # Look for backups in custom backup location if specified
    local custom_backups=""
    if [ -n "$BACKUP_LOCATION" ] && [ -d "$BACKUP_LOCATION" ]; then
        custom_backups=$(find "$BACKUP_LOCATION" -maxdepth 1 -type d -name "bash_backup_${username}_*" 2>/dev/null | sort -r)
    fi
    
    # Combine results
    local all_backups=("$home_backups" "$custom_backups")
    
    if [ -z "$home_backups" ] && [ -z "$custom_backups" ]; then
        log "warning" "No backups found for user $username"
        exit 0
    fi
    
    echo -e "\n${BLUE}Available backups for user $username:${NC}"
    
    if [ -n "$home_backups" ]; then
        echo -e "\n${YELLOW}Backups in home directory:${NC}"
        local count=1
        while IFS= read -r backup; do
            local date_part=$(basename "$backup" | sed -e 's/bash_backup_//g' -e 's/.*_\([0-9]\{8\}_[0-9]\{6\}\)$/\1/')
            local formatted_date=$(date -d "${date_part:0:8} ${date_part:9:2}:${date_part:11:2}:${date_part:13:2}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
            
            if [ -f "$backup/backup_info.txt" ]; then
                local file_count=$(grep -c "^- " "$backup/backup_info.txt")
                echo -e "$count. ${GREEN}$backup${NC} (Created: $formatted_date, Files: $file_count)"
            else
                echo -e "$count. ${GREEN}$backup${NC} (Created: $formatted_date)"
            fi
            count=$((count + 1))
        done <<< "$home_backups"
    fi
    
    if [ -n "$custom_backups" ]; then
        echo -e "\n${YELLOW}Backups in custom location:${NC}"
        local count=1
        while IFS= read -r backup; do
            local date_part=$(basename "$backup" | sed -e 's/bash_backup_'$username'_//g')
            local formatted_date=$(date -d "${date_part:0:8} ${date_part:9:2}:${date_part:11:2}:${date_part:13:2}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
            
            if [ -f "$backup/backup_info.txt" ]; then
                local file_count=$(grep -c "^- " "$backup/backup_info.txt")
                echo -e "$count. ${GREEN}$backup${NC} (Created: $formatted_date, Files: $file_count)"
            else
                echo -e "$count. ${GREEN}$backup${NC} (Created: $formatted_date)"
            fi
            count=$((count + 1))
        done <<< "$custom_backups"
    fi
    
    echo -e "\n${BLUE}To restore a backup, use:${NC}"
    echo -e "$0 $username --restore [backup_path]"
}

# Function to print completion message
print_completion_message() {
    local backup_dir=$1
    local username=$2
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   OPERATION COMPLETED                      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Details:${NC}"
    
    if [ ! -z "$backup_dir" ] && [ "$RESTORE_MODE" = false ]; then
        echo "- Backup files are stored in: $backup_dir"
        echo "- Default files have been restored"
        echo "- Permissions have been set"
        echo "- Symlinks have been removed"
    elif [ "$RESTORE_MODE" = true ]; then
        echo "- Files have been restored from: $RESTORE_PATH"
        echo "- Permissions have been set"
    fi
    
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "To apply changes, the user should either:"
    echo "1. Log out and log back in"
    echo "2. Run: source ~/.bashrc"
    echo ""
    echo -e "${YELLOW}Note:${NC} If you had custom modifications, check the backup files to restore them manually."
    
    if [ ! -z "$backup_dir" ] && [ "$RESTORE_MODE" = false ]; then
        echo ""
        echo -e "${BLUE}To restore this backup in the future:${NC}"
        echo "$0 $username --restore $backup_dir"
    fi
}

# Parse command line arguments
parse_arguments() {
    # Store original username if it's the first argument and not an option
    if [ $# -gt 0 ] && [[ ! "$1" == -* ]]; then
        username=$1
        shift
    fi
    
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE_MODE=true
                ;;
            -f|--force)
                FORCE_MODE=true
                ;;
            -d|--dry-run)
                DRY_RUN=true
                ;;
            -b|--backup-dir)
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    log "error" "Backup directory path is missing"
                    exit 1
                fi
                BACKUP_LOCATION="$2"
                shift
                ;;
            -r|--restore)
                RESTORE_MODE=true
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    log "error" "Restore path is missing"
                    exit 1
                fi
                RESTORE_PATH="$2"
                shift
                ;;
            -l|--list-backups)
                LIST_BACKUPS=true
                ;;
            --version)
                show_version
                exit 0
                ;;
            *)
                log "error" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
    
    # Validate username is provided
    if [ -z "$username" ]; then
        log "error" "No username provided"
        show_usage
        exit 1
    fi
}

# Trap cleanup function
cleanup() {
    echo ""
    log "warning" "Script interrupted"
    exit 1
}

# Main script
main() {
    # Set up trap for ctrl+c
    trap cleanup SIGINT SIGTERM
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check root privileges
    check_root
    
    # Validate username
    validate_user "$username"
    
    # Get user's home directory
    local home_dir=$(get_home_dir "$username")
    
    # If list backups mode
    if [ "$LIST_BACKUPS" = true ]; then
        list_user_backups "$username" "$home_dir"
        exit 0
    fi
    
    # If restore mode
    if [ "$RESTORE_MODE" = true ]; then
        restore_from_backup "$username" "$home_dir" "$RESTORE_PATH"
        if [ "$DRY_RUN" = false ]; then
            print_completion_message "" "$username"
        fi
        exit 0
    fi
    
    # Create backup
    local backup_dir=""
    if [ "$DRY_RUN" = false ]; then
        backup_dir=$(create_backup "$username" "$home_dir")
    else
        backup_dir="DRY_RUN_NO_BACKUP_CREATED"
        create_backup "$username" "$home_dir"
    fi
    
    # Reset profile
    reset_profile "$username" "$home_dir" "$backup_dir"
    
    # Print completion message
    if [ "$DRY_RUN" = false ]; then
        print_completion_message "$backup_dir" "$username"
    fi
}

# Make sure at least one argument is provided
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Run main script
main "$@"
