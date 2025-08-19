@echo off
REM AutoFish Pro - Quick Update Script
REM Simple batch file for auto-updating repository

setlocal enabledelayedexpansion

REM Configuration
set "GIT_PATH=C:\Git\cmd\git.exe"
set "REPO_PATH=D:\ssciprtgame\New folder"
set "BRANCH=main"

REM Get current timestamp for commit message
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%"
set "MIN=%dt:~10,2%"
set "SS=%dt:~12,2%"
set "TIMESTAMP=%YYYY%-%MM%-%DD% %HH%:%MIN%:%SS%"

if "%~1"=="" (
    set "COMMIT_MSG=Auto-update: !TIMESTAMP!"
) else (
    set "COMMIT_MSG=%~1"
)

echo.
echo 🎣 AutoFish Pro - Quick Update
echo ================================
echo 📁 Repository: %REPO_PATH%
echo 🌿 Branch: %BRANCH%
echo 💬 Message: !COMMIT_MSG!
echo.

REM Check if Git exists
if not exist "%GIT_PATH%" (
    echo ❌ Git not found at: %GIT_PATH%
    echo Please install Git or update the path
    pause
    exit /b 1
)

REM Change to repository directory
cd /d "%REPO_PATH%"
if errorlevel 1 (
    echo ❌ Failed to change to repository directory
    pause
    exit /b 1
)

REM Check git status
echo 🔍 Checking for changes...
"%GIT_PATH%" status --porcelain > temp_status.txt
if errorlevel 1 (
    echo ❌ Failed to check git status
    del temp_status.txt 2>nul
    pause
    exit /b 1
)

REM Check if there are changes
for %%R in (temp_status.txt) do if %%~zR equ 0 (
    echo ✅ No changes detected. Repository is up to date.
    del temp_status.txt
    pause
    exit /b 0
)

echo 📊 Changes detected:
type temp_status.txt
del temp_status.txt

echo.
set /p CONFIRM="🤔 Do you want to commit and push these changes? (Y/N): "
if /i not "!CONFIRM!"=="Y" (
    echo ❌ Operation cancelled
    pause
    exit /b 0
)

echo.
echo 🔄 Starting update process...

REM Stage all changes
echo 📋 Staging changes...
"%GIT_PATH%" add .
if errorlevel 1 (
    echo ❌ Failed to stage changes
    pause
    exit /b 1
)

REM Commit changes
echo 💾 Committing changes...
"%GIT_PATH%" commit -m "!COMMIT_MSG!"
if errorlevel 1 (
    echo ❌ Failed to commit changes
    pause
    exit /b 1
)

REM Push to remote
echo 🚀 Pushing to remote repository...
"%GIT_PATH%" push origin %BRANCH%
if errorlevel 1 (
    echo ❌ Failed to push to remote repository
    pause
    exit /b 1
)

echo.
echo ✅ Auto-update completed successfully!
echo 🎉 Changes have been pushed to GitHub repository
echo.
echo 📊 Final status:
"%GIT_PATH%" status --short

echo.
echo 🎣 AutoFish Pro repository updated successfully! ✨
pause
