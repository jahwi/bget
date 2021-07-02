@echo off
setlocal enabledelayedexpansion
call :macros


:: Bget-  Batch script fetcher
::Made by Jahwi
:: Conceived, coded and died in 2016, resurrected and recoded in 2018. Enjoy! \o/

::------------------------------------------------------------------------------------------------
::<SETTINGS>
::------------------------------------------------------------------------------------------------

::init directories
for %%a in (scripts temp bin docs) do (
	if not exist "%~dp0\%%~a" md "%~dp0\%%~a"
)
if not exist "%appdata%\Bget\scripts" md "%appdata%\Bget\scripts"


::using ADS, make and append configurable global vars to config file if non-existent.
if not exist "%~dp0\bin\config.bget" (
	echo [DO NOT DELETE] >"%~dp0\bin\config.bget"
	echo js>"%~dp0\bin\config.bget":defmethod
	echo yes>"%~dp0\bin\config.bget":adl
	echo %appdata%\Bget\scripts>"%~dp0\bin\config.bget":scl
	echo yes>"%~dp0\bin\config.bget":rsl
)


::init global vars.
set "version=0.5.0-090720	"
set global_vars_list=ddm adl scl rsl lf
set global_vars_full="ddm#[Default Download Method] Sets the default download method."^
 "adl#[auto-delete_logs] Toggles deletion of temp files on/off."^
 "scl#[Script Location] The default script download folder."^
 "rsl#[Refresh Script List] Toggles refreshing [redownloading] of the script list on every GET operation."^
 "lf#[Last Fetched Script List] Shows the date and time the script list was last refreshed."
::set "script_location=%appdata%\Bget\scripts"
set list_location=https://raw.githubusercontent.com/jahwi/bget-list/master/master.txt
::set auto-delete_logs=yes
set valid_defmethod=
set auto-delete_logs=
set valid_adl_bool=
REM load the configurable global vars from the config file
>nul 2>&1 set/p defmethod=<"%~dp0\bin\config.bget":defmethod
>nul 2>&1 set/p auto-delete_logs=<"%~dp0\bin\config.bget":adl
>nul 2>&1 set/p script_location=<"%~dp0\bin\config.bget":scl
>nul 2>&1 set/p refresh_script_list=<"%~dp0\bin\config.bget":rsl

	::validate the dafault download method, fix if errors are found.
	for %%s in (curl js vbs bits ps) do ( if /i "!defmethod!"=="%%s" set "valid_defmethod=yes" )
	if not "!valid_defmethod!"=="yes" (
		echo Error: Invalid default download method "!defmethod!". Setting to JS.
		echo js>"%~dp0\bin\config.bget":defmethod
		set defmethod=js
	)
	
	::validate the auto-delete_logs bool.
	if /i not "!auto-delete_logs!"=="yes" (
		if /i not "!auto-delete_logs!"=="no" echo yes>"%~dp0\bin\config.bget":adl
	)
	
	::validate the script location path.
	if not exist "!script_location!\" (
		set "script_location=%appdata%\Bget\scripts"
		echo !script_location!>"%~dp0\bin\config.bget":scl
	)
	
	REM validate the refresh script list bool.
	if /i not "!refresh_script_list!"=="yes" (
		if /i not "!refresh_script_list!"=="no" echo yes>"%~dp0\bin\config.bget":rsl
	)
	
::------------------------------------------------------------------------------------------------
::</SETTINGS>
::------------------------------------------------------------------------------------------------



:main

::checks for errors in user input, then calls the command.

::input validation
set input_string=%*
set temp_input_string=%*
if defined input_string for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z - . _ 1 2 3 4 5 6 7 8 9 0 [ ] { } \ : /) do (
	if defined input_string set input_string=!input_string:%%a=!
	if defined input_string set input_string=!input_string: =!
	if defined input_string set input_string=!input_string:"=!
)

::if no switch is supplied.
if "%~1"=="" (
	set msg=Error: No command supplied.
	call :help
	exit /b
)

if not "!input_string!"=="" (
	REM if '/?' or '-?' is triggered.
    if "!temp_input_string!"=="-?" (
		call :help
		exit /b
	)
    if "!temp_input_string!"=="/?" (
		call :help
		exit /b
	)
    echo Error: Invalid input.
    echo Type "%~n0 -help" for more information.
    exit /b
)


REM ------------------------------------------------------------------------------------------------------------------------
REM deal with -nobanner and -refresh

for %%# in (-nobanner -refresh) do (
	set %%#_found=false
	echo !temp_input_string! | findstr /i /c:"%%#" >nul
	if "!errorlevel!"=="0" (
		if defined temp_input_string set temp_input_string=!temp_input_string:%%#=!
		set %%#_found=true
	)
)

		REM remove trailing spaces
		:trim
		if defined temp_input_string if "!temp_input_string:~0,1!_"==" _" set temp_input_string=!temp_input_string:~1!
		if defined temp_input_string if "!temp_input_string:~-1!_"==" _" set temp_input_string=!temp_input_string:~0,-1!
			
		if defined temp_input_string if "!temp_input_string:~0,1!_"==" _" goto :trim
		if defined temp_input_string if "!temp_input_string:~-1!_"==" _" goto :trim
		

REM echo Nobanner found: !-nobanner_found!
REM echo Refresh found: !-refresh_found!
REM echo Edited string: "!temp_input_string!"
rem exit /b

REM print the bget intro, followed by the relevant output
	REM provision for the nobanner switch
if /i not "!-nobanner_found!"=="true" (
	for %%a in ("  ---------------------------------------------------------------------------" 
	"  Bget v!version!	Package Manager for Windows Scripts." 
	"  Made by Jahwi in 2018 | Edits made by Icarus | Bugs squashed by B00st3d" 
	"  https://github.com/jahwi/bget"
	"  Type %~n0 -help to get the list of commands."
	"  ---------------------------------------------------------------------------" 
	""
	) do echo=%%~a
)
	
::REFRESH function
	if /i "!-refresh_found!"=="true" set refresh_script_list=yes
	if /i "!-refresh_found!"=="true" echo [+] Refreshing script list... && call :getlist !defmethod! && if "!temp_input_string!"=="" exit /b
	
REM ------------------------------------------------------------------------------------------------------------------------




::loop through valid switches
set valid_bool=
for /f "tokens=1 delims= " %%a in ("!temp_input_string!") do (
	for %%# in (get remove update info list upgrade help pastebin openscripts search newscripts set query version) do (
		if /i "-%%#"=="%%~a" set valid_bool=yes
	)
)
if not "!valid_bool!"=="yes" (
	echo Error: Invalid switch.
	echo Type "%~n0 -help" for more information.
	exit /b
)

