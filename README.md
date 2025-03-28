<div align="center">

# <img src="https://www.debian.org/logos/openlogo-nd.svg" alt="Debian Logo" width="50"> Bash Profile Reset Script

<p>
  <img src="https://img.shields.io/badge/Version-1.1.0-blue.svg" alt="Version 1.1.0">
  <img src="https://img.shields.io/badge/OS-Debian%2012-red.svg" alt="OS Debian 12">
  <img src="https://img.shields.io/badge/License-GPL%20v3-green.svg" alt="License GPL v3">
  <img src="https://img.shields.io/badge/Shell-Bash-yellow.svg" alt="Shell Bash">
</p>

<p>A robust utility script to safely reset bash profile configuration files to Debian 12 defaults<br>with automatic backups, restoration capabilities, and advanced user controls.</p>

<p>
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#license">License</a> •
  <a href="#support">Support</a>
</p>

<p>
  <a href="https://www.buymeacoffee.com/digitalxs" target="_blank">
    <img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" >
  </a>
</p>

</div>

---

## 🚀 Quick Start

```bash
# Download the script
wget -v https://github.com/digitalxs/BashProfileReset/raw/refs/heads/main/reset-bash-profile.sh

# Make it executable
chmod +x reset-bash-profile.sh

# Run it (replace 'username' with the target user)
sudo ./reset-bash-profile.sh username
```

<div align="center">
  <img src="https://raw.githubusercontent.com/digitalxs/BashProfileReset/assets/screenshots/terminal-demo.png" alt="Terminal Demo" width="80%">
  <p><i>The script in action, showing a successful reset operation</i></p>
</div>

---

## 🎯 Features

<div align="center">
  <img src="https://raw.githubusercontent.com/digitalxs/BashProfileReset/assets/screenshots/features-overview.png" alt="Features Overview" width="80%">
</div>

  - Automatic timestamped backups of all bash configuration files
  - Customizable backup locations
  - Backup metadata tracking
  - Preservation of file attributes and permissions
  - Dry-run mode to preview changes without applying them
  - Force mode to skip confirmation prompts
  - Verbose mode for detailed operation logging
  - Custom backup location specification
  - List all available backups for a user
  - Restore from any previous backup
  - Safe restoration process with confirmations
  - Proper permission settings on all files
  - Secure backup directories (700 permissions)
  - Detailed operation logging
  - Color-coded output for better readability
  - Clear operation summaries
  - Helpful next-step guidance
  - Command-line help system

---

## 💾 Installation

1. **Download the script:**
   ```bash
   wget -v https://github.com/digitalxs/BashProfileReset/raw/refs/heads/main/reset-bash-profile.sh
   ```

2. **Make the script executable:**
   ```bash
   chmod +x reset-bash-profile.sh
   ```

3. **Verify installation:**
   ```bash
   ./reset-bash-profile.sh --version
   ```

<div align="center">
  <img src="https://raw.githubusercontent.com/digitalxs/BashProfileReset/assets/screenshots/installation.png" alt="Installation" width="80%">
  <p><i>Installing the script on Debian 12</i></p>
</div>

---

## 📚 Usage

### Basic Usage

Reset a user's bash profile to defaults on Debian 12:

```bash
sudo ./reset-bash-profile.sh username
```

### Advanced Usage Examples

<div align="center">
  <img src="https://raw.githubusercontent.com/digitalxs/BashProfileReset/assets/screenshots/advanced-usage.png" alt="Advanced Usage" width="80%">
  <p><i>Examples of advanced script options in action</i></p>
</div>

#### See All Available Options

```bash
sudo ./reset-bash-profile.sh --help
```

#### Perform a Dry Run (Preview Without Changes)

```bash
sudo ./reset-bash-profile.sh username --dry-run
```

#### Use Force Mode (Skip Confirmations)

```bash
sudo ./reset-bash-profile.sh username --force
```

