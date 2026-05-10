@echo off
setlocal
chcp 65001 >nul

set "PAPERCUT_USER=用户名"
set "PAPERCUT_PASS=密码"
set "DEFAULT_CHOICE=1"
set "BROWSER=msedge"

if "%~1"=="" (
  echo Please drag one or more files onto this script to upload.
  pause
  goto :eof
)


rem verify all provided files exist
for %%F in (%*) do (
  if not exist "%%~fF" (
    echo File not found: "%%~fF"
    pause
    goto :eof
  )
)


if "%PAPERCUT_USER%"=="用户名" (
  echo 请阅读README.md并编辑此脚本以设置用户名和密码。
  echo .
  pause
  goto :eof
)


set "CLI_CONFIG=%TEMP%\webprint-playwright-cli.json"
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
set "PRINTER_CHOICE=%PRINTER_CHOICE%"

REM Open Edge (headed) and perform initial setup
call playwright-cli -s=webprint open https://10.38.3.7/ --headed --config="%CLI_CONFIG%" --browser="%BROWSER%"


REM Login, select printer, click '2. 打印选项' and open '上传文件' (single run-code)
call playwright-cli -s=webprint run-code "async page => { const papercutUser = '%PAPERCUT_USER%'; const papercutPass = '%PAPERCUT_PASS%'; await page.getByRole('textbox', { name: '用户名' }).waitFor({ state: 'visible', timeout: 30000 }); await page.getByRole('textbox', { name: '用户名' }).fill(papercutUser); await page.getByRole('textbox', { name: '密码' }).fill(papercutPass); await page.getByRole('button', { name: '登录' }).click(); await page.waitForURL('**/app?service=page/UserSummary', { timeout: 30000 }).catch(() => {}); await page.getByRole('link', { name: '网络打印' }).click(); await page.getByRole('link', { name: '提交任务 »' }).click(); await page.waitForSelector('input[type=radio]', { timeout: 30000 }); const printerChoice = parseInt('%PRINTER_CHOICE%', 10); const printerName = '%PRINTER_NAME_ESC%'; const radios = page.locator('input[type=radio]'); const count = await radios.count(); if (count >= printerChoice) { await radios.nth(printerChoice - 1).check(); } else { await page.getByRole('radio', { name: printerName }).click(); } await page.getByRole('button', { name: '2. 打印选项和账户选择 »' }).click(); await page.getByRole('button', { name: '上传文件 »' }).click(); }"


REM Upload each file sequentially
for %%F in (%*) do (
  call playwright-cli -s=webprint run-code "async page => { await page.getByRole('button', { name: '从电脑上传' }).waitFor({ state: 'visible', timeout: 30000 }); }"
  
  call playwright-cli -s=webprint click "getByRole('button', { name: '从电脑上传' })"
  
  call playwright-cli -s=webprint upload "%%~fF"
  
)

REM Finalize and submit
call playwright-cli -s=webprint run-code "async page => { await page.getByRole('button', { name: '上传及完成 »' }).waitFor({ state: 'visible', timeout: 30000 }); }"

call playwright-cli -s=webprint click "getByRole('button', { name: '上传及完成 »' })"


echo Done. The job should now be in the queue.
del /q "%CLI_CONFIG%" >nul 2>&1
endlocal
goto :eof

endlocal
