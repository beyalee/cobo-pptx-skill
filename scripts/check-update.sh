#!/usr/bin/env bash
# check-update.sh — 对比本地与远端的 skill 版本
#
# 用法：bash ~/.claude/skills/cobo-customer-solution-deck/scripts/check-update.sh
#
# 设计约束：
#   · 永远 exit 0。版本检查失败绝不能挡住做 deck 这件正事。
#   · 最多等 5 秒。离线、GitHub 抽风、公司网络封锁都直接跳过。
#   · 用 git fetch 而不是 raw URL，这样私有仓库也能查（沿用 clone 时的登录）。
#   · 输出第一个词是机器可读的状态码，后面才是给人看的说明。

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
local_v="$(head -n1 "$DIR/VERSION" 2>/dev/null | tr -d '\r')"

if [ -z "$local_v" ] || ! git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  echo "SKILL_VERSION_UNKNOWN  本地没有 VERSION 或不是 git clone 安装的"
  echo "  重新安装：见 README 的「安装」"
  exit 0
fi

# 后台 fetch，最多等 5 秒；不弹登录框
GIT_TERMINAL_PROMPT=0 git -C "$DIR" fetch -q origin main >/dev/null 2>&1 &
pid=$!
for _ in 1 2 3 4 5 6 7 8 9 10; do
  kill -0 "$pid" 2>/dev/null || break
  sleep 0.5
done
if kill -0 "$pid" 2>/dev/null; then
  kill "$pid" 2>/dev/null
  echo "SKILL_CHECK_SKIPPED  本地 $local_v（连不上 GitHub，跳过检查）"
  exit 0
fi

remote_v="$(git -C "$DIR" show origin/main:VERSION 2>/dev/null | head -n1 | tr -d '\r')"

if [ -z "$remote_v" ]; then
  echo "SKILL_CHECK_SKIPPED  本地 $local_v（读不到远端版本，跳过检查）"
elif [ "$local_v" = "$remote_v" ]; then
  echo "SKILL_UP_TO_DATE  $local_v"
else
  echo "SKILL_OUTDATED"
  echo "  本地：$local_v"
  echo "  最新：$remote_v"
  echo "  更新：git -C \"$DIR\" pull"
fi

exit 0