#### Specify a Custom Backup Directory

```bash
sudo ./reset-bash-profile.sh username --backup-dir /var/backups/bash
```

#### List All Available Backups

```bash
sudo ./reset-bash-profile.sh username --list-backups
```

#### Restore From a Backup

```bash
sudo ./reset-bash-profile.sh username --restore /home/username/bash_backup_20240327_123456
```

#### Combine Multiple Options

```bash
sudo ./reset-bash-profile.sh username --verbose --backup-dir /backups --force
```

---

## 📋 What the Script Does

   - Checks for root privileges
   - Validates the username exists
   - Verifies the home directory is accessible
   - Creates a timestamped backup directory
   - Backs up all bash-related configuration files
   - Creates metadata about the backup
   - Sets secure permissions on the backup
   - Removes existing bash configuration files
   - Copies default files from `/etc/skel/`
   - Sets appropriate ownership and permissions
   - Provides a summary of operations performed
   - Shows the backup location
   - Gives instructions for applying changes

---

## 📁 Files Affected

### Primary Configuration Files
- `~/.bashrc` - Main bash configuration file
- `~/.profile` - Login shell configuration
- `~/.bash_logout` - Commands executed when logging out

### Additional Files (Backed Up If Present)
- `~/.bash_aliases` - Custom command aliases
- `~/.bash_functions` - User-defined bash functions
- `~/.bash_history` - Command history
- `~/.bashrc_help` - Custom help files
- `~/.inputrc` - Readline configuration
- `~/.config/starship.toml` - Starship prompt configuration

---

## 🔍 Troubleshooting

<div align="center">
  <img src="https://raw.githubusercontent.com/digitalxs/BashProfileReset/assets/screenshots/troubleshooting.png" alt="Troubleshooting" width="80%">
  <p><i>Common troubleshooting scenarios</i></p>
</div>

### Common Issues

1. **"Error: Please run as root"**
   - Solution: Run the script with sudo

2. **"Error: User 'username' does not exist"**
   - Solution: Check if the username is correct
   - Verify the user exists on the system

3. **"Warning: Could not backup/copy file"**
   - Solution: Check file permissions
   - Verify the source files exist in `/etc/skel/`

4. **"Error: Backup directory does not exist"**
   - Solution: Verify the path provided to `--restore` is correct
   - Use `--list-backups` to see available backups

### Debug Techniques

1. Run with verbose mode to see detailed operation logs:
   ```bash
   sudo ./reset-bash-profile.sh username --verbose
   ```

2. Use dry-run mode to test operations without making changes:
   ```bash
   sudo ./reset-bash-profile.sh username --dry-run
   ```

---

## 📜 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

<div align="center">
  <img src="https://www.gnu.org/graphics/gplv3-with-text-136x68.png" alt="GPL v3 Logo">
</div>

### GPL v3.0 Summary:

- You can use, modify, and distribute this software.
- If you distribute modified versions, you must make your source code available.
- Changes must be documented.
- The same license applies to derived works.

---

## 👨‍💻 Author

- **Original Author:** Luis Miguel P. Freitas
- **Website:** [DigitalXS.ca](https://digitalxs.ca)
- **Email:** luis@digitalxs.ca

---

## 🙏 Support

If you find this script useful, consider buying me a coffee! Your support helps maintain this project and develop new features.

<div align="center">
  <a href="https://www.buymeacoffee.com/digitalxs" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;">
  </a>
</div>

---

<div align="center">
  <p>
    <a href="https://github.com/digitalxs/BashProfileReset/issues">Report Bug</a> •
    <a href="https://github.com/digitalxs/BashProfileReset/issues">Request Feature</a> •
    <a href="https://digitalxs.ca">Visit Website</a>
  </p>
  
  <p>Made with ❤️ for the Debian community</p>
  
  <img src="https://www.debian.org/logos/openlogo-nd-50.png" alt="Debian Logo">
</div>
