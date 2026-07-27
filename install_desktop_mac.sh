#!/bin/bash
# ============================================================
# jaceyln wu · 工作台 — 桌面安装脚本（macOS）
# 终端执行: bash install_desktop_mac.sh
# ============================================================

DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="jaceyln wu · 工作台"

echo "📦 $APP_NAME 桌面安装（macOS）"
echo ""

# ── 方式1: 创建 .app 目录结构（用 Chrome 的 --app 模式） ──
APP_DIR="$HOME/Applications/jaceyln-wu.app"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

# 启动脚本
cat > "$APP_DIR/Contents/MacOS/jaceyln-wu" << 'LAUNCHER'
#!/bin/bash
DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
# 优先用 Chrome App 模式打开本地文件
if [ -d "/Applications/Google Chrome.app" ]; then
  open -n -a "Google Chrome" --args --app="file://$DIR/index.html" --window-size=1320,860
elif command -v google-chrome &>/dev/null; then
  google-chrome --app="file://$DIR/index.html" --window-size=1320,860 &
else
  open "https://jaceyln-wu.github.io/jaceyln-wu-workbench/"
fi
LAUNCHER
chmod +x "$APP_DIR/Contents/MacOS/jaceyln-wu"

# Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>jaceyln wu · 工作台</string>
    <key>CFBundleDisplayName</key>
    <string>jaceyln wu · 工作台</string>
    <key>CFBundleIdentifier</key>
    <string>com.jaceyln-wu.workbench</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>jaceyln-wu</string>
    <key>CFBundleIconFile</key>
    <string>icon</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
</dict>
</plist>
EOF

# 复制图标
cp "$DIR/icon-512.png" "$APP_DIR/Contents/Resources/icon.icns" 2>/dev/null || true

# ── 方式2: 创建 .webloc 在线版 ──
cat > "$HOME/Desktop/jaceyln wu · 工作台.webloc" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>URL</key>
    <string>https://jaceyln-wu.github.io/jaceyln-wu-workbench/</string>
</dict>
</plist>
EOF

echo "✅ 已完成："
echo "   · 桌面快捷方式（在线版）: ~/Desktop/jaceyln wu · 工作台.webloc"
echo "   · 应用程序包（离线版）: $APP_DIR"
echo ""
echo "   双击 .webloc 用默认浏览器打开在线版"
echo "   把 $APP_DIR 拖入 Dock 即可常驻"
echo ""
echo "🎉 安装完成！"
