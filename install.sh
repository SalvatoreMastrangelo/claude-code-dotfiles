#!/bin/bash
# Installs the Claude Code status line on this machine:
#   - copies statusline.sh to ~/.claude/
#   - adds the statusLine entry to ~/.claude/settings.json, leaving every other setting alone
# Safe to re-run; run it again after a `git pull` to pick up changes.
set -euo pipefail

cd "$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
STATUSLINE='{"type": "command", "command": "~/.claude/statusline.sh", "refreshInterval": 2}'

if ! command -v jq >/dev/null; then
  echo "error: jq is required (apt install jq / brew install jq)" >&2
  exit 1
fi

mkdir -p "$CLAUDE_DIR"
install -m 755 statusline.sh "$CLAUDE_DIR/statusline.sh"
echo "installed $CLAUDE_DIR/statusline.sh"

[[ -s $SETTINGS ]] || echo '{}' > "$SETTINGS"
if ! jq empty "$SETTINGS" 2>/dev/null; then
  echo "error: $SETTINGS is not valid JSON, fix it and re-run" >&2
  exit 1
fi

if jq -e --argjson want "$STATUSLINE" '.statusLine == $want' "$SETTINGS" >/dev/null; then
  echo "settings.json already has the statusLine entry"
else
  cp -p "$SETTINGS" "$SETTINGS.bak"
  updated=$(jq --argjson want "$STATUSLINE" '.statusLine = $want' "$SETTINGS")
  # Write in place so the file keeps its permissions (and stays a symlink if it is one)
  printf '%s\n' "$updated" > "$SETTINGS"
  echo "added statusLine to $SETTINGS (previous version saved as settings.json.bak)"
fi

echo "done: the status line shows up after the next assistant message, or restart Claude Code"
