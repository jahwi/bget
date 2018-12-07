@echo off
setlocal enabledelayedexpansion
call :macros


:: Bget-  Batch script fetcher
::Made by Jahwi, Icarus and Ben
:: Conceived, coded and died in 2016, resurrected and recoded in 2018. Enjoy! \o/


::init directories
for %%a in (scripts temp bin docs) do (
	if not exist "%~dp0\%%~a" md "%~dp0\%%~a"
)

::init global vars and settings
set list_location=https://raw.githubusercontent.com/jahwi/bget-list/master/master.txt
set auto-delete_logs=yes

goto :main

::check for curl
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
		call :download -bits "https://github.com/jahwi/bget/raw/master/curl/curl.exe#%~dp0\curl\curl.exe"
		call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/curl/curl-ca-bundle.crt#%~dp0\curl\curl-ca-bundle.crt"
		call :download -bits "https://github.com/jahwi/bget/raw/master/curl/libcurl.dll#%~dp0\curl\libcurl.dll"
		set missing_curl_download=
		for %%a in ("curl\curl.exe" "curl\curl-ca-bundle.crt" "curl\libcurl.dll" ) do ( if not exist "%~dp0\%%~a" set missing_curl_download=yes )
		if "!missing_curl_download!"=="yes" echo An error occured when downloading curl. && exit /b
		if not "!missing_curl_download!"=="yes" set missing_curl=
	)
)
exit /b

:main
::print the bget intro, followed by the relevant output
for %%a in ("  ---------------------------------------------------------------------------" 
"  Bget v0.1.3-071218		Batch Script Manager" 
"  Made by Jahwi in 2018 | Edits made by Icarus. | Bugs squashed by B00st3d" 
"  https://github.com/jahwi/bget" 
"  ---------------------------------------------------------------------------" 
""
) do echo=%%~a

::checks for errors in user input, then calls the switch.

::input validation
set input_string=%*
if defined input_string for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z - . _ 1 2 3 4 5 6 7 8 9 0 [ ] { }) do (
	if defined input_string set input_string=!input_string:%%a=!
	if defined input_string set input_string=!input_string: =!
	if defined input_string set input_string=!input_string:"=!
)

if not "!input_string!"=="" ( 
	set msg=Invalid input.
	call :help
	exit /b
)

if "%~1"=="" set msg=Error: No switch supplied. && call :help && exit /b
set valid_bool=
for %%x in (get remove update info list upgrade help pastebin openscripts) do (
	if /i "-%%x"=="%~1" set valid_bool=yes
)
if not "!valid_bool!"=="yes" set msg=Error: Invalid switch && call :help && exit /b
if "!valid_bool!"=="yes" ( 
	set switch_string=%*
	call :!switch_string:~1!
	if /i "!auto-delete_logs!"=="yes" (
		if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\temp\master!sess_rand!.txt" >nul
		if exist "%~dp0\temp\hash!sess_rand!.txt" del /f /q "%~dp0\temp\hash!sess_rand!.txt" >nul
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
	if exist "%~dp0\docs\readme.txt" (
		type "%~dp0\docs\readme.txt"
		exit /b
	)
	if not exist "%~dp0\docs\readme.txt" echo the Bget help doc is missing. Run bget -upgrade -usebits -force to get it. && exit /b
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
	"  -openscripts                          Opens the scripts folder."
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
		if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\temp\master!sess_rand!.txt"
		call :download -!get_method! "!list_location!#%~dp0\temp\master!sess_rand!.txt"
		if not exist "%~dp0\temp\master!sess_rand!.txt" echo An error occured getting the script list && exit /b
		set script_count=
			
			
		%=download all scripts on the server if all switch is triggered=%
		if /i "%~2"=="-all" (
			for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"') do (
				set /a script_count+=1
				if exist "%~dp0\scripts\%%~b\" echo "%%~b" already exists. Skipping.
				if not exist "%~dp0\scripts\%%~b\" (
					echo Fetching "%%~b"...
					if not exist "%~dp0\scripts\%%~b" md "%~dp0\scripts\%%~b"
					call :download -!get_method! "%%~c#%~dp0\scripts\%%~b\%%~e"
					if not exist "%~dp0\scripts\%%~b\%%~e" (
						echo Failed to get "%%~b"
						rd /s /q "%~dp0\scripts\%%~b"
					)
					%=Export the current hash, description and author=%
					if exist "%~dp0\scripts\%%~b\%%~e" (
						echo %%f>"%~dp0\scripts\%%~b\hash.txt"
						echo %%d>"%~dp0\scripts\%%~b\info.txt"
						echo %%g>"%~dp0\scripts\%%~b\author.txt"
						%=Deal with .cab packages=%
						if "%%~xe"==".cab" (
							echo Extracting...
							call :cab "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b"
						)
						%=Deal with zips=%
						if "%%~xe"==".zip" (
							echo Extracting...
							call :unzip "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b\"
						)
						echo Done.
					)
				)
			)
			if not defined script_count echo Could not read entries from the server list.
			exit /b
		)
		
		
		for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],%%~r," "%~dp0\temp\master!sess_rand!.txt"') do (
			
			
			if exist "%~dp0\scripts\%%~b\" (
				echo The script "%%~b" already exists in this directory.
				set /a script_count+=1
			)	
			if not exist "%~dp0\scripts\%%~b\" (
				set /a script_count+=1
				echo Fetching %%~b...
				if not exist "%~dp0\scripts\%%~b" md "%~dp0\scripts\%%~b"
				call :download -!get_method! "%%~c#%~dp0\scripts\%%~b\%%~e"
				if not exist "%~dp0\scripts\%%~b\%%~e" (
					echo An error occured while fetching "%%~nb".
					if exist "%~dp0\scripts\%%~b" rd /s /q "%~dp0\scripts\%%~b"
				)
				if exist "%~dp0\scripts\%%~b\%%~e" (
					echo %%f>"%~dp0\scripts\%%~b\hash.txt"
					echo %%d>"%~dp0\scripts\%%~b\info.txt"
					echo %%g>"%~dp0\scripts\%%~b\author.txt"
					if "%%~xe"==".cab" (
						echo Extracting...
						call :cab "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b"
					)
					%=Deal with zips=%
					if "%%~xe"==".zip" (
						echo Extracting...
						call :unzip "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b\"
					)
					echo Done.
				)
			)
		)
		if not defined script_count echo The script "%%~r" does not exist on the server.
	)
