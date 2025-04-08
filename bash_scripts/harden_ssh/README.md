# SSH Server Hardening Script

> [!NOTE]
> Link to the script [harden_ssh.sh](harden_ssh.sh)

This script is designed to **harden the SSH configuration** on a Linux server by enforcing secure settings and disabling insecure authentication methods. It ensures consistent configuration by modifying or appending specific directives in `/etc/ssh/sshd_config`, and restarting the SSH service to apply changes.

You could also set these up using cloud-init, Ansible or some other method.

---

## 🔧 What It Does

### 1. **Updates or Appends SSH Configuration Options**

The script sets the following SSH daemon settings:

| Setting                           | Value                  | Purpose                                                       |
|-----------------------------------|------------------------|---------------------------------------------------------------|
| `PermitRootLogin`                 | `no`                   | Disables SSH login as `root`                                  |
| `PubkeyAuthentication`            | `yes`                  | Enables public key (e.g., FIDO2) authentication               |
| `PasswordAuthentication`          | `no`                   | Disables password login                                       |
| `KbdInteractiveAuthentication`    | `no`                   | Disables keyboard-interactive login                           |
| `ChallengeResponseAuthentication` | `no`                   | Disables challenge-response login (e.g., one-time passwords)  |
| `MaxAuthTries`                    | `2`                    | Limits failed authentication attempts                         |
| `LoginGraceTime`                  | `20s`                  | Reduces time allowed for successful login                     |
| `AllowTcpForwarding`              | `no`                   | Disables TCP port forwarding                                  |
| `X11Forwarding`                   | `no`                   | Disables X11 (GUI) forwarding                                 |
| `AllowAgentForwarding`            | `no`                   | Disables SSH agent forwarding                                 |
| `UsePAM`                          | `no`                   | Disables PAM (Pluggable Authentication Modules)               |
| `AuthenticationMethods`           | `publickey`            | Enforces public key-only authentication                       |
| `AuthorizedKeysFile`              | `.ssh/authorized_keys` | Sets path to authorized public keys file                      |

Each line is either modified (if it already exists at the top of a line or is commented) or appended if missing.

---

### 2. **Ensures Access Control**

It verifies and ensures this line exists:

```conf
AllowUsers wombat
