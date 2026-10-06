@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
title Publish yijing-app to GitHub

echo ============================================================
echo    Yijing App  ^|  Publish to GitHub
echo ============================================================
echo.
echo   This script will: login ^-^> commit ^-^> create repo ^-^> push
echo   Repo name : yijing-app      Visibility : Public
echo   Pages URL : https://^<your-name^>.github.io/yijing-app/
echo.
echo   Press Ctrl+C to cancel any time.
echo ============================================================
echo.
pause

REM ---------- Step 1 : login ----------
echo.
echo [Step 1/5] Checking GitHub login...
gh auth status >nul 2>&1
if %errorlevel%==0 (
    echo Already logged in, skipping.
    goto step2
)
echo Not logged in yet. Starting authentication...
echo.
echo When prompted, choose:
echo   1. GitHub.com
echo   2. HTTPS
echo   3. Y   (authenticate Git with your GitHub credentials)
echo   4. Login with a web browser
echo.
echo Then an 8-char code appears. Open https://github.com/login/device
echo paste the code, click Authorize, come back and press Enter.
echo.
gh auth login
gh auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Login failed. Please try again.
    pause
    exit /b 1
)

:step2
echo.
echo [Step 2/5] Checking git identity...
git config user.email >nul 2>&1
if %errorlevel%==0 (
    echo Name  : 
    git config user.name
    echo Email : 
    git config user.email
    goto step3
)
set /p GNAME=Your name shown on GitHub ^> 
set /p GMAIL=Your email on GitHub ^> 
git config user.name "%GNAME%"
git config user.email "%GMAIL%"
echo Identity saved.

:step3
echo.
echo [Step 3/5] Committing files...
git add -A
git commit -m "Init: Yijing divination app - 64 gua reference"
if %errorlevel% neq 0 (
    echo Note: nothing new to commit, continuing anyway.
)

echo.
echo [Step 4/5] Creating repository and pushing...
git remote get-url origin >nul 2>&1
if %errorlevel%==0 (
    echo Remote already exists, pushing updates...
    git push -u origin main
) else (
    gh repo create yijing-app --public --source=. --push
)
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Push failed. If the name is taken, edit this script
    echo and change yijing-app to another name, then run again.
    pause
    exit /b 1
)

echo.
echo [Step 5/5] Enabling GitHub Pages...
for /f %%i in ('gh api user --jq .login') do set GHUSER=%%i
gh api -X POST "repos/%GHUSER%/yijing-app/pages" -f "source[branch]=main" -f "source[path]=/" >nul 2>&1
if %errorlevel%==0 (
    echo Pages enabled.
) else (
    echo Pages may already be enabled, or needs manual setup.
    echo Check: https://github.com/%GHUSER%/yijing-app/settings/pages
)

echo.
echo ============================================================
echo    DONE
echo ============================================================
echo    Repo      : https://github.com/%GHUSER%/yijing-app
echo    Pages URL : https://%GHUSER%.github.io/yijing-app/
echo.
echo    Pages takes 1-2 minutes to go live.
echo    Add it to your phone home screen to use it like an app.
echo ============================================================
echo.
pause
