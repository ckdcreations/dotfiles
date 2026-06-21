# Scripts

This directory contains helper scripts for bootstrapping and maintaining your machine.

## remoteConnect

Path: `bin/remoteConnect`

Purpose:
- Creates and maintains SSH host aliases in `~/.ssh/config`.
- Installs public keys for passwordless login when needed.
- Can create shell functions in `~/.zshrc.local` for quick SSH access.
- Opens browser tunnels through a mesh gateway for LAN services.

Usage:

```sh
remoteConnect [new|list|edit|delete|tunnel|web|log|show]
remoteConnect help
```

Useful commands:

```sh
remoteConnect new
remoteConnect list --commands
remoteConnect edit proxmox
remoteConnect tunnel proxmox 8006
remoteConnect web home-mesh-jump 192.168.1.143 8006
```

Notes:
- `tunnel` is for SSH-managed hosts where the web UI lives on the same machine as the SSH alias.
- `web` is for LAN services reached through `home-mesh-jump`.
- The local command names for the common services are stored in `~/.zshrc.local`.

Proxy and mesh setup guide:
- Local-only host: set local host, leave secondary and gateway empty.
- Mesh-only host: set secondary host, leave local and gateway empty.
- Local-first + mesh fallback: set local and secondary, leave gateway empty.
- ProxyJump through mesh gateway: set local host and set gateway alias (for example `home-mesh-jump`).

Tunnel guide:
- Same-host service port: `remoteConnect tunnel <alias> <port>`
- Any LAN service through jump: `remoteConnect web home-mesh-jump <target-ip> <port>`

## updatedot

Path: `bin/updatedot`

Purpose:
- Checks your `~/dotfiles` repository against GitHub (`origin`) and ensures it is up to date.
- Fast-forwards local branch when behind.
- Reports when local is ahead or diverged (without forcing history changes).
- Calls `source ~/.zshrc` at the end.

Usage:

```sh
updatedot
```

Behavior details:
- Fetches from `origin`.
- Uses the current branch and configured upstream (or sets upstream to `origin/<branch>` if missing and available).
- Pulls with `--ff-only` when behind.
- Exits with an error when branch has diverged.

Notes:
- Also add `alias reload="source ~/.zshrc"` in shell config for manual reloads.
- When run as a normal executable, the `source ~/.zshrc` call happens in the script shell; run `reload` in your current terminal to apply changes to your active session.

## mkgit

Path: `bin/mkgit`

Purpose:
- Creates one or more directories and initialises a git repository inside each one.
- With `--github`, creates or renames the matching GitHub repository so its name always equals the folder basename.
- Accepts multiple directory arguments, matching `mkdir` syntax.

Usage:

```sh
mkgit <dir> [dir2 ...]
mkgit --github <dir> [dir2 ...]
```

Options:
- `--github`: Create (or rename) the GitHub repository to match the folder name.
- `--public` / `--private`: Visibility of the GitHub repository (default: private).
- `--push`: Create an initial empty commit and push to the remote.
- `--remote <name>`: Remote name (default: origin).
- `--owner <owner>`: GitHub owner/org (default: authenticated user).
- `--host <host>`: GitHub hostname (default: github.com).

Examples:

```sh
# Local only — mkdir + git init
mkgit my-new-project

# mkdir + git init + create GitHub repo named my-new-project
mkgit --github my-new-project

# Multiple dirs at once, public repos, with initial push
mkgit --github --public --push notes experiments

# GitHub repo name will be renamed to match folder if it already exists remotely
mkgit --github CliffBooks
```

## mvgit

Path: `bin/mvgit`

Purpose:
- Renames a directory that is a git repository root.
- With `--github`, renames the matching GitHub repository so its name stays in sync with the new folder basename.

Usage:

```sh
mvgit <source> <dest>
mvgit --github <source> <dest>
```

Options:
- `--github`: Rename the GitHub repository to match the `<dest>` basename.
- `--remote <name>`: Remote name to inspect/update (default: origin).
- `--owner <owner>`: GitHub owner/org (default: authenticated user).
- `--host <host>`: GitHub hostname (default: github.com).

Examples:

