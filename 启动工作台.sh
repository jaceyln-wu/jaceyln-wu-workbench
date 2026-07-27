#!/bin/bash
# jaceyln wu 工作台 — 一键启动
# 用默认浏览器打开工作台，如果没有则尝试 chromium
DIR="$(cd "$(dirname "$0")" && pwd)"
FILE="$DIR/index.html"

if command -v xdg-open &>/dev/null; then
  xdg-open "$FILE"
elif command -v chromium &>/dev/null; then
  chromium --app="file://$FILE" --window-size=1320,860 &
elif command -v google-chrome &>/dev/null; then
  google-chrome --app="file://$FILE" --window-size=1320,860 &
else
  echo "请手动用浏览器打开: $FILE"
fi
