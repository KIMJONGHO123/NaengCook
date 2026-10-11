@echo off
setlocal
set /p NODE_VERSION=<"%~dp0.nvmrc"
set "NODE_HOME=%~dp0.tools\node-v%NODE_VERSION%-win-x64"
if not exist "%NODE_HOME%\node.exe" (
  echo Project Node is missing. Run this once from the project root:
  echo powershell -ExecutionPolicy Bypass -File scripts\setup-node.ps1
  exit /b 1
)
set "PATH=%NODE_HOME%;%PATH%"
for /f "delims=" %%V in ('node --version') do set "ACTUAL_VERSION=%%V"
if not "%ACTUAL_VERSION%"=="v%NODE_VERSION%" (
  echo Project Node version mismatch. Run scripts\setup-node.ps1 again.
  exit /b 1
)
if "%~1"=="--node-version" (
  node --version
  exit /b %errorlevel%
)
pushd "%~dp0apps\mobile"
if "%~1"=="" (
  call "%NODE_HOME%\npm.cmd" start
) else (
  call "%NODE_HOME%\npm.cmd" %*
)
set "RESULT=%errorlevel%"
popd
exit /b %RESULT%
