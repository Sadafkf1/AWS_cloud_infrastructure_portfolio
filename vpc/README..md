# Virtual Private Cloud (VPC)

## Overview

This part involved designing and building a custom AWS Virtual Private Cloud — an isolated virtual network that all other resources live inside. Rather than using AWS's default VPC, a custom one was created from scratch to demonstrate understanding of IP addressing, subnet design, and internet connectivity.

## Network Design

| Resource | Configuration |
|----------|---------------|
| VPC CIDR | 192.168.10.0/24 (256 addresses total) |
| Subnet1 | 192.168.10.0/25 — Network: 192.168.10.0, Broadcast: 192.168.10.127 |
| Subnet 2 | 192.168.10.128/25 — Network: 192.168.10.128, Broadcast: 192.168.10.255 |
| Internet Gateway | Attached to VPC; both subnets route to it |

The /24 was split into two equal /25 subnets, each with 128 addresses (126 usable). Both subnets were made public by routing 0.0.0.0/0 through the Internet Gateway.

## Why This Design?

Splitting a VPC into subnets is standard practice even for simple environments, because it:

* Allows resources to be isolated by purpose (e.g. public-facing vs. internal)

* Prepares the architecture for multi-AZ deployments

* Gives fine-grained control over route tables and security groups per subnet

Using 192.168.10.0/24 as the CIDR avoids conflicts with AWS's default VPC range (172.31.0.0/16) and follows RFC 1918 private address conventions.

## What Was Built

### VPC and Associated Resources

The following resources were created:

* Custom VPC with the /24 CIDR block

* Two /25 subnets in the same Availability Zone

* An Internet Gateway attached to the VPC

* Route tables updated so both subnets route internet traffic through the gateway

Screenshots:

| Screenshot | What it shows |
|------------|---------------|
| [`screenshots/vpc-created.png`](./screenshots/vpc-created.png) | VPC with CIDR 192.168.10.0/24 |
| [`screenshots/subnets-created.png`](./screenshots/subnets-created.png) | Subnet 1 (192.168.10.0/25), Subnet 2 (192.168.10.128/25) |
| [`screenshots/internet-gateway.png`](./screenshots/internet-gateway.png) | Internet Gateway attached to VPC |

### Verification with EC2 Instances

Two EC2 instances were launched — one in each subnet — to confirm the network was working correctly.

| Check | EC2 #1 (Subnet 1) | EC2 #2 (Subnet 2) |
|-------|-------------------|-------------------|
| Private IP in correct range | Yes | Yes |
| Public IP assigned | Yes | Yes |
| Internet access | Yes| Yes|

Screenshots:

| Screenshot | What it shows |
|------------|---------------|
| [`screenshots/ec2-subnet1-details.png`](./screenshots/ec2-subnet1-details.png) | EC2 #1 with private and public IP |
| [`screenshots/ec2-subnet2-details.png`](./screenshots/ec2-subnet2-details.png) | EC2 #2 with private and public IP |

## Key Learnings

CIDR notation becomes intuitive once you work through the math by hand. A /25 is exactly half of a /24 — you're just moving the subnet boundary one bit to the right. Verifying connectivity by actually launching EC2 instances (rather than just trusting the console) is the right approach to infrastructure validation.