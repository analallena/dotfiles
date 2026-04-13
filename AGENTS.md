# AGENTS.md

Guidelines for agentic coding agents working in this repository.

## Repository Overview

Personal macOS dotfiles — shell configurations, scripts, and workstation setup tooling.
Primary language: **Bash**. Secondary: Terraform/HCL, YAML (CI).

```
dotfiles/
├── bin/dot                        # CLI entrypoint; dispatches to scripts/
├── scripts/
│   ├── core/                      # Shared Bash library (sourced by all scripts)
│   │   ├── _main.sh               # Single-entry loader (sources all core modules)
│   │   ├── args.sh, collections.sh, documentation.sh, env.sh
│   │   ├── git.sh, log.sh, platform.sh, str.sh, table.sh, types.sh
│   ├── aws/logs                   # AWS CloudWatch log script
│   └── rename_files.sh
├── shell/                         # Shell init files (aliases, exports, functions)
├── git/DOTgitconfig               # Git config (symlinked to ~/.gitconfig)
├── setup/
│   ├── mac_setup.sh               # Creates symlinks for DOT* files
│   └── Brewfile                   # Homebrew package manifest
└── terraform-init-tf-state/       # Terraform S3 remote state bootstrap
```

## Build / Setup / Run Commands

There is no Makefile, package.json, or task runner. Everything is shell-driven.

| Task | Command |
|---|---|
| Bootstrap a new Mac | `bash setup/mac_setup.sh` |
| Install Homebrew packages | `brew bundle --file=setup/Brewfile` |
| Run any dotfiles script | `dot <context> <cmd> [args]` |
| Interactive script picker | `dot` (no args) — uses fzf |
| AWS log retrieval | `dot aws logs get [--log-group=...] [--log-stream=...] [--output=json\|text]` |
| AWS log deletion | `dot aws logs delete --log-group=<name>` |
| Reload shell | `reload` (alias for `source ~/.bash_profile`) |
| Trigger release | Push to `main` → GitHub Actions runs `npx semantic-release` |

### Required Environment Variables

- `DOTFILES_PATH` — must point to this repo root (e.g. `$HOME/ws/personal/dotfiles`)
- `DOTFILES_PATHS` — colon-separated list of dotfiles locations (defaults to `$DOTFILES_PATH`)

## Testing

There is no automated test suite. Validate changes manually:

1. Source the core library in a fresh shell and call the modified function directly.
2. Run `dot <context> <cmd> --help` to verify help output renders correctly.
3. Lint Bash scripts with `shellcheck <script>` (shellcheck is available via Homebrew).
4. Validate Terraform: `terraform -chdir=terraform-init-tf-state validate`
5. Check Brewfile syntax: `brew bundle check --file=setup/Brewfile`

To test a single script end-to-end:
```bash
DOTFILES_PATH="$(pwd)" bash scripts/<context>/<cmd> [args]
```

## Code Style — Bash

### Shebang & Safety Flags

Always use the env-based shebang. Apply `set -euo pipefail` at the top of every
standalone script (entrypoints and command scripts). Core library modules (sourced
files under `scripts/core/`) do not use `set -euo pipefail` because they are not
executed directly.

```bash
#!/usr/bin/env bash
set -euo pipefail
```

### Indentation & Formatting

- 2-space indentation; no tabs.
- One blank line between function definitions.
- Opening `{` on the same line as the function name.
- `case` statements indent each pattern 2 spaces, body 4 spaces.

### Quoting

Quote all variable expansions. Use `"${VAR}"` (braces + double quotes) in library
code. Avoid unquoted variables except in arithmetic contexts.

```bash
# Good
echo "${my_var}"
local result="${some_function}"

# Avoid
echo $my_var
```

### Local Variables

Declare all function-scoped variables with `local` at the top of the function.
Use `local -r` for variables that should not be reassigned.

```bash
my_func() {
  local -r input="${1}"
  local result
  result="$(compute "${input}")"
  echo "${result}"
}
```

### Constants & Read-only Globals

UPPER_SNAKE_CASE, declared with `readonly`:

```bash
readonly DOT_MAIN_SOURCED=true
readonly LOG_FILE="/tmp/dot.log"
```

### Variable Naming

| Scope | Convention | Example |
|---|---|---|
| Local variables | `lower_snake_case` | `log_group`, `selected_profile` |
| Global constants | `UPPER_SNAKE_CASE` + `readonly` | `DOTFILES_PATH` |
| Loop variables | short, descriptive | `file`, `line`, `key` |

## Naming Conventions — Functions

