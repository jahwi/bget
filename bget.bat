@echo off
setlocal enabledelayedexpansion
:: Bget-  Batch script fetcher
:: v0.1.1
::Made by Jahwi, Icarus and Ben
:: Conceived, coded and died in 2016, resurrected and recoded in 2018. Enjoy! \o/

::init directories
if not exist temp md temp
if not exist scripts md scripts
if not exist bin md bin
if not exist docs md docs

::init global vars and settings
set info_mode=off
set list_location=https://raw.githubusercontent.com/jahwi/bget-list/master/master.txt
set auto-delete_logs=yes

goto :main

::check for curl
:checkcurl
set missing_curl=
for %%a in (curl.exe libcurl.dll curl-ca-bundle.crt) do (
	if not exist "curl\%%a" set missing_curl=yes
)
if not "!missing_curl!"=="yes" exit /b
if "!missing_curl!"=="yes" (
	choice /c yn /n /m "Curl could not be found in the curl sub-directory. Download Curl now? [(Y)es/(N)o]"
	if "!errorlevel!"=="2" exit /b
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

:main
::print the bget intro, followed by the relevant output
for %%a in ("  ---------------------------------------------------------------------------" 
"  Bget v0.1.2		Batch Script Manager" 
"  Made by Jahwi in 2018	Edits made by Icarus." 
"  https://github.com/jahwi/bget" 
"  ---------------------------------------------------------------------------" 
""
) do echo=%%~a

::checks for errors in user input, then calls the switch.

::input validation
set input_string=%*
if defined input_string for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z -) do (
	set input_string=!input_string:%%a=!
	if defined input_string set input_string=!input_string: =!
)
if not "!input_string!"=="" ( 
	set msg=Invalid input.
	call :help
	exit /b
)

if "%~1"=="" set msg=Error: No switch supplied. && call :help && exit /b
set valid_bool=
for %%x in (get remove update info list upgrade help pastebin) do (
	if /i "-%%x"=="%~1" set valid_bool=yes
)
if not "!valid_bool!"=="yes" set msg=Error: Invalid switch && call :help && exit /b
if "!valid_bool!"=="yes" ( 
	set switch_string=%*
	call :!switch_string:~1!
	if /i "!auto-delete_logs!"=="yes" (
		if exist "temp\master!sess_rand!.txt" del /f /q "temp\master!sess_rand!.txt" >nul
		if exist "temp\hash!sess_rand!.txt" del /f /q "temp\hash!sess_rand!.txt" >nul
	)
	exit /b
)


set valid_bool=

::--------------------------------------------------------------------
::Beginning of Functions.
::--------------------------------------------------------------------
:help

::opens helpdoc
if /i "!switch_string:~0,10!"=="-help -doc" (
	if not "%~3"=="" echo Invalid number of arguments. && exit /b
	if /i not "!switch_string!"=="-help -doc" echo Invalid help switch. && exit /b
	if exist docs\readme.txt (
		type docs\readme.txt
		exit /b
	)
	if not exist docs\readme.txt echo the bget help doc is missing. Run bget -upgrade -usebits to get it. && exit /b
)

::is printed if help switch, no switch or an incorrect switch is supplied.
for %%a in (
	"  ---------------------------------------------------------------------------"
	"  BGET [-switch {subswitches} {ARG} ]"
	"  [-get {-usemethod} "SCRIPTs" ]        Fetches a script/scripts."
	"  [-pastebin {-usemethod} PASTE_CODE local_filename ] Gets a Pastebin script."
	"  [-remove "SCRIPTs" ]                  Removes a script/scripts"
	"  [-update {-usemethod} "SCRIPTs" ]     Updates the script/scripts"
	"  [-info {-usemethod} SCRIPT ]          Gets info on the specified script."
	"  [-list -server {-usemethod} ]         Lists scripts on Bget's server."
	"  [-list -local]                        Lists local scripts."
	"  [-upgrade {-usemethod} ]              Updates Bget."
	"  [-upgrade {-usemethod} -force ]       Updates Bget, regardless of version."
	"  -help                                 Prints this help screen."
	"  -help -doc                            Opens the full help text."
	""
	"  Supported methods: -useJS -useVBS -usePS -useBITS -useCURL"
	"  Example: bget -get -useVBS test"
	"  Some Antiviruses flag the JS and VBS download functions as viruses."
	"  Either witelist them or use the BITS method."
	"  Type BGET -help -doc for the full help text
	"  ---------------------------------------------------------------------------"
) do echo=%%~a
if defined msg echo !msg!
set msg=
exit /b
::--------------------------------------------------------------------

