. .\win-env.ps1 

& .\.venv\Scripts\Activate.ps1

west flash

Write-Host "Press any key to exit"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")