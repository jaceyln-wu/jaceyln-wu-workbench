@echo off
chcp 65001 >nul
echo ============================================================
echo  jaceyln wu · 工作台 — 桌面安装脚本（Windows）
echo ============================================================
echo.

:: ── 获取脚本所在目录 ──
set "SCRIPT_DIR=%~dp0"

:: ── 创建 VBS 快捷方式 ──
set "VBS=%TEMP%\jaceyln-wu-shortcut.vbs"
> "%VBS%" (
  echo Set WshShell = WScript.CreateObject("WScript.Shell"^)
  echo strDesktop = WshShell.SpecialFolders("Desktop"^)
  echo Set oShortcut = WshShell.CreateShortcut(strDesktop ^& "\jaceyln wu · 工作台.url"^)
  echo oShortcut.TargetPath = "https://jaceyln-wu.github.io/jaceyln-wu-workbench/"
  echo oShortcut.IconLocation = "%SCRIPT_DIR%icon-512.png,0"
  echo oShortcut.Save
  echo.
  echo ' 同时创建本地文件的 Chrome App 模式快捷方式
  echo Set oLocal = WshShell.CreateShortcut(strDesktop ^& "\jaceyln wu · 工作台(本地).lnk"^)
  echo oLocal.TargetPath = "chrome"
  echo oLocal.Arguments = "--app=""file:///%SCRIPT_DIR%index.html"" --window-size=1320,860"
  echo oLocal.IconLocation = "%SCRIPT_DIR%icon-512.png,0"
  echo oLocal.WorkingDirectory = "%SCRIPT_DIR%"
  echo oLocal.Save
)

cscript //nologo "%VBS%" >nul
del "%VBS%" >nul 2>&1

echo ✅ 桌面快捷方式已创建：
echo    · jaceyln wu · 工作台.url      (在线版，推荐)
echo    · jaceyln wu · 工作台(本地).lnk  (离线版)
echo.
echo 🎉 安装完成！双击桌面图标即可打开工作台。
echo.
echo 提示：如果 Chrome 不在默认路径，右键「本地」快捷方式
echo       → 属性 → 将 'chrome' 改为你电脑上 Chrome 的完整路径。
pause