All public functions use double-colon namespacing: `namespace::function_name`.
Private/internal helpers are prefixed with `_`.

| Namespace | Purpose |
|---|---|
| `args::` | Argument parsing and validation |
| `coll::` | Array / collection utilities |
| `docs::` | Help generation (docpars) |
| `env::` | Environment / region validation |
| `git::` | Git helpers |
| `log::` | Colored terminal logging |
| `platform::` | OS detection and command checks |
| `str::` | String utilities |
| `table::` | Terminal table printing |
| `types::` | Type-checking helpers |

Examples: `log::error`, `coll::contains_element`, `platform::is_macos`, `_log` (private).

## Imports / Sourcing

Source the core library using the single-entry guard-protected loader. Never source
individual core modules directly from scripts.

```bash
# At the top of every script, after set -euo pipefail
source "${DOTFILES_PATH}/scripts/core/_main.sh"
```

`_main.sh` uses a boolean guard (`DOT_MAIN_SOURCED`) to prevent double-sourcing.
Do not bypass this pattern.

Shell init chain: `DOTbash_profile` / `DOTbashrc` → `shell/init.sh` → `aliases.sh`,
`exports.sh`, `functions.sh`.

## Error Handling

Use a layered approach:

1. **`set -euo pipefail`** — fail fast on unhandled errors (entrypoint scripts only).
2. **Explicit `exit` with meaningful codes** — `exit 1` for usage/config errors,
   `exit 2` for invalid argument values.
3. **Propagate exit codes from subcommands** via `${?}` checks when you need to act
   on failures before re-exiting.
4. **Send error output to stderr**: use `echoerr()` or redirect with `1>&2`.

```bash
# Usage / config error
if [[ -z "${JWT_AUTH_TOKEN:-}" ]]; then
  echo "JWT_AUTH_TOKEN environment variable not set" 1>&2
  exit 1
fi

# Invalid argument value
env::check_valid_environment "${environment}"   # exits 2 internally

# Propagating a subcommand failure
aws sso login
if [[ ${?} -ne 0 ]]; then
  exit ${?}
fi
```

Use `log::error` for user-facing error messages and `log::warning` for non-fatal
issues. Reserve bare `echo` for data output (piped results, JSON, etc.).

## Logging

The `log::` namespace (from `scripts/core/log.sh`) provides colored terminal output.
Use these consistently — do not roll your own `echo`-based logging in new scripts.

| Function | Color | Use for |
|---|---|---|
| `log::header` | bold | Section titles |
| `log::success` | green | Completed actions |
| `log::error` | red | Failures |
| `log::warning` | tan | Non-fatal issues |
| `log::note` | blue | Informational messages |

## Self-Documenting Scripts (Help Text)

Every command script should be self-documenting using `##?` comment blocks and
`docs::eval`. This generates `--help` output at runtime via `docpars`.

```bash
##? Short description of the script.
##? Usage:
##?   mycommand [--flag=<value>]
##? Options:
##?   -f, --flag=<value>    Description of the flag
#?? 1.0.0

source "${DOTFILES_PATH}/scripts/core/_main.sh"
docs::eval "$@"
```

Always call `docs::eval "$@"` immediately after sourcing the core library.

## Dotfile Naming Convention

Shell config files are prefixed with `DOT` instead of `.` so they remain visible
in directory listings and version control (e.g. `DOTbash_profile` → `~/.bash_profile`).
The `setup/mac_setup.sh` script creates the symlinks.

## Adding a New Script

1. Create the file at `scripts/<context>/<command>` (no extension).
2. Make it executable: `chmod +x scripts/<context>/<command>`.
3. Add a shebang, `set -euo pipefail`, and source `_main.sh`.
4. Add `##?` help comments and call `docs::eval "$@"`.
5. The script is automatically discoverable by `dot <context> <command>`.

## Git & CI

- Commits must follow **Conventional Commits** (`feat:`, `fix:`, `chore:`, etc.) —
  `semantic-release` uses them to generate changelogs and version tags automatically.
- GPG commit signing is enforced via `git/DOTgitconfig` (`gpgsign = true`).
- Git identity is selected per workspace via `includeIf` blocks in DOTgitconfig
  (`personal/`, `tw/`, `work/` directory prefixes).
- The only CI pipeline is `.github/workflows/semantic-release.yaml`, triggered on
  push to `main`.

## Terraform

The `terraform-init-tf-state/` directory bootstraps S3 remote state. It is standalone
and not integrated with the Bash scripts. Follow standard Terraform conventions:
`terraform fmt`, `terraform validate`, and `tflint` before committing HCL changes.
