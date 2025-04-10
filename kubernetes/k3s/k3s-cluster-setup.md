# K3S Cluster Setup

## Prerequisites

Linux environment like Ubuntu or similar

My setup contains `three (3) Proxmox` hosts in a cluster. Each Proxmox host contains `two (2) VMs`; `one (1) for control plane` and `one (1) for worker`. Having multiple control planes on different hosts I'm able to achieve HA (High Availability). Worker nodes are then used for the actual work for running different pods.

## Terminology

- `server` and `control plane` are same thing
- `worker` and `agent` are same thing

k3s uses terms `server` and `agent`

## Install first server (Control Plane)

Change `<>` arguments and un the following command

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --cluster-init \
  --token <token> \
  --tls-san <dns-name> \
  --tls-san <vip-ip> \
  --disable traefik \
  --disable servicelb \
  --write-kubeconfig-mode=644" sh -
```

- `--cluster-init` - Initialize cluster with embedded etcd datastore for HA
- `--token <token>` - Shared token used for all nodes to join the cluster
- `--tls-san <dns-name>` - DNS name for TLS certificate. E.g., VIP hostname
- `--tls-san <vip-ip>` - Your VIP (Virtual IP) address for TLS certificate
- `--disable traefik` - Disable default traefik ingress controller (we will setup our own later)
- `--disable servicelb` - Disable built-in ServiceLB load balancer (we will setup kube-vip later)
- `--write-kubeconfig-mode=644` - Make kubeconfig readable for non-root users

> [!NOTE]
> You can have multiple `--tls-san` arguments for multiple DNS names and IPs

## Install additional servers (Control Planes)

The command for installing additional servers is pretty much same that we used for installing our first server. Only difference is that instead of defining `--cluster-init` we define the server to join with `--server <dns-name or IP>`

For `<dns-name or IP>` you can use either the first server's own IP/DNS name or VIP/VIP hostname. If you use server's dns name or IP we need to change our config later when we setup our VIP.

Run this command on all additional servers that you want to join into the cluster as control planes

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --server <dns-name or IP>:6443 \
  --token <token> \
  --tls-san <dns-name> \
  --tls-san <vip-ip> \
  --disable traefik \
  --disable servicelb \
  --write-kubeconfig-mode=644" sh -
```

## Install agents (workers)

Adding agents is really straight forward process. We only need a control plane's IP (we can use the first server's IP here again). We also need the same `token` we used in the previous step as well.

Again, run this on each hosts which you want to become an agent

```bash
curl -sfL https://get.k3s.io | K3S_URL="<dns-name or IP>:6443" K3S_TOKEN="<token>" sh -
```

## Check cluster's status

Run command on any `control plane`

```bash
kubectl get nodes
```

You should see something like this

```bash
NAME           STATUS   ROLES                       AGE     VERSION
k3s-cp-1       Ready    control-plane,etcd,master   19h     v1.32.3+k3s1
k3s-cp-2       Ready    control-plane,etcd,master   19h     v1.32.3+k3s1
k3s-cp-3       Ready    control-plane,etcd,master   19h     v1.32.3+k3s1
k3s-worker-1   Ready    <none>                      4h      v1.32.3+k3s1
k3s-worker-2   Ready    <none>                      3h42m   v1.32.3+k3s1
k3s-worker-3   Ready    <none>                      3h42m   v1.32.3+k3s1
```
