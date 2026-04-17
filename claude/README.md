# Claude Code Dotfiles Integration

Replicates the Claude Code statusline and attention signaling across workstations.

## Files

- `statusline-command.sh` — statusline (model + token count + progress bar)
- `hooks/tmux-bell.sh` — Claude `Notification` hook that emits terminal BEL so
  tmux flips the window tab yellow when Claude needs attention in a background
  window

## What `scripts/install.py` does

`install_claude()`:

1. Symlinks `statusline-command.sh` → `~/.claude/statusline-command.sh`
2. Symlinks every `hooks/*.sh` → `~/.claude/hooks/<name>.sh` (and `chmod +x`)
3. Idempotently merges into `~/.claude/settings.json`:
   - `statusLine.command` (always overwritten)
   - `hooks.Notification[]` entry pointing at `~/.claude/hooks/tmux-bell.sh`
     (added only if no entry with that command already exists — safe to re-run)

Other `settings.json` keys (MCP servers, model, permissions, enabled plugins)
are preserved on each install.

## How the tmux alert works

End-to-end path when Claude wants attention:

1. Claude Code fires a `Notification` hook event
2. `hooks/tmux-bell.sh` reads the JSON payload on stdin and writes `\a` (BEL)
   to `/dev/tty` — the pane's pty
3. tmux receives the BEL on that pane → `monitor-bell` sets the window's
   `window_bell_flag` to 1
4. `window-status-format` in `tmux.conf` is conditional on `window_bell_flag`,
   so the tab renders `bg=yellow` with a trailing `!`
5. Flag clears automatically when you enter that window

Supporting tmux options (in `tmux.conf`):

- `set -g bell-action none` — no audible beep, no status-line popup
- `set -g allow-passthrough on`
- `setw -g monitor-bell on`
- `setw -g window-status-bell-style 'fg=black,bg=yellow,bold'` (fallback for
  the default format; the custom `window-status-format` overrides it via an
  inline `#{?window_bell_flag,...}` branch)

The hook rings BEL unconditionally — Claude Code only invokes the `Notification`
hook when it actually needs attention, so filtering by payload field is
unnecessary (and fragile across Claude versions).

## Adding another notification

### A new Claude hook (e.g. Stop, PreToolUse)

1. Drop a script in `claude/hooks/<name>.sh` and `chmod +x` it
2. Extend `_ensure_notification_hook()` in `scripts/install.py` (or add a
   sibling helper) to wire it into the right event bucket in `settings.json`.
   The structure is:

   ```json
   "hooks": {
     "<EventName>": [
       { "hooks": [ { "type": "command", "command": "~/.claude/hooks/<name>.sh" } ] }
     ]
   }
   ```

   Event names: `Notification`, `Stop`, `PreToolUse`, `PostToolUse`,
   `UserPromptSubmit`, `SubagentStop`, etc. — check the Claude Code hooks docs
   for the current set.
3. Run `python3 scripts/install.py --claude-only`

### A different signal from the same hook

Edit `hooks/tmux-bell.sh`. The payload on stdin is JSON — parse with `jq` if
present. Options:

- **Double/triple BEL** for urgent events: `printf '\a\a\a' > /dev/tty`
- **Desktop notification**: `notify-send "Claude" "$message"` (Linux) or
  `osascript -e '...'` (macOS) — runs on the host, independent of tmux
- **Per-window marker file**: write a flag under `/tmp/claude-alert-$TMUX_PANE`,
  then read it from `status-right` with `#(cat /tmp/claude-alert-$(...))`. More
  complex but lets you carry richer state (which prompt, how long it's been
  waiting, etc.) into the status bar

### A new tmux alert style

The conditional lives in `tmux.conf`'s `window-status-format`:

```tmux
set -g window-status-format "#[fg=#{?window_bell_flag,black,colour235},bg=#{?window_bell_flag,yellow,colour252},bold] #I #W#{?window_bell_flag, !,} "
```

Swap `yellow`/`black` or the `!` suffix. For a second independent signal
(e.g. `window_activity_flag` or a custom user option like `@claude_status`),
add another nested `#{?...}` branch — tmux format directives nest freely.

## Verifying

After a fresh install or config change:

```bash
tmux source-file ~/.tmux.conf

# Fire BEL into a background pane and confirm the flag flips:
target=$(tmux list-panes -t <other-window> -F "#{pane_tty}" | head -1)
printf '\a' > "$target"
tmux display-message -p -t <other-window> '#{window_bell_flag}'   # expect: 1
```

Payloads Claude actually sends can be inspected by re-running Claude with
`CLAUDE_HOOK_DEBUG=1` — the hook appends each event to
`~/.claude/hooks/tmux-bell.log`.
