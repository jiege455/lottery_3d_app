@echo off
chcp 65001 >nul 2>&1
title 福彩3D助手 - APK打包中...
echo.
echo ============================================
echo    福彩3D/排列三 投注助手 - 打包脚本
echo    开发者：杰哥网络科技  QQ:2711793818
echo ============================================
echo.

set FLUTTER_HOME=C:\flutter\flutter
set PATH=%FLUTTER_HOME%\bin;%PATH%

cd /d "%~dp0"

echo [1/2] 正在编译 Release APK...
echo     (首次打包需要 3-10 分钟，请耐心等待...)
echo.
call flutter build apk --release --no-pub
if errorlevel 1 (
    echo.
    echo [错误] 编译失败！请检查上方错误信息。
    pause
    exit /b 1
)
echo.

echo [2/2] 打包完成！
echo.
for %%F in ("%~dp0build\app\outputs\flutter-apk\app-release.apk") do set APKSIZE=%%~zF
set /a APKMB=%APKSIZE% / 1048576
echo ============================================
echo   APK 文件: app-release.apk
echo   大小约: %APKMB% MB
echo   位置: %~dp0build\app\outputs\flutter-apk\
echo ============================================
echo.

if exist "%~dp0build\app\outputs\flutter-apk\app-release.apk" (
    echo 正在打开文件夹...
    explorer "%~dp0build\app\outputs\flutter-apk\"
) else (
    echo [警告] 未找到APK文件，可能编译未成功。
)

pause
