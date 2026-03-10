#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess
import time
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
HOME = Path.home()


def run(cmd: list[str], check: bool = True) -> None:
    print(f"running: {' '.join(cmd)}")
    subprocess.run(cmd, check=check)


def link_path(source: Path, target: Path) -> None:
    if target.is_symlink() and target.resolve() == source.resolve():
        return
    if target.exists() or target.is_symlink():
        backup = target.with_name(target.name + ".bkp")
        if backup.exists() or backup.is_symlink():
            if backup.is_dir() and not backup.is_symlink():
                shutil.rmtree(backup)
            else:
                backup.unlink()
        shutil.move(str(target), str(backup))
    target.parent.mkdir(parents=True, exist_ok=True)
    run(["ln", "-nfs", str(source), str(target)])


def install_dotfiles() -> None:
    entries = [
        ROOT_DIR / "tmux.conf",
        ROOT_DIR / "tmux",
        ROOT_DIR / "vimrc",
        ROOT_DIR / "vim",
        ROOT_DIR / "bash_aliases",
    ]
    for entry in entries:
        link_path(entry, HOME / f".{entry.name}")

    for entry in (ROOT_DIR / "git").iterdir():
        if entry.is_file():
            link_path(entry, HOME / f".{entry.name}")


def ensure_shell_sources() -> None:
    bash_aliases = HOME / ".bash_aliases"
    if bash_aliases.exists():
        def ensure_line(rc: Path, line: str) -> None:
            if rc.exists():
                content = rc.read_text(encoding="utf-8", errors="ignore")
                if line in content:
                    return
                rc.write_text(content + "\n" + line + "\n", encoding="utf-8")
            else:
                rc.write_text(line + "\n", encoding="utf-8")

        ensure_line(HOME / ".bashrc", "source ~/.bash_aliases")
        ensure_line(HOME / ".zshrc", "source ~/.bash_aliases")

        # Ensure pipx-installed binaries are reachable.
        ensure_line(HOME / ".bashrc", 'export PATH="$HOME/.local/bin:$PATH"')
        ensure_line(HOME / ".zshrc", 'export PATH="$HOME/.local/bin:$PATH"')


def install_binaries() -> None:
    bin_dir = ROOT_DIR / "bin"
    if not bin_dir.exists():
        return
    target_dir = Path("/usr/local/bin")
    if platform.system().lower() == "darwin" and Path("/opt/homebrew/bin").exists():
        target_dir = Path("/opt/homebrew/bin")
    target_dir.mkdir(parents=True, exist_ok=True)
    for entry in bin_dir.iterdir():
        if entry.is_file():
            run(["sudo", "ln", "-nfs", str(entry), str(target_dir / entry.name)])


def detect_platform(explicit: str) -> str:
    if explicit != "auto":
        return explicit
    system = platform.system().lower()
    if system == "darwin":
        return "macos"
    if system == "linux":
        return "ubuntu" if is_ubuntu() else "linux"
    raise SystemExit(f"Unsupported platform: {platform.system()}")


def is_ubuntu() -> bool:
    os_release = Path("/etc/os-release")
    if not os_release.exists():
        return False
    data = os_release.read_text(encoding="utf-8", errors="ignore")
    return "ubuntu" in data.lower()


def ensure_homebrew() -> None:
    if shutil.which("brew") is None:
        raise SystemExit("Homebrew not found. Install it from brew.sh, then re-run.")


def install_packages_ubuntu() -> None:
    run(["sudo", "apt-get", "update"])
    run(
        [
            "sudo",
            "apt-get",
            "install",
            "-y",
            "ca-certificates",
            "curl",
            "wget",
            "git",
            "gnome-tweaks",
            "dconf-cli",
            "tmux",
            "neovim",
            "htop",
            "python3-pip",
            "xdotool",
            "xclip",
            "ripgrep",
            "fd-find",
            "jq",
            "jo",
            "pwgen",
            "keychain",
            "meld",
            "universal-ctags",
        ]
    )


def install_packages_macos() -> None:
    ensure_homebrew()
    run(["brew", "update"])
    run(
        [
            "brew",
            "install",
            "git",
            "tmux",
            "neovim",
            "ripgrep",
            "fd",
            "fzf",
            "jq",
            "jo",
            "htop",
            "wget",
            "curl",
            "python3",
            "universal-ctags",
            "bash-completion@2",
        ]
    )


def install_fzf(platform_id: str) -> None:
    if shutil.which("fzf"):
        return

    if platform_id == "ubuntu":
        run(["sudo", "apt-get", "install", "-y", "fzf"], check=False)
    elif platform_id == "macos":
        run(["brew", "install", "fzf"])

    if shutil.which("fzf") is None:
        run(["git", "clone", "--depth", "1", "https://github.com/junegunn/fzf.git", str(HOME / ".fzf")])
        run([str(HOME / ".fzf" / "install"), "--all"])
    else:
        if (HOME / ".fzf").exists():
            run([str(HOME / ".fzf" / "install"), "--all"], check=False)


