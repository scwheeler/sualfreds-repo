@echo off

TITEL Container

:input
cls
ECHO.
ECHO ************************************************
ECHO * 1 = Klone Nightlies *
ECHO * 2 = Update Repo Files *
ECHO * 3 = Repo Commit *
echo * *
Echo * 4 = Beenden *
ECHO ************************************************
ECHO.

color 0d
choice /C:1234 


if errorlevel 4 goto Abbruch
if errorlevel 3 goto Commit
if errorlevel 2 goto Update
if errorlevel 1 goto Klone


Rem *** 4 ***
:Abbruch
goto ende


Rem *** 3 ***
:Commit
echo.
echo. [ SVN Committer ]
:: The two lines below should be changed to suit your system.
set SOURCE=%~dp0
set SVN=C:\Program Files\TortoiseGit\bin
echo.
echo. Committing %SOURCE% to SVN...
"%SVN%\TortoiseProc.exe" /command:commit /path:"%SOURCE%" /closeonend:3
echo. done.
echo.
echo. Operation complete.
goto input


Rem *** 2 ***
:Update
setlocal enabledelayedexpansion
set tools_dir=%~dp0tools

echo ^<?xml version="1.0" encoding="UTF-8" standalone="yes"?^> > %~dp0addons.xml
echo ^<addons^> >> %~dp0addons.xml

if exist plugin.video.amazon\resources\cache rd /s /q plugin.video.amazon\resources\cache >nul 2>&1

for /f %%f in ('dir /b /a:d') do if exist %%f\addon.xml (
    del /q /s %%f\*.pyo >nul 2>&1
    del /q /s %%f\*.pyc >nul 2>&1
    set add=
    for /f "delims=" %%a in (%%f\addon.xml) do (
        set line=%%a
        if "!line:~0,6!"=="<addon" set add=1
        if not "!line!"=="!line:version=!" if "!add!"=="1" (
            set new=!line:version=ß!
            for /f "delims=ß tokens=2" %%n in ("!new!") do set new=%%n
            for /f "delims=^= " %%n in ("!new!") do set new=%%n
            set version=!new:^"=!
        )
        if "!line:~-1!"==">" set add=
        if not "!line:~0,5!"=="<?xml" echo %%a >> %~dp0addons.xml
    )
    if not exist %%f\%%f-!version!.zip (
        echo. 
		echo.
		echo NEUE VERSION von %%f !		
		if exist "%%f\%%f*.zip" (
		echo Erstelle Backups bisheriger Releases
		IF not exist temp mkdir temp	
		IF not exist temp\%%f mkdir temp\%%f
		IF not exist temp\%%f\oldreleases mkdir temp\%%f\oldreleases
		move "%%f\%%f*.zip" temp\%%f\oldreleases >nul 2>&1
		)
		if exist %%f\media (
			if "%%f"=="skin.bellofredo" (
				echo Loesche nicht gebrauchte Dateien
				del /q skin.bellofredo\media\Textures.xbt >nul 2>&1
				del /q skin.bellofredo\UpdateRepo.bat >nul 2>&1
				del /q skin.bellofredo\720p\script-skinshortcuts-includes.xml >nul 2>&1
			)
			echo Starte Textures.xbt Source-Kram
			IF not exist temp mkdir temp	
			IF not exist temp\%%f mkdir temp\%%f			
			XCOPY %%f\media temp\%%f\media /E /C /Q /I /Y
			rd /S /Q %%f\media
			mkdir %%f\media
			echo Erstelle Textures.xbt ... wart a weile Bub
			%tools_dir%\TexturePacker -input temp\%%f\media -output %%f\media\Textures.xbt >nul 2>&1
		)
		echo Packe %%f-!version!.zip
		%tools_dir%\7z a %%f\%%f-!version!.zip %%f -tzip -ax!%%f*.zip> nul
		if exist %%f\media (
			echo Stelle original Media Ordner wieder her
			rd /s /q %%f\media
			mkdir %%f\media
			XCOPY temp\%%f\media %%f\media /E /C /Q /I /Y
			rd /s /q temp\%%f\media
		)
		echo %%f-!version!.zip Prozess fertig.
		echo. 
    ) else (
        echo.
		echo %%f-!version!.zip bereits aktuell
    )
)
echo ^</addons^> >> %~dp0addons.xml
for /f "delims= " %%a in ('%tools_dir%\fciv -md5 %~dp0addons.xml') do echo %%a > %~dp0addons.xml.md5
echo.
pause
goto input


Rem *** 1 ***
:Klone
echo. 
echo Klone BelloFredo WorkDir
echo. 
XCOPY ..\..\Bello-Kodi-15.x-Nightlies\trunk skin.bellofredo /E /C /Q /I /Y
echo Loesche nicht gebrauchte Dateien
del /q skin.bellofredo\media\Textures.xbt
del /q skin.bellofredo\UpdateRepo.bat
del /q skin.bellofredo\720p\script-skinshortcuts-includes.xml
pause
goto input


:ende
