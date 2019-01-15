@echo off
setlocal enabledelayedexpansion
::Bget upgrade script
::v0.2.0-10012019
::v0.3.0-14012019 added support for fetching Bget's version info.
::v0.3.1-15012019 fixed the unnecessary "could not find the file specified" ADS prompts


::init global vars
set upgrade_hash_location=https://raw.githubusercontent.com/jahwi/bget/master/bin/hash.txt
set upgrade_script_location=https://raw.githubusercontent.com/jahwi/bget/master/upgrade/upgrade.bat
set bget_location=https://raw.githubusercontent.com/jahwi/bget/master/bget.bat
set changelog_location=https://raw.githubusercontent.com/jahwi/bget/master/docs/changelog.txt
set readme_location=https://raw.githubusercontent.com/jahwi/bget/master/docs/readme.txt
set version_location=https://raw.githubusercontent.com/jahwi/bget/master/bin/version.txt
>nul 2>&1 set /p upgrade_method=<"%~dp0\%~nx0:upgrade_method"
>nul 2>&1 set /p force_bool=<"%~dp0\%~nx0:force_bool"
if not defined upgrade_method set upgrade_method=bits
echo Updating...

::get bget's file hash
set /a sess_rand=%random%
call :download -!upgrade_method! "!upgrade_hash_location!" "%~dp0\temp\hash!sess_rand!.txt"
call :download -!upgrade_method! "!version_location!" "%~dp0\temp\version!sess_rand!.txt"
if not exist "%~dp0\temp\hash!sess_rand!.txt" echo Failed to get the upgrade hash. && exit /b
if not exist "%~dp0\temp\version!sess_rand!.txt" echo Failed to get the version info. && exit /b
>nul 2>&1 set/p new_upgrade_hash=<"%~dp0\temp\hash!sess_rand!.txt"
>nul 2>&1 set/p version=<"%~dp0\temp\version!sess_rand!.txt"
set version=!version: =!

if not exist "%~dp0\bin\hash.txt" (
	echo No local hash found. Will upgrade anyway.
	echo %random%%random%%random%>"%~dp0\bin\hash.txt"
)

::compare old and new hashes

::force if switch is applied


>nul 2>&1 set/p current_upgrade_hash=<"%~dp0\bin\hash.txt"
if /i "!force_bool!"=="yes" (
	echo Forcing upgrade...
	set current_upgrade_hash=%random%%random%%random%
)
if /i "!new_upgrade_hash!"=="!current_upgrade_hash!" echo You already have the latest version. && exit /b

::the actual upgrade
if defined version echo Fetching version !version!.
::make dirs
if not exist docs md docs
if not exist temp md temp
if exist "%~dp0\temp\changelog.txt" del /f /q "%~dp0\temp\changelog.txt"
if exist "%~dp0\temp\bget.bat" del /f /q "%~dp0\temp\bget.bat"
if exist "%~dp0\temp\hash.txt" del /f /q "%~dp0\temp\hash.txt"
call :download -!upgrade_method! "!bget_location!" "%~dp0\temp\bget.bat"
call :download -!upgrade_method! "!upgrade_hash_location!" "%~dp0\temp\hash.txt"
call :download -!upgrade_method! "!changelog_location!" "%~dp0\temp\changelog.txt"
call :download -!upgrade_method! "!readme_location!" "%~dp0\temp\readme.txt"
if not exist "%~dp0\temp\hash.txt" echo Failed to get the Bget hash. && exit /b
if not exist "%~dp0\temp\changelog.txt" echo Failed to get the changelog. && exit /b
if not exist "%~dp0\temp\bget.bat" echo Failed to get Bget's latest version. && exit /b

::move downloaded files
move /Y "%~dp0\temp\bget.bat"
move /Y "%~dp0\temp\hash.txt" "%~dp0\bin\hash.txt"
move /Y "%~dp0\temp\changelog.txt" "%~dp0\docs\changelog.txt"
move /Y "%~dp0\temp\readme.txt" "%~dp0\docs\readme.txt"
move /Y "%~dp0\temp\version!sess_rand!.txt" "%~dp0\bin\version.txt"

::start changelog
start /max /d "%~dp0" notepad "docs\changelog.txt"