:get
::the man, the myth, the legend, the main squeeze, the bees knees, the script fetching function.

::check for user errors
set get_bool=
set get_method=

if "%~1"=="" echo Error: No get method supplied. && exit /b
for %%s in (curl js vbs bits ps) do (
	if /i "%~1"=="-use%%s" (
		set get_bool=yes
		set get_method=%%s
		if "%~2"=="" echo Error: Invalid argument. && exit /b
	)
)
if not "!get_bool!"=="yes" (
	set msg=Error: Invalid get method.
	call :help
	exit /b
)
set get_bool=



::downloads
::will attempt to download curl if when using the curl get method, curl isnt found in the curl subdirectory.
	echo Reading script list...
	for %%r in (%~2) do (
		set /a sess_rand=%random%
		if exist temp\master!sess_rand!.txt del /f /q temp\master!sess_rand!.txt
		call :download -!get_method! "!list_location!#%cd%\temp\master!sess_rand!.txt"
		if not exist temp\master!sess_rand!.txt echo An error occured getting the script list && exit /b
		set script_count=
		
		%=download all scripts on the server if all switch is triggered=%
		if /i "%~2"=="-all" (
			for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#]," temp\master!sess_rand!.txt') do (
				if exist "scripts\%%~b\" echo "%%~b" already exists. Skipping.
				if not exist "scripts\%%~b\" (
					echo Fetching "%%~b"...
					if not exist "scripts\%%~b" md "scripts\%%~b"
					call :download -!get_method! "%%~c#%cd%\scripts\%%~b\%%~e"
					if not exist "scripts\%%~b\%%~e" echo Failed to get "%%~b"
					if exist "scripts\%%~b\%%~e" (
						echo %%f>scripts\%%~b\hash.txt
						echo %%d>scripts\%%~b\info.txt
						echo %%g>scripts\%%~b\author.txt
						%=Deal with .cab packages=%
						if "%%~xe"==".cab" (
							echo Extracting...
							expand "scripts\%%~b\%%~e" -F:* "scripts\%%~b" >nul
							if not exist "scripts\%%~b\package" md "scripts\%%~b\package"
							move /Y "scripts\%%~b\%%~e" "scripts\%%~b\package"
						)
						echo Done.
					)
				)
			)
			exit /b
		)
		
		%=From info function.=%
		for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],%%~r," temp\master!sess_rand!.txt') do (
			if "!info_mode!"=="on" (
				echo.
				echo Name: %%~b
				echo Author:%%~g
				echo Description: %%~d
				echo Category: %%~h
				echo Location: %%~c
				echo Hash: %%~f
				set info_mode=off
				exit /b
			)
			
			
			if exist scripts\%%~b\ echo The script "%%~b" already exists in this directory. && exit /b
			set /a script_count+=1
			echo Fetching %%~b...
			if not exist "scripts\%%~b" md "scripts\%%~b"
			call :download -!get_method! "%%~c#%cd%\scripts\%%~b\%%~e"
			if not exist "scripts\%%~b\%%~e" echo An error occured while fetching the script. && exit /b
			if exist "scripts\%%~b\%%~e" (
				echo %%f>scripts\%%~b\hash.txt
				echo %%d>scripts\%%~b\info.txt
				echo %%g>scripts\%%~b\author.txt
				if "%%~xe"==".cab" (
					echo Extracting...
					expand "scripts\%%~b\%%~e" -F:* "scripts\%%~b" >nul
					if not exist "scripts\%%~b\package" md "scripts\%%~b\package"
					move /Y "scripts\%%~b\%%~e" "scripts\%%~b\package"
				)
				echo Done.
			)
		)
		if not defined script_count echo The script "%%~r" does not exist on the server. && exit /b
	)
	exit /b
::--------------------------------------------------------------------

:pastebin
::warning: scripts downloaded from pastebin are not vetted by bget staff
::be sure to inspect code downloaded from pastebin.
echo Bget Pastebin tip: PASTE_CODE is the unique element of a PASTEBIN url.
echo E.g a pastebin script located at https://pastebin.com/YkEtQYFR would have YkEtQYFR as its paste code.
echo If you get the paste code wrong, you'll get a pastebin error as the output file instead of your intended script.
echo.
echo.


