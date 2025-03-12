# Thunderbolt networking

## Note

These configs are verified to work for Minisforum MS-01 units.

## Overview

The mesh network is being set up using Thunderbolt technology to interconnect three MS-01 nodes. This document outlines the necessary steps to configure a basic mesh network using Thunderbolt interfaces. The goal is to create a redundant and high-speed interconnection between nodes, enhancing both performance and reliability.

## References

The original gist, provided by [scyto](https://gist.github.com/scyto), can be found here: [Thunderbolt Mesh Network Setup](https://gist.github.com/scyto/67fdc9a517faefa68f730f82d7fa3570). This resource provided valuable insights and steps to facilitate the setup process.

## Setup

This particular setup has been tested with MS-01 machines. However, it's important to note that your mileage may vary depending on specific hardware configurations, Thunderbolt compatibility, and other factors unique to your setup.

![Thunderbolt mesh network](<thunderbolt mesh network.png>)

## Prerequisites

- Proxmox VE version 8.3.4 or later
- All nodes updated
- All nodes connected via Thunderbolt cables (I used Cable Matters TB4 cables)

## Steps

Do the following steps for each node in your setup

1. [Thunderbolt setup](thunderbolt-setup.md)
2. [OpenFabric routing](openfabric-routing.md)
