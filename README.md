These are the dotfiles I use :)

**Get Started**
1. Clone the repo to `~/.dotfiles` (or any location).
1. `cd` into the repo.
1. macOS only: run `scripts/bootstrap-macos.sh` once to install Homebrew + Python3.
1. Run `python3 scripts/install.py`.

What this does:
- Symlinks dotfiles into your home directory.
- Installs packages for macOS or Ubuntu.
- Installs tmux/vim plugins, fonts, and Python tools.
- On macOS, installs iTerm2 and imports the Solarized Dark color preset.

**LSP Servers**
LSP setup lives in `vim/settings/lsp.lua`.
- Filetype → server mapping is in `ft_to_server`.
- To add a new one: add the filetype + server there and add a matching `configure("server", {...})` block in the same file.
- If a server is missing, you’ll get a warning when you open a file of that type.
