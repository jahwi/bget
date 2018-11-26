@echo off
title Bget Updater
setlocal enabledelayedexpansion


::init global vars
set upgrade_hash_location=https://raw.githubusercontent.com/jahwi/bget/master/bin/hash.txt
set upgrade_script_location=https://raw.githubusercontent.com/jahwi/bget/master/upgrade/upgrade.bat
set bget_location=https://raw.githubusercontent.com/jahwi/bget/master/bget.bat
set changelog_location=https://raw.githubusercontent.com/jahwi/bget/master/docs/changelog.txt
set readme_location=https://raw.githubusercontent.com/jahwi/bget/master/docs/readme.txt
set /p upgrade_method=<%~nx0:upgrade_method
set /p force_bool=<%~nx0:force_bool
if not defined upgrade_method set upgrade_method=bits
echo Updating...

::get bget's file hash
set /a sess_rand=%random%
call :download -!upgrade_method! "!upgrade_hash_location!#%cd%\temp\hash!sess_rand!.txt"
if not exist temp\hash!sess_rand!.txt echo Failed to get the upgrade hash. && pause && exit /b
set/p new_upgrade_hash=<temp\hash!sess_rand!.txt

if not exist bin\hash.txt (
	echo No local hash found. Will upgrade anyway.
	echo %random%%random%%random%>bin\hash.txt
)

::compare old and new hashes

::force if switch is applied
if /i "!force_bool!"=="yes" (
	echo Forcing upgrade...
	echo %random%%random%%random%>bin\hash.txt
)

set/p current_upgrade_hash=<bin\hash.txt
if /i "!new_upgrade_hash!"=="!current_upgrade_hash!" echo You already have the latest version. && pause && exit /b

::the actual upgrade

::make dirs
if not exist docs md docs
if exist temp\changelog.txt del /f /q changelog.txt
if exist temp\bget.bat del /f /q temp\bget.bat
if exist temp\hash.txt del /f /q temp\hash.txt
call :download -!upgrade_method! "!bget_location!#%cd%\temp\bget.bat"
call :download -!upgrade_method! "!upgrade_hash_location!#%cd%\temp\hash.txt"
call :download -!upgrade_method! "!changelog_location!#%cd%\temp\changelog.txt"
call :download -!upgrade_method! "!readme_location!#%cd%\temp\readme.txt"
if not exist "temp\hash.txt" echo Failed to get the Bget hash. && pause && exit /b
if not exist "temp\changelog.txt" echo Failed to get the changelog. && pause && exit /b
if not exist "temp\bget.bat" echo Failed to get Bget's latest version. && pause && exit /b

::move downloaded files
move /Y "temp\bget.bat"
move /Y "temp\hash.txt" "bin\hash.txt"
move /Y "temp\changelog.txt" "docs\changelog.txt"
move /Y "temp\readme.txt" "docs\readme.txt"

::start changelog
start /max notepad docs\changelog.txt

::delete self
start /B del /f /q %~nx0
pause
exit


:download

::BITSADMIN download function
if /i "%~1"=="-bits" (
	set /a rnd=%random%
	for /f "tokens=1,2 delims=#" %%w in ("%~2") do (
		bitsadmin /transfer Bget!rnd! /download /priority HIGH "%%w" "%%x"
	)
	set rnd=
	set bits_string=
	exit /b
)
::Jscript download function.
::Download.js was made by jsjoberg @ https://gist.github.com/jsjoberg/8203376
if /i "%~1"=="-js" (
	if not exist "bin\download.js" (
		choice /c yn /n /m  "Bget's JS download function could not be found. Download? [(Y)es/(N)o]"
		if "!errorlevel!"=="2" exit /b
		if "!errorlevel!"=="1" (
		if not exist bin md bin
			call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/bin/download.js#%cd%\bin\download.js"
			if not exist bin\download.js echo An error occured when downloading the JS function. && pause && exit /b
		)

	)
	if exist "bin\download.js" (
		for /f "tokens=1,2 delims=#" %%e in ("%~2") do (
			cscript //NoLogo //e:Jscript bin\download.js "%%e" "%%f"
		)
	)
	exit /b
)
::Curl download function
if /i "%~1"=="-curl" (
	call :checkcurl
	if "!missing_curl!"=="yes" (
		set upgrade_method=bits
		echo Defaulting to BITSADMIN...
		call :download -bits "%~2"
		exit /b
	)
	for /f "tokens=1,2 delims=#" %%b in ("%~2") do (
		curl -s "%%b" -o "%%c"
	)
exit /b
)

::powershell download function
if /i "%~1"=="-ps" (
	for /f "tokens=1,2 delims=#" %%b in ("%~2") do (
	powershell -Command wget "%%b" -OutFile "%%~sc"
	)
	exit /b
)

::vbs thingy
::vbs script gotten from http://semitwist.com/articles/article/view/downloading-files-from-plain-batch-with-zero-dependencies
if /i "%~1"=="-vbs" (
	if not exist "bin\download.vbs" (
		choice /c yn /n /m  "Bget's VBS download function could not be found. Download? [(Y)es/(N)o]"
		if "!errorlevel!"=="2" exit /b
		if "!errorlevel!"=="1" (
		if not exist bin md bin
		call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/bin/download.vbs#%cd%\bin\download.vbs"
		if not exist bin\download.vbs echo An error occured when downloading the VBS function. && pause && exit /b
		)

	)
	if exist "bin\download.vbs" (
		for /f "tokens=1,2 delims=#" %%e in ("%~2") do (
			cscript //NoLogo //e:VBScript bin\download.vbs "%%e" "%%f"
		)
		exit /b
	)
)
exit /b

:checkcurl
set missing_curl=
for %%a in (curl.exe libcurl.dll curl-ca-bundle.crt) do (
	if not exist "curl\%%a" set missing_curl=yes
)
if not "!missing_curl!"=="yes" exit /b
if "!missing_curl!"=="yes" (
	choice /c yn /n /m "Curl could not be found in the curl sub-directory. Download Curl now? [(Y)es/(N)o]"
	if "!errorlevel!"=="2" (
		set upgrade_method=bits
		exit /b
	)
	if "!errorlevel!"=="1" (
		if not exist curl md curl
		call :download -bits "https://github.com/jahwi/bget/raw/master/curl/curl.exe#%cd%\curl\curl.exe"
		call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/curl/curl-ca-bundle.crt#%cd%\curl\curl-ca-bundle.crt"
		call :download -bits "https://github.com/jahwi/bget/raw/master/curl/libcurl.dll#%cd%\curl\libcurl.dll"
		set missing_curl_download=
		for %%a in ("curl\curl.exe" "curl\curl-ca-bundle.crt" "curl\libcurl.dll" ) do ( if not exist "%%~a" set missing_curl_download=yes )
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