# dotfiles

Portable shell, git, and machine setup for macOS and other UNIX-like systems.

## Quick install (one line)

On any machine on the local network:

```sh
git clone https://github.com/ckdcreations/dotfiles.git ~/dotfiles && ~/dotfiles/bin/updatedot --install-new-ssh-keys
```

This clones the repo and runs `updatedot`, which links all managed config,
generates and installs any missing SSH keys (prompting for a password one
host at a time as needed), makes sure the Claude Code CLI is installed and
you're logged in, and pulls `ckdCreations-claude-skills` into
`~/.claude/skills`.

One caveat on a brand-new machine: the `forgejo` git-SSH host can't be
auto-authorized (Forgejo doesn't support password-based key install like a
normal SSH host does), so that one host gets skipped with a warning during
the key walk-through. Register `~/.ssh/id_ed25519_forgejo.pub` once via the
Forgejo web UI (Settings → SSH/GPG Keys), then re-run `updatedot` to pick up
the skills repo. Everything else in the command above runs unattended.

## What this repo manages

- `shell/zprofile` for login-shell environment setup
- `shell/zshrc` for interactive zsh behavior and aliases
- `git/gitconfig` for shared Git defaults
- `git/gitignore_global` for personal Git ignores
- `bin/bootstrap` to install symlinks with backups
- `bin/update-system` to update common package managers
- `bin/macos-defaults` for optional macOS preferences
- `bin/remoteConnect` to set up passwordless SSH host aliases and browser tunnels through the mesh jump host
- `bin/github-auth-setup` to configure GitHub CLI auth and git protocol
- `bin/github-create-repo` to create and publish repos from local git

Script details are documented in `bin/README.md`.

## Mesh service shortcuts

This machine keeps local web UI shortcuts in `~/.zshrc.local` for services that live on the home mesh:

```sh
proxmox-ui   # Proxmox web UI at 192.168.1.143:8006
jellyfin     # Jellyfin at 192.168.1.160:8096
immich       # Immich at 192.168.1.152:2283
filebrowser  # File Browser at 192.168.1.80:8080
cliffbooks   # CliffBooks at 192.168.1.18:3000
```

Each shortcut opens a local browser tunnel through `home-mesh-jump`. The command names are defined in `shell/zshrc.local`, and the underlying tunnel runner lives in `bin/remoteConnect`.

Machine-local config stays outside version control:

- `~/.gitconfig.local`
- `~/.zshrc.local`

## Historical Note

- Date: 2026-05-28
- A prior revision included Symetrix VPN credentials in plaintext in `bashrc`.
- GitHub flagged this as exposed credentials.
- Repository owner review classified the values as intentionally shared internal "open secrets" at that time.
- Current implementation keeps VPN connection logic but reads credentials from Keychain or environment variables to reduce future secret-scanner alerts and preserve safer conventions.

## Bootstrap

```sh
git clone https://github.com/ckdcreations/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
./bin/bootstrap
```

Fast path (new machine, one command):

```sh
./bin/new-machine-setup --brew --macos-defaults
```

Optional macOS package install:

```sh
./bin/bootstrap --brew
```

Optional macOS defaults:

```sh
./bin/macos-defaults
```

## New machine checklist

1. Install Git.
2. Clone this repo to `~/dotfiles`.
3. Run `./bin/bootstrap`.
4. Create or adjust `~/.gitconfig.local` and `~/.zshrc.local`.
5. Open a new shell.

## Exact same setup on another machine

If you want behavior to match exactly (including your local aliases and SSH config), copy your local-only files from the old machine, then restore them on the new one.

Fastest two-command flow:

Old machine:

```sh
cd "$HOME/dotfiles"
./bin/export-local-config --force
```

New machine (after transferring `~/dotfiles-local-export.tgz`):

```sh
tar -C "$HOME" -xzf "$HOME/dotfiles-local-export.tgz"
cd "$HOME/dotfiles"
./bin/new-machine-setup --brew --macos-defaults --restore-local "$HOME/dotfiles-local-export"
```

On old machine (create an export bundle):

```sh
mkdir -p "$HOME/dotfiles-local-export/ssh"
cp "$HOME/.gitconfig.local" "$HOME/dotfiles-local-export/gitconfig.local" 2>/dev/null || true
cp "$HOME/.zshrc.local" "$HOME/dotfiles-local-export/zshrc.local" 2>/dev/null || true
cp -R "$HOME/.ssh/." "$HOME/dotfiles-local-export/ssh/" 2>/dev/null || true
tar -C "$HOME" -czf "$HOME/dotfiles-local-export.tgz" dotfiles-local-export
```

Transfer `~/dotfiles-local-export.tgz` to the new machine, then run:

```sh
tar -C "$HOME" -xzf "$HOME/dotfiles-local-export.tgz"
git clone https://github.com/ckdcreations/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
./bin/new-machine-setup --brew --macos-defaults --restore-local "$HOME/dotfiles-local-export"
```

Then reload shell in the current terminal:

```sh
source ~/.zprofile
source ~/.zshrc
source ~/.zshrc.local
```

## Scripts

See `bin/README.md` for script usage and behavior.
For a dedicated migration guide, see `NEW-MACHINE-README.md`.
