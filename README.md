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

Machine-local config stays outside version control:

- `~/.gitconfig.local`
- `~/.zshrc.local`

## Bootstrap

```sh
git clone <your-remote> "$HOME/dotfiles"
cd "$HOME/dotfiles"
./bin/bootstrap
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