exit /b
::--------------------------------------------------------------------

:pastebin
::I feel like I've paste-been here before.
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
if exist "%~dp0\scripts\pastebin\%~2\%~3" echo Error: The file name already exists && exit /b
if not exist "%~dp0\scripts\pastebin\%~2" md "%~dp0\scripts\pastebin\%~2"
echo Fetching "%~2" into "%~3"...
call :download -!paste_method! "https://pastebin.com/raw/%~2#%~dp0\scripts\pastebin\%~2\%~3"
if not exist "%~dp0\scripts\pastebin\%~2\%~3" (
	echo An error occured fetching the pastebin script.
	if exist "%~dp0\scripts\pastebin\%~2" rd /s /q "%~dp0\scripts\pastebin\%~2"
	exit /b
)
if exist "%~dp0\scripts\pastebin\%~2\%~3" echo Done. && exit /b
::paranoia
exit /b
::--------------------------------------------------------------------

:remove
::"Mr Stark, I don't feel so good"
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
		for /d %%a in ("%~dp0\scripts\*") do (
			set /a script_count+=1
			echo Removing "%%~na"... && rd /s /q "%%~a"
			if exist "%%a" echo Failed to remove %%~na.
		)
		if not defined script_count echo You have no scripts.
		exit /b
	)
	
)
::check if the script exists

for %%r in (%~1) do (
	if not exist "%~dp0\scripts\%%~r" echo The script "%%~r" does not exist.
	if exist "%~dp0\scripts\%%~r" (
		if /i "%%~r"=="pastebin" (
			choice /c yn /n /m "Clear ALL your pastebin scripts? This can't be undone. [(Y)es/(N)o]"
			if "!errorlevel!"=="2" exit /b
			if "!errorlevel!"=="1" (
				rd /s /q "%~dp0\scripts\pastebin"
				if exist "%~dp0\scripts\pastebin" echo An error occured while deleting the pastebin folder.
				if not exist "%~dp0\scripts\pastebin" echo Pastebin scripts removed.
				exit /b
			)	
		)


		rd /s /q "%~dp0\scripts\%%~r"
		if exist "%~dp0\scripts\%%~r" echo Bget could not delete "%%~r".
		if not exist "%~dp0\scripts\%%~r" echo Removed %%r.
	)
)
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
if not "%~4"=="" echo Invalid number of arguments. && exit /b
set update_bool=


