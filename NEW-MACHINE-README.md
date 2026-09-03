# New Machine Setup (Fast + Exact)

This guide gets a new laptop to the same setup as your current machine as quickly as possible without copying private SSH keys between devices.

## TL;DR

One line, on the new machine:

```sh
git clone https://github.com/ckdcreations/dotfiles.git ~/dotfiles && ~/dotfiles/bin/updatedot --install-new-ssh-keys
```

For exact parity, start with the tracked repo config, then restore only truly machine-local files if needed.

## 1) Clone and sync the tracked config

On the new machine:

```sh
git clone https://github.com/ckdcreations/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
updatedot --install-new-ssh-keys
```

`updatedot` will:

- pull the latest dotfiles
- re-link the tracked shell and SSH config
- generate any missing `~/.ssh/id_ed25519_*` keys referenced by the tracked SSH aliases (with `--install-new-ssh-keys`, it also walks through installing each one, prompting for that host's password one at a time)
- make sure the Claude Code CLI is installed and you're logged in (never attempts the OAuth login on your behalf — it'll tell you to run `claude` yourself and wait for confirmation)
- pull `ckdCreations-claude-skills` and symlink each skill into `~/.claude/skills`

One exception: the `forgejo` git-SSH host can't be auto-authorized this way (Forgejo doesn't support password-based key install), so it's skipped with a warning during the key walk-through. Register `~/.ssh/id_ed25519_forgejo.pub` once via the Forgejo web UI (Settings → SSH/GPG Keys), then re-run `updatedot` to pick up the skills repo.

## 2) Export only machine-local files from old machine

Run on your current machine:

```sh
cd "$HOME/dotfiles"
./bin/export-local-config --force --no-ssh
```

Manual equivalent (for reference):

```sh
cp "$HOME/.gitconfig.local" "$HOME/dotfiles-local-export/gitconfig.local" 2>/dev/null || true
cp "$HOME/.zshrc.machine.local" "$HOME/dotfiles-local-export/zshrc.machine.local" 2>/dev/null || true

tar -C "$HOME" -czf "$HOME/dotfiles-local-export.tgz" dotfiles-local-export
```

Transfer `~/dotfiles-local-export.tgz` to the new machine.

## 3) Restore machine-local overrides only if needed

If you have a local export bundle:

```sh
tar -C "$HOME" -xzf "$HOME/dotfiles-local-export.tgz"
./bin/new-machine-setup --brew --macos-defaults --restore-local "$HOME/dotfiles-local-export"
```

## 4) Activate in the current terminal

```sh
source ~/.zprofile
source ~/.zshrc
```

After that, opening Apple Terminal starts your tmux + GitHub Copilot layout automatically.

## 5) Match VS Code Chat + terminal behavior exactly

To get identical VS Code behavior (Chat in primary editor, smaller terminal below) on a new machine, ensure these settings exist in User settings:

`~/Library/Application Support/Code/User/settings.json`

```json
{
  "workbench.startupEditor": "chat",
  "workbench.panel.defaultLocation": "bottom",
  "workbench.panel.opensMaximized": "never",
  "terminal.integrated.defaultLocation": "panel",
  "terminal.integrated.tabs.hideCondition": "singleTerminal"
}
```

For this repo's main workspace, also keep matching values in:

- `~/Documents/Programming/Workspaces/PrimaryWorkspace.code-workspace`

Recommended machine-to-machine flow:

1. Enable VS Code Settings Sync (Settings enabled) on the source machine.
2. Sign into the same account on the new machine and enable Settings Sync.
3. Open VS Code once to let settings sync apply.
4. Open `PrimaryWorkspace.code-workspace`.

Important: exact terminal panel height is not a direct setting key.
You must set it once manually per machine:

1. Drag the editor/panel splitter to preferred terminal height.
2. Close and reopen VS Code.

VS Code persists that panel height for future sessions.

Verification command:

```sh
rg -n 'workbench.startupEditor|workbench.panel.defaultLocation|workbench.panel.opensMaximized|terminal.integrated.defaultLocation|terminal.integrated.tabs.hideCondition' \
  "$HOME/Library/Application Support/Code/User/settings.json" \
  "$HOME/Documents/Programming/Workspaces/PrimaryWorkspace.code-workspace"
```

## What the script does

- Runs `bin/bootstrap` (or `bin/bootstrap --brew` with `--brew`)
- Optionally applies macOS defaults with `--macos-defaults`
- Generates missing managed SSH keys for the current device
- Optionally restores:
  - `~/.gitconfig.local`
  - `~/.zshrc.machine.local`
- Prints next-step source commands so commands like `remoteConnect` are immediately usable

## Safety notes

- Restore does not overwrite existing local files unless `--force-restore` is provided.
- Shared SSH aliases live in the repo; `~/.ssh/config.local` remains available for machine-only additions.
