# Repository Guidelines

## Project Structure & Module Organization

This repository is a small Bash script collection centered on `base.sh`, the main entry script for interactive server setup tasks. Shared helpers live in `utils.sh`, while `main.sh` is a lightweight example script. Initialization helpers are kept in `init.sh`, deployment-related scripts live under `deploy-server/`, and design notes or implementation plans belong in `docs/plans/`. Keep new shell utilities at the repository root unless they are clearly deployment-specific.

## Build, Test, and Development Commands

- `bash base.sh` — run the main interactive script locally.
- `bash main.sh` — run the simple example flow that exercises `utils.sh`.
- `bash -n base.sh utils.sh main.sh init.sh` — perform a syntax check before committing.
- `shellcheck *.sh deploy-server/*.sh` — run static analysis if `shellcheck` is installed.
- `./git_commit_push_main.sh "docs: update guide"` — helper for commit, sync, and push on the default branch.

Use a disposable VM or test host for commands that install packages, modify `sshd`, or require `root`.

## Coding Style & Naming Conventions

Use Bash with `#!/bin/bash` and prefer `set -euo pipefail` for new scripts. Follow the existing style: 4-space indentation inside functions, lowercase snake_case for function names such as `install_ssh_server`, and uppercase snake_case for environment variables such as `LOG_LEVEL` or `SSH_PORT`. Reuse the logging helpers in `base.sh` (`debug`, `info`, `warn`, `error`) instead of ad hoc `echo` statements when editing that script.

## Testing Guidelines

There is no automated test suite yet, so keep validation lightweight and script-focused. At minimum, run `bash -n` on every changed `.sh` file. When behavior changes, execute the affected script path directly and verify the relevant branch manually. Name any future test fixtures after the script they cover, for example `tests/base_log.bats`.

## Commit & Pull Request Guidelines

Recent history mixes short Chinese summaries with prefix-based messages like `docs: add git commit helper script`. Prefer concise, imperative commits with prefixes such as `feat:`, `fix:`, `docs:`, or `refactor:`. Keep pull requests narrow in scope and include: a short summary, touched scripts, manual verification commands, and screenshots or terminal output only when the UI/logging format changes.

## Security & Configuration Tips

Do not hardcode secrets, passwords, or machine-specific proxy values in new code. Read them from environment variables and document defaults in `README.md` when needed. Treat commands that change SSH settings, install packages, or call remote URLs as high-risk and make them easy to review.
