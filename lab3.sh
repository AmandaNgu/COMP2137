#!/bin/bash

SERVER1_IP="192.168.16.2"
SERVER2_IP="192.168.16.3"

#Checking if verbose is enabled
if [[ "$1" == "-verbose" ]]; then
    VERBOSE="-verbose"
else
    VERBOSE=""
fi

#Copy and run the script on Server 1
echo "Configuring Server 1..."
scp configure-host.sh root@$SERVER1_IP:/root/
ssh root@$SERVER1_IP "/root/configure-host.sh -name loghost -ip $SERVER1_IP -hostentry webhost $SERVER2_IP $VERBOSE"

#Copy and run the script on Server 2
echo "Configuring Server 2..."
scp configure-host.sh root@$SERVER2_IP:/root/
ssh root@$SERVER2_IP "/root/configure-host.sh -name webhost -ip $SERVER2_IP -hostentry loghost $SERVER1_IP $VERBOSE"

echo "Updating local /etc/hosts..."
./configure-host.sh -hostentry loghost $SERVER1_IP $VERBOSE
./configure-host.sh -hostentry webhost $SERVER2_IP $VERBOSE

echo "Configuration completed!"
