# Thunderbolt Setup

I'm only using ipv6 in this setup, but you could also add ipv4 if you want to.

## Kernel modules

Open the `/etc/modules` file and add the following lines:

```bash
thunderbolt
thunderbolt-net
```

## Interfaces

Open the `/etc/network/interfaces` file and add the following lines at the end before `source /etc/network/interfaces.d/*`:

**Replace `x` in the address** where `x` is your node number e.g., 1,2,3 etc.

I used the following ipv6 addresses fc00::81, fc00::82, fc00::83

Everything else should be same for each node except the `address` field

```bash
auto en05
iface en05 inet manual
        mtu 65520
#Do not edit in GUI

auto en06
iface en06 inet manual
       mtu 65520
#Do not edit in GUI

auto lo:6
iface lo:6 inet static
        address fc00::8x/128
```

If you see any `thunderbolt0` or `thunderbolt1` delete them.

## Rename Thunderbolt connections

Use `udevadm monitor` to find the device IDs. Start the monitor and then plug in your thunderbolt cable. You should see pci path. Copy it.

My PCI paths were `pci-0000:00:0d.2` and `pci-0000:00:0d.3` for all three MS-01 units. Yours may differ.

Create following files for thunderbolt connections:

`/etc/systemd/network/00-thunderbolt0.link` and add following lines:

```bash
[Match]
Path=pci-0000:00:0d.2
Driver=thunderbolt-net
[Link]
MACAddressPolicy=none
Name=en05
```

`/etc/systemd/network/00-thunderbolt1.link` and add following lines:

```bash
[Match]
Path=pci-0000:00:0d.3
Driver=thunderbolt-net
[Link]
MACAddressPolicy=none
Name=en06
```

## Ensure that interfaces are up on reboot

This is probably not needed, but I added it. :)

Create the `/etc/udev/rules.d/10-tb-en.rules` and add following lines:

```bash
ACTION=="move", SUBSYSTEM=="net", KERNEL=="en05", RUN+="/usr/local/bin/pve-en05.sh"
ACTION=="move", SUBSYSTEM=="net", KERNEL=="en06", RUN+="/usr/local/bin/pve-en06.sh"
```

Then create the script `/usr/local/bin/pve-en05.sh` and add following lines:

```bash
#!/bin/bash

# this brings the renamed interface up and reprocesses any settings in /etc/network/interfaces for the renamed interface
/usr/sbin/ifup en05
```

Then create the script `/usr/local/bin/pve-en06.sh` and add following lines:

```bash
#!/bin/bash

# this brings the renamed interface up and reprocesses any settings in /etc/network/interfaces for the renamed interface
/usr/sbin/ifup en06
```

- Make sure to give execute permissions to the scripts: `chmod -x /usr/local/bin/*.sh`
- Run `update-initramfs -u -k all` to update the initramfs with the new udev rules.
- Reboot

### Enable IOMMU if slow performance

Update grub by opening `/etc/default/grub` and add following `intel_iommu=on iommu=pt` to `GRUB_CMDLINE_LINUX_DEFAULT`.

**If you have something else in there, DO NOT REMOVE them! Just append the new options.**

Here's my line `GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"`

If you get this wrong, your system might not boot. So be careful. Do this at your own risk!

I had to do this to get proper performance.
