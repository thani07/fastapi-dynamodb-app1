@echo off
echo ========================================
echo GitHub Push Fix Script
echo ========================================
echo.

cd /d "%~dp0"

echo Step 1: Checking current status...
git status
echo.

echo Step 2: Do you want to start fresh? (This will delete git history)
echo WARNING: This will erase all git history and create a new repository!
echo.
set /p choice="Type YES to continue, or NO to cancel: "

if /i not "%choice%"=="YES" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 3: Backing up current .git folder...
if exist .git.backup rmdir /s /q .git.backup
move .git .git.backup
echo Backup created: .git.backup
echo.

echo Step 4: Starting fresh repository...
git init
git add .
git commit -m "Initial commit - cleaned AWS secrets"
git branch -M main
git remote add origin https://github.com/thani07/fastapi-dynamodb-app1.git
echo.

echo Step 5: Ready to push to GitHub
echo.
echo IMPORTANT: Make sure you have added these secrets to GitHub:
echo   - AWS_ACCESS_KEY_ID
echo   - AWS_SECRET_ACCESS_KEY
echo   - AWS_ACCOUNT_ID
echo.
echo Go to: https://github.com/thani07/fastapi-dynamodb-app1/settings/secrets/actions
echo.
set /p push="Have you added the secrets? Type YES to push: "

if /i "%push%"=="YES" (
    echo.
    echo Pushing to GitHub (force push)...
    git push -f origin main
    echo.
    echo ========================================
    echo SUCCESS! Check GitHub Actions:
    echo https://github.com/thani07/fastapi-dynamodb-app1/actions
    echo ========================================
) else (
    echo.
    echo Push cancelled. You can manually push later with:
    echo git push -f origin main
)

echo.
pause
