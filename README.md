# Bash Profile Reset Script

A utility script to safely reset bash profile configuration files to Debian 12 defaults while creating automatic backups.

## Features

- Automatically backs up existing bash configuration files
- Restores default Debian bash profile settings
- Sets correct file permissions
- Creates timestamped backups
- Provides clear feedback and error handling
- Validates user input and permissions

## Prerequisites

- Debian 12 Linux distribution
- Root access (sudo privileges)
- Bash shell
- wget

## Installation

1. Download the script:
```bas4h
wget -v https://github.com/digitalxs/BashProfileReset/raw/refs/heads/main/reset-bash-profile.sh
```

2. Make the script executable:
```bash
chmod +x reset-bash-profile.sh
```

## Usage

Run the script with sudo, providing the target username:

```bash
sudo ./reset-bash-profile.sh username
```

Example:
```bash
sudo ./reset-bash-profile.sh johndoe
```

## What the Script Does

1. Creates a timestamped backup directory in the userhttps://github.com/digitalxs/BashProfileReset/raw/refs/heads/main/reset-bash-profile.sh's home folder
2. Backs up existing `.bashrc`, `.profile`, and `.bash_logout` files
3. Copies default configuration files from `/etc/skel/`
4. Sets appropriate ownership and permissions
5. Provides instructions for applying changes

## File Locations

- Backup files: `~/bash_backup_YYYYMMDD_HHMMSS/`
- Default configuration source: `/etc/skel/`
- Target files:
  - `~/.bashrc`
  - `~/.profile`
  - `~/.bash_logout`

## After Running the Script

The user should either:
1. Log out and log back in
OR
2. Run the following command to apply changes immediately:
```bash
source ~/.bashrc
```

## Restoring Custom Modifications

If you had custom modifications in your bash profile:
1. Check the backup directory (`~/bash_backup_YYYYMMDD_HHMMSS/`)
2. Compare the backed-up files with the new ones
3. Manually restore any desired customizations

## Troubleshooting

### Common Issues

1. "Error: Please run as root"
   - Solution: Run the script with sudo

2. "Error: User 'username' does not exist"
   - Solution: Check if the username is correct
   - Verify the user exists on the system

3. "Warning: Could not backup/copy file"
   - Solution: Check file permissions
   - Verify the source files exist in `/etc/skel/`

## Contributing

Feel free to submit issues and enhancement requests to luis@digitalxs.ca!

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE Version 3 - see the LICENSE file for details.

## Author

Luis Miguel P. Freitas - 2025

## Acknowledgments

- Based on Debian default bash configuration
- Inspired by the need for a safe way to reset bash profiles after customizations that went wrong.

## Version History

- 1.0.2 (2024-02-23)
  - Some corrections and bugfixes
  - Basic functionality for resetting bash profile
  - Automatic backups with timestamps
  - Changed curl to wget
    