REM call the swittch if the commands are valid
if "!valid_bool!"=="yes" (
	REM set switch_string=%*
	REM cut out the se commands 
	REM if /i "!switch_string:~0,9!"=="-nobanner" set switch_string=!switch_string:~10!
	REM if /i "!switch_string:~0,8!"=="-refresh" set switch_string=!switch_string:~9!
	
	call :!temp_input_string:~1!
	
	REM cleanup logs and temp files
	if /i "!auto-delete_logs!"=="yes" (
		
		REM deletes the script list if rsl is set to "yes"
		if "!refresh_script_list!"=="yes" if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\temp\master!sess_rand!.txt" >nul
		if exist "%~dp0\temp\hash!sess_rand!.txt" del /f /q "%~dp0\temp\hash!sess_rand!.txt" >nul
	)
	exit /b
)




::--------------------------------------------------------------------
::Beginning of switch functions.
::--------------------------------------------------------------------
:help

::opens helpdoc
if /i "%~1"=="-doc" (
	if /i not "%*"=="-doc" echo Error[h3]: Invalid number of arguments. && exit /b
	if exist "%~dp0\docs\readme.txt" (
		type "%~dp0\docs\readme.txt"
		exit /b
	)
	if not exist "%~dp0\docs\readme.txt" echo the Bget help doc is missing. Run bget -upgrade -usebits -force to get it. && exit /b
)

::check for invalid args
for %%# in (get remove update info list upgrade help pastebin openscripts search newscripts set query version) do (
	if /i "%%#"=="%~1" if /i not "%*"=="%~1" echo Error[h3]: Invalid number of arguments. && exit /b
)

::help for the -get command
if /i "%~1"=="get" (
	echo Description: Fetches scripts using script names.
	
	echo.
	echo Usage: %~n0 -get {optional download method} [options] "script names"
	echo.
	echo.
	
	echo Options
	echo -use[method]                Fetches the specified scripts using the specfied method.
	echo -all                        Fetches all the scripts from Bget's repo.
	echo -only                       Fetches only scripts that meet a criteria.
	
	
	echo.
	echo.
	echo Example: %~n0 -get -usecurl "test colour brpg"
	echo Example: %~n0 -get -all -only author Jahwi
	echo Example: %~n0 -get "test color rpg rtfc" -only author Jahwi
	
	echo.
	echo Note:
	echo [1] Valid methods are: -usejs, -usevbs, -useps, -usebits, -usecURL
	echo [2] If no download method is supplied, Bget will default to the default download method [!defmethod!].
	echo [3] Scripts located outside Bget's repo cannot be downloaded using the BITS method.
	echo [4] If the "refresh script list" variable is set to "yes", Bget will ignore the specified download method, and instead read a cached script list. See the readme's QUERY and SET sections for more details.
	echo [5] FIlter criteria for the -only filter are: name, author, category, and date.
	
	exit /b
)

::help for the -pastebin command
if /i "%~1"=="pastebin" (
	
	echo Description: Fetches a script hosted on Pastebin, using a paste code.
	
	echo.
	echo Usage: %~n0 -pastebin {optional download method} "Paste Code" "local filename"
	echo.
	echo.
	
	echo Options
	echo -use[method]                Fetches the specified scripts using the specfied method.
	
	
	echo.
	echo.
	echo Example: %~n0 -pastebin "1wsBxRs4" script.bat
	
	echo.
	echo Note:
	echo [1] Valid methods are: -usejs, -usevbs, -useps, and -usecURL
	echo [2] If no download method is supplied, Bget will default to the default download method [!defmethod!].
	echo [3] Pastebin scripts cannot be downloaded using the BITS download method.
	echo [4] Pastebin scripts are kept in the scripts folder, at [!script_location!\pastebin\].
	echo [5] The Paste Code is the unique element of a PASTEBIN url.
	echo     E.g a pastebin script located at https://pastebin.com/YkEtQYFR would have YkEtQYFR as its paste code.
	echo     If you get the paste code wrong, you'll probably get a pastebin error in the output file instead of your intended script.
	
	exit /b
)

::help for the -remove command
if /i "%~1"=="remove" (
	
	echo Description: Removes scripts and/or logs.
	
	echo.
	echo Usage: %~n0 -remove [options] [scripts]
	echo.
	echo.
	
	echo Options
	echo -all                Removes all scripts.
	echo -all -y             Removes all scripts, and doesn't ask for confirmation.
	echo -pastebin           Removes all pastebin scripts.
	echo -pastebin -y        Removes all pastebin scripts, and doesn't prompt for confirmation.
	echo -logs               Deletes Bget's temporary files, empties Bget's temp folder.
	
	
	echo.
	echo.
	echo Example: %~n0 -remove "scriptA scriptB scriptC"
	echo Example: %~n0 -remove -all
	echo Example: %~n0 -remove -pastebin
	
	exit /b
)

::help for the -update command
if /i "%~1"=="update" (
	echo Description: Fetches the latest versions of scripts.
	
	echo.
	echo Usage: %~n0 -update {optional download method} [options] "script names"
	echo.
	echo.
	
	echo Options
	echo -use[method]                Updates the specified scripts using the specfied method.
	echo -all                        Updates all the scripts from Bget's repo.
	echo -force                      Updates all the scripts from Bget's repo, regardless of local version.
	
	
	echo.
	echo.
	echo Example: %~n0 -update -usecurl "test colour brpg"
	echo Example: %~n0 -update -all -force
	
	echo.
	echo Note:
	echo [1] Valid methods are: -usejs, -usevbs, -useps, -usebits, -usecURL
	echo [2] If no download method is supplied, Bget will default to the default download method [!defmethod!].
	echo [3] Scripts located outside Bget's repo cannot be updated using the BITS method.
	echo [4] If the "refresh script list" variable is set to "yes", Bget will ignore the specified download method, and instead read a cached script list. See the readme's QUERY and SET sections for more details.
	
	exit /b
)

::help for the -info command
if /i "%~1"=="info" (
	echo Description: Displays info about a specified script.
	
	echo.
	echo Usage: %~n0 -info {optional download method} "script name"
	echo.
	echo.
	echo Options
	echo -use[method]                Fetches script info using the specfied method.
	echo.
	echo.
	echo Example: %~n0 -info -usecurl "test"
	
	echo.
	echo Note:
	echo [1] Valid methods are: -usejs, -usevbs, -useps, -usebits, -usecURL
	echo [2] If no download method is supplied, Bget will default to the default download method [!defmethod!].
	echo [3] Scripts located outside Bget's repo cannot have their hashes and last modified vars displayed by the info command.
	echo [4] If the "refresh script list" variable is set to "yes", Bget will ignore the specified download method, and instead read a cached script list. See the readme's QUERY and SET sections for more details.
	
	exit /b
)

