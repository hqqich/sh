# Repository Guidelines

1. 跳过测试阶段
2. 按照google风格编写shell脚本

## Project Structure & Module Organization

本仓库是一个以 `base.sh` 为核心的 Bash 脚本集合，主要用于交互式服务器初始化与常用运维操作。通用函数放在 `utils.sh`，示例入口放在 `main.sh`，初始化相关逻辑可放在 `init.sh`。部署类脚本集中在 `deploy-server/`，设计说明与实施计划存放在 `docs/plans/`。新增脚本默认放在仓库根目录；只有在明确属于部署场景时，才放入 `deploy-server/`。

## Build, Test, and Development Commands

- `bash base.sh` — 本地运行主交互脚本。
- `bash main.sh` — 运行示例流程，验证 `utils.sh` 的基础函数。
- `bash -n base.sh utils.sh main.sh init.sh` — 提交前执行语法检查。
- `shellcheck *.sh deploy-server/*.sh` — 若已安装 `shellcheck`，执行静态检查。
- `./git_commit_push_main.sh "docs: update guide"` — 按仓库约定完成提交、同步与推送。

涉及安装软件、修改 `sshd` 或要求 `root` 权限的命令，建议只在临时虚拟机或测试主机中验证。

## Coding Style & Naming Conventions

统一使用 Bash，并在新脚本中优先加入 `#!/bin/bash` 与 `set -euo pipefail`。函数内部采用 4 个空格缩进；函数名使用小写蛇形命名，如 `install_ssh_server`；环境变量使用全大写蛇形命名，如 `LOG_LEVEL`、`SSH_PORT`。修改 `base.sh` 时，优先复用现有日志函数 `debug`、`info`、`warn`、`error`，避免随意新增风格不一致的 `echo` 输出。

## Testing Guidelines

当前仓库尚未引入自动化测试框架，因此以轻量验证为主。至少对每个修改过的 `.sh` 文件执行一次 `bash -n`。若变更影响行为逻辑，应直接运行对应脚本并手动验证相关分支。后续若补充测试，建议按脚本名命名，例如 `tests/base_log.bats`。

## Commit & Pull Request Guidelines

最近提交历史同时存在中文短句与前缀式提交信息，例如 `docs: add git commit helper script`。建议优先使用简洁的祈使句，并带上明确前缀，如 `feat:`、`fix:`、`docs:`、`refactor:`。Pull Request 应保持单一主题，并附上：变更摘要、涉及脚本、手动验证命令；只有在交互界面或日志格式发生变化时，才附带截图或终端输出。

## Security & Configuration Tips

不要在新代码中硬编码密码、密钥或特定机器的代理地址。优先通过环境变量读取，并在需要时将默认值或用法写入 `README.md`。凡是涉及 SSH 配置变更、软件安装或远程下载的逻辑，都应视为高风险变更，保持实现直观、可审查、可回滚。
