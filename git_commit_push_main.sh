#!/bin/bash

set -euo pipefail

# 这个脚本整理了本次实际使用过的提交流程，适合在子模块这种容易出现
# detached HEAD 的仓库里复用：
# 1. 暂存变更并提交
# 2. 拉取远端目标分支最新状态
# 3. 如果当前是 detached HEAD，就切到目标分支并 cherry-pick 刚才的提交
# 4. 如果当前就在目标分支，就先 rebase 到远端最新提交
# 5. 最后推送到 origin
#
# 用法：
#   ./git_commit_push_main.sh "docs: update README"
#   ./git_commit_push_main.sh "feat: update scripts" README.md base.sh
#
# 可选环境变量：
#   TARGET_BRANCH=main ./git_commit_push_main.sh "docs: update README"

usage() {
    echo "用法: $0 \"commit message\" [file1 file2 ...]"
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

commit_message="$1"
shift

# 优先读取 origin 的默认分支；如果拿不到，就回退到 main。
target_branch="${TARGET_BRANCH:-$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)}"
target_branch="${target_branch:-main}"

echo "目标分支: $target_branch"

# 传了文件名就只暂存指定文件；不传则暂存所有改动。
if [ $# -gt 0 ]; then
    echo "暂存指定文件: $*"
    git add "$@"
else
    echo "暂存所有变更"
    git add -A
fi

# 有暂存内容才创建新提交；没有的话沿用当前 HEAD 继续后续流程。
if git diff --cached --quiet; then
    echo "没有新的暂存内容，跳过 commit，直接处理当前 HEAD。"
else
    git commit -m "$commit_message"
fi

commit_to_push="$(git rev-parse HEAD)"
current_branch="$(git branch --show-current || true)"

echo "同步远端分支: origin/$target_branch"
git fetch origin "$target_branch"

if [ -z "$current_branch" ]; then
    echo "当前是 detached HEAD，切换到 $target_branch 并 cherry-pick 提交 $commit_to_push"
    git switch "$target_branch"

    if ! git cherry-pick "$commit_to_push"; then
        cat <<EOF

cherry-pick 发生冲突，请手动解决后继续：
  git add <冲突文件>
  git cherry-pick --continue
  git push origin $target_branch
EOF
        exit 1
    fi
elif [ "$current_branch" = "$target_branch" ]; then
    echo "当前就在 $target_branch，先 rebase 到 origin/$target_branch"

    if ! git rebase "origin/$target_branch"; then
        cat <<EOF

rebase 发生冲突，请手动解决后继续：
  git add <冲突文件>
  git rebase --continue
  git push origin $target_branch
EOF
        exit 1
    fi
else
    echo "当前分支是 $current_branch，不是 $target_branch。"
    echo "按本次流程，切换到 $target_branch 并把当前提交 cherry-pick 过去。"
    git switch "$target_branch"

    if ! git cherry-pick "$commit_to_push"; then
        cat <<EOF

cherry-pick 发生冲突，请手动解决后继续：
  git add <冲突文件>
  git cherry-pick --continue
  git push origin $target_branch
EOF
        exit 1
    fi
fi

echo "推送到 origin/$target_branch"
git push origin "$target_branch"

echo "完成，当前最新提交为: $(git rev-parse --short HEAD)"
