@echo off
rem get date and hope no participants compile at the same second
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
rem echo hour=%hour%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
rem echo min=%min%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%
rem echo secs=%secs%
rem set year=%date:~-2,2%
rem echo year=%year%
set month=%date:~3,2%
if "%month:~0,1%" == " " set month=0%month:~1,1%
rem echo month=%month%
set day=%date:~0,2%
if "%day:~0,1%" == " " set day=0%day:~1,1%
rem echo day=%day%
set datevar=%month%%day%%hour%%min%%secs%

rem rem make android ID and name unique so we can have multiple installs
rem restore original manifest and src subdir
copy tools\love-android-sdl2\original\AndroidManifest.xml tools\love-android-sdl2\
rd tools\love-android-sdl2\src\love /s/q
xcopy tools\love-android-sdl2\original\love tools\love-android-sdl2\src\love /e/i

rem replace id, name and src subdir
tools\sed-win\bin\sed -i "s/loveToAndroid Game/NoDino/g" tools\love-android-sdl2\AndroidManifest.xml
tools\sed-win\bin\sed -i "s/love.to.android/love\.to\.android%datevar%/g" tools\love-android-sdl2\AndroidManifest.xml
tools\sed-win\bin\sed -i "s/love.to.android/love\.to\.android%datevar%/g" tools\love-android-sdl2\src\love\to\android\LtaActivity.java
move tools\love-android-sdl2\src\love\to\android tools\love-android-sdl2\src\love\to\android%datevar%

REM remove files sed creates (4 year old bug as of 2015)
del sed* /q

REM set variables
setlocal
set ANT_HOME=%~dp0\tools\ant
set JAVA_HOME=%~dp0\tools\jdk-win
set ANDROID_HOME=%~dp0\tools\android-win
set PATH=%PATH%;%ANT_HOME%\bin

REM cd and remove previoius output
del game.apk /q
cd tools\love-android-sdl2
rd gen /s/q
rd bin /s/q

REM easier game copying
IF EXIST ..\..\game.love (
del assets\game.love
copy ..\..\game.love assets\game.love
)

REM easier icon copying
IF EXIST ..\..\icon.png (
del res\drawable-xxhdpi\ic_launcher.png
copy ..\..\icon.png res\drawable-xxhdpi\ic_launcher.png
)

REM compile and move
call ant release
copy bin\love_android_sdl2-debug.apk ..\..\game.apk

echo.
echo Press any key to close
pause >nul
