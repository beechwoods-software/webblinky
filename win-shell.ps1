. .\win-env.ps1 

# Start a new interactive PowerShell with these env vars inherited
Start-Process powershell -ArgumentList "-NoExit", "-NoProfile", "-Command", @"
& '$PWD\.venv\Scripts\Activate.ps1'
"@
