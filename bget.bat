@echo off
setlocal enabledelayedexpansion
call :macros


:: Bget-  Batch script fetcher
::Made by Jahwi, Icarus and Ben
:: Conceived, coded and died in 2016, resurrected and recoded in 2018. Enjoy! \o/

::------------------------------------------------------------------------------------------------
::<SETTINGS>
::------------------------------------------------------------------------------------------------

::init directories
for %%a in (scripts temp bin docs) do (
	if not exist "%~dp0\%%~a" md "%~dp0\%%~a"
)


::make and append to config file if non-existent.
if not exist "%~dp0\bin\config.bget" (
	echo [DO NOT DELETE] >"%~dp0\bin\config.bget"
	echo js>"%~dp0\bin\config.bget":defmethod
	echo yes>"%~dp0\bin\config.bget":adl
)


::init global vars.
set "version=0.2.0-100119	"
set list_location=https://raw.githubusercontent.com/jahwi/bget-list/master/master.txt
::set auto-delete_logs=yes
set valid_defmethod=
set auto-delete_logs=
set valid_adl_bool=
>nul 2>&1 set/p defmethod=<"%~dp0\bin\config.bget":defmethod
>nul 2>&1 set/p auto-delete_logs=<"%~dp0\bin\config.bget":adl

	::validate the dafault download method, fix if errors are found.
	for %%s in (curl js vbs bits ps) do (
		if /i "!defmethod!"=="%%s" (
			set valid_defmethod=yes
		)
	)
	if not "!valid_defmethod!"=="yes" (
		echo js>"%~dp0\bin\config.bget":defmethod
		set defmethod=js
	)
	
	::validate the auto-delete_logs bool.
	for %%s in (yes no) do (
		if /i "!auto-delete_logs!"=="%%s" set "valid_adl_bool=yes"
	)
	if not "!valid_adl_bool!"=="yes" (
		echo yes>"%~dp0\bin\config.bget":adl
	)
	
::------------------------------------------------------------------------------------------------
::</SETTINGS>
::------------------------------------------------------------------------------------------------



:main
::print the bget intro, followed by the relevant output
for %%a in ("  ---------------------------------------------------------------------------" 
"  Bget v!version!	Batch Script Manager" 
"  Made by Jahwi in 2018 | Edits made by Icarus | Bugs squashed by B00st3d" 
"  https://github.com/jahwi/bget"
"  Type %~n0 -help to get the list of commands."
"  ---------------------------------------------------------------------------" 
""
) do echo=%%~a

::checks for errors in user input, then calls the switch.

::input validation
set input_string=%*
if defined input_string for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z - . _ 1 2 3 4 5 6 7 8 9 0 [ ] { } ) do (
	if defined input_string set input_string=!input_string:%%a=!
	if defined input_string set input_string=!input_string: =!
	if defined input_string set input_string=!input_string:"=!
)

::if no switch is supplied.
if not "!input_string!"=="" (
	%=if /? is triggered.=%
    if "!input_string!"=="/?" (
		call :help
		exit /b
	)
    echo Error: Invalid input.
    echo Type "%~n0 -help" for more information.
    exit /b
)

if "%~1"=="" (
	set msg=Error: No switch supplied.
	call :help
	exit /b
)
set valid_bool=

::loop through valid switches
for %%x in (get remove update info list upgrade help pastebin openscripts search newscripts set) do (
	if /i "-%%x"=="%~1" set valid_bool=yes
)
if not "!valid_bool!"=="yes" (
	echo Error: Invalid switch
	echo Type "%~n0 -help" for more information.
	exit /b
)
if "!valid_bool!"=="yes" ( 
	set switch_string=%*
	call :!switch_string:~1!
	if /i "!auto-delete_logs!"=="yes" (
		if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\temp\master!sess_rand!.txt" >nul
		if exist "%~dp0\temp\hash!sess_rand!.txt" del /f /q "%~dp0\temp\hash!sess_rand!.txt" >nul
	)
	exit /b
)




