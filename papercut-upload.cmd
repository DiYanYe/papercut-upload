@echo off
setlocal
chcp 65001 >nul

rem Usage: drag files onto this .cmd, or run: papercut-upload-checked.cmd "C:\path\file1.pdf" "C:\path\file2.docx"

if "%~1"=="" (
  echo Usage: Drag one or more files onto this script to upload.
  exit /b 1
)


set "BROWSER=msedge"
set "DEFAULT_CHOICE=1"
set "PAPERCUT_USER=替换你的用户名！"
set "PAPERCUT_PASS=替换你的密码！"


set "PWC=playwright-cli"
set "WAIT_TIMEOUT=30000"


echo Select printer:
echo   1. win-vccfcnbjej2\PaperCut-WebPrint （虚拟）
echo   2. win-vccfcnbjej2\PaperCut-WebPrint-彩色双面 （虚拟）
echo   3. win-vccfcnbjej2\PaperCut-WebPrint-黑白 （虚拟）
echo   4. win-vccfcnbjej2\PaperCut-WebPrint-黑白双面 （虚拟）
set "PRINTER_CHOICE="
:printer_prompt
set /p PRINTER_CHOICE=Press Enter to select [%DEFAULT_CHOICE%], or type 1-4 to choose a printer: 
if "%PRINTER_CHOICE%"=="" set "PRINTER_CHOICE=%DEFAULT_CHOICE%"
if "%PRINTER_CHOICE%"=="1" goto printer_ok
if "%PRINTER_CHOICE%"=="2" goto printer_ok
if "%PRINTER_CHOICE%"=="3" goto printer_ok
if "%PRINTER_CHOICE%"=="4" goto printer_ok
echo Invalid choice. Please enter 1-4.
goto printer_prompt
:printer_ok

if "%PRINTER_CHOICE%"=="2" (
  set "PRINTER_NAME=win-vccfcnbjej2\\PaperCut-WebPrint-彩色双面 （虚拟）"
) else if "%PRINTER_CHOICE%"=="3" (
  set "PRINTER_NAME=win-vccfcnbjej2\\PaperCut-WebPrint-黑白 （虚拟）"
) else if "%PRINTER_CHOICE%"=="4" (
  set "PRINTER_NAME=win-vccfcnbjej2\\PaperCut-WebPrint-黑白双面 （虚拟）"
) else (
  set "PRINTER_NAME=win-vccfcnbjej2\\PaperCut-WebPrint （虚拟）"
)

call %PWC% open https://10.38.3.7/ --browser=%BROWSER% --headed

call %PWC% run-code "async page => { await page.getByRole('button', { name: '高级' }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
call %PWC% click "getByRole('button', { name: '高级' })"
call %PWC% run-code "async page => { await page.getByRole('link', { name: /继续.*/ }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
call %PWC% click "getByRole('link', { name: /继续.*/ })"
call %PWC% run-code "async page => { await page.getByRole('textbox', { name: '用户名' }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
call %PWC% fill "getByRole('textbox', { name: '用户名' })" "%PAPERCUT_USER%"
call %PWC% fill "getByRole('textbox', { name: '密码' })" "%PAPERCUT_PASS%"
call %PWC% click "getByRole('button', { name: '登录' })"

call %PWC% run-code "async page => { await page.getByRole('link', { name: '网络打印' }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
call %PWC% click "getByRole('link', { name: '网络打印' })"
call %PWC% run-code "async page => { await page.getByRole('link', { name: '提交任务 »' }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
call %PWC% click "getByRole('link', { name: '提交任务 »' })"

call %PWC% run-code "async page => { await page.getByRole('radio', { name: '%PRINTER_NAME%' }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
call %PWC% click "getByRole('radio', { name: '%PRINTER_NAME%' })"
call %PWC% click "getByRole('button', { name: '打印选项和账户选择 »' })"
call %PWC% run-code "async page => { await page.getByRole('button', { name: '上传文件 »' }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
call %PWC% click "getByRole('button', { name: '上传文件 »' })"

for %%F in (%*) do (
  call %PWC% run-code "async page => { await page.getByRole('button', { name: '从电脑上传' }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
  call %PWC% click "getByRole('button', { name: '从电脑上传' })"
  call %PWC% upload "%%~fF"
)

call %PWC% run-code "async page => { await page.getByRole('button', { name: '上传及完成 »' }).waitFor({ state: 'visible', timeout: %WAIT_TIMEOUT% }); }"
call %PWC% click "getByRole('button', { name: '上传及完成 »' })"

echo.
echo Done. Press any key to close.
pause >nul
endlocal