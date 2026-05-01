# Amazon RDS (Relational Database Service)

## Overview

This part involved provisioning a managed MySQL database using Amazon RDS, then connecting to it remotely from outside of AWS. Using a managed database service like RDS removes the need to handle patching, backups, and availability manually — tasks that consume significant operational effort with self-hosted databases.

## Database Specifications

| Property | Value |
|----------|-------|
| Engine | MySQL |
| Instance Class | db.m5.large (2 vCPU, 8 GB RAM) | 
| Storage | 20 GB SSD (gp2) |
| Public Access | Enabled|
| Availability | Single AZ (dev/test setup) |
| Default Port | 3306 |

## What Was Built

### RDS Instance Creation

The database instance was created through the AWS RDS console. A security group was configured to allow inbound MySQL traffic (port 3306) from the connecting IP address. Public accessibility was enabled so that the remote connection test could be performed from a local PC.
Note on public access in production: Enabling public access is appropriate for a development/test environment. In a production setup, the RDS instance would be placed in a private subnet and accessed only through EC2 instances or a VPN — never directly from the internet.

Screenshots:

| Screenshot | What it shows |
|------------|---------------|
| [`screenshots/rds-instance-created.png`](./screenshots/rds-instance-created.png) | RDS instance in "Available" state with endpoint, engine, and instance class |

### Remote Connection

The database was connected to remotely using a MySQL client. The connection was made using the RDS endpoint, database port (3306), and the master credentials set during instance creation.

Connection details used:

| Parameter | Value |
|-----------|-------|
| Host | `<rds-endpoint>`.us-east-1.rds.amazonaws.com |
| Port | 3306 |
| User | admin | 
| Client | MySQL Workbench / mysql CLI |

Screenshots:

| Screenshot | What it shows |
|------------|---------------|
| [`screenshots/rds-remote-connection.png`](./screenshots/rds-remote-connection.png) | Successful remote connection to RDS from local PC |

##Managed vs Self-Hosted: Why RDS?

| Responsibility | Self-Hosted MySQL | Amazon RDS |
|----------------|-------------------|------------|
| OS patching | Manual | AWS handles it |
| Database patching | Manual | AWS handles it |
| Automated backups | Manual setup | Built-in |
| Failover | Manual setup | Multi-AZ option |
| Scaling | Manual | Storage auto-scales | 
| Monitoring | Manual setup | CloudWatch built-in |

For a development team, RDS reduces the operational overhead significantly — the team focuses on the application data, not on keeping the database server running.

## Key Learnings

Remote database access depends on three things lining up correctly: the right security group rules, public accessibility enabled, and the correct endpoint. Troubleshooting connection failures is a useful exercise because it forces you to think through each layer — network, security, credentials — systematically.