::--------------------------------------------------------------------
::Beginning of Functions.
::--------------------------------------------------------------------
:help

::opens helpdoc
if /i "!switch_string:~0,10!"=="-help -doc" (
	if not "%~3"=="" echo Error[h3]: Invalid number of arguments. && exit /b
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
	"  [-list -server {-usemethod} -full ]   Lists scripts with minimal formatting."
	"  [-list -local]                        Lists local scripts."
	"  [-search {usemethod} "STRING" ]       Search scripts on the server."
	"  [-upgrade {-usemethod} ]              Updates Bget."
	"  [-upgrade {-usemethod} -force ]       Updates Bget, regardless of version."
	"  [-newscripts {-usemethod} ]           Lists new scripts released."
	"  [-set -ddm {method}]                  Changes the default download method. "
	"  -openscripts                          Opens the scripts folder."
	"  -help                                 Prints this help screen."
	"  -help -doc                            Opens the full help text."
	""
	"  [#]Supported methods: -useJS -useVBS -usePS -useBITS -useCURL"
	"   Example: bget -get -useVBS test"
	"  [#]Some Antiviruses flag the JS and VBS download functions."
	"   Either witelist them or use the BITS/PS methods."
	"  [#]If you downloaded Bget from anywhere other than Github, be sure to"
	"   upgrade it."
	"  [#]Type BGET -help -doc for the full help text
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

if "%~1"=="" echo Error[g1]: Incorrect syntax. && exit /b
for %%s in (curl js vbs bits ps) do (
	if /i "%~1"=="-use%%s" (
		set get_bool=yes
		set get_method=%%s
		if "%~2"=="" echo Error[g2]: Incorrect syntax. && exit /b
	)
)
if not "!get_bool!"=="yes" (
	REM echo Error: Invalid get method.
	REM echo Type "%~n0 -help" for more information.
	echo No method supplied. Defaulting to !defmethod! download method...
	call :get -use!defmethod! "%~1"
	exit /b
)
set get_bool=
if not "%~3"=="" (
	echo Error[g3]: Invalid number of arguments.
	echo Type "%~n0 -help" for more information.
	exit /b
)


::downloads
::will attempt to download curl if when using the curl get method, curl isnt found in the curl subdirectory.

::gets the script list
	echo Reading script list...
	call :getlist !get_method!
	if not exist "%~dp0\temp\master!sess_rand!.txt" exit /b

::if "-all" switch is used
	if /i "%~2"=="-all" (
		for /f "tokens=1-8 delims=," %%r in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"') do (
			call :get_recurse "%%~s"
		)
		exit /b
	)

::single scripts and args that aren't "-all"
	for %%r in (%~2) do (
		call :get_recurse "%%~r"
	)
