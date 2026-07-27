@echo off
chcp 65001 >nul
title jaceyln wu · 工作台 — 安装到桌面
echo.
echo   ╔══════════════════════════════════════════╗
echo   ║   jaceyln wu · 工作台  安装到桌面      ║
echo   ╚══════════════════════════════════════════╝
echo.

:: ── 自动检测桌面路径（C盘） ──
set "DESKTOP=%USERPROFILE%\Desktop"
if not exist "%DESKTOP%" set "DESKTOP=%USERPROFILE%\桌面"

:: ── 当前脚本所在目录（即工作台文件夹） ──
set "SRC=%~dp0"

echo 工作台目录: %SRC%
echo 桌面目录:   %DESKTOP%
echo.

:: ── 创建在线版快捷方式 (.url) ──
(
echo [InternetShortcut]
echo URL=https://jaceyln-wu.github.io/jaceyln-wu-workbench/
)> "%DESKTOP%\jaceyln wu · 工作台.url"
echo [OK] 在线版快捷方式已创建

:: ── 创建本地版快捷方式 (.lnk) ──
set "VBS=%TEMP%\jw_link.vbs"
> "%VBS%" (
  echo Set WshShell = WScript.CreateObject("WScript.Shell"^)
  echo Set oLink = WshShell.CreateShortcut("%DESKTOP%\jaceyln wu · 工作台(本地).lnk"^)
  echo oLink.TargetPath = "chrome"
  echo oLink.Arguments = "--app=""file:///%SRC%index.html"" --window-size=1320,860 --name=jaceyln-wu"
  echo oLink.WorkingDirectory = "%SRC%"
  echo oLink.Description = "jaceyln wu 抖音创作者工作台"
  echo oLink.IconLocation = "%SRC%icon-512.png,0"
  echo oLink.Save
)
cscript //nologo "%VBS%" >nul
del "%VBS%" >nul 2>&1
echo [OK] 本地版快捷方式已创建

echo.
echo   ╔══════════════════════════════════════════╗
echo   ║  🎉 安装完成！                         ║
echo   ║                                        ║
echo   ║  桌面已出现两个图标：                  ║
echo   ║  · 在线版：双击打开网页版（推荐）      ║
echo   ║  · 本地版：独立窗口打开本地文件        ║
echo   ║                                        ║
echo   ║  提示：本地版需要 Chrome 浏览器。      ║
echo   ║  如果打不开，右键快捷方式→属性，       ║
echo   ║  把「chrome」改为你 Chrome 的完整路径  ║
echo   ╚══════════════════════════════════════════╝
echo.
pause
