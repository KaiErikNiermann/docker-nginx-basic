#!/bin/bash

droplet_ip=$(doctl compute droplet list --format PublicIPv4 | grep -v 'Public IPv4' | cut -f1)

if [ "$droplet_ip" == "68.183.215.151" ]; 
then 
    echo MATCH 
fi