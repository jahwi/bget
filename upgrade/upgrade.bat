@echo off
title Bget updater
setlocal enabledelayexexpansion
echo Updating...
timeout /nobreak /t 5>nul
move /Y "temp\bget.bat"
move /Y "temp\hash.txt" "bin\hash.txt"
notepad changelog.txt
exit