@echo off
setlocal enabledelayedexpansion
title Batch Calculator by Yasin
color 2

for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
set "out=%temp%\calc_ans.txt"
set "done=%temp%\calc_done.flag"

:top
echo --------------------------------------
echo Vai er Calculator
echo --------------------------------------
echo Enter the math expression:
echo.
set "sum="
set /p sum=
if not defined sum goto top

if exist "%out%" del "%out%" >nul 2>&1
if exist "%done%" del "%done%" >nul 2>&1

start /b "" cmd /c "powershell -noprofile -command "%sum%" > "%out%" 2>&1 & echo done > "%done%""

echo.
call :spinner

set /p ans=<"%out%"
del "%out%" >nul 2>&1
del "%done%" >nul 2>&1

echo = !ans!                  
echo --------------------------------------
pause
cls
echo Previous Answer: !ans!
goto top

:spinner
for %%s in (/ - \ ^| / - \ ^|) do (
    <nul set /p "=Calculating [%%s]!CR!"
    ping -n 1 -w 120 127.0.0.1 >nul
    if exist "%done%" goto :eof
)
goto spinner