::help for the -list command
if /i "%~1"=="list" (
	echo Description: Lists local and remote scripts.
	
	echo.
	echo Usage: %~n0 -list {optional download method} [options]
	echo.
	echo.
	
	echo Options
	echo -local                      List fetched scripts.
	echo -server -use[method]        Fetches and displays the script list using the specfied method.
	echo    -full                       Displays the script list with minimal formatting. Can only be used with the
	echo                             -server switch. Can be used with both the -only and -sortby filters.
	echo  -only                       Displays only output matching any of the following criteria:
	echo                              name, author, category, and date. Can only be used with the -server switch.
	echo    -only name xyz              Displays scripts with names matching the specified search string.
	echo    -only author xyz            Displays scripts with an author matching the specified search string.
	echo    -only category xyz          Displays scripts with a category matching the specified search string.
	echo    -only date xyz              Displays scripts with a last modified date matching the specified search string.
	echo  -sortby                     Sorts the script list by any of the following criteria:
	echo                              name, author, category, and date. Can only be used with the -server switch.
	echo    -sortby name                Sorts the script list alphabetically by script name.
	echo    -sortby author              Sorts the script list alphabetically by script author.
	echo    -sortby category            Sorts the script list alphabetically by script category.
	echo    -sortby date                Sorts the script list by scripts' last modified dates.
	
	
	echo.
	echo.
	echo Example: %~n0 -list -local
	echo Example: %~n0 -list -server -usecurl
	echo Example: %~n0 -list -server -full
	echo Example: %~n0 -list -server -only author Jahwi
	echo Example: %~n0 -list -server -only author Jahwi -full
	echo Example: %~n0 -list -server -sortby author
	echo Example: %~n0 -list -server -sortby author -full
	
	echo.
	echo Note:
	echo [1] Valid methods are: -usejs, -usevbs, -useps, -usebits, -usecURL
	echo [2] If no download method is supplied, Bget will default to the default download method [!defmethod!].
	echo [3] Bget can't display the hash or last-modified dates of scripts located outside the repo.
	echo [4] If the "refresh script list" variable is set to "yes", Bget will ignore the specified download method, and instead read a cached script list. See the readme's QUERY and SET sections for more details.
	
	exit /b
)

::help for the -upgrade command
if /i "%~1"=="upgrade" (
	echo Description: Downloads and sets-up the latest version of Bget.
	
	echo.
	echo Usage: %~n0 -upgrade {optional download method} [options]
	echo.
	echo.
	
	echo Options
	echo -use[method]                Upgrades Bget using the specfied method.
	echo -force                      Upgrades Bget, regardless of local version.
	
	
	echo.
	echo.
	echo Example: %~n0 -upgrade -usecurl
	echo Example: %~n0 -upgrade -force
	
	echo.
	echo Note:
	echo [1] Valid methods are: -usejs, -usevbs, -useps, -usebits, -usecURL
	echo [2] If no download method is supplied, Bget will default to the default download method [!defmethod!].
	
	exit /b
)

::help for the -help command
::so meta
if /i "%~1"=="help" (
	echo Description: Gives help info about Bget's commands.
	
	echo.
	echo Usage: %~n0 -help [options]
	echo.
	echo.
	
	echo Options
	echo -doc                        Displays Bget's readme
	echo [command]                  Displays help info about a particular command.
	
	
	echo.
	echo.
	echo Example: %~n0 -help
	echo Example: %~n0 -help -doc
	echo Example: %~n0 -help get
	
	echo.
	
	exit /b
)

::help for the -openscripts command
if /i "%~1"=="openscripts" (
	echo Description: Opens the directory where scripts are stored at [!script_location!].
	
	echo.
	echo Usage: %~n0 -openscripts
	echo.
	echo.
	echo.
	echo Example: %~n0 -openscripts
	
	echo.
	
	exit /b
)

::help for the -search command
if /i "%~1"=="search" (
	echo Description: Searches for scripts from the script list.
	
	echo.
	echo Usage: %~n0 -search {optional download method} [string]
	echo.
	echo.
	echo.
		
	echo Options
	echo -use[method]                Fetches the resource using the specfied method.
	echo.
	echo Example: %~n0 -search "test"
	echo.
	echo Note:
	echo [1] Valid methods are: -usejs, -usevbs, -useps, -usebits, -usecURL
	echo [2] If no download method is supplied, Bget will default to the default download method [!defmethod!].
	echo [3] If the "refresh script list" variable is set to "yes", Bget will ignore the specified download method, and instead read a cached script list. See the readme's QUERY and SET sections for more details.
	exit /b
)

::help for the -newscripts command
if /i "%~1"=="newscripts" (
	echo Description: Checks for recently added scripts on Bget's server.
	
	echo.
	echo Usage: %~n0 -newscripts {optional download method}
	echo.
	echo.
	echo.
	
	echo Options
	echo -use[method]                Fetches the resource using the specfied method.
	echo Example: %~n0 -newscripts
	echo Example: %~n0 -newscripts -usevbs
	echo.
	echo Note:
	echo [1] Valid methods are: -usejs, -usevbs, -useps, -usebits, -usecURL
	echo [2] If no download method is supplied, Bget will default to the default download method [!defmethod!].
	echo [3] If the "refresh script list" variable is set to "yes", Bget will ignore the specified download method, and instead read a cached script list. See the readme's QUERY and SET sections for more details.
	echo.
	
	exit /b
)

::help for the -set command
if /i "%~1"=="set" (
	echo Description: Assigns values to configurable global variables.
	
	echo.
	echo Usage: %~n0 -set [global_variable] [value]
	echo.
	echo.
	call :set
	echo.
	echo Example: %~n0 -set rsl yes.
	
	echo.
	
	exit /b
)

::help for the -query command
if /i "%~1"=="query" (
	echo Description: Displays the values of select global variables.
	
	echo.
	echo Usage: %~n0 -query [global_variable]
	echo.
	echo.
	call :query
	echo.
	echo Example: %~n0 -query scl
	
	echo.
	
	exit /b
)

::help for the -nobanner command
if /i "%~1"=="nobanner" (
	echo Description: Supresses the banner when running commands.
	
	echo.
	echo Usage: %~n0 -nobanner [command]
	echo.
	echo Example: %~n0 -nobanner -get "test"
	echo Example: %~n0 -nobanner -update "test"
	exit /b
)

::help for the -refresh command
if /i "%~1"=="refresh" (
	echo Description: Downloads a new copy of the script list before running commands.
	
	echo.
	echo Usage: %~n0 -refresh [command]
	echo.
	echo Example: %~n0 -refresh -get "test"
	echo Example: %~n0 -refresh -update "test"
	exit /b
)




