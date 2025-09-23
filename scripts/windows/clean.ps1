. .\env.ps1 

Push-Location $env:WORKSPACE

Write-Host "Cleaning..." -ForegroundColor Cyan

Remove-Item -Path 'build' -Recurse -Force

Write-Host "All done. Press any key to exit." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Pop-Location