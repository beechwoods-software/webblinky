. .\win-env.ps1 

Write-Host "Installing host tools..." -ForegroundColor Cyan

$HOST_TOOLS = @(
	"versions/python311"
	"cmake"
	"ninja"
	"gperf"
	"dtc"
	"wget"
    "7zip"
)

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    # Install scoop if not already installed
	iwr -UseBasicParsing -UseDefaultCredentials 'https://get.scoop.sh' | iex
}

scoop install git
scoop bucket add extras
scoop bucket add versions
scoop bucket add Logiase_scoop-embedded https://github.com/Logiase/scoop-embedded

foreach ($pkg in $HOST_TOOLS) {
    scoop install $pkg
}

# Download and extract OpenOCD
$url = "https://sysprogs.com/getfile/2482/openocd-20250710.7z"
$archiveName = "openocd-20250710.7z"
Invoke-WebRequest -Uri $url -OutFile $archiveName
& "7z.exe" x $archiveName -o"external"
Rename-Item -Path ".\external\OpenOCD-20250710-0.12.0" -NewName "openocd"
Remove-Item $archiveName

# --- Finished ---
Write-Host "All done." -ForegroundColor Green
Write-Host "You may need to open a new terminal (or sign out/in) for PATH changes to take effect in new processes."

Write-Host "Press any key to exit"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