::is printed if help command, no command or an incorrect arg is supplied.
for %%a in (
	"  ---------------------------------------------------------------------------"
	"  Usage: BGET [-switch {ARGs} ]"
	"  [-get {-usemethod} "SCRIPTs" ]        Fetches a script/scripts."
	"  [-pastebin {-usemethod} PASTE_CODE local_filename ] Gets a Pastebin script."
	"  [-remove "SCRIPTs" ]                  Removes a script/scripts"
	"  [-update {-usemethod} "SCRIPTs" ]     Updates the script/scripts"
	"  [-info {-usemethod} SCRIPT ]          Gets info on the specified script."
	"  [-list -server {-usemethod} ]         Lists scripts on Bget's server."
	"  [-list -local]                        Lists local scripts."
	"  [-search {usemethod} "STRING" ]       Search scripts on the server."
	"  [-upgrade {-usemethod} ]              Updates Bget."
	"  [-newscripts {-usemethod} ]           Lists new scripts released."
	"  [-set -ddm {method}]                  Changes the default download method."
	"  [-query {global_variable} ]           Displays the value of select global variables."
	"  -openscripts                          Opens the scripts folder."
	"  -nobanner                             Skips displaying the intro banner."
	"  -refresh                              Download the latest version of the script list."
	"  -help                                 Prints this help screen."
	"  -help -doc                            Opens the full help text."
	""
	"  [#]Supported methods: -useJS -useVBS -usePS -useBITS -useCURL"
	"   Example: bget -get -useVBS test"
	"  [#]Some Antiviruses flag the JS and VBS download functions."
	"   Either witelist them or use the BITS/PS methods."
	"  [#]If you downloaded Bget from anywhere other than GitHub, be sure to"
	"   upgrade it."
	"  [#]Type BGET -help -doc for the full help text."
	"  [#]Type BGET -help [command] for command-specific help."
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

if "%~1"=="" echo Error[g1]: Incorrect syntax. Type '%~0 -help get' for mre info. && exit /b

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
	if "!refresh_script_list!"=="yes" echo No method supplied. Defaulting to !defmethod! download method.
	call :get -use!defmethod! "%~1" "%~2" "%~3" "%~4" "%~5"
	exit /b
)
set get_bool=
set only_bool=
if not "%~3"=="" (
	if /i not "%~3"=="-only" (
		echo Error[g3]: Invalid number of arguments.
		echo Type "%~n0 -help" for more information.
		exit /b
	) 
	if /i "%~3"=="-only" (
		if "%~4"=="" echo Error: Invalid filter "%~4". Valid filters are: name, category, author, and date. && exit /b
		if "%~5"=="" echo Error: Invalid filter "%~4". Valid filters are: name, category, author, and date. && exit /b
		set only_bool=true
		set only_count=
		set filter_param=%~4
		set filter_content=%~5
		echo.
		echo Filter [Only %~4 = %~5]
	)
)


::downloads
::will attempt to download curl if when using the curl get method, curl isnt found in the curl subdirectory.
set script_fetched_count=0
set scripts_to_download=

::gets the script list
	echo Reading script list...
	call :getlist !get_method!
	if not exist "%~dp0\temp\master!sess_rand!.txt" exit /b

::if "-all" switch is used
	set all_bool=
	if /i "%~2"=="-all" (
		set all_bool=true
		for /f "tokens=1-8 delims=," %%r in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"') do (
			set /a scripts_to_download+=1
		)
		REM call :get_recurse "%%~s"
		if not defined scripts_to_download echo Error[g5]: Script list is empty. && exit /b
		call :get_recurse -all
		echo Fetched [!script_fetched_count!/!scripts_to_download!] scripts.
		exit /b
	)

::single scripts and args that aren't "-all"
	for %%# in (%~2) do ( set /a scripts_to_download+=1 )
	for %%r in (%~2) do ( call :get_recurse "%%~r" )
	echo Fetched [!script_fetched_count!/!scripts_to_download!] scripts.
exit /b


:get_recurse
rem is called many times to get the specified script		
set script_count=
set get_script=false
set "findstr_match=%~1,"
if "%~1"=="-all" set "findstr_match="
:: echo "!findstr_match!"
		for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],!findstr_match!" "%~dp0\temp\master!sess_rand!.txt"') do (
			
			rem provision for the -only switch
			set get_script=true
			if "!only_bool!"=="true" (
				set get_script=false
				set temp_filter_param=
				if /i "!filter_param!"=="name" set "temp_filter_param=%%~b"
				if /i "!filter_param!"=="category" set "temp_filter_param=%%~h"
				if /i "!filter_param!"=="author" set "temp_filter_param=%%~g"
				if /i "!filter_param!"=="date" set "temp_filter_param=%%~i"

				if not defined temp_filter_param (
					echo Error: Invalid filter "!filter_param!". Valid filters are: name, category, author, and date.
					exit /b
				)

				if /i "!filter_content!"=="!temp_filter_param!" (
					set get_script=true
					set /a only_count+=1
				) else (
					rem skip lines that don't meet criteria
					if not "!all_bool!" == "true" (
						echo Filter: Skipping %%~b...
						set /a script_count+=1
					)
				)
			)


			if "!get_script!"=="true" (
				set /a script_count+=1
				if exist "!script_location!\%%~b\" (
					echo The script "%%~b" already exists in this directory. Skipping...
					set /a script_count+=1
				)	
				if not exist "!script_location!\%%~b\" (
					set /a script_count+=1
					echo Fetching %%~b...
					
					REM add warning because BITS cant download from external repositories.
					if /i "!get_method!"=="bits" (
						if /i "%%f"=="External-File-No-Hash-Available" (
							echo Warning: BITS download method cannot download scripts from an external repo.
						)
					)
					
					if not exist "!script_location!\%%~b" md "!script_location!\%%~b"
					call :download -!get_method! "%%~c" "!script_location!\%%~b\%%~e"
					if not exist "!script_location!\%%~b\%%~e" (
						echo Error[g4]: An error occured while fetching "%%~nb".
						if exist "!script_location!\%%~b" rd /s /q "!script_location!\%%~b"
					)
					if exist "!script_location!\%%~b\%%~e" (
						set /a script_fetched_count+=1
						echo %%f>"!script_location!\%%~b\hash.txt"
						echo %%d>"!script_location!\%%~b\info.txt"
						echo %%g>"!script_location!\%%~b\author.txt"
						echo %date% %time% >"!script_location!\%%~b\last_modified.txt"
						if "%%~xe"==".cab" (
							echo Extracting...
							call :cab "!script_location!\%%~b\%%~e" "!script_location!\%%~b"
						)
						%=Deal with zips=%
						if "%%~xe"==".zip" (
							echo Extracting...
							call :unzip "!script_location!\%%~b\%%~e" "!script_location!\%%~b\"
						)
						echo     [+] Done.
					)
				)
			)
		)

		if not defined script_count echo The script "%~1" does not exist on the server.

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
if "%~1"=="" echo Error [u2]: Incorrect Syntax. Type '%~0 -help update' for more info. && exit.
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
	if "!refresh_script_list!"=="yes" echo No method supplied. Defaulting to !defmethod! download method.
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
set scripts_to_update=0
set script_updated_count=0

