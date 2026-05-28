# Scripts

This directory contains helper scripts for bootstrapping and maintaining your machine.

## bootstrap

Path: `bin/bootstrap`

Purpose:
- Links managed dotfiles into your home directory.
- Preserves existing files by moving them into a timestamped backup folder.
- Creates local override files from examples when missing.

Usage:

```sh
./bin/bootstrap
```

Options:
- `--brew`: On macOS, runs `brew bundle --file ./Brewfile` after linking.

Behavior details:
- Detects the repository root automatically from the script location.
- Stores backups under:
  - `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/<timestamp>/`
- Handles these links:
  - `git/gitconfig` -> `~/.gitconfig`
  - `git/gitignore_global` -> `~/.gitignore_global`
  - `shell/zprofile` -> `~/.zprofile`
  - `shell/zshrc` -> `~/.zshrc`
- Creates these local files if missing:
  - `~/.gitconfig.local` from `git/gitconfig.local.example`
  - `~/.zshrc.local` from `shell/zshrc.local.example`
- Special case for existing `~/.gitconfig`:
  - If it is a regular file and `~/.gitconfig.local` is missing, the file is moved to `~/.gitconfig.local`.

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

## remoteConnect

Path: `bin/remoteConnect`

Purpose:
- Interactive setup for passwordless SSH login.
- Creates an SSH host alias in `~/.ssh/config`.
- Installs your public key on the remote host.
- Optionally creates a shell alias in `~/.zshrc.local`.

Usage:

```sh
remoteConnect
```

Prompt flow:
- SSH host alias (name used with `ssh <alias>`)
- Remote host (IP or DNS)
- Remote username
- SSH port (default `22`)
- Private key path (default `~/.ssh/id_ed25519_<alias>`)
- Optional shell alias command name

Behavior details:
- Ensures `~/.ssh` and `~/.ssh/config` exist with secure permissions.
- Generates an `ed25519` key if the selected key does not exist.
- Uses `ssh-copy-id` when available, with a fallback method if not installed.
- Appends a host block to `~/.ssh/config` with `IdentityFile` and `IdentitiesOnly yes`.
- Refuses to overwrite an existing SSH host alias with the same name.

Result:
- Connect using `ssh <your-host-alias>`.
- If you created a shell alias, reload with `source ~/.zshrc.local`.

## new-machine-setup

Path: `bin/new-machine-setup`

Purpose:
- One-command setup for a new machine after cloning this repo.
- Runs bootstrap (optionally with Homebrew bundle install).
- Optionally applies macOS defaults.
- Optionally restores local-only files (`.gitconfig.local`, `.zshrc.local`, `.ssh`) from an export folder.

Usage:

```sh
./bin/new-machine-setup [options]
```

Options:
- `--brew`: Runs `./bin/bootstrap --brew`.
- `--macos-defaults`: Runs `./bin/macos-defaults` on macOS.
- `--restore-local <dir>`: Restores local files from `<dir>`.
- `--force-restore`: Overwrite existing local files during restore.

Restore folder format:
- `<dir>/gitconfig.local`
- `<dir>/zshrc.local`
- `<dir>/ssh/` (optional, includes SSH config and keys)

Examples:

```sh
./bin/new-machine-setup --brew --macos-defaults
./bin/new-machine-setup --brew --macos-defaults --restore-local "$HOME/dotfiles-local-export"
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
- `<output>/zshrc.local`
- `<output>/ssh/` (unless `--no-ssh`)
- `<output>.tgz` (unless `--no-archive`)

Examples:

```sh
./bin/export-local-config --force
./bin/export-local-config --output "$HOME/migration-bundle" --force
./bin/export-local-config --no-ssh --no-archive --force
```