::update
::will attempt to download curl if when using the curl update method, curl isnt found in the curl subdirectory.
::sess rand allows multiple bget instances to be run without running into a "file is in use" issue
echo Reading script list...
for %%r in (%~2) do (
		
		set /a sess_rand=%random%
		if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\temp\master!sess_rand!.txt"
		call :download -!update_method! "!list_location!#%~dp0\temp\master!sess_rand!.txt"
		if not exist "%~dp0\temp\master!sess_rand!.txt" echo An error occured getting the script list. && exit /b
		set script_count=

		%= updates all scripts =%
		if /i "%~2"=="-all" (
			for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"') do (
				if exist "%~dp0\scripts\%%~b\" (
					
					
					if exist "%~dp0\scripts\%%~b\%%~e" (
						set /a script_count+=1
						set hash=
						if not exist "%~dp0\scripts\%%~b\hash.txt" echo hash file for %%~b is missing. Updating anyway.
						if exist "%~dp0\scripts\%%~b\hash.txt" (
							set/p hash=<"%~dp0\scripts\%%~b\hash.txt"
							if /i "%~3"=="-force" echo Forcing update... && set hash=%random%%random%%random%%random%
							if /i "!hash!"=="%%~f" echo "%%~b" is up-to-date. Skipping.
						)
						
						if /i not "!hash!"=="%%~f" (
							if not exist "%~dp0\temp\%%~b" md "%~dp0\temp\%%~b"
							echo Updating "%%~b"...
							call :download -!update_method! "%%~c#%~dp0\temp\%%~b\%%~e"
							if not exist "%~dp0\temp\%%~b\%%~e" echo Could not update "%%~b".
							if exist "%~dp0\temp\%%~b\%%~e" (
								if not defined hash set /a hash=%random%
								if not exist "%~dp0\scripts\%%~b\old-!hash!" md "%~dp0\scripts\%%~b\old-!hash!"
								echo Cleaning up old version...
								move /Y "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b\old-!hash!"
								move /Y "%~dp0\temp\%%~b\%%~e" "%~dp0\scripts\%%~b\"
								rd /s /q "%~dp0\temp\%%~b"
								echo %%f>"%~dp0\scripts\%%~b\hash.txt"
								echo %%d>"%~dp0\scripts\%%~b\info.txt"
								echo %%g>"%~dp0\scripts\%%~b\author.txt"
								
								%=Extract archives=%
							
								%=deal with cabs=%
								if "%%~xe"==".cab" (
									echo Extracting...
									call :cab "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b"
								)
								%=Deal with zips=%
								if "%%~xe"==".zip" (
									echo Extracting...
									call :unzip "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b\"
								)
									echo Done.
							)
						)
					)
				)
			)
			if not defined script_count echo You have no scripts.
			exit /b
		)		
		
		
		if not exist "%~dp0\scripts\%%~r" echo Error: "%%~r" does not exist on the local machine.
		if exist "%~dp0\scripts\%%~r" (
			for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],%%~r," "%~dp0\temp\master!sess_rand!.txt"') do (
				set /a script_count+=1
				echo Updating %%~b...
				set hash=
				if not exist "%~dp0\scripts\%%~b\hash.txt" echo hash file for %%~b is missing. Updating anyway.
				if exist "%~dp0\scripts\%%~b\hash.txt" (
					set/p hash=<"%~dp0\scripts\%%~b\hash.txt"
					if /i "%~3"=="-force" echo Forcing update... && set hash=%random%%random%%random%%random%
					if /i "!hash!"=="%%~f" echo "%%~b" is up-to-date. Skipping.
				)
				if /i not "!hash!"=="%%~f" (
					if not exist "%~dp0\temp\%%~b" md "%~dp0\temp\%%~b"
					call :download -!update_method! "%%~c#%~dp0\temp\%%~b\%%~e"
					if not exist "%~dp0\temp\%%~b\%%~e" echo Could not update "%%~b".
					if exist "%~dp0\temp\%%~b\%%~e" (
						if not defined hash set /a hash=%random%
						if not exist "%~dp0\scripts\%%~b\old-!hash!" md "%~dp0\scripts\%%~b\old-!hash!"
						echo Cleaning up old version...
						move /Y "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b\old-!hash!"
						move /Y "%~dp0\temp\%%~b\%%~e" "%~dp0\scripts\%%~b\"
						rd /s /q "%~dp0\temp\%%~b"
						if not exist "%~dp0\scripts\%%~b\%%~e" echo An error occured while updating the script.
						if exist "%~dp0\scripts\%%~b\%%~e" (
							echo %%f>"%~dp0\scripts\%%~b\hash.txt"
							echo %%d>"%~dp0\scripts\%%~b\info.txt"
							echo %%g>"%~dp0\scripts\%%~b\author.txt"
							
							%=Extract archives=%
							
							%=deal with cabs=%
							if "%%~xe"==".cab" (
								echo Extracting...
								call :cab "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b"
							)
							%=Deal with zips=%
							if "%%~xe"==".zip" (
								echo Extracting...
								call :unzip "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b\"
							)
							echo Done.
						)
					)
				)
			)
			if not defined script_count echo The script does not exist on the server.
		)

)
exit /b
::--------------------------------------------------------------------

