# Helper scripts

These are scripts which allows you to perform task more easily on Proxmox VE

# How to run the scripts

Run the following command on `Proxmox PV Shell`

```sh
bash -c "$(wget -qLO - https://github.com/Normio/Homelab/raw/main/Proxmox/<name of the script>.sh)"
```

Change the name according to the script you want to run

## Post PVE install (name: post-pve-install)

- Updates sources
- Disables `enterprise` repository
- Enables `no-subscription` repository
- Corrects `ceph package` repositories
- Add `pvetest` repository (set it disabled)
- Disable subscription nag
- Enable `high availability` or disable `high availability`
- Update `Proxmox VE`
- Reboot `Proxmox VE`

```sh
bash -c "$(wget -qLO - https://github.com/Normio/Homelab/raw/main/Proxmox/post-pve-install.sh)"
```

## Post PBS install (name: post-pbs-install)

- Updates sources
- Disables `enterprise` repository
- Enables `no-subscription` repository
- Add `pvetest` repository (set it disabled)
- Disable subscription nag
- Update `Proxmox Backup Server`
- Reboot `Proxmox Backup Server`

```sh
bash -c "$(wget -qLO - https://github.com/Normio/Homelab/raw/main/Proxmox/post-pbs-install.sh)"
```
