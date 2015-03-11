@echo off
echo. 
echo Klone BelloFredo WorkDir
echo. 
XCOPY ..\..\Bello-Kodi-15.x-Nightlies\trunk skin.bellofredo /E /C /Q /I /Y
echo. 
echo Loesche nicht gebrauchte Dateien
echo. 
del /q skin.bellofredo\media\Textures.xbt
del /q skin.bellofredo\720p\script-skinshortcuts-includes.xml
pause
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
		echo NEUE VERSION von %%f !
		echo. 
		echo Erstelle Backups bisheriger Releases
		echo.
		IF not exist temp mkdir temp	
		IF not exist temp\%%f mkdir temp\%%f
		IF not exist temp\%%f\oldreleases mkdir temp\%%f\oldreleases
		IF not exist temp\%%f\oldreleases\dummy.txt echo. > temp\%%f\oldreleases\dummy.txt        
		move "%%f\%%f*.zip" temp\%%f\oldreleases >nul 2>&1
		if exist %%f\media (
			echo.
			echo Starte Textures.xbt Source-Kram
			echo.	
			XCOPY %%f\media temp\%%f\media /E /C /Q /I /Y
			rd /S /Q %%f\media
			mkdir %%f\media
			echo. 
			echo Erstelle Textures.xbt ... wart a weile Bub
			echo.
			%tools_dir%\TexturePacker -input temp\%%f\media -output %%f\media\Textures.xbt >nul 2>&1
			echo.
		)
		echo Packe %%f-!version!.zip
		echo.
		%tools_dir%\7z a %%f\%%f-!version!.zip %%f -tzip -ax!%%f*.zip> nul
		if exist %%f\media (
			echo.
			echo Stelle original Media Ordner wieder her
			echo.
			rd /s /q %%f\media
			mkdir %%f\media
			XCOPY temp\%%f\media %%f\media /E /C /Q /I /Y
			rd /s /q temp\%%f\media
		)
		echo. 
		echo. 
		echo %%f-!version!.zip Prozess fertig.
		echo.
		echo. 
    ) else (
        echo %%f-!version!.zip bereits aktuell
    )
)
echo ^</addons^> >> %~dp0addons.xml
for /f "delims= " %%a in ('%tools_dir%\fciv -md5 %~dp0addons.xml') do echo %%a > %~dp0addons.xml.md5
pause

echo.
echo. [ SVN Committer ]
:: The two lines below should be changed to suit your system.
set SOURCE=E:\github\sualfreds-repo\
set SVN=C:\Program Files\TortoiseSVN\bin
echo.
echo. Committing %SOURCE% to SVN...
"%SVN%\TortoiseProc.exe" /command:commit /path:"%SOURCE%" /closeonend:3
echo. done.
echo.
echo. Operation complete.