```sh
# Local rename only
mvgit old-name new-name

# Rename folder + rename GitHub repo to match
mvgit --github old-name new-name

# Works with paths too
mvgit --github projects/CliffBooks projects/CliffBooks-v2
```

## bootstrap

Path: `bin/bootstrap`

Purpose:
- Links managed dotfiles into your home directory.
- Preserves existing files by moving them into a timestamped backup folder.
- Creates local override files from examples when missing.
- Links the shared SSH config and generates any missing per-device SSH keys for managed hosts.

Usage:

```sh
./bin/bootstrap
```

Options:
- `--brew`: On macOS, runs `brew bundle --file ./Brewfile` after linking.
- `--install-new-ssh-keys`: Installs newly generated managed SSH public keys onto matching remotes.

Behavior details:
- Detects the repository root automatically from the script location.
- Stores backups under:
  - `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/<timestamp>/`
- Handles these links:
  - `git/gitconfig` -> `~/.gitconfig`
  - `git/gitignore_global` -> `~/.gitignore_global`
  - `shell/zprofile` -> `~/.zprofile`
  - `shell/zshrc` -> `~/.zshrc`
  - `shell/zshrc.local` -> `~/.zshrc.local`
  - `ssh/config` -> `~/.ssh/config`
- Creates these local files if missing:
  - `~/.gitconfig.local` from `git/gitconfig.local.example`
  - `~/.zshrc.machine.local` from `shell/zshrc.machine.local.example`
  - `~/.ssh/config.local` from `ssh/config.local.example`
- Special case for existing `~/.gitconfig`:
  - If it is a regular file and `~/.gitconfig.local` is missing, the file is moved to `~/.gitconfig.local`.
- Generates missing `IdentityFile` keypairs for aliases defined in `ssh/config`.

Examples:

```sh
./bin/bootstrap
./bin/bootstrap --brew
```

## macos-defaults

Path: `bin/macos-defaults`

Purpose:
- Applies a small set of macOS preference tweaks.

Usage:

```sh
./bin/macos-defaults
```

Behavior details:
- Fails fast on non-macOS systems.
- Applies defaults including:
  - show all file extensions
  - faster key repeat settings
  - Finder path bar enabled
  - Finder list view preference
  - Dock auto-hide enabled
- Restarts Finder and Dock to apply changes immediately where possible.

## update-system

Path: `bin/update-system`

Purpose:
- Updates package managers available on the current machine.

Usage:

```sh
./bin/update-system
```

Behavior details:
- Runs only what exists on your system:
  - Homebrew: `brew update`, `brew upgrade`, and optional `brew bundle` if `~/dotfiles/Brewfile` exists.
  - APT: `sudo apt-get update && sudo apt-get upgrade -y`
  - DNF: `sudo dnf upgrade --refresh -y`
  - pacman: `sudo pacman -Syu`

Notes:
- Some package manager actions may prompt for sudo credentials.
- The script assumes your dotfiles repo is at `~/dotfiles` for the Brewfile step.

## update-dotfiles

Path: `bin/update-dotfiles`

Purpose:
- Safely updates local dotfiles from your git remote and branch.
- Auto-stashes local changes by default, pulls with rebase, then restores your work.
- Re-runs `./bin/bootstrap` so symlinks and local setup stay aligned with updated repo files.
- Supports generating and optionally installing newly missing managed SSH keys.

Usage:

```sh
./bin/update-dotfiles
```

Options:
- `--remote <name>`: Git remote to update from (default: `origin`).
- `--branch <name>`: Branch to update from (default: `main`).
- `--hard`: Force local repo to exactly match `<remote>/<branch>` (destructive).
- `--no-stash`: Fail if working tree is dirty instead of auto-stashing.
- `--no-bootstrap`: Skip re-running bootstrap after git update.
- `--brew`: Passes `--brew` to bootstrap.
- `--ensure-tools`: Runs `./bin/cli-tools --install` after update.
- `--install-new-ssh-keys`: Passes `--install-new-ssh-keys` through to bootstrap, or directly to `ensure-managed-ssh` when bootstrap is skipped.

Examples:

```sh
./bin/update-dotfiles
./bin/update-dotfiles --branch main
./bin/update-dotfiles --hard
./bin/update-dotfiles --ensure-tools
updatedot
updatedot --install-new-ssh-keys
```

## updatedot

Path: `bin/updatedot`

Purpose:
- Short wrapper for `bin/update-dotfiles`.

Usage:

```sh
updatedot
updatedot --install-new-ssh-keys
```

## cli-tools

Path: `bin/cli-tools`

Purpose:
- Prints a snapshot of key command-line tool availability and versions.
- Optionally runs Homebrew bundle install from `./Brewfile` first.

Usage:

```sh
./bin/cli-tools
```

Options:
- `--install`: Runs `brew bundle --file ./Brewfile` before snapshot.
- `--output <file>`: Writes snapshot to a file and stdout.

Examples:

```sh
./bin/cli-tools
./bin/cli-tools --install
./bin/cli-tools --output "$HOME/.local/state/dotfiles/cli-tools-latest.txt"
```

## remoteConnect

Path: `bin/remoteConnect`

Manual page:
- See `bin/remoteConnect.md` for full man-style documentation.
- See `bin/remoteConnect.1` for a man-compatible roff page.

Purpose:
- Interactive setup for passwordless SSH login.
- Creates an SSH host alias in `~/.ssh/config`.
- Installs your public key on the remote host.
- Optionally creates a shell alias in `~/.zshrc.local`.

Usage:

```sh
remoteConnect
remoteConnect new
remoteConnect list
remoteConnect list --commands
remoteConnect edit
remoteConnect edit <alias>
remoteConnect delete
remoteConnect log
remoteConnect help
```

Prompt flow:
- Server name (human-friendly label)
- SSH host alias (name used with `ssh <alias>`)
- Local network host (optional)
- Secondary remote/VPN host IP (optional)
- Remote username
- SSH port (default `22`)
- Optional mesh gateway alias (for ProxyJump routing)
- Private key path (default `~/.ssh/id_ed25519_<alias>`)
- Optional shell alias command name

Behavior details:
- Ensures `~/.ssh` and `~/.ssh/config` exist with secure permissions.
- Generates an `ed25519` key if the selected key does not exist.
- Requires at least one host value (local or Meshnet).
- Uses `ssh-copy-id` when available, with fallback paths if it is not installed.
- Uses built-in SSH/`ssh-copy-id` password prompts directly in the terminal during bootstrap.
- Forces bootstrap auth to prefer terminal password prompts (`keyboard-interactive,password`) when the server allows it.
- If neither local nor Meshnet is reachable during setup, still creates the alias and defers key installation with follow-up commands.
- When both addresses are configured, the generated SSH alias prefers the local address and falls back to the Meshnet address automatically.
- Appends a host block to `~/.ssh/config` with `IdentityFile`, `IdentitiesOnly yes`, and dynamic host selection when Meshnet is configured.
- Refuses to overwrite an existing SSH host alias with the same name.
- Writes a running troubleshooting log to `${XDG_STATE_HOME:-~/.local/state}/remoteConnect/remoteConnect.log`.
- On setup cancellation after key-install failure, removes key files created during that failed run to avoid leftover `~/.ssh` artifacts.
- When `~/.ssh/config` is symlinked to `~/dotfiles/ssh/config`, changes made by `remoteConnect` are automatically tracked in the repo.

Management commands:
- `remoteConnect list` shows generated SSH aliases from `~/.ssh/config` and notes whether a matching shell alias exists in `~/.zshrc.local`.
- `remoteConnect list --commands` shows the exact alias command path (`ssh <alias>`) and resolved SSH options (identity file, port, user, host selection).
- `remoteConnect edit <alias>` edits an existing alias in place by prompting with current values, then rewrites the SSH host block so `IdentityFile`, user, port, and local/mesh IP updates stay in sync.
- `remoteConnect delete` removes the selected generated SSH alias and matching shell alias.
- `remoteConnect log` prints recent entries from the running log file.

Result:
- Connect using `ssh <your-host-alias>`.
- If you created a shell alias, reload with `source ~/.zshrc.local`.