:info
::couldn't make a joke here if i tried.
::Chuck Norris doesn't read books, he simply stares the book down till he gets the information he wants.
::retrieves relevant information about the script from the bget server
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
if not "%~3"=="" echo Invalid number of arguments. && exit /b



::downloads
::will attempt to download curl if when using the curl get method, curl isnt found in the curl subdirectory.
	echo Reading script list...
	set /a sess_rand=%random%
	if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\temp\master!sess_rand!.txt"
	call :download -!get_method! "!list_location!#%~dp0\temp\master!sess_rand!.txt"
	if not exist "%~dp0\temp\master!sess_rand!.txt" echo An error occured getting the script list && exit /b
	set script_count=
	
	
	for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],%~2," "%~dp0\temp\master!sess_rand!.txt"') do (
	
		echo.
		echo Name: %%~b
		echo Author:%%~g
		echo Description: %%~d
		echo Category: %%~h
		echo Location: %%~c
		echo Hash: %%~f
		exit /b
	)
if not defined script_count echo "%~2" does not exist on this server.
exit /b
::--------------------------------------------------------------------

:openscripts

::input validation
if not "%~1"=="" echo Invalid number of arguments. && exit /b

echo opening scripts folder...
explorer "%~dp0scripts"

exit /b
::--------------------------------------------------------------------

:list
::not last and not least, the list function.
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
if /i not "%~3"=="" (
	if /i not "%~3"=="-full" echo Invalid argument. && exit /b
)
if not "%~4"=="" echo Invalid number of arguments. && exit /b


::lists scripts on the local computer
::not compatible with any use method
if /i "%~1"=="-local" (
	if not "%~2"=="" echo Invalid number of arguments. && exit /b
	set script_count=
	for /d %%a in ("%~dp0\scripts\*") do (
		if exist "%%a\hash.txt" (
			set /a script_count+=1
			echo !script_count!. %%~na
		)	
	)
	if not defined script_count echo You have no scripts. && exit /b
	exit /b
)


::lists scripts on the server
set list_bool=
if /i "%~1"=="-server" (
	if /i not "%~3"=="" (
		if /i not "%~3"=="-full" echo Invalid argument. && exit /b
	)
	if not "%~4"=="" echo Invalid number of arguments. && exit /b
	if "%~2"=="" echo No get method supplied. && exit /b

	for %%a in (curl js ps vbs bits) do (
		if /i "-use%%~a"=="%~2" (
			set list_bool=yes
			set list_method=%%~a
		)
	)
	if not defined list_bool echo Invalid method. && exit /b
	set /a sess_rand=%random%
	if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\emp\master!sess_rand!.txt"
	call :download -!list_method! "!list_location!#%~dp0\temp\master!sess_rand!.txt"
	if not exist "%~dp0\temp\master!sess_rand!.txt" echo An error occured while fetching the script list. && exit /b
	echo Reading script list...
	echo.
	set script_count=
	echo No	Name		Category	Description		Author
	for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"') do (
		set /a script_count+=1
		
		
		rem ADDED BY ICKY
		REM code for padding
		set "tmpH=%%~h"
		set "tmpD=%%~d"
		set "tmpD=!tmpD:.=!"
		set "tmpH=!tmpH:	=!"
		%pad% "!script_count!".4.pad1
		%pad% "%%~b".16.pad2
		%pad% "!tmpH!".10.pad3
		%pad% "!tmpD:~0,20!".21.pad4
		
		rem display everything
		if /i not "%~3"=="-full" (
			echo !pad1!!script_count!. %%~b!pad2!^|!pad3!!tmpH!^| !tmpD:~0,20!...!pad4!^| %%g
		)
		
		if /i "%~3"=="-full" (
			echo !script_count!. %%~b ^| %%~h ^| %%~d ^| %%~g
		)
		
		rem END ADDED BY ICKY
		
		
	)
	if not defined script_count echo Could not get the script list. && exit /b
	
	rem reset window size, but do that AFTER the user presses a key
	rem stating they are finshed viewing. - ADDED BY ICKY

	exit /b
)
exit /b
::--------------------------------------------------------------------