def install_vim_plug() -> None:
    autoload = HOME / ".vim" / "autoload"
    autoload.mkdir(parents=True, exist_ok=True)
    run(
        [
            "curl",
            "-fLo",
            str(autoload / "plug.vim"),
            "--create-dirs",
            "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
        ]
    )

    if shutil.which("nvim"):
        nvim_autoload = HOME / ".local" / "share" / "nvim" / "site" / "autoload"
        nvim_autoload.mkdir(parents=True, exist_ok=True)
        run(
            [
                "curl",
                "-fLo",
                str(nvim_autoload / "plug.vim"),
                "--create-dirs",
                "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
            ]
        )


def ensure_nvim_config() -> None:
    if shutil.which("nvim") is None:
        return
    config_dir = HOME / ".config" / "nvim"
    config_dir.mkdir(parents=True, exist_ok=True)
    init_vim = config_dir / "init.vim"
    if not init_vim.exists():
        init_vim.write_text(
            "set runtimepath^=~/.vim runtimepath+=~/.vim/after\n"
            "let &packpath = &runtimepath\n"
            "source ~/.vimrc\n",
            encoding="utf-8",
        )


def install_vim_plugins() -> None:
    install_vim_plug()
    ensure_nvim_config()
    if shutil.which("nvim"):
        run(["nvim", "--headless", "+PlugInstall", "+qall"])
    elif shutil.which("vim"):
        run(["vim", "-E", "-s", "+PlugInstall", "+qall"])
    else:
        print("Skipping vim plugins: vim/neovim not found.")


def install_tmux_plugins() -> None:
    tpm_dir = HOME / ".tmux" / "plugins" / "tpm"
    tpm_dir.parent.mkdir(parents=True, exist_ok=True)
    if not tpm_dir.exists():
        run(["git", "clone", "https://github.com/tmux-plugins/tpm", str(tpm_dir)])
    run([str(tpm_dir / "bin" / "install_plugins")])


def install_fonts(platform_id: str) -> None:
    fonts_src = ROOT_DIR / "fonts"
    if not fonts_src.exists():
        return

    if platform_id == "macos":
        dest = HOME / "Library" / "Fonts"
    else:
        dest = HOME / ".local" / "share" / "fonts"

    dest.mkdir(parents=True, exist_ok=True)
    for font in fonts_src.iterdir():
        if font.is_file():
            shutil.copy2(font, dest / font.name)

    if platform_id != "macos" and shutil.which("fc-cache"):
        run(["fc-cache", "-vf", str(dest)])


def install_python_tools() -> None:
    if shutil.which("pip3") is None:
        return

    if platform.system().lower() == "darwin":
        venv_dir = HOME / ".venvs" / "pynvim"
        if not venv_dir.exists():
            run(["python3", "-m", "venv", str(venv_dir)])
        run([str(venv_dir / "bin" / "python"), "-m", "pip", "install", "--upgrade", "pip"])
        run([str(venv_dir / "bin" / "python"), "-m", "pip", "install", "pynvim"])

        if shutil.which("pipx"):
            run(["pipx", "install", "grip"], check=False)
            run(["pipx", "ensurepath"], check=False)
        elif shutil.which("brew"):
            run(["brew", "install", "pipx"])
            run(["pipx", "install", "grip"], check=False)
            run(["pipx", "ensurepath"], check=False)
    else:
        run(["pip3", "install", "--user", "pynvim", "grip"])


def install_iterm2_macos() -> None:
    if shutil.which("brew") is None:
        return
    run(["brew", "install", "--cask", "iterm2"])

    profile_url = (
        "https://raw.githubusercontent.com/altercation/solarized/master/"
        "iterm2-colors-solarized/Solarized%20Dark.itermcolors"
    )
    profile_path = Path("/tmp/solarized-dark.itermcolors")
    run(["curl", "-fsSL", profile_url, "-o", str(profile_path)])
    run(["open", str(profile_path)])
    time.sleep(1)
    print("iTerm2: imported Solarized Dark color preset.")
    print("Open iTerm2 > Settings > Profiles > Colors > Color Presets to select it.")
    print("To make iTerm2 default terminal: iTerm2 menu > Make iTerm2 Default Term.")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--platform", default="auto", choices=["auto", "ubuntu", "macos", "linux"])
    parser.add_argument("--skip-fonts", action="store_true")
    args = parser.parse_args()

    platform_id = detect_platform(args.platform)
    if platform_id not in {"ubuntu", "macos"}:
        raise SystemExit(f"Unsupported platform: {platform_id}")

    install_dotfiles()
    ensure_shell_sources()
    install_binaries()

    if platform_id == "ubuntu":
        install_packages_ubuntu()
    else:
        install_packages_macos()

    install_fzf(platform_id)
    install_tmux_plugins()
    install_vim_plugins()
    if not args.skip_fonts:
        install_fonts(platform_id)
    install_python_tools()
    if platform_id == "macos":
        install_iterm2_macos()


if __name__ == "__main__":
    main()
