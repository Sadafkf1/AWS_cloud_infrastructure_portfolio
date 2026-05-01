# EC2 Instance & Web Application Hosting

##Overview

This part involved provisioning a Linux EC2 virtual machine, deploying a Python web application onto it, and making the application accessible from the internet. The storage was then expanded by attaching a second EBS volume, demonstrating how cloud storage can be modified without replacing the instance.

Instance Specifications

| Property | Value |
|----------|-------|
| Operating System | Amazon Linux 2 |
| Instance Type | t2.micro (1 vCPU, 1 GB RAM) |
| Root Storage | 8 GB EBS (gp2) |
| Additional Storage | 15 GB EBS |
| Application | Python web app (source)|

## What Was Built

### EC2 Instance

A Linux EC2 instance was launched with the specified configuration. A security group was created to allow inbound HTTP (port 80) and SSH (port 22) traffic from the internet, while blocking everything else by default.

Screenshots:

| Screenshot | What it shows | 
|------------|---------------|
| [`screenshots/ec2-instance-details.png`](./screenshots/ec2-instance-details.png) |Instance summary with OS, type, and storage | 

### Web Application Deployment

After launching the instance, the application was deployed by:

1. SSH-ing into the instance using the key pair

2. Installing Git and Python dependencies

3. Cloning the application from GitHub

4. Starting the application server

5. Verifying the app was accessible via the instance's public IP

!(bash-script.png)

Screenshots:

| Screenshot | What it shows |
|------------|---------------|
| [`screenshots/app-running-browser.png`](./screenshots/app-running-browser.png) | Web application accessible from a browser via public IP | 
| [`screenshots/ssh-connection.png`](./screenshots/ssh-connection.png) | Terminal showing successful SSH connection to the instance |

### Storage Expansion

A second EBS volume of 15 GB was created and attached to the running instance without any downtime. This demonstrates how cloud infrastructure can be modified live — no need to stop or rebuild the server.

Screenshots:

| Screenshot | What it shows |
|------------|---------------|
| [`screenshots/ebs-volume-details.png`](./screenshots/ebs-volume-details.png) | EC2 instance storage tab showing 8 GB | 
| [`screenshots/ebs-volume-attached.png`](./screenshots/ebs-volume-attached.png) | New 15 GB volume in the EBS console |

## Key Learnings

Deploying an application manually (without automation) is valuable because it builds understanding of every step the automation later needs to replicate. The storage expansion exercise is a good example of how cloud elasticity works in practice — you add capacity without touching the running application.