# Claude Code Dotfiles Integration

Replicates the Claude Code statusline across workstations.

## Files

- `statusline-command.sh` — statusline script (model + token count + progress bar)

## What `scripts/install.py` does

`install_claude()`:

1. Symlinks `statusline-command.sh` → `~/.claude/statusline-command.sh`
2. Merges this block into `~/.claude/settings.json` (preserving any other keys):

   ```json
   "statusLine": {
     "type": "command",
     "command": "bash ~/.claude/statusline-command.sh"
   }
   ```

Machine-specific config in `settings.json` (MCP servers, model, permissions)
is left untouched — only `statusLine` is overwritten on each install.