:upgrade
::What d'you call asking your teacher for an A instead of a B? An upgrade.
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
call :download -!upgrade_method! "!upgrade_hash_location!#%~dp0\temp\hash!sess_rand!.txt"
if not exist "%~dp0\temp\hash!sess_rand!.txt" echo Failed to get the upgrade hash. && exit /b
set new_upgrade_hash=
set current_upgrade_hash=
set/p new_upgrade_hash=<"%~dp0\temp\hash!sess_rand!.txt"
if not exist "%~dp0\bin\hash.txt" (
	echo No local hash found. Will upgrade anyway.
	echo %random%%random%%random%>"%~dp0\bin\hash.txt"
)

::force upgrade
if /i "%~2"=="-force" (
	echo Forcing upgrade...
	echo %random%%random%%random%>"%~dp0\bin\hash.txt"
)

::compare old and new hashes
set/p current_upgrade_hash=<"%~dp0\bin\hash.txt"
if /i "!new_upgrade_hash!"=="!current_upgrade_hash!" echo You already have the latest version. && exit /b

::get the upgrade script and run it
if exist "%~dp0\upgrade.bat" del /f /q "%~dp0\upgrade.bat"
call :download -!upgrade_method! "!upgrade_script_location!#%~dp0\upgrade.bat"
if not exist "%~dp0\upgrade.bat" echo Failed to get the Bget upgrade script. && exit /b
::pass the upgrade method as an ADS to the upgrade script
echo !upgrade_method!>"%~dp0\upgrade.bat:upgrade_method"
::pass the force switch as an ADS to the upgrade script
if /i "%~2"=="-force" echo yes>"%~dp0\upgrade.bat:force_bool"
start /b /d "%~dp0" upgrade.bat
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
		bitsadmin /transfer Bget!rnd! /download /priority HIGH "%%w" "%%x" >nul
	)
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
			call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/bin/download.js#%~dp0\bin\download.js"
			if not exist "%~dp0\bin\download.js" echo An error occured when downloading the JS function. && exit /b
		)

	)
	if exist "%~dp0\bin\download.js" (
		for /f "tokens=1,2 delims=#" %%e in ("%~2") do (
			cscript //NoLogo //e:Jscript "%~dp0\bin\download.js" "%%e" "%%f"
		)
	)
	exit /b
)
::Curl download function
if /i "%~1"=="-curl" (
	call :checkcurl
	if "!missing_curl!"=="yes" exit /b
	for /f "tokens=1,2 delims=#" %%b in ("%~2") do (
		"%~dp0\curl\curl.exe" -s "%%b" -o "%%c"
	)
exit /b
)

::powershell -Command wget "%%b" -OutFile "%%~sc"
::powershell download function
if /i "%~1"=="-ps" (
	for /f "tokens=1,2 delims=#" %%b in ("%~2") do (
	Powershell.exe -command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;(New-Object System.Net.WebClient).DownloadFile('%%b','%%~sc')"
	)
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
		call :download -bits "https://raw.githubusercontent.com/jahwi/bget/master/bin/download.vbs#%~dp0\bin\download.vbs"
		if not exist "%~dp0\bin\download.vbs" echo An error occured when downloading the VBS function. && exit /b
		)

	)
	if exist "%~dp0\bin\download.vbs" (
		for /f "tokens=1,2 delims=#" %%e in ("%~2") do (
			cscript //NoLogo //e:VBScript "%~dp0\bin\download.vbs" "%%e" "%%f"
		)
		exit /b
	)
)
exit /b







rem ADDED BY ICKY. Padding function. Fuck batbox

:getDemention
	( set "c=0" & for /f "skip=3 tokens=*" %%a in ('mode con:') do (
		set /a "c+=1" & if !c! leq 2 set "m[!c!]=%%a"
	)) & set /a "hei=!m[1]:Lines:=!", "wid=!m[2]:Columns:=!"
goto :eof

