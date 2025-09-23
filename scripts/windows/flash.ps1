. .\env.ps1 

Push-Location $env:WORKSPACE

& .\.venv\Scripts\Activate.ps1

Write-Host "Flashing..." -ForegroundColor Cyan
west flash

Write-Host "All done. Press any key to exit." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Pop-Location