exit /b
			

			
:get_recurse
::calls itself to download the specified scripts		
set script_count=
		for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],%~1," "%~dp0\temp\master!sess_rand!.txt"') do (
		
			set /a script_count+=1
			if exist "%~dp0\scripts\%%~b\" (
				echo The script "%%~b" already exists in this directory. Skipping...
				set /a script_count+=1
			)	
			if not exist "%~dp0\scripts\%%~b\" (
				set /a script_count+=1
				echo Fetching %%~b...
				
				REM add warning because BITS cant download from external repositories.
				if /i "!get_method!"=="bits" (
					if /i "%%f"=="External-File-No-Hash-Available" (
						echo Warning: BITS download method cannot download scripts from an external repo.
					)
				)
				
				if not exist "%~dp0\scripts\%%~b" md "%~dp0\scripts\%%~b"
				call :download -!get_method! "%%~c" "%~dp0\scripts\%%~b\%%~e"
				if not exist "%~dp0\scripts\%%~b\%%~e" (
					echo Error[g4]: An error occured while fetching "%%~nb".
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
		if not defined script_count echo The script "%~1" does not exist on the server.
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

:pastebin_recurse
::check for user errors
set paste_bool=
set paste_method=
::if "%~1"=="" echo Error[p1]: No Pastebin get method supplied. && exit /b
if "%~1"=="-usebits" echo Error: BITSadmin does not work with the pastebin function as of yet. && exit /b
for %%s in (curl js vbs ps) do (
	if /i "%~1"=="-use%%s" (
		set paste_bool=yes
		set paste_method=%%s
	)
)
if not "!paste_bool!"=="yes" (
	REM echo Error: Invalid get method.
	REM echo Type "%~n0 -help" for more information.
	echo No method supplied. Defaulting to !defmethod! download method...
	call :pastebin_recurse -use!defmethod! "%~1" "%~2"
	exit /b
)
if "%~2"=="" echo Error[p2]: No paste code supplied. && exit /b
if "%~3"=="" echo Error[p4]: You must specify a local filename. && exit /b
if not "%~4"=="" echo Error[p3]: Invalid number of arguments. && exit /b
set paste_bool=

::begin the pastebin fetching
if exist "%~dp0\scripts\pastebin\%~2\%~nx3" echo Error[p5]: The file name already exists && exit /b
if not exist "%~dp0\scripts\pastebin\%~2" md "%~dp0\scripts\pastebin\%~2"
echo Fetching "%~2" into "%~nx3"...
call :download -!paste_method! "https://pastebin.com/raw/%~2" "%~dp0\scripts\pastebin\%~2\%~nx3"
if not exist "%~dp0\scripts\pastebin\%~2\%~nx3" (
	echo Error[p4]: An error occured fetching the pastebin script.
	if exist "%~dp0\scripts\pastebin\%~2" rd /s /q "%~dp0\scripts\pastebin\%~2"
	exit /b
)
if exist "%~dp0\scripts\pastebin\%~2\%~nx3" echo Done. && exit /b
::paranoia
exit /b
::--------------------------------------------------------------------

:remove
::"Mr Stark, I don't feel so good"
::removes a script (You guessed it!)

::check for errors
if "%~1"=="" (
	echo Error: No script supplied.
	echo Type "%~n0 -help" for more information.
	exit /b
)

::TODO: ADD Y SWITCH TO BYPASS PROMPT
if /i "%~1"=="-all" (
	choice /c yn /n /m "Delete all scripts? [y/n]
	if "!errorlevel!"=="2" exit /b
	if "!errorlevel!"=="1" (
		set script_count=
		for /d %%a in ("%~dp0\scripts\*") do (
			set /a script_count+=1
			echo Removing "%%~na"... && rd /s /q "%%~a"
			if exist "%%~a" rd /s /q "%%~a"
			if exist "%%a" echo Error[p6]: Failed to remove %%~na.
		)
		if not defined script_count echo You have no scripts.
		exit /b
	)
	
)

::deletes pastebin scripts.
if /i "%~1"=="-pastebin" (
	choice /c yn /n /m "Clear ALL your pastebin scripts? This can't be undone. [(Y)es/(N)o]"
	if "!errorlevel!"=="2" exit /b
	if "!errorlevel!"=="1" (
		rd /s /q "%~dp0\scripts\pastebin"
		if not exist "%~dp0\scripts\pastebin" echo Pastebin scripts removed.
		if exist "%~dp0\scripts\pastebin" echo Error[p7]: An error occured while deleting the pastebin folder.
		exit /b
	)
)

::deletes individual/multiple scrips.
for %%r in (%~1) do (
	if not exist "%~dp0\scripts\%%~r" echo The script "%%~r" does not exist.
	if exist "%~dp0\scripts\%%~r" (
		rd /s /q "%~dp0\scripts\%%~r"
		if exist "%~dp0\scripts\%%~r" rd /s /q "%~dp0\scripts\%%~r"
		if exist "%~dp0\scripts\%%~r" echo Error[p7]: Bget could not delete "%%~r".
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

::display syntax if no first argument is supplied.
if "%~1"=="" (
	echo Syntax:
	echo -update "scripts"                 Updates the specified script/scripts
	echo -update "scripts" -force          Updates the specified scripts, regardless of version.
	exit /b
)
for %%s in (curl js vbs bits ps) do (
	if /i "%~1"=="-use%%s" (
		set update_bool=yes
		set update_method=%%s
		if "%~2"=="" echo Error[u2] Incorrect Syntax. && exit /b
	)
)
if not "!update_bool!"=="yes" (
	REM echo Error: Invalid get method.
	REM echo Type "%~n0 -help" for more information.
	echo No method supplied. Defaulting to !defmethod! download method...
	call :update -use!defmethod! "%~1" "%~2"
	exit /b
)
if not "%~3"=="" (
	if /i not "%~3"=="-force" echo Error[u3]: Invalid number of arguments. && exit /b
)
if not "%~4"=="" echo Error[u3]: Invalid number of arguments. && exit /b
set update_bool=


::update
::will attempt to download curl if when using the curl update method, curl isnt found in the curl subdirectory.
::sess rand allows multiple bget instances to be run without running into a "file is in use" issue

::gets script list
echo Reading script list...
call :getlist !update_method!
if not exist "%~dp0\temp\master!sess_rand!.txt" exit /b

::if "-all" switch is used
	if /i "%~2"=="-all" (
		for /f "tokens=1-8 delims=," %%r in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"') do (
			if exist "%~dp0\scripts\%%~s\" call :update_recurse "%%~s" %~3
		)
		exit /b
	)

::single scripts and args that aren't "-all"
	for %%r in (%~2) do (
		call :update_recurse "%%~r" %~3
	)
exit /b

:update_recurse

		set script_count=
		if not exist "%~dp0\scripts\%~1\" echo Error: "%~1" does not exist on the local machine.
		if exist "%~dp0\scripts\%~1\" (
			for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],%~1," "%~dp0\temp\master!sess_rand!.txt"') do (
				set /a script_count+=1
				echo Updating %%~b...
				set hash=
				if not exist "%~dp0\scripts\%%~b\hash.txt" echo hash file for %%~b is missing. Updating anyway.
				if exist "%~dp0\scripts\%%~b\hash.txt" (
					set/p hash=<"%~dp0\scripts\%%~b\hash.txt"
					if /i "%~2"=="-force" echo Forcing update... && set hash=%random%%random%%random%%random%
					if /i "!hash!"=="%%~f" echo "%%~b" is up-to-date. Skipping.
				)
				if /i not "!hash!"=="%%~f" (
				
					REM add warning because BITS cant download from external repositories.
					if /i "!update_method!"=="bits" (
						if /i "%%f"=="External-File-No-Hash-Available" (
							echo Warning: BITS download method cannot download scripts from an external repo.
						)
					)				

					if not exist "%~dp0\temp\%%~b" md "%~dp0\temp\%%~b"
					call :download -!update_method! "%%~c" "%~dp0\temp\%%~b\%%~e"
					if not exist "%~dp0\temp\%%~b\%%~e" echo Could not update "%%~b".
					if exist "%~dp0\temp\%%~b\%%~e" (
						if not defined hash set /a hash=%random%
						if not exist "%~dp0\scripts\%%~b\old-!hash!" md "%~dp0\scripts\%%~b\old-!hash!"
						echo Cleaning up old version...
						if exist "%~dp0\scripts\%%~b\%%~e" move /Y "%~dp0\scripts\%%~b\%%~e" "%~dp0\scripts\%%~b\old-!hash!"
						if exist "%~dp0\scripts\%%~b\package\%%~e" move /Y "%~dp0\scripts\%%~b\package\%%~e" "%~dp0\scripts\%%~b\old-!hash!"
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

exit /b
::--------------------------------------------------------------------

:info
::couldn't make a joke here if i tried.
::Chuck Norris doesn't read books, he simply stares the book down till he gets the information he wants.
::retrieves relevant information about the script from the bget server

::check for user errors
set get_bool=
set get_method=

if "%~1"=="" echo Error[i1]: Incorrect Syntax. && exit /b
for %%s in (curl js vbs bits ps) do (
	if /i "%~1"=="-use%%s" (
		set get_bool=yes
		set get_method=%%s
		if "%~2"=="" echo Error[i2]: Incorrect Syntax. && exit /b
	)
)
if not "!get_bool!"=="yes" (
	REM echo Error: Invalid get method.
	REM echo Type "%~n0 -help" for more information.
	echo No method supplied. Defaulting to !defmethod! download method...
	call :info -use!defmethod! "%~1" "%~2"
	exit /b
)
set get_bool=
if not "%~3"=="" echo Error[i3]: Invalid number of arguments. && exit /b



::downloads
::will attempt to download curl if when using the curl get method, curl isnt found in the curl subdirectory.
	echo Reading script list...
	call :getlist !get_method!
	if not exist "%~dp0\temp\master!sess_rand!.txt" exit /b
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
set list_method=

::display syntax if no first argument is supplied.
if /i "%~1"=="" (
	echo Syntax:
	echo -list -server                 Lists scripts indexed by Bget.
	echo -list -server -full           Displays the indexed scripts list with less formatting.
	echo -list -local                  Lists downloaded scripts.
	exit /b
)
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
	if not "%~2"=="" echo Error[l3]: Invalid number of arguments. && exit /b
	set script_count=
	for /d %%a in ("%~dp0\scripts\*") do (
		if exist "%%a\hash.txt" (
			set /a script_count+=1
			echo !script_count!. %%~na
		)
	)

	set p_script_count=
	REM lists pastebin scripts.
	if exist "%~dp0\scripts\pastebin" (
		echo ---------Pastebin Downloads---------------------
		for /d %%a in ("%~dp0scripts\pastebin\*") do (
			for %%b in ("%%~a\*") do (
				set /a p_script_count+=1
				echo !p_script_count!. %%~na\%%~nxb
			)
		)
	)
	
	if not defined script_count (
		if not defined p_script_count (
			echo You have no scripts. && exit /b
		)
	)
	exit /b
)


::lists scripts on the server
set list_bool=
if /i "%~1"=="-server" (

	REM if "%~2"=="" echo No get method supplied. && exit /b

	for %%a in (curl js ps vbs bits) do (
		if /i "-use%%~a"=="%~2" (
			set list_bool=yes
			set list_method=%%~a
		)
	)
	if not defined list_bool (
		REM echo Error: Invalid get method.
		REM echo Type "%~n0 -help" for more information.
		echo No method supplied. Defaulting to !defmethod! download method...
		call :list -server -use!defmethod! "%~2"
		exit /b
	)
	
	if /i not "%~3"=="" (
		if /i not "%~3"=="-full" echo Invalid argument. && exit /b
	)
	if not "%~4"=="" echo Error[l3]: Invalid number of arguments. && exit /b
	
	::fetch and parse the script list.
	echo Reading script list...
	call :getlist !list_method!
	if not exist "%~dp0\temp\master!sess_rand!.txt" exit /b
	echo.
	set script_count=
	echo No	Name		Category	Description		Author
	for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"') do (
		set /a script_count+=1
		
		if /i not "%~3"=="-full" (
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
			echo !pad1!!script_count!. %%~b!pad2!^|!pad3!!tmpH!^| !tmpD:~0,20!...!pad4!^| %%g
		)	
		
		if /i "%~3"=="-full" (
			set "tmpH=%%~h"
			set "tmpH=!tmpH:	=!"
			%pad% "!script_count!".4.pad1
			%pad% "!tmpH!".10.pad3
			%pad% "%%~b".16.pad2
			echo !pad1!!script_count!. %%~b!pad2!^|!pad3!!tmpH!^| %%~d ^| %%~g
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

:search

::search scripts on the server.

::check for user errors
set search_bool=
set search_method=
if "%~1"=="" echo Error[s1]: Incorrect Syntax. && exit /b
for %%a in (curl js ps vbs bits) do (
	if /i "-use%%~a"=="%~1" (
		set search_bool=yes
		set search_method=%%~a
	)
)
if not defined search_bool (
	REM echo Error: Invalid get method.
	REM echo Type "%~n0 -help" for more information.
	echo No method supplied. Defaulting to !defmethod! download method...
	call :search -use!defmethod! "%~1" "%~2"
	exit /b
)
if "%~2"=="" echo No search string supplied. && exit /b
if not "%~3"=="" echo Invalid number of arguments. && exit /b
set search_bool=

::gets script list
echo Reading script list...
call :getlist !search_method!
if not exist "%~dp0\temp\master!sess_rand!.txt" exit /b
	
::search
set match_count=
echo.
echo Searching...
echo Search String: [%~2]
echo.
for /f "tokens=1-8 delims=," %%a in ('findstr /i /c:"%~2" "%~dp0\temp\master!sess_rand!.txt"') do (
	if /i "%%~a"=="[#]" (
		for /f %%r in ('echo %%b,%%d,%%g ^| findstr /i /c:"%~2"') do (
			set /a match_count+=1
			if "!match_count!"=="1" echo No, Name, Description, Author
			echo !match_count!. %%b ^|%%d ^| %%g
		)
	)
)
if not defined match_count echo Your string did not match any scripts on the server. && exit /b
exit /b
::--------------------------------------------------------------------


:newscripts
::list new scripts. It works by comparing a local script list with the current one on the server.

::check for user errors
set ns_bool=
set ns_method=
REM if "%~1"=="" echo No method supplied. && exit /b
for %%a in (curl js ps vbs bits) do (
	if /i "-use%%~a"=="%~1" (
		set ns_bool=yes
		set ns_method=%%~a
	)
)
if not defined ns_bool (
	REM echo Error: Invalid get method.
	REM echo Type "%~n0 -help" for more information.
	echo No method supplied. Defaulting to !defmethod! download method...
	call :newscripts -use!defmethod! "%~1" "%~2"
	exit /b
)

if not "%~2"=="" echo Error[n3]: Invalid number of arguments. && exit /b
if not defined sess_rand set sess_rand=%random%
call :download -!ns_method! "https://raw.githubusercontent.com/jahwi/bget-list/master/newscripts.bget" "%~dp0\temp\newscripts!sess_rand!.bget"
if not exist "%~dp0\temp\newscripts!sess_rand!.bget" echo Failed to get the new scripts list. && exit /b
echo New scripts:
echo Name, Description, Date Added
findstr /n /r . "%~dp0\temp\newscripts!sess_rand!.bget"
del /f /q "%~dp0\temp\newscripts!sess_rand!.bget" >nul 2>&1

exit /b
::--------------------------------------------------------------------

:set
::allows users set some of the global vars.
::to set, or not to set. That is the question.

::display syntax if no first argument is supplied.
if /i "%~1"=="" (
	echo Syntax:
	echo -set -ddm method                 Changes default get method.
	echo -set -adl yes/no                 Toggles auto-deletion of temp files on/off.
	exit /b
)
set set_bool=
for %%a in (-ddm -adl) do (
	if /i "%%~a"=="%~1" set set_bool=yes
)
if /i not "!set_bool!"=="yes" echo Error: Invalid set argument. && exit /b
if "%~2"=="" echo Error: Incorrect syntax. && exit /b
if "%~1"=="" echo Error: Incorrect syntax. && exit /b
if not "%~3"=="" echo Error: Invalid number of arguments. && exit /b

::sets the default download method
set set_bool=
set temp_defmethod=
set recheck_defmethod=
if /i "%~1"=="-ddm" (
	REM check for user errors
	for %%a in (js vbs curl ps bits) do (
		if /i "%~2"=="%%a" (
			set "set_bool=yes"
			set "temp_defmethod=%%a"
		)
	)
	REM a bit redundant but whatever:
	if not defined temp_defmethod echo Error: Invalid download method. Supported methods are js, vbs, curl, ps and bits. & exit /b
	if not defined set_bool echo Error: Invalid download method. Supported methods are js, vbs, curl, ps and bits. & exit /b
	
	REM changes the default get method var and appends it.
	set defmethod=!temp_defmethod!
	echo !defmethod!>"%~dp0\bin\config.bget":defmethod
	
	>nul 2>&1 set/p recheck_defmethod=<"%~dp0\bin\config.bget":defmethod
	if /i "!recheck_defmethod!"=="!defmethod!" echo Default download method changed to !defmethod!. && exit /b
	if /i not "!recheck_defmethod!"=="!defmethod!" echo Failed to change the default download method. && exit /b
)

::sets the auto-delete_logs var.
set adl_bool=
set temp_adl_bool=
set recheck_adl=
if /i "%~1"=="-adl" (
	REM check for user errors
	for %%a in (yes no) do (
		if "%~2"=="%%~a" (
			set "adl_bool=yes"
			set "temp_adl_bool=%%~a"
		)
	)
	if not "!adl_bool!"=="yes" echo Error: Invalid syntax. Valid options are: yes and no. && exit /b
	
	REM set the auto-delete_logs var and append to config file.
	echo !temp_adl_bool!>"%~dp0\bin\config.bget":adl
	set /p recheck_adl=<"%~dp0\bin\config.bget":adl
	set auto-delete_logs=!temp_adl_bool!
	if "!recheck_adl!"=="!temp_adl_bool!" echo Changed "Auto-delete logs" variable to "!temp_adl_bool!". && exit /b
	if not "!recheck_adl!"=="!temp_adl_bool!" echo Failed to change the "Auto-delete logs" variable. && exit /b

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
::if "%~1"=="" echo Error: No update method supplied. && exit /b
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
	REM echo Error: Invalid get method.
	REM echo Type "%~n0 -help" for more information.
	echo No method supplied. Defaulting to !defmethod! download method...
	call :upgrade -use!defmethod! "%~1"
	exit /b
)
set upgrade_bool=

echo Attempting upgrade...

::get bget's file hash
set /a sess_rand=%random%
call :download -!upgrade_method! "!upgrade_hash_location!" "%~dp0\temp\hash!sess_rand!.txt"
if not exist "%~dp0\temp\hash!sess_rand!.txt" echo Failed to get the upgrade hash. && exit /b
set new_upgrade_hash=
set current_upgrade_hash=
set/p new_upgrade_hash=<"%~dp0\temp\hash!sess_rand!.txt"
if not exist "%~dp0\bin\hash.txt" (
	echo No local hash found. Will upgrade anyway.
	echo %random%%random%%random%>"%~dp0\bin\hash.txt"
)
if exist "%~dp0\temp\hash!sess_rand!.txt" del /f /q "%~dp0\temp\hash!sess_rand!.txt" >nul 2>&1



::put hash in var
set/p current_upgrade_hash=<"%~dp0\bin\hash.txt"

::force upgrade
if /i "%~2"=="-force" (
	set current_upgrade_hash=%random%%random%%random%
)

::compare hashes
if /i "!new_upgrade_hash!"=="!current_upgrade_hash!" echo You already have the latest version. && exit /b

::get the upgrade script and run it
if exist "%~dp0\upgrade.bat" del /f /q "%~dp0\upgrade.bat"
call :download -!upgrade_method! "!upgrade_script_location!" "%~dp0\upgrade.bat"
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




::-----------------------------------------------------------------------------------------------------
::Beginning of helper functions.
::-----------------------------------------------------------------------------------------------------


:getlist
	set /a sess_rand=%random%
	if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\temp\master!sess_rand!.txt"
	call :download -%~1 "!list_location!" "%~dp0\temp\master!sess_rand!.txt"
	if not exist "%~dp0\temp\master!sess_rand!.txt" echo An error occured while getting the script list. && exit /b
	exit /b

::downloads the files as specified
::usage: call :download -method "URL" "local_destination"
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
::-----------------------------------------------------------------------------------------------------
::End of helper functions.
::-----------------------------------------------------------------------------------------------------
