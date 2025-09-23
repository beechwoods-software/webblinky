. .\env.ps1 

Push-Location $env:WORKSPACE

Write-Host "Creating virtual environment..." -ForegroundColor Cyan
& $PYTHON -m venv .venv

# Activate the venv inside this script
& .\.venv\Scripts\Activate.ps1

Write-Host "Upgrading pip..." -ForegroundColor Cyan
python -m pip install --upgrade pip

Write-Host "Installing west..." -ForegroundColor Cyan
pip install west

Write-Host "Setting up west enironment..." -ForegroundColor Cyan
west init -l .\manifest
west update
west packages pip --install
west blobs fetch hal_infineon --allow-regex 'img/whd/resources/firmware/COMPONENT_43439/43439a0_bin.c' 
west blobs fetch hal_infineon --allow-regex 'img/whd/resources/clm/COMPONENT_43439/43439A0_clm_blob.c' 

Write-Host "Installing zephyr-sdk..." -ForegroundColor Cyan
west sdk install -t arm-zephyr-eabi --install-dir "$env:ZEPHYR_SDK_INSTALL_DIR" 

# Exit the venv
deactivate

Write-Host "All done. You can now build Zephyr apps with:" -ForegroundColor Green
Write-Host "  west build -b <board> path\to\app" -ForegroundColor Yellow

Write-Host "Press any key to exit"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Pop-Location