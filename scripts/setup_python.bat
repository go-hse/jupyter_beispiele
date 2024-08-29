@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyright 2024: Andreas Roessler, HS Esslingen
:: Version 1.0, 29.08.2024
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set GIT_VERSION=2.46.0
set PY_VERSION=3.12.5
set PY_SHORT=312

:: Save current directory
set PARENT=%~dp0
cd /D %PARENT%

:: Current User PATH
set "ORGPATH=%PATH%"

:: DEFAULT WINDOWS-PATH
set PATH=%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\

call :FindProgram git.exe :InstallGit GIT_PATH
call :FindProgram code.exe :InstallCode CODE_PATH
call :InstallPython 

%comspec% /K title %PARENT%

:: FINISH Goto End-Of-File
GOTO :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Unterprogramm zur Programmsuche
:FindProgram
echo Arg %1 %2 %3

set "PROGRAM_NAME=%1"
set "INSTALL_CALL=%2"
set "PROGRAM_PATH="
set "PROGRAM_DIR="

echo Find %PROGRAM_NAME% in %PATH%

for %%I in ("%PROGRAM_NAME%") do (
    if exist "%%~$PATH:I" (
        set "PROGRAM_PATH=%%~$PATH:I"
        set "PROGRAM_DIR=%%~dp$PATH:I"
    )
)

if defined PROGRAM_PATH (
    echo %PROGRAM_NAME% gefunden: %PROGRAM_PATH%
    echo Verzeichnis: %PROGRAM_DIR%
    set "%~3=%PROGRAM_DIR%"
) else (
    echo %PROGRAM_NAME% wurde nicht im Pfad gefunden.
    call %INSTALL_CALL%
)
exit /b
:: ENDE Unterprogramm zur Programmsuche
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: VS CODE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:InstallCode

set DOWNLOAD="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
set CODE_ZIP=code.zip
set CODE_PATH=%PARENT%Code

if exist %CODE_ZIP% (
    echo ZIP %CODE_ZIP% exists
) else (
    curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L %DOWNLOAD% -o %CODE_ZIP%
    powershell -command "Expand-Archive -Force '%PARENT%%CODE_ZIP%' -DestinationPath '%CODE_PATH%'"
)

if exist %CODE_PATH%\data (
    echo Data Dir %CODE_PATH%\data exists
) else (
    mkdir %CODE_PATH%\data\user-data\User
)

:: VS Code Settings
(
echo ^{"extensions.ignoreRecommendations": true,"terminal.integrated.defaultProfile.windows": "Command Prompt"^}
) > %CODE_PATH%\data\user-data\User\settings.json

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: GIT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:InstallGit
set GIT_ZIP=MinGit-%GIT_VERSION%-64-bit.zip

set DOWNLOAD="https://github.com/git-for-windows/git/releases/download/v%GIT_VERSION%.windows.1/%GIT_ZIP%"
set GIT_PATH=%PARENT%Git.%GIT_VERSION%

if exist %GIT_ZIP% (
    echo ZIP %GIT_ZIP% exists
) else (
    curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L %DOWNLOAD% -o %GIT_ZIP%
    powershell -command "Expand-Archive -Force '%PARENT%%GIT_ZIP%' -DestinationPath '%GIT_PATH%'"
)
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PYTHON
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:InstallPython

set PY_ZIP=python-%PY_VERSION%-embed-amd64.zip
set DOWNLOAD="https://www.python.org/ftp/python/%PY_VERSION%/%PY_ZIP%"
set PYTHON_PATH=%PARENT%Python.%PY_VERSION%

if exist %PY_ZIP% (
    echo ZIP %PY_ZIP% exists
) else (
    curl -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -L %DOWNLOAD% -o %PY_ZIP%
    powershell -command "Expand-Archive -Force '%PARENT%%PY_ZIP%' -DestinationPath '%PYTHON_PATH%'"
)

set STDPATH=%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\
set "PATH=%STDPATH%;%PYTHON_PATH%;%PYTHON_PATH%\Scripts;%CODE_PATH%;%GIT_PATH%\cmd"

set LOADER=get-pip.py
if exist %LOADER% (
    echo LOADER %LOADER% exists
) else (
    curl -sSL https://bootstrap.pypa.io/%LOADER% -o %LOADER%
    python %LOADER%
)

:: to make pip work, see https://stackoverflow.com/questions/32639074/why-am-i-getting-importerror-no-module-named-pip-right-after-installing-pip
(
echo python%PY_SHORT%.zip
echo .
echo Lib\site-packages
) > %PYTHON_PATH%\python%PY_SHORT%._pth

pip install virtualenv

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: install jupyter-notebook-extesions from
:: https://jupyter.org/install
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
pip install notebook

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Create and fill Sources Dir
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
cd /D %PARENT%
mkdir Sources
echo print^('Hello World!'^) > Sources\01_hello_world.py

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: GET JUPYTERS BY HTTPS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set REPO=python_introduction
git clone https://github.com/go-hse/%REPO%.git

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Write SCRIPTS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
(
echo c = get_config^(^)  #noqa
echo c.ServerApp.ip = '127.0.0.1'
) > %PARENT%jupyter_notebook_config.py


(
echo @echo off
echo set "PATH=%PATH%"
echo set "JUPYTER_CONFIG_DIR=%PARENT%"
echo start jupyter notebook %REPO%\notebooks\00_Uebersicht.ipynb
echo start code Sources
echo start "Python-Umgebung in %PARENT%" %comspec% /K
) > %PARENT%start_python.bat

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: START
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

python --version
python Sources\01_hello_world.py
exit /b
