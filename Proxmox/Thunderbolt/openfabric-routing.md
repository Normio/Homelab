# OpenFabric Routing

**Do all steps on each node.**

These configs are verified to work for Minisforum MS-01 units.

## Enable IPv6 forwarding

Open file `/etc/sysctl.conf` and uncomment the following line:

```bash
#net.ipv6.conf.all.forwarding=1
```

Reboot server running `reboot now` command.

## Install FRR

Install FRR (Free Range Routing) using the following commands: `apt install frr`

Open file `/etc/frr/daemons` and enable fabricd by changing `fabricd=no` to `fabricd=yes`

## Fix FRR boot timing issues

Open file `/etc/systemd/system/frr.service.d/dependencies.conf` and add the following:

```bash
[Unit]
Wants=sys-subsystem-net-devices-en05.device sys-subsystem-net-devices-en06.device
After=sys-subsystem-net-devices-en05.device sys-subsystem-net-devices-en06.device
```

Open file `/lib/systemd/system/frr.service` and change `[Unit]` section to the following:

```bash
[Unit]
Description=FRRouting
Documentation=https://frrouting.readthedocs.io/en/latest/setup.html
Wants=network-online.target
After=network-online.target systemd-sysctl.service
OnFailure=heartbeat-failed@%n
```

Restart network services with `systemctl restart networking`

## Configure OpenFabric

1. Enter to FRR CLI with command `vtysh`
2. (Optional) check current config with `show running-config`
3. Enter configuration mode with `configure`
4. Apply the following configuration by copy-pasting (you may need to press enter to set the last !):

    **Replace `X` in the address with your node number e.g., 1,2,3 etc.**

    Tip: copy first to some text editor and replace X before copy-pasting to FRR CLI:

    ```bash
    ipv6 forwarding
    !
    interface en05
    ipv6 router openfabric 1
    exit
    !
    interface en06
    ipv6 router openfabric 1
    exit
    !
    interface lo
    ipv6 router openfabric 1
    openfabric passive
    exit
    !
    router openfabric 1
    net 49.0000.0000.000X.00
    exit
    !
    ```

5. Exit configuration mode with `end`
6. Save configuration with `write memory`
7. (Optional) check current config again with `show running-config` to make sure everything is correct. If you see any errors, you can edit `/etc/frr/frr.conf` directly and restart frr service.
8. Exit the CLI with `exit`

Once you have done steps 1 to 8 on each node you can check connectivity between nodes using:
`vtysh -c "show openfabric topology"`

You should see something like this:

My nodes are named `hippo-1`, `hippo-2` and `hippo-3`.

```bash
Area 1:
IS-IS paths to level-2 routers that speak IP
Vertex               Type         Metric Next-Hop             Interface Parent
hippo-1                                                               

IS-IS paths to level-2 routers that speak IPv6
Vertex               Type         Metric Next-Hop             Interface Parent
hippo-1                                                               
fc00::81/128         IP6 internal 0                                     hippo-1(4)
hippo-2              TE-IS        10     hippo-2              en06      hippo-1(4)
hippo-3              TE-IS        10     hippo-3              en05      hippo-1(4)
fc00::82/128         IP6 internal 20     hippo-2              en06      hippo-2(4)
fc00::83/128         IP6 internal 20     hippo-3              en05      hippo-3(4)

IS-IS paths to level-2 routers with hop-by-hop metric
Vertex               Type         Metric Next-Hop             Interface Parent
```

You should now be able to ping other nodes via thunderbolt mesh network.
Try `ping fc00::82` or `ping fc00::83` from your node.
