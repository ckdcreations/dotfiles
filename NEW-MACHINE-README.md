# New Machine Setup (Fast + Exact)

This guide gets a new laptop to the same setup as your current machine as quickly as possible.

## TL;DR

On the new machine, after cloning this repo:

```sh
cd "$HOME/dotfiles"
./bin/new-machine-setup --brew --macos-defaults
```

For exact parity (including local aliases and SSH config), use `--restore-local` as shown below.

## 1) Export local-only files from old machine

Run on your current machine:

```sh
cd "$HOME/dotfiles"
./bin/export-local-config --force
```

Manual equivalent (for reference):

```sh
mkdir -p "$HOME/dotfiles-local-export/ssh"
cp "$HOME/.gitconfig.local" "$HOME/dotfiles-local-export/gitconfig.local" 2>/dev/null || true
cp "$HOME/.zshrc.local" "$HOME/dotfiles-local-export/zshrc.local" 2>/dev/null || true
cp -R "$HOME/.ssh/." "$HOME/dotfiles-local-export/ssh/" 2>/dev/null || true

tar -C "$HOME" -czf "$HOME/dotfiles-local-export.tgz" dotfiles-local-export
```

Transfer `~/dotfiles-local-export.tgz` to the new machine.

## 2) Clone and run one setup command on new machine

```sh
git clone <your-remote> "$HOME/dotfiles"
cd "$HOME/dotfiles"
```

If you have a local export bundle:

```sh
tar -C "$HOME" -xzf "$HOME/dotfiles-local-export.tgz"
./bin/new-machine-setup --brew --macos-defaults --restore-local "$HOME/dotfiles-local-export"
```

If you do not need local file restore:

```sh
./bin/new-machine-setup --brew --macos-defaults
```

## 3) Activate in the current terminal

```sh
source ~/.zprofile
source ~/.zshrc
source ~/.zshrc.local
```

## What the script does

- Runs `bin/bootstrap` (or `bin/bootstrap --brew` with `--brew`)
- Optionally applies macOS defaults with `--macos-defaults`
- Optionally restores:
  - `~/.gitconfig.local`
  - `~/.zshrc.local`
  - `~/.ssh/*`
- Prints next-step source commands so commands like `remoteConnect` are immediately usable

## Safety notes

- Restore does not overwrite existing local files unless `--force-restore` is provided.
- If you restore `~/.ssh`, confirm key permissions are strict (`700` for dir, `600` for private files).
