#!/bin/sh

# This script starts Corylus via the Puma web server - http://puma.io/

# Customize these variables first
CORYLUS_PATH=/usr/local/corylus
BIND_IP_PORT=[2001:db8::8]:80

cd $CORYLUS_PATH
/usr/local/bin/puma -b tcp://${BIND_IP_PORT}