::check for user errors
set paste_bool=
set paste_method=
if "%~1"=="" echo Error: No Pastebin get method supplied. && exit /b
if "%~1"=="-usebits" echo Error: BITSadmin does not work with the pastebin function as of yet. && exit /b
for %%s in (curl js vbs ps) do (
	if /i "%~1"=="-use%%s" (
		set paste_bool=yes
		set paste_method=%%s
	)
)
if not "!paste_bool!"=="yes" (
	set msg=Error: Invalid paste get method.
	call :help
	exit /b
)
if "%~2"=="" echo Error: No paste code supplied. && exit /b
if "%~3"=="" echo Error: You must specify a local filename. && exit /b
set paste_bool=

::begin the pastebin fetching
if exist "scripts\pastebin\%~2\%~3" echo Error: The file name already exists && exit /b
if not exist "scripts\pastebin\%~2" md "scripts\pastebin\%~2"
echo Fetching "%~2" into "%~3"...
call :download -!paste_method! "https://pastebin.com/raw/%~2#%cd%\scripts\pastebin\%~2\%~3"
if not exist "scripts\pastebin\%~2\%~3" echo An error occured fetching the pastebin script. && exit /b
if exist "scripts\pastebin\%~2\%~3" echo Done. && exit /b
::paranoia
exit /b
::--------------------------------------------------------------------

:remove
::removes a script (You guessed it!)

::check for errors
if "%~1"=="" (
	set msg=Error: No script supplied.
	call :help
	exit /b
)

if /i "%~1"=="-all" (
	choice /c yn /n /m "Delete all scripts? [y/n]
	if "!errorlevel!"=="2" exit /b
	if "!errorlevel!"=="1" (
		set script_count=
		for /d %%a in (scripts\*) do (
			echo Removing "%%~na"... && rd /s /q "%%a"
			if exist "%%a" echo Failed to remove %%~na.
		)
		exit /b
	)
	
)
::check if the script exists

for %%r in (%~1) do (
	if not exist "scripts\%%~r" echo The script "%%~r" does not exist. && exit /b

	if /i "%%~r"=="pastebin" (
		choice /c yn /n /m "Clear ALL your pastebin scripts? This can't be undone. [(Y)es/(N)o]"
		if "!errorlevel!"=="2" exit /b
		if "!errorlevel!"=="1" (
			rd /s /q scripts\pastebin
			if exist scripts\pastebin echo An error occured while deleting the pastebin folder.
			if not exist scripts\pastebin echo Pastebin folder removed.
			exit /b
		)	
	)


	rd /s /q "scripts\%%~r"
	if exist "scripts\%%~r" echo Bget could not delete "%%~r". && exit /b
	if not exist "scripts\%%~r" echo Removed %%r.
)
::more paranoia
exit /b
::--------------------------------------------------------------------

:update
::updates the specified script
::the script must exist for it to be updated

::what do you call a date in the sky?
::an UPdate.

::check for user errors
set update_bool=
set update_method=
if "%~1"=="" echo Error: No update method supplied. && exit /b
for %%s in (curl js vbs bits ps) do (
	if /i "%~1"=="-use%%s" (
		set update_bool=yes
		set update_method=%%s
		if "%~2"=="" echo Error: Invalid argument. && exit /b
	)
)
if not "!update_bool!"=="yes" (
	set msg=Error: Invalid update method.
	call :help
	exit /b
)
set update_bool=


