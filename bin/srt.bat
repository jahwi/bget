@echo off
setlocal enabledelayedexpansion

if /i "%~1"=="disp_list" (goto :list_list)

REM Bget's sorter
REM usage: srt filter_type file_to_sort fullarg onlyarg
REM usage: srt name master.txt -nofull -only name jahwi
::::version 0.1.3
REM Changelog-------------------------------------------------------------
REM 03-OCT-2019: Minor fix to param handling.
REM 06-JUL-2020: Addded -only filter
REM            : Improved sorting time
REM 01-JUL-2021: Removed need for temp files
REM ----------------------------------------------------------------------

REM sorting algo: contatenate parameter in front of the whole string, print those out to a file, sort the file
REM using sort.exe, and then display the sorted lines.

rem usage: bsort author file-to-sort [-full/-nofull] [-only author jahwi]
rem sorts by tokens, e.g. the above will sort and display where only the author token is "jahwi"
rem and also sort by the author token

rem concatenate the parameter in front of the string to be sorted

@REM set /a rndf=%random%
@REM set tmp_sortfile="%~dp0tmp_sort!rndf!.txt"
@REM set sortfile="%~dp0sort!rndf!.txt"
@REM if exist !tmp_sortfile! del /f /q !tmp_sortfile!
@REM if exist !sortfile! del /f /q !sortfile!
rem echo on

rem sort the list
@REM call sort !tmp_sortfile!>>!sortfile!
call :macros
rem display the sorted strings
set script_count=0
set only_count=0
set only_bool=false
@REM if exist "!tmp_sortfile!" del /f /q "!tmp_sortfile!"
for /f "usebackq tokens=2-10 delims=," %%b in (`call %~0 disp_list %~2 %~1`) do (
    set /a script_count+=1
    set temp_filter_param=
    set format_bool=true

    rem provision for the only switch:
    if "%~4"=="-only" (
        set only_bool=true
        if not "%~5"=="" (
            if not "%~6"=="" (
                rem attempt to save time by only formatting if the criteria has been met
                set format_bool=false
                if "%~5"=="name" set "temp_filter_param=%%~b"
                if "%~5"=="category" set "temp_filter_param=%%~h"
                if "%~5"=="author" set "temp_filter_param=%%~g"
                if "%~5"=="date" set "temp_filter_param=%%~i"
                
                if defined temp_filter_param (
                    if /i "%~6"=="!temp_filter_param!" (
                        set format_bool=true
                        set /a only_count+=1
                        set /a script_count=!only_count!
                    )
                )
            )
        )
    )

    if "!format_bool!"=="true" (
        rem format the output
        set "tmpH=%%~h"
        set "tmpD=%%~d"
        set "tmpD=!tmpD:.=!"
        set "tmpH=!tmpH:	=!"

        REM display completely formatted list.
        if /i not "%~3"=="-full" (
            %pad% "!script_count!".4.pad1
            %pad% "%%~b".16.pad2
            %pad% "!tmpH!".11.pad3
            %pad% "!tmpD:~0,20!".21.pad4
            %pad% "%%~g".20.pad5
            %pad% "%%~i".20.pad6
                
            set "script_string=!pad1!!script_count!. %%~b!pad2!^|!pad3!!tmpH!^| !tmpD:~0,20!...!pad4!^| %%g !pad5!^| %%i"
        )

        REM display minimally-formatted list.
        if /i "%~3"=="-full" (
            set "script_string=!pad1!!script_count!. %%~b!pad2!^|!pad3!!tmpH!^| %%~d ^| %%~g ^| %%i"
        )
        echo !script_string!
    )
)

rem cleanup
@REM if exist "!tmp_sortfile!" del /f /q "!tmp_sortfile!"

rem exit
if "!only_bool!"=="true" (
	if "!only_count!"=="0" echo No scripts found matching the filter.
    exit /b
)

if "!script_count!"=="0" (
	echo Could not list the script list.
    exit /b
)

exit /b

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

exit /b

:list_list
set /a rndf=%random%
for /f "delims=" %%- in ('findstr /b /c:"[#]," "%~2"') do (
    for /f "tokens=1-10 delims=," %%a in ("%%~-") do (

        REM define the category from args
        set temp_filter_param=
        if "%~3"=="name" set "temp_filter_param=%%~b"
        if "%~3"=="category" set "temp_filter_param=%%~h"
        if "%~3"=="author" set "temp_filter_param=%%~g"
        if "%~3"=="date" set "temp_filter_param=%%~i"

        echo !temp_filter_param!%%~-
        @REM echo !temp_filter_param!%%~->>%~p0log_!rndf!.txt
    )
)
exit /b


