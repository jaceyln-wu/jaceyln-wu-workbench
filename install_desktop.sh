#!/bin/bash
# ============================================================
# jaceyln wu · 工作台 — 桌面安装脚本（Linux）
# 双击运行或终端执行: bash install_desktop.sh
# ============================================================

DIR="$(cd "$(dirname "$0")" && pwd)"
DESKTOP_FILE="$DIR/jaceyln-wu.desktop"
ICON_FILE="$DIR/icon-512.png"

echo "📦 jaceyln wu · 工作台 桌面安装"

# ── 自动检测浏览器 ──
BROWSER=""
for b in google-chrome-stable google-chrome chromium chromium-browser; do
  if command -v "$b" &>/dev/null; then
    BROWSER="$b"
    break
  fi
done

if [ -z "$BROWSER" ]; then
  echo "❌ 未检测到 Chrome/Chromium，请先安装。"
  echo "   sudo apt install chromium-browser  (Ubuntu/Debian)"
  echo "   或从 https://www.google.com/chrome/ 下载安装"
  exit 1
fi
echo "✅ 检测到浏览器: $BROWSER"

# ── 生成 .desktop 文件 ──
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Type=Application
Name=jaceyln wu · 工作台
Comment=抖音创作者桌面工作台 — 任务/时间/复盘/爆款灵感/学习资料
Icon=$ICON_FILE
Exec=$BROWSER --app="file://$DIR/index.html" --window-size=1320,860 --name=jaceyln-wu
Terminal=false
Categories=Utility;Office;
StartupWMClass=jaceyln-wu
EOF
echo "✅ 桌面入口已生成: $DESKTOP_FILE"

# ── 安装到系统 ──
if [ -d "$HOME/.local/share/applications" ]; then
  cp "$DESKTOP_FILE" "$HOME/.local/share/applications/"
  echo "✅ 已安装到系统菜单: ~/.local/share/applications/"
fi

if [ -d "$HOME/Desktop" ]; then
  cp "$DESKTOP_FILE" "$HOME/Desktop/"
  chmod +x "$HOME/Desktop/jaceyln-wu.desktop"
  echo "✅ 已复制到桌面: ~/Desktop/"
elif [ -d "$HOME/桌面" ]; then
  cp "$DESKTOP_FILE" "$HOME/桌面/"
  chmod +x "$HOME/桌面/jaceyln-wu.desktop"
  echo "✅ 已复制到桌面: ~/桌面/"
fi

# ── 更新缓存 ──
if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null
fi

echo ""
echo "🎉 安装完成！"
echo "   现在可以在系统菜单搜索 'jaceyln' 打开工作台"
echo "   或直接双击桌面上的 'jaceyln wu · 工作台' 图标"
echo ""
echo "   如果双击没反应，右键 → 属性 → 权限 → 勾选「允许作为程序执行」"
