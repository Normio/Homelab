# Cloud-Init Server Provisioning

A cloud-init configuration for bootstrapping Linux servers with a non-root user and hardened SSH settings.

## Overview

This cloud-init file automates initial server setup by:

- Creating a user with passwordless sudo access
- Configuring SSH key-based authentication
- Applying SSH security hardening
- Disabling root login and password authentication

## Configuration

### User Setup

```yaml
users:
  - name: {your-username-here}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    lock_passwd: false
    passwd: $6$rounds=4096$yoursalt$yourhash...
    ssh_authorized_keys:
      - ssh-rsa AAAA... public key here
```

Replace `{your-username-here}` with your desired username. Generate the password hash using:

```bash
mkpasswd --method=SHA-512 --rounds=4096
```

> ⚠️ **Important: `lock_passwd` Behavior**
>
> The `lock_passwd: false` setting is explicitly required on some distributions (e.g., Ubuntu) to prevent the user account from being locked. When set to `true` or omitted, the account password may be prefixed with `!` in `/etc/shadow`, which locks the account entirely—not just password login.
>
> On certain OS versions, a locked account can prevent SSH public key authentication from working, even with valid keys configured. If you cannot SSH into your server after provisioning, check `/etc/shadow` for a locked account (`!` prefix) and unlock it with:
>
> ```bash
> sudo passwd -u {username}
> ```

### SSH Hardening

The configuration writes a drop-in file to `/etc/ssh/sshd_config.d/99-hardening.conf`:

| Setting | Value | Purpose |
|---------|-------|---------|
| `PermitRootLogin` | no | Blocks direct root SSH access |
| `PubkeyAuthentication` | yes | Enables SSH key authentication |
| `PasswordAuthentication` | no | Disables password login |
| `MaxAuthTries` | 2 | Limits failed attempts before disconnect |
| `LoginGraceTime` | 20s | Reduces window for authentication |
| `AllowTcpForwarding` | no | Disables SSH tunneling |
| `X11Forwarding` | no | Disables X11 display forwarding |
| `AllowUsers` | wombat | Restricts SSH to specific user(s) |

> **Note:** Update `AllowUsers` to match your configured username.

## Usage

1. Copy the cloud-init file and customize:
   - Set your username
   - Generate and set password hash
   - Add your SSH public keys
   - Update `AllowUsers` in the SSH config

2. Provide the file to your cloud provider or hypervisor during instance creation (typically as "user data").

3. After first boot, connect via SSH:
   ```bash
   ssh {username}@{server-ip}
   ```

## Troubleshooting

**Cannot connect via SSH after provisioning:**
- Verify the account isn't locked: `sudo grep {username} /etc/shadow`
- Check SSH service status: `systemctl status ssh`
- Review auth logs: `journalctl -u ssh` or `/var/log/auth.log`

**SSH keys not working:**
- Confirm `~/.ssh/authorized_keys` exists with correct permissions (600)
- Ensure the `.ssh` directory has permissions 700
- Verify `AllowUsers` includes your username