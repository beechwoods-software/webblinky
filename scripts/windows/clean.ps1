. .\env.ps1 

Push-Location $env:WORKSPACE

Remove-Item -Path 'build' -Recurse -Force

Write-Host "Press any key to exit"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Pop-Location