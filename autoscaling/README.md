# Multi-Layer Web Application with Auto Scaling

## Overview

This part brings together everything from the other parts into a production-like, scalable web application architecture. Instead of a single EC2 instance serving traffic, an Application Load Balancer distributes requests across multiple EC2 instances that are automatically created and removed by an Auto Scaling Group based on real-time demand.

The result is an application that can handle traffic spikes without manual intervention and scales back down to save costs when traffic drops.

Architecture

!(architecture.png)

## Resource Summary

| Resource | Name | Key Details |
|----------|------|-------------|
| Target Group | web-app-targets | Protocol: HTTP:80, Health check: /, VPC: vpc-07a0b6d5f97e64a0f |
| Load Balancer | web-app-lb | Type: Application, Scheme: Internet-facing, DNS: web-app-lb-1833895790.us-east-1.elb.amazonaws.com | Launch Template | web-app-template | AMI: ami-0953476d60561c955 (Amazon Linux 2), Type: t2.micro, User data: app deployment script | 
| Auto Scaling Group | web-app-autoscale | Min: 1, Desired: 1, Max: 6, 6 subnets across AZs, Health check: EC2 |
| Scaling Policy | Target Tracking | Metric: ALB request count per target, Target: 15 req/target, Warm-up: 300s |

## What Was Built

### Infrastructure Setup

All resources were created in the following order (order matters — each component depends on the previous one):

1. Target Group — defines which EC2 instances receive traffic and how health checks work

2. Application Load Balancer — receives public traffic and forwards it to the target group

3. Launch Template — defines the exact configuration of every EC2 instance the ASG will create, including a user data script that automatically installs and starts the application on launch

4. Auto Scaling Group — uses the launch template to maintain the desired number of instances and scales based on the policy

Screenshots:

| Screenshot | What it shows |
|------------|---------------|
| [`screenshots/target-group.png`](./screenshots/target-group.png) | Target group with health check configuration |
| [`screenshots/load-balancer.png`](./screenshots/load-balancer.png) | ALB in "Active" state with DNS name | 
| [`screenshots/launch-template.png`](./screenshots/launch-template.png) | Launch template with instance type, AMI, and user data | 
| [`screenshots/asg-created.png`](./screenshots/asg-created.png) | Auto Scaling Group with min/desired/max settings |
| [`screenshots/ec2-instances-running.png`](./screenshots/ec2-instances-running.png) | At least 2 EC2 instances running behind the ALB | 

### Application Verification

With at least two EC2 instances running, the ALB was tested by hitting the load balancer's DNS endpoint repeatedly. The load balancer distributed requests to different instances on each request, confirming it was routing traffic correctly.

Screenshots:

| Screenshot | What it shows | 
|------------|---------------|
| [`screenshots/app-via-alb.png`](./screenshots/app-via-alb.png) | Application accessible through the ALB DNS name |
| [`screenshots/load-balancer-routing.png`](./screenshots/load-balancer-routing.png) | Different EC2 instance IDs showing in responses (proving ALB is routing) |

### Auto Scaling Policy

A Target Tracking Policy was configured with the following strategy:

| Setting | Value | 
|---------|-------|
| Metric | ALB request count per target| 
| Target value | 15 requests per instance |
| Scale-out behaviour | Add instances when requests exceed 15/instance | 
| Scale-in behaviour | Remove instances when demand drops (enabled) |
| Instance warm-up | 300 seconds (instances need time to be ready before being included in metrics) |

This policy was chosen because the application's load is best measured by the number of requests being handled, rather than raw CPU utilisation. Request count directly reflects what the users are experiencing.

Screenshots:

| Screenshot | What it shows | 
|------------|---------------|
| [`screenshots/scaling-policy.png`](./screenshots/scaling-policy.png) | Target tracking policy configured on the ASG |

### Load Test & Auto Scaling Verification

Testing strategy: loader.io was used to send 750 concurrent client requests per minute to the ALB endpoint. This was enough to push the request count per instance above the 15-request threshold, triggering scale-out.

Test results:

| Phase | Observation |
|-------|-------------|
| Scale-out | New EC2 instances automatically launched as traffic increased |
| At peak | Multiple instances running simultaneously |
| Scale-in | Instances terminated automatically after traffic dropped and the cooldown period elapsed

Screenshots:

| Screenshot | What it shows | 
|------------|---------------|
| [`load-test-results/loaderio-test.png`](./load-test-results/loaderio-test.png) | loader.io sending 750 clients/min to the ALB |
| [`screenshots/asg-activity-log-scaleout-scalein.png`](./screenshots/asg-activity-log-scaleout-scalein.png) | ASG activity log showing new instances launched |
| [`screenshots/cloudwatch-metrics.png`](./screenshots/cloudwatch-metrics.png) | CloudWatch request-count metric spiking during the test |

### Technical Documentation

Full resource details as provisioned:

#### Target Group

* Name: web-app-targets

* Protocol: HTTP, Port: 80

* Health check path: /

* VPC: vpc-07a0b6d5f97e64a0f

#### Application Load Balancer

* Name: web-app-lb

* Type: Application

* Scheme: Internet-facing

* DNS: web-app-lb-1833895790.us-east-1.elb.amazonaws.com

* Region: us-east-1

#### Launch Template

* Name: web-app-template

* AMI: ami-0953476d60561c955 (Amazon Linux 2)

* Instance type: t2.micro

* User data: see 'user-data-script.sh'

#### Auto Scaling Group

* Name: web-app-autoscale

* Min capacity: 1 | Desired: 1 | Max: 6

* Subnets: subnet-08cf7413a3d1c02c3, subnet-07eea325601d30213, subnet-0b0e41daa63dc6498, subnet-09f1fa3d21b22e377, subnet-0b9476cdeca82ce9d, subnet-049795ea0b1130bee

* Health check type: EC2

#### Scaling Policy

* Type: Target Tracking

* Metric: ALB request count per target

* Target value: 15 requests/target

* Warm-up period: 300 seconds

* Scale-in: Enabled


###  Feedback & Improvements

During the project review, two pieces of feedback were received and acted on:

Feedback 1: "Need better monitoring"

Response: Configured CloudWatch alarms for CPU utilisation, memory, and application errors. Set up SNS notifications for all scaling events so the team receives alerts when instances are added or removed.

Feedback 2: "Security concerns"

Response: Implemented WAF (Web Application Firewall) on the ALB to filter malicious requests. Restricted security groups to only the ports the application actually uses. Enabled VPC Flow Logs to capture network traffic for audit and troubleshooting purposes.

## Key Learnings

Auto Scaling is only as reliable as the health checks and metrics driving it. The 300-second warm-up period is important — without it, a freshly launched instance that isn't ready yet could be counted in the metrics and cause the policy to make incorrect scaling decisions. Load testing isn't optional for an auto-scaling setup: you need to actually generate traffic to prove the policy triggers correctly.