::gets script list
echo Reading script list...
call :getlist !update_method!
if not exist "%~dp0\temp\master!sess_rand!.txt" exit /b

::if "-all" switch is used
	if /i "%~2"=="-all" (
		for /f "tokens=1-8 delims=," %%r in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"') do (
			if exist "!script_location!\%%~s\" (
				call :update_recurse "%%~s" %~3
				set /a scripts_to_update+=1
			)
		)
		if "!scripts_to_update!"=="0" echo Error: No local scripts found.
		echo Updated [!script_updated_count!/!scripts_to_update!] scripts.
		exit /b
	)

::single scripts and args that aren't "-all"
	for %%# in (%~2) do ( set /a scripts_to_update+=1 )
	for %%_ in (%~2) do (
		call :update_recurse "%%~_" %~3
	)
	echo Updated [!script_updated_count!/!scripts_to_update!] scripts.
exit /b

:update_recurse
		set script_count=

		rem make sure script exists on the local machine before attempting to update it.
		if not exist "!script_location!\%~1\" echo Error: "%~1" does not exist on the local machine.
		if exist "!script_location!\%~1\" (
			for /f "tokens=1-8 delims=," %%a in ('findstr /b /c:"[#],%~1," "%~dp0\temp\master!sess_rand!.txt"') do (
				set /a script_count+=1
				echo Updating %%~b...
				set hash=
				if not exist "!script_location!\%%~b\hash.txt" echo hash file for %%~b is missing. Updating anyway.
				if exist "!script_location!\%%~b\hash.txt" (
					set/p hash=<"!script_location!\%%~b\hash.txt"
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
						if not exist "!script_location!\%%~b\old-!hash!" md "!script_location!\%%~b\old-!hash!"
						echo Cleaning up old version...
						if exist "!script_location!\%%~b\%%~e" move /Y "!script_location!\%%~b\%%~e" "!script_location!\%%~b\old-!hash!"
						if exist "!script_location!\%%~b\package\%%~e" move /Y "!script_location!\%%~b\package\%%~e" "!script_location!\%%~b\old-!hash!"
						move /Y "%~dp0\temp\%%~b\%%~e" "!script_location!\%%~b\"
						rd /s /q "%~dp0\temp\%%~b"
						if not exist "!script_location!\%%~b\%%~e" echo An error occured while updating the script.
						if exist "!script_location!\%%~b\%%~e" (
							set /a script_updated_count+=1
							echo %%f>"!script_location!\%%~b\hash.txt"
							echo %%d>"!script_location!\%%~b\info.txt"
							echo %%g>"!script_location!\%%~b\author.txt"
							echo %date% %time% >"!script_location!\%%~b\last_modified.txt"
							
							%=Extract archives=%
							
							%=deal with cabs=%
							if "%%~xe"==".cab" (
								echo Extracting...
								call :cab "!script_location!\%%~b\%%~e" "!script_location!\%%~b"
							)
							%=Deal with zips=%
							if "%%~xe"==".zip" (
								echo Extracting...
								call :unzip "!script_location!\%%~b\%%~e" "!script_location!\%%~b\"
							)
							echo     [+] Done.
						)
					)
				)
			)
			if not defined script_count echo The script does not exist on the server.
		)

exit /b
::--------------------------------------------------------------------

:pastebin
::I feel like I've paste-been here before.
::warning: scripts downloaded from pastebin are not vetted by bget staff
::be sure to inspect code downloaded from pastebin.
echo Bget Pastebin tip: PASTE_CODE is the unique element of a PASTEBIN url.
echo E.g a pastebin script located at https://pastebin.com/YkEtQYFR would have YkEtQYFR as its paste code.
echo If you get the paste code wrong, you'll probably get a pastebin error as the output file instead of your intended script.
echo.
echo.

:pastebin_recurse
::check for user errors
set paste_bool=
set paste_method=
::if "%~1"=="" echo Error[p1]: No Pastebin get method supplied. && exit /b
if "%~1"=="-usebits" echo Error: the pastebin function doesn't support BITSadmin as of yet. && exit /b
for %%s in (curl js vbs ps) do (
	if /i "%~1"=="-use%%s" (
		set paste_bool=yes
		set paste_method=%%s
	)
)
if not "!paste_bool!"=="yes" (
	REM echo Error: Invalid get method.
	REM echo Type "%~n0 -help" for more information.
	echo No method supplied. Defaulting to !defmethod! download method.
	call :pastebin_recurse -use!defmethod! "%~1" "%~2"
	exit /b
)
if "%~2"=="" echo Error[p2]: No paste code supplied. && exit /b
if "%~3"=="" echo Error[p4]: You must specify a local filename. && exit /b
if not "%~4"=="" echo Error[p3]: Invalid number of arguments. && exit /b
set paste_bool=

::begin the pastebin fetching
if exist "!script_location!\pastebin\%~2\%~nx3" echo Error[p5]: The file name already exists && exit /b
if not exist "!script_location!\pastebin\%~2" md "!script_location!\pastebin\%~2"
echo Fetching "%~2" into "%~nx3"...
call :download -!paste_method! "https://pastebin.com/raw/%~2" "!script_location!\pastebin\%~2\%~nx3"
if not exist "!script_location!\pastebin\%~2\%~nx3" (
	echo Error[p4]: An error occured fetching the pastebin script.
	if exist "!script_location!\pastebin\%~2" rd /s /q "!script_location!\pastebin\%~2"
	exit /b
)
if exist "!script_location!\pastebin\%~2\%~nx3" echo     [+] Done. && exit /b
::paranoia
exit /b
::--------------------------------------------------------------------

:remove
::"Mr Stark, I don't feel so good"
::removes a script (You guessed it!)
set removed_scripts=0
set script_count=
::check for errors
if "%~1"=="" (
	echo Error: No script supplied.
	echo Type "%~n0 -help" for more information.
	exit /b
)


