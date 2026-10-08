@echo off
setlocal
chcp 65001 >nul

set "PAPERCUT_USER=2510055"
set "PAPERCUT_PASS=202506anewchapter!"
set "DEFAULT_CHOICE=4"
set "BROWSER=msedge"
set "CLI_CONFIG=%TEMP%\webprint-playwright-cli.json"

if "%~1"=="" (
  echo Please drag one or more files onto this script to upload.
  pause
  goto :cleanup
)

rem 逐个收集并校验文件参数，避免特殊字符的文件名破坏解析导致闪退
set "ARG_COUNT=0"
:collect_args
if "%~1"=="" goto :args_collected
if not exist "%~1" (
  echo File not found: "%~1"
  pause
  goto :cleanup
)
set /a ARG_COUNT+=1
set "ARG_%ARG_COUNT%=%~1"
shift
goto :collect_args
:args_collected

if "%PAPERCUT_USER%"=="用户名" (
  echo 请阅读README.md并编辑此脚本以设置用户名和密码。
  echo .
  pause
  goto :cleanup
)

(
  echo {
  echo   "browser": {
  echo     "browserName": "chromium",
  echo     "launchOptions": {
  echo       "args": ["--ignore-certificate-errors"]
  echo     }
  echo   }
  echo }
) > "%CLI_CONFIG%"

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
  set "PRINTER_NAME=win-vccfcnbjej2\PaperCut-WebPrint-彩色双面 （虚拟）"
) else if "%PRINTER_CHOICE%"=="3" (
  set "PRINTER_NAME=win-vccfcnbjej2\PaperCut-WebPrint-黑白 （虚拟）"
) else if "%PRINTER_CHOICE%"=="4" (
  set "PRINTER_NAME=win-vccfcnbjej2\PaperCut-WebPrint-黑白双面 （虚拟）"
) else (
  set "PRINTER_NAME=win-vccfcnbjej2\PaperCut-WebPrint （虚拟）"
)

set "PRINTER_NAME_ESC=%PRINTER_NAME:\=\\%"

REM Open Edge (headed) and perform initial setup
call playwright-cli -s=webprint open https://10.38.3.7/ --headed --config="%CLI_CONFIG%" --browser="%BROWSER%"
if errorlevel 1 goto :cleanup

REM Login, select printer, click '2. 打印选项' and open '上传文件' (single run-code)
call playwright-cli -s=webprint run-code "async page => { const papercutUser = '%PAPERCUT_USER%'; const papercutPass = '%PAPERCUT_PASS%'; await page.getByRole('textbox', { name: '用户名' }).waitFor({ state: 'visible', timeout: 30000 }); await page.getByRole('textbox', { name: '用户名' }).fill(papercutUser); await page.getByRole('textbox', { name: '密码' }).fill(papercutPass); await page.getByRole('button', { name: '登录' }).click(); await page.waitForURL('**/app?service=page/UserSummary', { timeout: 30000 }).catch(() => {}); await page.getByRole('link', { name: '网络打印' }).click(); await page.getByRole('link', { name: '提交任务 »' }).click(); await page.waitForSelector('input[type=radio]', { timeout: 30000 }); const printerChoice = parseInt('%PRINTER_CHOICE%', 10); const printerName = '%PRINTER_NAME_ESC%'; const radios = page.locator('input[type=radio]'); const count = await radios.count(); if (count >= printerChoice) { await radios.nth(printerChoice - 1).check(); } else { await page.getByRole('radio', { name: printerName }).click(); } await page.getByRole('button', { name: '2. 打印选项和账户选择 »' }).click(); await page.getByRole('button', { name: '上传文件 »' }).click(); }"
if errorlevel 1 goto :cleanup

REM Upload each file sequentially
set /a IDX=1
:upload_loop
if %IDX% GTR %ARG_COUNT% goto :upload_done
call set "CUR_FILE=%%ARG_%IDX%%%"
call playwright-cli -s=webprint run-code "async page => { await page.getByRole('button', { name: '从电脑上传' }).click(); }"
if errorlevel 1 goto :cleanup
call playwright-cli -s=webprint upload "%CUR_FILE%"
if errorlevel 1 goto :cleanup
set /a IDX+=1
goto :upload_loop
:upload_done

REM Finalize and submit
call playwright-cli -s=webprint run-code "async page => { await page.getByRole('button', { name: '上传及完成 »' }).click(); }"

:cleanup
del /q "%CLI_CONFIG%" >nul 2>&1
echo Done. The job should now be in the queue.
endlocal
exit /b