:sort
	pushd %temp%
		( for %%a in (%~1) do echo=%%~a>>tmpSort.txt)
		(for /f "tokens=*" %%a in ('sort tmpSort.txt') do ( set /a "s+=1" & set "sorted[!s!]=%%a"))
		( del /f /q tmpSort.txt ) & set "s="
	popd
goto :eof

:bubble
	( set "c=0" & for %%a in (x %~1) do ( set /a "c+=1", "n[!c!]=%%a" )) & set /a "cm=c - 1"
	( for /l %%l in (0,1,!cm!) do for /l %%c in (1,1,!cm!) do ( set /a "x=%%c + 1"
		for %%x in (!x!) do if !n[%%c]! gtr !n[%%x]! set /a "save=n[%%c]", "n[%%c]=n[%%x]", "n[%%x]=save"
	)) & ( for /l %%y in (2,1,!c!) do ( <nul set /p "=!n[%%y]! ")) & echo.
goto :eof

:pad
	set "str=X%~1"
	set length=0
	for /L %%a in (8,-1,0) do (
		set /a "length|=1<<%%a"
		for %%b in (!length!) do if "!str:~%%b,1!" equ "" set /a "length&=~1<<%%a"
	)
    set /a "spacing=%~2 - length"
	for /l %%a in (1,1,%spacing%) do set "sp=!sp! "
	if "%~3" neq "" ( set "%~3=!sp!") else ( echo missing OUTvar argument %%~3 )
	set "sp="
goto :eof

:macros

set ^"LF=^

^" Above empty line is required - do not remove
set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"

set pad=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3 delims=." %%1 in ("^!args^!") do (%\n%
	set "str=X%%~1"%\n%
	set length=0%\n%
	for /L %%a in (8,-1,0) do (%\n%
		set /a "length|=1<<%%a"%\n%
		for /f "tokens=1" %%b in ("^!length^!") do if "^!str:~%%b,1^!" equ "" set /a "length&=~1<<%%a"%\n%
	)%\n%
    set /a "spacing=%%~2 - length + 3"%\n%
	for /f "tokens=1" %%s in ("^!spacing^!") do for /l %%a in (1,1,%%s) do set "sp=^!sp^! "%\n%
	for /f "tokens=1 delims=" %%s in ("^!sp^!") do set "%%~3=%%~s"%\n%
	set "sp="%\n%
)) else set args=

goto :eof

rem END OF ICKY FUNCTIONS








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

:powerMode bufWidth  bufHeight
powershell -command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$S=$W.windowsize;$B.width=if (%1 -gt $S.width) {%1} else {$S.width};$B.height=if (%2 -gt $S.height) {%2} else {$S.height};$W.buffersize=$B;}"
exit /b

:unzip
	set zip=%~1
	set unzip_path=%~2
	set zip=!zip:\\=\!
	set /a ziprand=%random%
	set unzip_path=!unzip_path:\\=\!


	echo ZipFile="!zip!">"%~dp0\temp\unzip!ziprand!.vbs"
	echo ExtractTo="!unzip_path!">>"%~dp0\temp\unzip!ziprand!.vbs"
	echo set objShell = CreateObject^("Shell.Application"^)>>"%~dp0\temp\unzip!ziprand!.vbs"
	echo set FilesInZip=objShell.NameSpace(ZipFile).items>>"%~dp0\temp\unzip!ziprand!.vbs"
	echo objShell.NameSpace^(ExtractTo^).CopyHere^(FilesInZip^)>>"%~dp0\temp\unzip!ziprand!.vbs"
	echo Set fso = Nothing>>"%~dp0\temp\unzip!ziprand!.vbs"
	echo Set objShell = Nothing>>"%~dp0\temp\unzip!ziprand!.vbs"
	cscript //NOLOGO "%~dp0\temp\unzip!ziprand!.vbs"
	del /f /q "%~dp0\temp\unzip!ziprand!.vbs"
	
	if not exist "!unzip_path!\package" md "!unzip_path!\package"
	move /Y "!zip!" "!unzip_path!\package"	
	
	set ziprand=
	set zip=
	set unzip_path=
	exit /b

:cab
	set cab=%~1
	set cab_path=%~2
	set cab=!cab:\\=\!
	set cab_path=!cab_path:\\=\!
	
	expand "!cab!" -F:* "!cab_path!" >nul
	if not exist "!cab_path!\package" md "!cab_path!\package"
	move /Y "!cab!" "!cab_path!\package"
	
	set cab=
	set cab_path=
	exit /b


