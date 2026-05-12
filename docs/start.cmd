@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo 正在生成索引...
python "%~dp0..\build_index.py" "%~dp0."
if errorlevel 1 (
  echo 生成索引失败，请确认已安装 Python 并已加入 PATH。
  pause
  exit /b 1
)

echo.
echo 请在浏览器打开（勿用 file:/// 直接打开 html）:
echo   http://127.0.0.1:8765/index.html
echo.
echo 按 Ctrl+C 可停止服务。端口 8765 若被占用，请编辑本脚本修改端口号。
echo.

python -m http.server 8765 --bind 127.0.0.1 --directory "%~dp0."
pause
