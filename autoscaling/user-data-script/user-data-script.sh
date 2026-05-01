#!/bin/bash
# Launch Template User Data Script
# Automatically runs when a new EC2 instance is launched by the Auto Scaling Group.
# Installs dependencies and starts the Python web application.

# Update system packages
yum update -y

# Install Git and Python 3
yum install git python3 -y

# Clone the application from GitHub
git clone https://github.com/qiaoli116/ictcld401-python-app.git /home/ec2-user/app

# Navigate to the application directory
cd /home/ec2-user/app

# Install Python dependencies
pip3 install -r requirements.txt

# Start the application (runs on port 80)
python3 app.py &
