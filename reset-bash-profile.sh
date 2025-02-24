#!/bin/bash

# reset_bash_profile.sh - Script to reset bash profile to Debian 12 defaults
# Usage: sudo ./reset_bash_profile.sh [username]
# Author: Luis Miguel P. Freitas
# Contact me at: luis@digitalxs.ca or https:digitalxs.ca
# YOU ARE ABSOLUTELY FREE TO USE THIS SCRIPT AS YOU WANT. IT'S YOUR RESPONSABILITY ALONE!
# Function to check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Please run as root (use sudo)"
        exit 1
    fi
}

# Function to validate username
validate_user() {
    local username=$1
    if ! id "$username" >/dev/null 2>&1; then
        echo "Error: User '$username' does not exist"
        exit 1
    fi
}

# Function to get user home directory
get_home_dir() {
    local username=$1
    echo "$(getent passwd "$username" | cut -d: -f6)"
}

# Main script
main() {
    # Check if username is provided
    if [ $# -ne 1 ]; then
        echo "Usage: $0 [username]"
        echo "Example: $0 johndoe"
        exit 1
    fi

    # Store username
    local username=$1

    # Check root privileges
    check_root

    # Validate username
    validate_user "$username"

    # Get user's home directory
    local home_dir=$(get_home_dir "$username")

    echo "Resetting bash profile for user: $username"
    echo "Home directory: $home_dir"

    # Create backup directory
    local backup_dir="$home_dir/bash_backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup directory: $backup_dir"
    mkdir -p "$backup_dir"

    # Backup existing files
    echo "Backing up existing files..."
    for file in .bashrc .profile .bash_logout; do
        if [ -f "$home_dir/$file" ]; then
            cp "$home_dir/$file" "$backup_dir/" 2>/dev/null || echo "Warning: Could not backup $file"
        fi
    done

    # Copy default files
    echo "Copying default files from /etc/skel/..."
    for file in .bashrc .profile .bash_logout; do
        cp "/etc/skel/$file" "$home_dir/" 2>/dev/null || echo "Warning: Could not copy $file"
    done

    # Set permissions
    echo "Setting correct permissions..."
    for file in .bashrc .profile .bash_logout; do
        chown "$username:$username" "$home_dir/$file"
        chmod 644 "$home_dir/$file"
    done

    echo "
Bash profile reset completed successfully!
- Backup files are stored in: $backup_dir
- Default files have been restored
- Permissions have been set

To apply changes, the user should either:
1. Log out and log back in
2. Run: source ~/.bashrc

Note: If you had custom modifications, check the backup files to restore them manually."
}

# Run main script
main "$@"
