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