::update
::will attempt to download curl if when using the curl update method, curl isnt found in the curl subdirectory.
::sess rand allows multiple bget instances to be run without running into a "file is in use" issue
	echo Reading script list...
	for %%r in (%~2) do (
		
		set /a sess_rand=%random%
		if exist temp\master!sess_rand!.txt del /f /q temp\master!sess_rand!.txt
		call :download -!update_method! "!list_location!#%cd%\temp\master!sess_rand!.txt"
		if not exist temp\master!sess_rand!.txt echo An error occured getting the script list. && exit /b
		set script_count=

		%= updates all scripts =%
		if /i "%~2"=="-all" (
			for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#]," temp\master!sess_rand!.txt') do (
				if exist "scripts\%%~b\" (
					
					
					if exist "scripts\%%~b\%%~e" (
						set /a script_count+=1
						set hash=
						if not exist scripts\%%~b\hash.txt echo hash file for %%~b is missing. Updating anyway.
						if exist scripts\%%~b\hash.txt (
							set/p hash=<scripts\%%~b\hash.txt
							if /i "!hash!"=="%%~f" echo "%%~b" is up-to-date. Skipping.
						)
						
						if /i not "!hash!"=="%%~f" (
						if not exist "temp\%%~b" md "temp\%%~b"
						echo Updating "%%~b"...
						call :download -!update_method! "%%~c#%cd%\temp\%%~b\%%~e"
						if not exist "temp\%%~b\%%~e" echo Could not update "%%~b".
							if exist "temp\%%~b\%%~e" (
								if not defined hash set /a hash=%random%
								if not exist "scripts\%%~b\old-!hash!" md "scripts\%%~b\old-!hash!"
								echo Cleaning up old version...
								move /Y "scripts\%%~b\%%~e" "scripts\%%~b\old-!hash!"
								move /Y "temp\%%~b\%%~e" "scripts\%%~b\"
								rd /s /q "temp\%%~b"
								echo %%f>scripts\%%~b\hash.txt
								echo %%d>scripts\%%~b\info.txt
								echo %%g>scripts\%%~b\author.txt
								if "%%~xe"==".cab" (
									echo Extracting...
									expand "scripts\%%~b\%%~e" -F:* "scripts\%%~b" >nul
									if not exist "scripts\%%~b\package" md "scripts\%%~b\package"
									move /Y "scripts\%%~b\%%~e" "scripts\%%~b\package"
								)
								echo Done.
							)
						)
					)
				)
			)
			if not defined script_count echo You have no scripts. && exit /b
			exit /b
		)		
		
		
		if not exist "scripts\%%~r" echo Error: "%%~r" does not exist on the local machine. && exit /b
		for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],%%~r," temp\master!sess_rand!.txt') do (
			set /a script_count+=1
			echo Updating %%~b...
			set hash=
			if not exist scripts\%%~b\hash.txt echo hash file for %%~b is missing. Updating anyway.
			if exist scripts\%%~b\hash.txt (
				set/p hash=<scripts\%%~b\hash.txt
				if /i "!hash!"=="%%~f" echo This is already the latest version. && exit /b
			)
			if not exist "temp\%%~b" md "temp\%%~b"
			call :download -!update_method! "%%~c#%cd%\temp\%%~b\%%~e"
			if not exist "temp\%%~b\%%~e" echo "%%~b" is already up-to-date.. && exit /b
			if not defined hash set /a hash=%random%
			md "scripts\%%~b\old-!hash!"
			echo Cleaning up old version...
			move /Y "scripts\%%~b\%%~e" "scripts\%%~b\old-!hash!"
			move /Y "temp\%%~b\%%~e" "scripts\%%~b\"
			rd /s /q "temp\%%~b"
			if not exist "scripts\%%~b\%%~e" echo An error occured while updating the script. && exit /b
			if exist "scripts\%%~b\%%~e" (
				echo %%f>scripts\%%~b\hash.txt
				echo %%d>scripts\%%~b\info.txt
				echo %%g>scripts\%%~b\author.txt
				if "%%~xe"==".cab" (
					echo Extracting...
					expand "scripts\%%~b\%%~e" -F:* "scripts\%%~b" >nul
					if not exist "scripts\%%~b\package" md "scripts\%%~b\package"
					move /Y "scripts\%%~b\%%~e" "scripts\%%~b\package"
				)
				echo Done.
			)
		)
)
	if not defined script_count echo The script does not exist on the server. && exit /b
	exit /b
::--------------------------------------------------------------------

:info
::retrieves relevant information about the script from the bget server
set info_mode=on
call :get %*
set info_mode=off
exit /b
::--------------------------------------------------------------------

:list
::lists scripts on your pc or on the server

::checks for user errors

::checks if switch is correct
set list_bool=
for %%a in (server local) do (
	if /i "-%%~a"=="%~1" (
		set list_bool=yes
	)
)
if not defined list_bool echo Invalid list switch. && exit /b
if not "%~3"=="" echo Invalid number of arguments.


::lists scripts on the local computer
::not compatible with any use method
if /i "%~1"=="-local" (
	if not "%~2"=="" echo Invalid number of arguments. && exit /b
	set script_count=
	for /d %%a in (scripts\*) do (
		set /a script_count+=1
		echo !script_count!. %%~na
	)
	if not defined script_count echo You have no scripts. && exit /b
	exit /b
)


