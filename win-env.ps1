# --- user-configurable --------------------------------------------------------
# $ZEPHYR_SDK_INSTALL_DIR = 'D:\SDKs\zephyr-sdk'  # ← uncomment & set to override
$PYTHON = 'python311'

# --- Zephyr env ---------------------------------------------------------------
$env:ZEPHYR_BASE = if (Test-Path .\external\zephyr) { (Resolve-Path .\external\zephyr).Path } else { '' }
$env:ZEPHYR_TOOLCHAIN_VARIANT = 'zephyr'
$env:OPENOCD_BASE = if (Test-Path .\external\openocd) { (Resolve-Path .\external\openocd).Path } else { '' }
$env:OPENOCD_BIN = "$env:OPENOCD_BASE/bin/openocd.exe"
$env:OPENOCD_SCRIPTS = "$env:OPENOCD_BASE/share/openocd/scripts"

# Prefer the *user var* if set; otherwise keep existing env; otherwise use default.
if ($ZEPHYR_SDK_INSTALL_DIR -and -not [string]::IsNullOrWhiteSpace($ZEPHYR_SDK_INSTALL_DIR)) {
  $env:ZEPHYR_SDK_INSTALL_DIR = $ZEPHYR_SDK_INSTALL_DIR
}
elseif ([string]::IsNullOrWhiteSpace($env:ZEPHYR_SDK_INSTALL_DIR)) {
  $env:ZEPHYR_SDK_INSTALL_DIR = Join-Path $env:USERPROFILE 'zephyr-sdk'
}