if /i "%~1"=="-all" (

	REM the -y switch triggers a bypass.
	if /i not "%~2"=="-y" choice /c yn /n /m "Delete all scripts? [y/n]
	if /i not "%~2"=="-y" if "!errorlevel!"=="2" exit /b
	
		set script_count=
		for /d %%a in ("!script_location!\*") do (
			if exist "%%~a\hash.txt" (
				set /a script_count+=1
				echo Removing "%%~na"... && rd /s /q "%%~a"
				if exist "%%~a" rd /s /q "%%~a"
				if exist "%%a" echo Error[p6]: Failed to remove %%~na.
				if not exist "%%a" set /a "removed_scripts+=1"
			)
		)
		echo Removed [!removed_scripts!/!script_count!] scripts.
		if not defined script_count echo You have no scripts.
		exit /b
	
)

::deletes pastebin scripts.
if /i "%~1"=="-pastebin" (

	if /i not "%~2"=="-y" choice /c yn /n /m "Clear ALL your pastebin scripts? This can't be undone. [(Y)es/(N)o]"
	if /i not "%~2"=="-y" if "!errorlevel!"=="2" exit /b
		if exist "!script_location!\pastebin" (
			rd /s /q "!script_location!\pastebin" >nul
			if not exist "!script_location!\pastebin" echo Pastebin scripts removed.
			if exist "!script_location!\pastebin" echo Error[p7]: An error occured while deleting the pastebin folder.
		) else ( echo Error: You don't have any pastebin scripts in the scripts directory. )
		exit /b
)

::deletes logs
if /i "%~1"=="-logs" (
		if exist "%~dp0\temp" (
			rd /s /q "%~dp0\temp"
			if not exist "%~dp0\temp" echo [+] Temp files removed.
			if exist "%~dp0\temp" echo Error[r1]: An error occured while deleting the temp files.
			if not exist "%~dp0\temp" md "%~dp0\temp"
		)
		exit /b
)

::deletes individual/multiple scrips.
for %%r in (%~1) do (
	set /a script_count+=1
	if not exist "!script_location!\%%~r" echo The script "%%~r" does not exist.
	if exist "!script_location!\%%~r" (
		rd /s /q "!script_location!\%%~r"
		if exist "!script_location!\%%~r" rd /s /q "!script_location!\%%~r"
		if exist "!script_location!\%%~r" echo Error[p7]: Bget could not delete "%%~r".
		if not exist "!script_location!\%%~r" set /a "removed_scripts+=1" && echo Removed %%r.
	)
)
echo Removed [!removed_scripts!/!script_count!] scripts.
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
	if "!refresh_script_list!"=="yes" echo No method supplied. Defaulting to !defmethod! download method.
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
	
	
	for /f "tokens=1-11 delims=," %%a in ('findstr /i /b /c:"[#],%~2," "%~dp0\temp\master!sess_rand!.txt"') do (
	
		echo.
		echo Name: %%~b
		echo Author: %%~g
		set info_desc=%%~d
		echo Description: !info_desc:;=,!
		echo Category: %%~h
		echo Location: %%~c
		echo Size: %%~k bytes.
		echo Checksum: %%~f
		echo Last Modified: %%i
		echo Tags: %%~j
		exit /b
	)
if not defined script_count echo "%~2" does not exist on this server.
exit /b
::--------------------------------------------------------------------

:openscripts

::input validation
if not "%~1"=="" echo Invalid number of arguments. && exit /b

echo Opening scripts folder...
if defined script_location (
	if exist "!script_location!" if exist "!script_location!\*" explorer "!script_location!"

)
 

exit /b
::--------------------------------------------------------------------

:list
::not last and not least, the list function.
::lists scripts on your pc or on the server


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

::checks for user errors

::checks if switch is correct
for %%a in (server local) do (
	if /i "-%%~a"=="%~1" (
		set list_bool=yes
	)
)
if not defined list_bool echo Invalid list switch. && exit /b
REM if /i not "%~3"=="" ( if /i not "%~3"=="-full" echo Invalid argument. && exit /b )
REM if not "%~4"=="" echo Invalid number of arguments. && exit /b


::lists scripts on the local computer
::not compatible with any use method
if /i "%~1"=="-local" (
	if not "%~2"=="" echo Error[l3]: Invalid number of arguments. && exit /b
	set script_count=
	echo No  	   Name               Description                    Author          Last Updated
	for /d %%a in ("!script_location!\*") do (
		if exist "%%a\hash.txt" (
			set /a script_count+=1
			for %%_ in (last_modified author hash info) do (
				set %%_=Nil
				if exist "%%a\%%_.txt" set/p %%_=<"%%a\%%_.txt"
			)
			set info=!info:.=!
			set info=!info:;=,!
			
			REM format the text
			%pad% "!script_count!".4.pad1
			%pad% "%%~na".16.pad2
			%pad% "!last_modified!".25.pad3
			%pad% "!author!".20.pad4
			%pad% "!info:~0,20!".20.pad5
			
			echo !pad1!!script_count!. !pad2!%%~na ^| !pad5!!info:~0,20!.... ^| !pad4!!author! ^| !pad3!!last_modified! 
		)
	)

	set p_script_count=
	REM lists pastebin scripts.
	if exist "!script_location!\pastebin" (
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


REM lists scripts on the server
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
		if "!refresh_script_list!"=="yes" echo No method supplied. Defaulting to !defmethod! download method.
		call :list -server -use!defmethod! "%~2" "%~3" "%~4" "%~5" "%~6" "%~7"
		exit /b
	)
	
	REM if /i not "%~3"=="" ( if /i not "%~3"=="-full" echo Invalid argument. && exit /b )
	REM if not "%~7"=="" echo Error[l3]: Invalid number of arguments. && exit /b
	
	REM fetch and parse the script list.
	echo Reading script list...
	call :getlist !list_method!
	if not exist "%~dp0\temp\master!sess_rand!.txt" exit /b
	::set sess_rand=1010
	echo.

	REM check for use of the -full switch
	set arg=
	set full_bool=
	set only_bool=
	set sortby_bool=
	set either_bool=
	set space=
	set both=
	for /l %%a in (3,1,7) do (
		set temp_arg=%%a
		call set arg=%%~!temp_arg!
		if /i "!arg!"=="-full" set "full_bool=yes"
		if /i "!arg!"=="-only" set "only_bool=true" && set "either_bool=true"
		if /i "!arg!"=="-sortby" set "sortby_bool=true" && set "either_bool=true"
		set "arg="
	)
	if "!only_bool!"=="true" if "!sortby_bool!"=="true" set "space= " && set "both=true"
	
	REM LIST BY SPECIFIC PARAMETERS LIKE NAME, CATEGORY OR AUTHOR.
	
	REM If third or fourth token is -only/sortby, the next arg must be a valid filter. check for this.
	set filter_type=
	set filter_content=
	set filter_param=name
	set int_loop_count=
	set -only_arg=-noonly
	set -sortby_filter_param=name
	for /l %%a in (3,1,7) do (
	
		REM Housekeeping
		set filter_bool=
		set next_arg=
		set next_arg_string=
		set current_arg_string=
				
		set /a "int_a=%%a" , "next_arg=%%a+1" , "upper_arg=%%a+2"
		call set next_arg_string=%%~!next_arg!
		call set current_arg_string=%%~!int_a!
		call set upper_arg_string=%%~!upper_arg!
		for %%b in (-only -sortby) do (
			set %%b_filter=false
			if /i "!current_arg_string!"=="%%~b" (
				set %%b_filter=true
				for %%# in (name category author date) do (
					if /i "%%~#"=="!next_arg_string!" (
						set "filter_bool=yes"
						set "filter_type=%%~b"
						set "filter_param=%%~#"
						set "%%~b_filter_param=%%~#"
						set "filter_content=!upper_arg_string!"
						set "%%~b_filter_content=!upper_arg_string!"
						set /a int_loop_count+=1
						set "%%~b_arg=%%~b %%~# !upper_arg_string!"
					)
					
					REM print the filter parameters only once.
					REM if "!int_loop_count!"=="1" (
					REM 	if "!filter_type!"=="-only" echo Filter [
					REM 		%%#^=!filter_content!
					REM 	if "!filter_type!"=="-sortby" echo Filter [Sort by !filter_param!]
					REM 	set int_loop_count=
					REM )

				)
				if not "!filter_bool!"=="yes" echo Error: Invalid filter. Valid filters are: name, category, author, and date. && exit /b
			)
		)
	)

	REM display the filters being used if either filter is triggered
	if "!either_bool!"=="true" (
		<nul set /p="Filter ["
		if "!sortby_bool!"=="true" <nul set /p="Sort by !-sortby_filter_param!!space!"
		if "!both!"=="true" <nul set /p="AND "
		if "!only_bool!"=="true" (
			<nul set /p="Only !-only_filter_param! = !-only_filter_content!"
		)
		echo ]
	)

	REM display sorted output
	set "full_arg=-nofull"
	if "!full_bool!"=="yes" set "full_arg=-full"

	echo.
	echo No	Name		Category	Description		Author			Last Modified

	REM for /f "tokens=1-9 delims=," %%a in ('findstr /b /c:"[#]," "%~dp0\temp\master!sess_rand!.txt"')
	REM echo '%~dp0bin\srt.bat !-sortby_filter_param! %~dp0temp\master!sess_rand!.txt !full_arg! !-only_arg!'
	for /f "delims=" %%a in ('%~dp0bin\srt.bat !-sortby_filter_param! 
	%~dp0temp\master!sess_rand!.txt !full_arg! !-only_arg!') do (
		echo %%~a
	)
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
	if "!refresh_script_list!"=="yes" echo No method supplied. Defaulting to !defmethod! download method.
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

::check for -only and -sortby
for %%# in (-only -sortby) do (
	set %%#_found=false
	echo !temp_input_string! | findstr /i /c:"%%#" >nul
	if "!errorlevel!"=="0" (
		set %%#_found=true
	)
)
	