## new-machine-setup

Path: `bin/new-machine-setup`

Purpose:
- One-command setup for a new machine after cloning this repo.
- Runs bootstrap (optionally with Homebrew bundle install).
- Optionally applies macOS defaults.
- Generates missing managed SSH keys for the new device.
- Optionally restores local-only files (`.gitconfig.local`, `.zshrc.machine.local`, `.ssh`) from an export folder.

Usage:

```sh
./bin/new-machine-setup [options]
```

Options:
- `--brew`: Runs `./bin/bootstrap --brew`.
- `--macos-defaults`: Runs `./bin/macos-defaults` on macOS.
- `--restore-local <dir>`: Restores local files from `<dir>`.
- `--force-restore`: Overwrite existing local files during restore.
- `--install-new-ssh-keys`: Installs newly generated managed SSH public keys onto matching remotes.

Restore folder format:
- `<dir>/gitconfig.local`
- `<dir>/zshrc.machine.local`
- `<dir>/ssh/` (optional, includes SSH config and keys)

Examples:

```sh
./bin/new-machine-setup --brew --macos-defaults
./bin/new-machine-setup --brew --macos-defaults --restore-local "$HOME/dotfiles-local-export"
```

## ensure-managed-ssh

Path: `bin/ensure-managed-ssh`

Purpose:
- Links the repo-managed SSH config into `~/.ssh/config`.
- Creates `~/.ssh/config.local` when it is missing.
- Generates missing `IdentityFile` keypairs for the tracked SSH aliases.
- Optionally installs newly generated public keys onto the target remotes.

Usage:

```sh
./bin/ensure-managed-ssh
./bin/ensure-managed-ssh --install-new-keys
```

## export-local-config

Path: `bin/export-local-config`

Purpose:
- Exports local-only files from the current machine for migration.
- Produces a restore-ready folder for `new-machine-setup --restore-local`.
- Optionally creates a compressed archive for easy transfer.

Usage:

```sh
./bin/export-local-config [options]
```

Options:
- `--output <dir>`: Export directory path (default `~/dotfiles-local-export`).
- `--no-archive`: Skip creating `.tgz` archive.
- `--no-ssh`: Exclude `~/.ssh` from the export.
- `--force`: Replace existing export directory if it already exists.

Export contents:
- `<output>/gitconfig.local`
- `<output>/zshrc.machine.local`
- `<output>/ssh/` (unless `--no-ssh`)
- `<output>.tgz` (unless `--no-archive`)

Examples:

```sh
./bin/export-local-config --force
./bin/export-local-config --output "$HOME/migration-bundle" --force
./bin/export-local-config --no-ssh --no-archive --force
```

## github-auth-setup

Path: `bin/github-auth-setup`

Purpose:
- Sets up GitHub CLI authentication and git integration for a chosen protocol.
- Fixes the common mismatch where git remote uses SSH but auth is configured for HTTPS (or vice versa).
- Optionally rewrites the current repository `origin` URL to the selected protocol.

Usage:

```sh
./bin/github-auth-setup [options]
```

Options:
- `--host <host>`: GitHub host (default `github.com`).
- `--protocol <https|ssh>`: Git protocol to use (default `https`).
- `--no-fix-remote`: Keep current `origin` URL unchanged.

Examples:

```sh
./bin/github-auth-setup --protocol https
./bin/github-auth-setup --protocol ssh
```

## github-create-repo

Path: `bin/github-create-repo`

Purpose:
- Creates a GitHub repository from a local git repository.
- Sets the remote and optionally pushes in one command.

Usage:

```sh
./bin/github-create-repo [options] <repo-name>
```

Options:
- `--owner <name>`: Owner or organization (default authenticated user).
- `--public`: Create public repository.
- `--private`: Create private repository (default).
- `--source <dir>`: Source git repository directory (default `.`).
- `--remote <name>`: Remote name (default `origin`).
- `--no-push`: Create remote without pushing local branch.
- `--host <host>`: GitHub host (default `github.com`).

Examples:

```sh
./bin/github-create-repo my-new-repo
./bin/github-create-repo --public --owner ckdcreations notes
```
