. .\env.ps1 

Push-Location $env:WORKSPACE

# Start a new interactive PowerShell with these env vars inherited
Start-Process powershell -ArgumentList "-NoExit", "-NoProfile", "-Command", @"
& '$PWD\.venv\Scripts\Activate.ps1'
"@

Pop-Location