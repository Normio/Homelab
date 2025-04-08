# Ubuntu

## System Maintenance Command

This command performs a complete update and cleanup of a Debian-based Linux system.

### Command

```bash
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y
```

Explanation

- `sudo apt update`: Updates the local package index with the latest changes in repositories.
- `sudo apt full-upgrade -y`: Upgrades all installed packages to their latest versions. It intelligently handles changing dependencies and may remove obsolete packages if necessary.
- `sudo apt autoremove -y`: Removes packages that were installed as dependencies but are no longer needed.

### Usage

Use this command regularly to:

- Apply the latest security patches.
- Keep your system and software up to date.
- Clean up unused packages to save disk space.
