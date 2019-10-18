@echo off
setlocal enabledelayedexpansion
call :macros

REM Bget's sorter
REM usage: srt filter_type file_to_sort fullarg
::::version 0.1.2
REM Changelog-------------------------------------------------------------
REM 03-OCT-2019: Minor fix to param handling.
REM ----------------------------------------------------------------------
set script_count=
if exist %~dp0temp_arrays.txt del /f /q %~dp0temp_arrays.txt >nul 2>&1
for /f "delims=" %%- in ('findstr /b /c:"[#]," "%~2"') do (
	for /f "tokens=1-10 delims=," %%a in ("%%-") do (
		set /a script_count+=1
		
		REM define the category from args
		if "%~1"=="name" set temp_filter_param=%%~b
		if "%~1"=="category" set temp_filter_param=%%~h
		if "%~1"=="author" set temp_filter_param=%%~g
		if "%~1"=="date" set temp_filter_param=%%~i
		set "wholestring=%%~-"
		
		REM clean the string
		
		for %%? in (- / \ : .) do (
			if defined temp_filter_param set temp_filter_param=!temp_filter_param:%%?=!
		)
		if defined temp_filter_param set temp_filter_param=!temp_filter_param: =!
		if defined temp_filter_param set temp_filter_param=!temp_filter_param:	=!
		set /a "max!temp_filter_param!+=1"
		
		for %%# in (!temp_filter_param!) do (
			for %%z in (!max%%#!) do (
				set "[!temp_filter_param!][%%z]=!wholestring!"
				if "%%~z"=="1" echo !temp_filter_param!>>%~dp0temp_arrays.txt
				REM if "%%~z"=="1" set array=!array! !temp_filter_param!
			)
		)
	)
)
if not defined script_count echo Could not get the script list. && exit /b
REM sort the array file alphabetically
if exist "%~dp0array.txt" del /f /q "%~dp0array.txt" >nul 2>&1
sort %~dp0temp_arrays.txt>>%~dp0array.txt
if exist %~dp0temp_arrays.txt del /f /q %~dp0temp_arrays.txt >nul 2>&1

rem Print the sorted strings
set script_count=
for /f %%# in (%~dp0array.txt) do (
	for /l %%? in (1,1,!max%%#!) do (
		for /f "tokens=1-10 delims=," %%a in ("![%%#][%%?]!") do (
			set /a script_count+=1
				REM init for the padding
			set "tmpH=%%~h"
			set "tmpD=%%~d"
			set "tmpD=!tmpD:.=!"
			set "tmpH=!tmpH:	=!"

				REM display formatted list.
			if /i not "%~3"=="-full" (
				%pad% "!script_count!".4.pad1
				%pad% "%%~b".16.pad2
				%pad% "!tmpH!".11.pad3
				%pad% "!tmpD:~0,20!".21.pad4
				%pad% "%%~g".20.pad5
				%pad% "%%~i".20.pad6
					
				set "script_string=!pad1!!script_count!. %%~b!pad2!^|!pad3!!tmpH!^| !tmpD:~0,20!...!pad4!^| %%g !pad5!^| %%i"
				echo !script_string!
			)
			
				REM display slightly unformatted list.
			if /i "%~3"=="-full" (
				set "script_string=!pad1!!script_count!. %%~b!pad2!^|!pad3!!tmpH!^| %%~d ^| %%~g ^| %%i"
				echo !script_string!
			)
		)
	)
)
if exist %~dp0array.txt del /f /q %~dp0array.txt >nul 2>&1
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

goto :eof