# Auto attach/detach YubiKey on RDP login/logout (Ubuntu + GNOME)

This guide sets up a systemd user service to automatically attach your YubiKey when an RDP session starts, and detach it when the session ends.

Tested on Ubuntu.

## Prerequisites

- Ubuntu with GNOME desktop installed
- `usbip` installed on Ubuntu (see [Install usbip](../usbip/README.md))
- YubiKey attached on remote machine using `usbip`
- Remote login enabled on Ubuntu
- Login user with home directory (we'll use wombat as example)

## Step 1: Enable user lingering

This allows user systemd services to survive after logout/logon cycles.

```bash
sudo loginctl enable-linger wombat
```

## Step 2: Copy these scripts

Copy the attach and detach scripts in the user's home directory.

`/home/wombat/attach-yubikey.sh`
[Copy script here](attach-yubikey.sh)

`/home/wombat/detach-yubikey.sh`
[Copy script here](detach-yubikey.sh)

Make them executable:

```bash
sudo chmod +x /home/wombat/attach-yubikey.sh /home/wombat/detach-yubikey.sh
```

## Step 3: Create the systemd user service

Create the systemd user service to manage YubiKey attach/detach.

`~/.config/systemd/user/yubikey-session.service`

```bash
[Unit]
Description=Attach YubiKey on RDP session start and detach on session end
After=graphical-session.target
Requires=graphical-session.target

[Service]
Type=oneshot
ExecStart=/home/wombat/attach-yubikey.sh
ExecStopPost=/home/wombat/detach-yubikey.sh
RemainAfterExit=true

[Install]
WantedBy=graphical-session.target
```

Reload systemd for the user:

```bash
systemctl --user daemon-reload
```

## Step 4: Enable the service

Enable the service to start with the GNOME graphical session:

```bash
systemctl --user enable yubikey-session.service
```

## Step 5: Allow passwordless sudo for YubiKey scripts

As our scripts are using `usbip` with `sudo` we need to configure passwordless `sudo` for the required commands

Open a sudoers drop-in file

```bash
sudo visudo -f /etc/sudoers.d/yubikey-session
```

Copy following lines to the new file

We are allowing only specific commands for the security

```bash
# Allow usbip attach without password
wombat ALL=(ALL) NOPASSWD: /usr/bin/usbip attach -r *

# Allow usbip detach without password
wombat ALL=(ALL) NOPASSWD: /usr/bin/usbip detach -p *

# Allow chmod on /dev/hidraw* without password
wombat ALL=(ALL) NOPASSWD: /usr/bin/chmod a+rw /dev/hidraw*
```

Set strict permissions for the newly created file

```bash
sudo chmod 440 /etc/sudoers.d/yubikey-session
```

## Step 6: Test it

1. RDP into the machine
2. see logs `journalctl --user -u yubikey-session.service` - you should see that Yubikey was attached
3. Close the RDP session
4. Reconnect and check logs again `journalctl --user -u yubikey-session.service` - you should now see that Yubikey was detached (and attached again due to reconnect)