::lists scripts on the server
set list_bool=
if /i "%~1"=="-server" (
	if "%~2"=="" echo No get method supplied. && exit /b
	if not "%~3"=="" echo Invalid number of arguments. && exit /b
	for %%a in (curl js ps vbs bits) do (
		if /i "-use%%~a"=="%~2" (
			set list_bool=yes
			set list_method=%%~a
		)
	)
	if not defined list_bool echo Invalid method. && exit /b
	set /a sess_rand=%random%
	if exist temp\master!sess_rand!.txt del /f /q temp\master!sess_rand!.txt
	call :download -!list_method! "!list_location!#%cd%\temp\master!sess_rand!.txt"
	if not exist "temp\master!sess_rand!.txt" echo An error occured while fetching the script list. && exit /b
	echo Reading script list...
	set script_count=
	echo No, Name, Category, Description, Author
	for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#]," temp\master!sess_rand!.txt') do (
		set /a script_count+=1
		echo !script_count!. %%~b^| %%~h^| %%~d^| %%g
	)
	if not defined script_count echo Could not get the script list. && exit /b
	exit /b
)
exit /b
::--------------------------------------------------------------------

:upgrade
::gets the latest version of bget.

::check for user errors
set upgrade_bool=
set upgrade_method=
set upgrade_script_location=https://raw.githubusercontent.com/jahwi/bget/master/upgrade/upgrade.bat
set upgrade_hash_location=https://raw.githubusercontent.com/jahwi/bget/master/bin/hash.txt
if "%~1"=="" echo Error: No update method supplied. && exit /b
if /i not "%~2"=="" (
	if not "%~2"=="-force" echo Error: Invalid number of arguments. && exit /b
)
for %%s in (curl js vbs bits ps) do (
	if /i "%~1"=="-use%%s" (
		set upgrade_bool=yes
		set upgrade_method=%%s
	)
)
if not "!upgrade_bool!"=="yes" (
	set msg=Error: Invalid get method.
	call :help
	exit /b
)
set upgrade_bool=

echo Attempting upgrade...

::get bget's file hash
set /a sess_rand=%random%
call :download -!upgrade_method! "!upgrade_hash_location!#%cd%\temp\hash!sess_rand!.txt"
if not exist temp\hash!sess_rand!.txt echo Failed to get the upgrade hash. && pause && exit /b
set new_upgrade_hash=
set current_upgrade_hash=
set/p new_upgrade_hash=<temp\hash!sess_rand!.txt
if not exist bin\hash.txt (
	echo No local hash found. Will upgrade anyway.
	echo %random%%random%%random%>bin\hash.txt
)

::force upgrade
if /i "%~2"=="-force" (
	echo Forcing upgrade...
	echo %random%%random%%random%>bin\hash.txt
)

::compare old and new hashes
set/p current_upgrade_hash=<bin\hash.txt
if /i "!new_upgrade_hash!"=="!current_upgrade_hash!" echo You already have the latest version. && pause && exit /b

::ge tthe upgrade script and run it
if exist upgrade.bat del /f /q upgrade.bat
call :download -!upgrade_method! "!upgrade_script_location!#%cd%\upgrade.bat"
if not exist "upgrade.bat" echo Failed to get the Bget upgrade script. && exit /b
echo !upgrade_method!>upgrade.bat:upgrade_method
::pass the force switch as an ADS to the upgrade switch
if /i "%~2"=="-force" echo yes>upgrade.bat:force_bool
start upgrade.bat
exit
::-----------------------------------------------------------------------------------------------------
::End of Functions.
::-----------------------------------------------------------------------------------------------------


::downloads the files as specified
::usage: call :download -method "URL#local_destination"
::Download switches:
::-bits uses the BITSADMIN service
::-js uses Jscript
::-vbs uses a Visual Basic Script
::-curl uses the Curl client
::-ps uses a powershell command.
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
			if not exist bin\download.js echo An error occured when downloading the JS function. && exit /b
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
	if "!missing_curl!"=="yes" exit /b
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
		if not exist bin\download.vbs echo An error occured when downloading the VBS function. && exit /b
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

:trash
set var_to_clean=%*
for %%t in (!var_to_clean!) do (set %%t=)
set var_to_clean=
exit /b

:hash
::returns the hash of a file
for /f "skip=1 delims=" %%z in ('certutil -hashfile "%~1" MD5') do (
	set tmp_hash=%%z"
	if /i not "!tmp_hash:~0,4!"=="Cert" set "hash=%%z"
)
exit /b


