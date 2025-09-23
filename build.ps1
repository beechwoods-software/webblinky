. .\win-env.ps1 

& .\.venv\Scripts\Activate.ps1

west build -p always -d build -b rpi_pico2/rp2350a/m33/w . -- -DOPENOCD="$env:OPENOCD_BIN" -DOPENOCD_DEFAULT_PATH="$env:OPENOCD_SCRIPTS" -DRPI_PICO_DEBUG_ADAPTER=cmsis-dap

Write-Host "Press any key to exit"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")