::delete self
break
echo Cleaning up...
echo del /f /q "%~dpnx0">>"%~dp0\temp\cleanup.bat"
start /min /d "%~dp0temp" cleanup.bat
break
::del /f /q "%~dpnx0"
exit /b


:download

::BITSADMIN download function
if /i "%~1"=="-bits" (
	set /a rnd=%random%
	bitsadmin /transfer Bget!rnd! /download /priority HIGH "%~2" "%~3" >nul
	set rnd=
	set bits_string=
	exit /b
)

::Jscript download function.
::Download.js was made by jsjoberg @ https://gist.github.com/jsjoberg/8203376
if /i "%~1"=="-js" (
	if not exist "%~dp0\bin\download.js" (
		choice /c yn /n /m  "Bget's JS download function could not be found. Download? [(Y)es/(N)o]"
		if "!errorlevel!"=="2" exit /b
		if "!errorlevel!"=="1" (
		if not exist "%~dp0\bin" md "%~dp0\bin"
			call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/bin/download.js" "%~dp0\bin\download.js"
			if not exist "%~dp0\bin\download.js" echo An error occured when downloading the JS function. && exit /b
		)

	)
	if exist "%~dp0\bin\download.js" (
		cscript //NoLogo //e:Jscript "%~dp0\bin\download.js" "%~2" "%~3"
	)
	exit /b
)

::Curl download function
if /i "%~1"=="-curl" (
	call :checkcurl
	if "!missing_curl!"=="yes" exit /b
	"%~dp0\curl\curl.exe" -s "%~2" -o "%~3"
exit /b
)

::powershell -Command wget "%%b" -OutFile "%%~sc"
::powershell download function
if /i "%~1"=="-ps" (
	Powershell.exe -command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;(New-Object System.Net.WebClient).DownloadFile('%~2','%~3')"
	exit /b
)

::vbs thingy
::vbs script gotten from http://semitwist.com/articles/article/view/downloading-files-from-plain-batch-with-zero-dependencies
if /i "%~1"=="-vbs" (
	if not exist "%~dp0\bin\download.vbs" (
		choice /c yn /n /m  "Bget's VBS download function could not be found. Download? [(Y)es/(N)o]"
		if "!errorlevel!"=="2" exit /b
		if "!errorlevel!"=="1" (
		if not exist "%~dp0\bin" md "%~dp0\bin"
		call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/bin/download.vbs" "%~dp0\bin\download.vbs"
		if not exist "%~dp0\bin\download.vbs" echo An error occured when downloading the VBS function. && exit /b
		)

	)
	if exist "%~dp0\bin\download.vbs" (
		cscript //NoLogo //e:VBScript "%~dp0\bin\download.vbs" "%~2" "%~3"
		exit /b
	)
)
exit /b

:checkcurl
set missing_curl=
for %%a in (curl.exe libcurl.dll curl-ca-bundle.crt) do (
	if not exist "%~dp0\curl\%%a" set missing_curl=yes
)
if not "!missing_curl!"=="yes" exit /b
if "!missing_curl!"=="yes" (
	choice /c yn /n /m "Curl could not be found in the curl sub-directory. Download Curl now? [(Y)es/(N)o]"
	if "!errorlevel!"=="2" exit /b
	if "!errorlevel!"=="1" (
		if not exist "%~dp0\curl" md "%~dp0\curl"
		call :download -bits "https://github.com/jahwi/bget/raw/master/curl/curl.exe" "%~dp0\curl\curl.exe"
		call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/curl/curl-ca-bundle.crt" "%~dp0\curl\curl-ca-bundle.crt"
		call :download -bits "https://github.com/jahwi/bget/raw/master/curl/libcurl.dll" "%~dp0\curl\libcurl.dll"
		set missing_curl_download=
		for %%a in ("curl\curl.exe" "curl\curl-ca-bundle.crt" "curl\libcurl.dll" ) do ( if not exist "%~dp0\%%~a" set missing_curl_download=yes )
		if "!missing_curl_download!"=="yes" echo An error occured when downloading curl. && exit /b
		if not "!missing_curl_download!"=="yes" set missing_curl=
	)
)
exit /b

:trash
set var_to_clean=%*
for %%t in (!var_to_clean!) do (set %%t=)
set var_to_clean=
exit /b