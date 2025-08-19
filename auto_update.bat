@echo off
title AutoFish Pro - Auto Update
color 0B

echo.
echo ========================================
echo   AutoFish Pro - Auto Update Script
echo ========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Git is not installed or not in PATH!
    echo Please install Git from: https://git-scm.com/
    pause
    exit /b 1
)

REM Check if we're in a git repository
if not exist ".git" (
    echo ❌ This directory is not a Git repository!
    echo Please run 'git init' first or navigate to the correct directory.
    pause
    exit /b 1
)

echo ℹ️  Checking for changes...
git status --porcelain > temp_status.txt
set /p changes= < temp_status.txt
del temp_status.txt

if "%changes%"=="" (
    echo ⚠️  No changes detected in the repository.
    echo Repository is already up to date.
    pause
    exit /b 0
)

echo.
echo 📝 Changed files:
git status --short
echo.

REM Get current timestamp for commit message
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "timestamp=%YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%"

set "commitMessage=🔄 Auto-update: General improvements - %timestamp%"

echo ℹ️  Commit message: %commitMessage%
echo.

echo ℹ️  Staging all changes...
git add .
if errorlevel 1 (
    echo ❌ Failed to stage changes!
    pause
    exit /b 1
)

echo ✅ Changes staged successfully
echo.

echo ℹ️  Committing changes...
git commit -m "%commitMessage%"
if errorlevel 1 (
    echo ❌ Failed to commit changes!
    pause
    exit /b 1
)

echo ✅ Changes committed successfully
echo.

echo ℹ️  Pushing to remote repository...
git push origin main
if errorlevel 1 (
    echo ❌ Failed to push to remote repository!
    echo.
    echo Possible solutions:
    echo   1. Pull latest changes: git pull origin main
    echo   2. Check repository permissions
    echo   3. Verify remote URL: git remote -v
    pause
    exit /b 1
)

echo ✅ Successfully pushed to remote repository!
echo.
echo 📊 Update Summary:
echo   Commit: %commitMessage%
for /f "tokens=*" %%i in ('git remote get-url origin') do set "remoteUrl=%%i"
echo   Remote: %remoteUrl%
echo   Time: %timestamp%
echo.
echo 🎉 Repository updated successfully!
echo Your changes are now live on GitHub!
echo.
pause
