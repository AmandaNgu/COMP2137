#!/bin/bash

# Checking if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run this script as root."
    exit 1
fi

echo "Starting system configuration..."

# Configuring the network
echo "Configuring network, please wait"
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"

if grep -q "192.168.16.21" "$NETPLAN_FILE"; then
    echo "Network is already set to 192.168.16.21."
else
    echo "Updating netplan configuration..."
    echo "network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.16.21/24" > "$NETPLAN_FILE"
    netplan apply
    echo "Netplan configuration applied."
fi

# Update /etc/hosts
echo "Updating /etc/hosts..."
if grep -q "192.168.16.21 server1" /etc/hosts; then
    echo "/etc/hosts is already updated."
else
    sed -i '/server1/d' /etc/hosts
    echo "192.168.16.21 server1" >> /etc/hosts
    echo "/etc/hosts updated."
fi

# Installing apache2 and squid if not already there
echo "Installing apache2 and squid..."
apt update
apt install -y apache2 squid

# Create users
create_user() {
    local username=$1
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
    else
        echo "Creating user $username..."
        useradd -m -s /bin/bash "$username"
        mkdir -p /home/$username/.ssh
        ssh-keygen -t rsa -f /home/$username/.ssh/id_rsa -N "" -q
        ssh-keygen -t ed25519 -f /home/$username/.ssh/id_ed25519 -N "" -q
        cat /home/$username/.ssh/id_rsa.pub >> /home/$username/.ssh/authorized_keys
        cat /home/$username/.ssh/id_ed25519.pub >> /home/$username/.ssh/authorized_keys
        chown -R $username:$username /home/$username/.ssh
        echo "User $username created with SSH keys."
    fi
}

# List of users to create
echo "Creating users..."
create_user "dennis"
create_user "aubrey"
create_user "captain"
create_user "snibbles"
create_user "brownie"
create_user "scooter"
create_user "sandy"
create_user "perrier"
create_user "cindy"
create_user "tiger"
create_user "yoda"

# Adding sudo permission for dennis
echo "Granting sudo access to dennis..."
usermod -aG sudo dennis

echo "System configuration complete!"
exit 0
