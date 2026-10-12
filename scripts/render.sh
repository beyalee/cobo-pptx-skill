#!/usr/bin/env bash
# render.sh — 用 Keynote 把 pptx 导出成 PDF，再逐页转成 PNG，供逐页 QA。
#
# 用法：bash ~/.claude/skills/cobo-customer-solution-deck/scripts/render.sh deck.pptx [输出目录]
#
# · macOS 自带 Keynote 就能用，不用装 LibreOffice。
# · 第一次运行时 Keynote 可能弹欢迎页、缺字体提示或「允许控制 Keynote」授权框，
#   卡住不动就请用户切到 Keynote 点掉，再重跑。
# · Keynote 导出会跳过隐藏页。
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IN="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
OUT="${2:-$(dirname "$IN")/render}"; mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
PDF="$OUT/$(basename "${IN%.*}").pdf"

osascript <<OSA
with timeout of 600 seconds
  tell application id "com.apple.Keynote"
    set d to open POSIX file "$IN"
    export d to POSIX file "$PDF" as PDF
    close d saving no
  end tell
end timeout
OSA

python3 "$DIR/pdf2png.py" "$PDF" --sheet
