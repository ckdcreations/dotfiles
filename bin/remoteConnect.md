# REMOTECONNECT(1)

## NAME

remoteConnect - interactive SSH bootstrap and managed host alias workflow

## SYNOPSIS

```sh
remoteConnect [new|list|edit|delete|log|show]
remoteConnect help
```

## DESCRIPTION

remoteConnect creates and maintains SSH host entries in ~/.ssh/config, installs public keys for passwordless login, and optionally creates shell aliases in ~/.zshrc.local.

The command supports interactive setup for new hosts and management commands for listing, editing, deleting, and viewing logs for remoteConnect-managed entries.

## COMMANDS

### new

Runs interactive setup for a new managed host alias.

Prompts for:

- server label (human-friendly name)
- SSH host alias
- local network host/IP (optional)
- secondary remote or VPN host/IP (optional)
- remote username
- SSH port (default: 22)
- optional mesh gateway alias for ProxyJump routing
- local private key path (default: ~/.ssh/id_ed25519_ALIAS)

If key material does not exist, remoteConnect creates an ed25519 keypair.

Key installation behavior:

- uses ssh-copy-id when available
- falls back to manual SSH append to authorized_keys if ssh-copy-id is missing
- uses terminal-native password prompts for bootstrap auth
- if no host is reachable during setup, the alias is still created and key installation is deferred with follow-up commands

### list

Lists remoteConnect-managed aliases from ~/.ssh/config.

```sh
remoteConnect list
remoteConnect list --commands
```

With --commands, shows resolved connection details including identity file, port, user, host selection, optional ProxyJump route, and matching shell alias status.

### edit

Edits an existing remoteConnect-managed alias in place.

```sh
remoteConnect edit
remoteConnect edit <alias>
```

Prompts with current values and rewrites the managed host block so user, port, identity path, host addresses, and optional gateway route remain synchronized.

### delete

Deletes a selected remoteConnect-managed alias from ~/.ssh/config and removes its matching remoteConnect-created shell alias from ~/.zshrc.local.

### log

Prints entries from the remoteConnect activity log.

```sh
remoteConnect log
remoteConnect log -t 100
remoteConnect log 100
```

### show

Alias for log.

### help

Prints usage and command help.

## FILES

- ~/.ssh/config
  Managed host entries are appended with a marker comment line:

  ```text
  # Server: SERVER_NAME
  ```

- ~/.zshrc.local
  Optional shell alias blocks are added as:

  ```text
  # Created by remoteConnect
  alias ALIAS_NAME="ssh HOST_ALIAS"
  ```

- ${XDG_STATE_HOME:-~/.local/state}/remoteConnect/remoteConnect.log
  Persistent operational log.

- dotfiles/bin/ssh-select-host
  Helper used for dynamic host preference and reachability checks.

## ROUTING MODEL

remoteConnect supports three routing patterns:

- local-only:
  uses local network host/IP directly

- secondary-only:
  uses secondary remote/VPN host/IP directly

- local plus secondary:
  writes dynamic Match rules that prefer local when reachable and fall back to secondary

Optional gateway routing:

- if mesh gateway alias is supplied, the managed host entry includes ProxyJump GATEWAY_ALIAS
- key bootstrap also uses ProxyJump when a gateway is configured

## EXIT STATUS

- 0: success
- 1: operation failed (validation, network, auth, or file update error)
- 2: command usage error (unknown command or missing required argument)

## EXAMPLES

Create a new server entry:

```sh
remoteConnect new
```

List aliases with resolved command details:

```sh
remoteConnect list --commands
```

Edit one alias directly:

```sh
remoteConnect edit proxmox
```

Delete an alias:

```sh
remoteConnect delete
```

Review the last 75 log lines:

```sh
remoteConnect log -t 75
```

## SECURITY NOTES

- SSH directory and config permissions are enforced (700 for ~/.ssh, 600 for ~/.ssh/config).
- Host aliases are validated to safe characters: letters, numbers, dot, underscore, and dash.
- Existing aliases are never overwritten during creation.
- Failed setup runs remove key files generated during that failed run to avoid stale credential artifacts.

## SEE ALSO

- ssh(1)
- ssh-config(5)
- ssh-copy-id(1)
- ssh-keygen(1)
