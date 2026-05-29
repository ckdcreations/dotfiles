# dotfiles

Portable shell, git, and machine setup for macOS and other UNIX-like systems.

## What this repo manages

- `shell/zprofile` for login-shell environment setup
- `shell/zshrc` for interactive zsh behavior, aliases, NVM, and optional Apple Terminal tmux startup
- `shell/zshrc.local` for shared personal aliases and terminal behavior that should follow you across machines
- `ssh/config` for shared SSH aliases and key file definitions
- `git/gitconfig` for shared Git defaults
- `git/gitignore_global` for personal Git ignores
- `bin/copilot-tmux-start` to open a split tmux session with GitHub Copilot CLI
- `bin/bootstrap` to install symlinks with backups
- `bin/update-dotfiles` to safely sync local dotfiles from GitHub and re-run bootstrap
- `bin/updatedot` as the short update command
- `bin/ensure-managed-ssh` to link tracked SSH config and generate per-device SSH keys
- `bin/cli-tools` to snapshot CLI tool versions and optionally auto-install from Brewfile
- `bin/update-system` to update common package managers
- `bin/macos-defaults` for optional macOS preferences
- `bin/remoteConnect` to run `new`, `list`, `edit`, `delete`, and `log` for passwordless SSH setup with local-first Meshnet fallback and troubleshooting logs
- `bin/github-auth-setup` to configure GitHub CLI auth and git protocol
- `bin/github-create-repo` to create and publish repos from local git

Script details are documented in `bin/README.md`.

Machine-local config stays outside version control:

- `~/.gitconfig.local`
- `~/.zshrc.machine.local`
- `~/.ssh/config.local`

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
4. Create or adjust `~/.gitconfig.local`, `~/.zshrc.machine.local`, and `~/.ssh/config.local`.
5. Open a new shell.

## Exact same setup on another machine

If you want behavior to match exactly on another machine, start with the tracked repo config. Shared shell aliases and SSH hosts now live in git, while each machine generates its own SSH keys locally.

Fastest two-command flow:

Old machine:

```sh
cd "$HOME/dotfiles"
./bin/export-local-config --force --no-ssh
```

New machine:

```sh
git clone <your-remote> "$HOME/dotfiles"
cd "$HOME/dotfiles"
updatedot
```

If you need machine-only overrides from the old machine, export just those local files:

```sh
cp "$HOME/.gitconfig.local" "$HOME/dotfiles-local-export/gitconfig.local" 2>/dev/null || true
cp "$HOME/.zshrc.machine.local" "$HOME/dotfiles-local-export/zshrc.machine.local" 2>/dev/null || true
tar -C "$HOME" -czf "$HOME/dotfiles-local-export.tgz" dotfiles-local-export
```

Transfer `~/dotfiles-local-export.tgz` to the new machine, then run:

```sh
tar -C "$HOME" -xzf "$HOME/dotfiles-local-export.tgz"
./bin/new-machine-setup --brew --macos-defaults --restore-local "$HOME/dotfiles-local-export"
```

SSH note:

- `updatedot` generates any missing `IdentityFile` keys referenced by `ssh/config`.
- On a brand-new device, install those generated public keys on the remotes with `updatedot --install-new-ssh-keys` or the printed `ssh-copy-id` commands.

Then reload shell in the current terminal:

```sh
source ~/.zprofile
source ~/.zshrc
```

## VS Code Chat + Terminal parity (identical behavior)

Use this checklist to make VS Code open with Chat as the primary editor and a smaller terminal panel under it, consistently across machines.

### 1) Required global VS Code settings (User settings)

Set these keys in `~/Library/Application Support/Code/User/settings.json` on macOS:

```json
{
  "workbench.startupEditor": "chat",
  "workbench.panel.defaultLocation": "bottom",
  "workbench.panel.opensMaximized": "never",
  "terminal.integrated.defaultLocation": "panel",
  "terminal.integrated.tabs.hideCondition": "singleTerminal"
}
```

What each key does:

- `workbench.startupEditor: chat`: opens VS Code to Chat in the editor area on startup.
- `workbench.panel.defaultLocation: bottom`: keeps panel (including terminal) at the bottom.
- `workbench.panel.opensMaximized: never`: prevents panel from taking full height.
- `terminal.integrated.defaultLocation: panel`: opens terminals in the panel, under the editor.
- `terminal.integrated.tabs.hideCondition: singleTerminal`: hides terminal tabs when only one terminal exists.

### 2) Workspace-specific override (recommended)

For this multi-root workspace, keep the same keys under `settings` in:

- `Documents/Programming/Workspaces/PrimaryWorkspace.code-workspace`

This ensures behavior is pinned even if global settings change later.

### 3) Make it persist across all reopenings

Persistence is automatic once the settings are written.

- Close VS Code completely.
- Reopen VS Code.
- Reopen `PrimaryWorkspace.code-workspace`.

Expected result:

- Chat opens as the primary editor view.
- Terminal appears in the bottom panel.

### 4) One-time manual step for identical terminal size

VS Code does not expose a stable numeric setting for exact panel height.
Terminal height is stored from your last layout state.

Do this once per machine:

- Drag the editor/panel splitter so terminal is the preferred smaller height.
- Close and reopen VS Code.

VS Code will reuse that panel height on future reopenings.

### 5) Keep laptop and desktop aligned

Use Settings Sync for User settings:

1. On source machine: turn on Settings Sync and include Settings.
2. On target machine: sign into the same account and enable Settings Sync.
3. Reopen VS Code after sync completes.
4. Apply the one-time panel resize on the target machine for matching height.

### 6) Quick verification commands

Run these commands to confirm required keys exist:

```sh
rg -n 'workbench.startupEditor|workbench.panel.defaultLocation|workbench.panel.opensMaximized|terminal.integrated.defaultLocation|terminal.integrated.tabs.hideCondition' \
  "$HOME/Library/Application Support/Code/User/settings.json" \
  "$HOME/Documents/Programming/Workspaces/PrimaryWorkspace.code-workspace"
```

If all five keys are listed in both files, startup behavior is correctly configured.

## Scripts

See `bin/README.md` for script usage and behavior.
For a dedicated migration guide, see `NEW-MACHINE-README.md`.
