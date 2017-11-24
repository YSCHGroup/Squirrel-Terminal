@echo off
color 0c
rem mode 18,2
cls
echo Squirrel Terminal

rem create path file in Temp
echo %cd%>C:\Temp\SquirrelTerminal.bin

rem Start.powershell-terminal
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%cd%\terminal_shell.ps1""' -Verb RunAs}"
taskkill /PID powershell.exe /F
if %errorlevel%==128 PowerShell -NoProfile -ExecutionPolicy Bypass -Command ".\terminal_shell.ps1"

rem create shortcut-execute in system32 (executable from external cmd/powershell window /w different exec names)
echo @echo off>"C:\Windows\System32\squirrel.bat"
echo PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%cd%\terminal_shell.ps1""' -Verb RunAs}" >>"C:\Windows\System32\squirrel.bat"
echo exit >>"C:\Windows\System32\squirrel.bat"
echo @echo off>"C:\Windows\System32\squirrel terminal.bat"
echo PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%cd%\terminal_shell.ps1""' -Verb RunAs}" >>"C:\Windows\System32\squirrel terminal.bat"
echo exit >>"C:\Windows\System32\squirrel terminal.bat"
echo @echo off>"C:\Windows\System32\squirrelterminal.bat"
echo PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%cd%\terminal_shell.ps1""' -Verb RunAs}" >>"C:\Windows\System32\squirrelterminal.bat"
echo exit >>"C:\Windows\System32\squirrelterminal.bat"
echo @echo off>"C:\Windows\System32\sqt.bat"
echo PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%cd%\terminal_shell.ps1""' -Verb RunAs}" >>"C:\Windows\System32\sqt.bat"
echo exit >>"C:\Windows\System32\sqt.bat"
exit