::search
set match_count=
echo.
echo Searching...
echo Search String: [%~2]
echo.
for /f "delims=" %%? in ('findstr /i /c:"%~2" "%~dp0\temp\master!sess_rand!.txt"') do (
	for /f "tokens=1-10 delims=," %%a in ("%%?") do (
		set done_with_line=
		set taglist=
		if /i "%%~a"=="[#]" (
			for /f %%r in ('echo %%b,%%d,%%g,%%j ^| findstr /i /c:"%~2"') do (
				set /a match_count+=1
				set search_desc=%%d
				if "!match_count!"=="1" echo No, Name, Description, Author
				
				REM if "!-sortby_found!"=="true" echo %%? >>"%~dp0temp\search_!sess_rand!.txt"
				echo !match_count!. %%b ^| !search_desc:;=,! ^| %%g
			)
		)
	)
)
if not defined match_count echo Your string did not match any scripts on the server. && exit /b
exit /b
REM sort if the sortby was triggered.
echo --------------------------------------------------------------------
call "%~dp0bin\srt.bat" "!filter_param!" "%~dp0temp\search_!sess_rand!.txt"
echo Sorting...
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
	echo No method supplied. Defaulting to !defmethod! download method.
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
	echo -set ddm method                 Changes default get method.
	echo -set adl yes/no                 Toggles auto-deletion of temp files on/off.
	echo -set scl "path"                 Sets the default script download location.
	echo -set rsl yes/no                 Toggles refreshing/redownloading of the script list on every get operation.
	exit /b
)
set set_bool=
for %%a in (ddm adl scl rsl) do (
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
if /i "%~1"=="ddm" (
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
	exit /b
)

::sets the auto-delete_logs var.
set adl_bool=
set temp_adl_bool=
set recheck_adl=
if /i "%~1"=="adl" (
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
	exit /b

)

::sets the default script location
set recheck_scl=
if /i "%~1"=="scl" (
	if not exist "%~2\*" echo Error: Path does not exist. && exit /b
	set "script_location=%~2"
	echo %~2>"%~dp0\bin\config.bget":scl
	
	REM recheck
	set/p recheck_scl=<"%~dp0\bin\config.bget":scl
	if not "!script_location!"=="!recheck_scl!" echo Failed to change the default script location. && exit /b
	if "!script_location!"=="!recheck_scl!" echo Changed the default script location to "!script_location!". && exit /b
)

::sets the refresh script list variable
set recheck_rsl=
if /i "%~1"=="rsl" (
	
	REM check for errors
	if /i not "%~2"=="yes" (
		if not "%~2"=="no" echo Error: Invalid syntax. Valid options are: yes and no. && exit /b
	)
	
	REM set the values and append to config file via ADS
	echo %~2>"%~dp0\bin\config.bget":rsl
	
	REM check if ads has been set
	set /p recheck_rsl=<"%~dp0\bin\config.bget":rsl
	if /i not "!recheck_rsl!"=="%~2" echo Failed to change the refresh script variable. && exit /b
	if /i "!recheck_rsl!"=="%~2" echo Changed the refresh script list variable to "!recheck_rsl!" && exit /b
	exit /b
)

exit /b
::--------------------------------------------------------------------


:query
::displays the content of variables
set query_bool=

::if no variable supplied
if "%~1"=="" (
	echo    Global variables:
	echo -----------------------
	for %%a in (!global_vars_full!) do (
		set temp_gv=%%~a
		echo !temp_gv:#=:	!
	)
	exit /b
)

REM map the global vars
	if defined defmethod set "ddm=!defmethod!"
	if defined auto-delete_logs set "adl=!auto-delete_logs!"
	if defined script_location set "scl=!script_location!"
	if defined refresh_script_list set "rsl=!refresh_script_list!"

	REM map last refreshed var
	set lf=Nil
	if defined display_last_fetched set lf=!display_last_fetched!
	if not defined display_last_fetched call :get_last_fetched exit
	if defined display_last_fetched set lf=!display_last_fetched!
	set lf=!lf:Script List Last Fetched:=!


rem display the global vars
for %%a in (!global_vars_full!) do (
	for /f "tokens=1,2 delims=#" %%b in (%%a) do (
	
		if "%~1"=="%%~b" set "query_bool=yes" && echo %%~b: !%%~b!
		
		REM echo all the variables if all switch is triggered.
		if /i "%~1"=="-all" set "query_bool=yes" && echo %%~b: !%%~b!
	)
)
if not "!query_bool!"=="yes" echo Invalid variable. Valid variables are: !global_vars_list: =, !. && exit /b

exit /b
::--------------------------------------------------------------------

:version
REM prints the version no of bget and its components

if not "%~1"=="" echo Error. Invalid syntax. && exit /b

echo Bget:	!version!

REM display the cURL version
if exist "%~dp0\curl\curl.exe" (
	for /f "usebackq delims=" %%a in (`"%~dp0curl\curl.exe" --version`) do (
		set curl_ver_string=%%a
		if /i "!curl_ver_string:~0,4!"=="curl" set "curl_ver_string=!curl_ver_string:~5!" && set "curl_ver_string=Curl:	!curl_ver_string!" && echo !curl_ver_string!
	)
)

REM display the sorter version
 if exist "%~dp0\bin\srt.bat" for /f "tokens=1,2 delims= " %%a in ('findstr /b /c:"::::version" "%~dp0\bin\srt.bat"') do (
	echo Sorter:	%%~b
 )
 
REM display version nos of downloader scripts.
for /f "tokens=1,2 delims= " %%a in ('findstr /b /c:"////BgetVersion" "%~dp0\bin\download.js"  ') do (
	echo VBS Download script:	%%~b 
)
for /f "tokens=1,2 delims= " %%a in ('findstr /b /c:"''''BgetVersion" "%~dp0\bin\download.vbs"  ') do (
	echo JS Download script:	%%~b 
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
	echo No method supplied. Defaulting to !defmethod! download method.
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
if /i "%~2"=="-force" set "current_upgrade_hash=%random%%random%%random%"

::compare hashes
if /i "!new_upgrade_hash!"=="!current_upgrade_hash!" echo You already have the latest version. && exit /b

::get the upgrade script and run it
if exist "%~dp0\upgrade.bat" del /f /q "%~dp0\upgrade.bat"
call :download -!upgrade_method! "!upgrade_script_location!" "%~dp0\upgrade.bat"
if not exist "%~dp0\upgrade.bat" echo Failed to get the Bget upgrade script. && exit /b

::pass the upgrade method as an ADS to the upgrade script
if not defined upgrade_method echo Undefined upgrade method.
echo !upgrade_method!>"%~dp0\upgrade.bat:upgrade_method"

::pass the force switch as an ADS to the upgrade script
if /i "%~2"=="-force" echo yes>"%~dp0\upgrade.bat:force_bool"
if /i not "%~2"=="-force" echo no>"%~dp0\upgrade.bat:force_bool"
start /b /d "%~dp0" upgrade.bat
exit
::-----------------------------------------------------------------------------------------------------
::End of Functions.
::-----------------------------------------------------------------------------------------------------




::-----------------------------------------------------------------------------------------------------
::Beginning of helper functions.
::-----------------------------------------------------------------------------------------------------


:getlist

	REM exception for the -rsl global variable, prevents getlist from downloading script list
	REM TODO: LAST FETCHED FILE ISNT 0000
	if /i "!refresh_script_list!"=="no" (
	
	REM get the latest script list
	set /p last_fetched_file=<"%~dp0\bin\config.bget":lastfetched
	set /p last_fetched_sessno=<"%~dp0\bin\config.bget":lastfetched_sessno
	if defined last_fetched_sessno set last_fetched_sessno=!last_fetched_sessno: =!
	
	if defined last_fetched_sessno set sess_rand=!last_fetched_sessno!
	if not defined last_fetched_sessno set sess_rand=Default
	if not exist !last_fetched_file! echo [+] No local script list exists yet. Caching one now. && goto :cachelist
	echo [+] Using a cached script list...
	goto :get_last_fetched
	)
	
	REM gets the script list
	set /a sess_rand=%random%
	if exist "%~dp0\temp\master!sess_rand!.txt" del /f /q "%~dp0\temp\master!sess_rand!.txt"
	
	:cachelist
	call :download -%~1 "!list_location!" "%~dp0\temp\master!sess_rand!.txt"
	if not exist "%~dp0\temp\master!sess_rand!.txt" echo An error occured while getting the script list. && exit /b
	if exist "%~dp0\temp\master!sess_rand!.txt" echo Script List Last Fetched: %date% %time% >>"%~dp0\temp\master!sess_rand!.txt"
	if exist "%~dp0\temp\master!sess_rand!.txt" echo "%~dp0\temp\master!sess_rand!.txt">"%~dp0\bin\config.bget":lastfetched
	if exist "%~dp0\temp\master!sess_rand!.txt" echo !sess_rand! >"%~dp0\bin\config.bget":lastfetched_sessno
	
	:get_last_fetched
	set /p last_fetched_file=<"%~dp0\bin\config.bget":lastfetched
	if not defined last_fetched_file echo %random%%random%%random%>"%~dp0\bin\config.bget":lastfetched
	if exist !last_fetched_file! echo. && for /f "delims=" %%# in ('findstr /b /c:"Script List Last Fetched:" !last_fetched_file!') do (set "display_last_fetched=%%#")
	
	REM add option to exit without displaying
	if not "%~1"=="exit" if defined display_last_fetched echo !display_last_fetched!
	exit /b


:download
::downloads the files as specified
::usage: call :download -method "URL" "local_destination"
::Download switches:
::-bits uses the BITSADMIN service
::-js uses Jscript
::-vbs uses a Visual Basic Script
::-curl uses the Curl client
::-ps uses a powershell command.


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
	if exist "%~dp0\temp\unzip!ziprand!.vbs" del /f /q "%~dp0\temp\unzip!ziprand!.vbs"
	if exist "%~dp0\temp\unzip!ziprand!.vbs" del /f /q "%~dp0\temp\unzip!ziprand!.vbs"
	if exist "%~dp0\temp\unzip!ziprand!.vbs" del /f /q "%~dp0\temp\unzip!ziprand!.vbs"
	
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
