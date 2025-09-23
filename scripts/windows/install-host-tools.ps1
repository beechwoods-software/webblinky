. .\env.ps1 

Push-Location $env:WORKSPACE

Write-Host "Installing host tools..." -ForegroundColor Cyan

$HOST_TOOLS = @(
	"versions/python311"
	"cmake"
	"ninja"
	"gperf"
	"dtc"
	"wget"
	"electrohire-scoop-embedded/openocd"
    "7zip"
)

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    # Install scoop if not already installed
	Write-Host "Installing scoop..." -ForegroundColor Cyan
	iwr -UseBasicParsing -UseDefaultCredentials 'https://get.scoop.sh' | iex
}

scoop install git
scoop bucket add extras
scoop bucket add versions
scoop bucket add electrohire-scoop-embedded https://github.com/electrohire/scoop-embedded.git

foreach ($pkg in $HOST_TOOLS) {
    scoop install $pkg
}

# --- Finished ---
Write-Host "All done." -ForegroundColor Green
Write-Host "You may need to open a new terminal (or sign out/in) for PATH changes to take effect in new processes."

Write-Host "Press any key to exit"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Pop-Location