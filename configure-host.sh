#!/bin/bash

VERBOSE=false
HOSTNAME=""
IP=""
HOSTENTRY=""

function print_verbose {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -verbose)
            VERBOSE=true
            shift
            ;;
        -name)
            HOSTNAME="$2"
            shift 2
            ;;
        -ip)
            IP="$2"
            shift 2
            ;;
        -hostentry)
            HOSTENTRY="$2"
            IP="$3"
            shift 3
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

#Change the hostname if needed
if [ ! -z "$HOSTNAME" ]; then
    CURRENT_HOSTNAME=$(hostname)
    if [ "$CURRENT_HOSTNAME" != "$HOSTNAME" ]; then
        print_verbose "Changing hostname from $CURRENT_HOSTNAME to $HOSTNAME"
        echo "$HOSTNAME" > /etc/hostname
        hostname "$HOSTNAME"
        logger "Hostname changed to $HOSTNAME"
    else
        print_verbose "Hostname is already $HOSTNAME"
    fi
fi

#Change the IP address if needed
if [ ! -z "$IP" ]; then
    CURRENT_IP=$(hostname -I | awk '{print $1}')
    if [ "$CURRENT_IP" != "$IP" ]; then
        print_verbose "Changing IP address from $CURRENT_IP to $IP"
        
        # Update the netplan configuration (assuming 'eth0' interface)
        echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - $IP/24" > /etc/netplan/01-netcfg.yaml
        netplan apply
        logger "IP address changed to $IP"
    else
        print_verbose "IP address is already $IP"
    fi
fi

#Update /etc/hosts file with the provided host entry
if [ ! -z "$HOSTENTRY" ]; then
    grep -q "$HOSTENTRY" /etc/hosts
    if [ $? -eq 0 ]; then
        print_verbose "Host entry for $HOSTENTRY already exists."
    else
        print_verbose "Adding host entry $HOSTENTRY with IP $IP"
        echo "$IP $HOSTENTRY" >> /etc/hosts
        logger "Added host entry $HOSTENTRY with IP $IP"
    fi
fi

echo "Configuration complete!"
