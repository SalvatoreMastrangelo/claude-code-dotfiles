#!/bin/bash
# Installs the Claude Code status lines on this machine:
#   - copies statusline.sh and subagent-statusline.sh to ~/.claude/
#   - adds the statusLine and subagentStatusLine entries to ~/.claude/settings.json,
#     leaving every other setting alone
# Safe to re-run; run it again after a `git pull` to pick up changes.
set -euo pipefail

cd "$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPTS=(statusline.sh subagent-statusline.sh)
WANT='{
  "statusLine": {"type": "command", "command": "~/.claude/statusline.sh", "refreshInterval": 2},
  "subagentStatusLine": {"type": "command", "command": "~/.claude/subagent-statusline.sh"}
}'

if ! command -v jq >/dev/null; then
  echo "error: jq is required (apt install jq / brew install jq)" >&2
  exit 1
fi

mkdir -p "$CLAUDE_DIR"
for script in "${SCRIPTS[@]}"; do
  install -m 755 "$script" "$CLAUDE_DIR/$script"
  echo "installed $CLAUDE_DIR/$script"
done

[[ -s $SETTINGS ]] || echo '{}' > "$SETTINGS"
if ! jq empty "$SETTINGS" 2>/dev/null; then
  echo "error: $SETTINGS is not valid JSON, fix it and re-run" >&2
  exit 1
fi

if jq -e --argjson want "$WANT" '. as $have | $want | to_entries | all(.value == $have[.key])' "$SETTINGS" >/dev/null; then
  echo "settings.json already has the status line entries"
else
  cp -p "$SETTINGS" "$SETTINGS.bak"
  updated=$(jq --argjson want "$WANT" '. + $want' "$SETTINGS")
  # Write in place so the file keeps its permissions (and stays a symlink if it is one)
  printf '%s\n' "$updated" > "$SETTINGS"
  echo "added the status line entries to $SETTINGS (previous version saved as settings.json.bak)"
fi

echo "done: the status lines show up after the next assistant message, or restart Claude Code"
