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

Write-Host "All done. Press any key to exit." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Pop-Location