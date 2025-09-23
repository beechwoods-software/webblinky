. .\env.ps1 

Push-Location $env:WORKSPACE

& .\.venv\Scripts\Activate.ps1

Write-Host "Building..." -ForegroundColor Cyan

west build -p always -d build -b rpi_pico2/rp2350a/m33/w . -- -DRPI_PICO_DEBUG_ADAPTER=cmsis-dap

Write-Host "All done. Press any key to exit." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Pop-Location