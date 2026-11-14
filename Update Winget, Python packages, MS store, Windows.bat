@echo off
:: Check for Administrator privileges and auto-elevate if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo ==========================================
echo Updating Winget Packages...
echo ==========================================
winget source update
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements

echo.
echo ==========================================
echo Updating Microsoft Store Apps...
echo ==========================================
:: Triggers the background Store auto-updater (works on all Windows 10/11 versions)
powershell -Command "Get-CimInstance -Namespace 'Root\cimv2\mdm\dmmap' -ClassName 'MDM_EnterpriseModernAppManagement_AppManagement01' | Invoke-CimMethod -MethodName UpdateScanMethod" >nul 2>&1
:: Uses the native Windows 11 Store CLI if available
where store >nul 2>&1 && store updates

echo.
echo ==========================================
echo Updating Python and Pip Packages...
echo ==========================================
python -m pip install --upgrade pip
for /F "skip=2 delims= " %%i in ('python -m pip list --outdated') do (
    echo Upgrading %%i...
    python -m pip install --upgrade %%i
)

echo.
echo ==========================================
echo Checking and Installing Windows Updates...
echo ==========================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null; Install-Module -Name PSWindowsUpdate -Force }; Import-Module PSWindowsUpdate; Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot"

echo.
echo ==========================================
echo All updates completed!
echo ==========================================
pause
