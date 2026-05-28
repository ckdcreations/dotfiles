# dotfiles

Portable shell, git, and machine setup for macOS and other UNIX-like systems.

## What this repo manages

- `shell/zprofile` for login-shell environment setup
- `shell/zshrc` for interactive zsh behavior and aliases
- `git/gitconfig` for shared Git defaults
- `git/gitignore_global` for personal Git ignores
- `bin/bootstrap` to install symlinks with backups
- `bin/update-system` to update common package managers
- `bin/macos-defaults` for optional macOS preferences
- `bin/remoteConnect` to set up passwordless SSH host aliases

Script details are documented in `bin/README.md`.

Machine-local config stays outside version control:

- `~/.gitconfig.local`
- `~/.zshrc.local`

## Bootstrap

```sh
git clone <your-remote> "$HOME/dotfiles"
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
git clone <your-remote> "$HOME/dotfiles"
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
