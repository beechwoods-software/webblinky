# webblinky

The **webblinky** demo showcases WiFi onboarding and control on the **Raspberry Pi Pico 2 W (RP2350)**.
It demonstrates how an application can expose a simple web interface to control the onboard LED, while also highlighting **captive WiFi onboarding**:

* On first boot (or when no WiFi credentials are configured), the Pico 2 W starts in **Access Point (AP) mode**.
* It creates a network with SSID:

```
webblinky-<MAC-ADDR>
```

* When a client device (phone/laptop) connects, a **captive portal** automatically opens.
* This portal prompts the user for their home/office WiFi SSID and PSK.
* Once provided, the Pico 2 W reconfigures itself, joins that WiFi network, and can then be controlled from the onboard web server.

This onboarding flow eliminates the need for hard-coding WiFi credentials and provides a simple, user-friendly setup path.

---

## Hardware Required

* **Raspberry Pi Pico 2 W (RP2350)**
* **USB Debug Probe Kit for Raspberry Pi Pico** (for flashing/debugging; available from Raspberry Pi resellers and Amazon)
* **OpenOCD** (portable build already included in this repository)

---

## Setup

This project uses a **west manifest** to manage and resolve dependencies.
Install west and Zephyr prerequisites for your platform (see Zephyr docs), then use the platform instructions below.

For more details, see the official [Zephyr Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html).

---

### local.conf (optional)

Creating a `local.conf` file in the repository root is **optional**.
It is only needed if you want to bypass the captive WiFi onboarding flow and preconfigure the device with known WiFi credentials.

This may be useful if:

* You are deploying in an environment where the target SSID/PSK is stable and always available.
* You want to skip the captive portal step for automated testing or CI builds.
* The device will operate in a controlled lab or manufacturing setup with fixed WiFi credentials.

If the WiFi credentials are likely to change (e.g., consumer environments, field deployments), it is better to rely on the **captive portal onboarding** instead.

The `local.conf` may contain:

* `CONFIG_PRECONFIG_WIFI` is a boolean. If `true`, sets the initial SSID and PSK to the values in `CONFIG_ONBOARDING_WIFI_SSID` and `CONFIG_ONBOARDING_WIFI_PSK`.
  If `false`, it will default to bringing up the WiFi as an AP for configuration.
* `CONFIG_ONBOARDING_WIFI_SSID="<Your SSID>"`
* `CONFIG_ONBOARDING_WIFI_PSK="<PreShared Key to Your SSID>"`

⚠️ Do **not** check `local.conf` into the repository as it contains site-specific proprietary information.

---

## Windows Setup and Usage

On Windows, all environment setup and build/flash operations are automated through PowerShell scripts located in:

```
scripts/windows/
```

You can **right-click any script → “Run with PowerShell”**, or run them from a PowerShell prompt at the repo root as shown below.

⚙️ **Dependencies**

* These scripts use **OpenOCD** (included in this repository).
* The **USB Debug Probe Kit for Raspberry Pi Pico** is required for flashing/debugging.

### 1) Install host tools

```powershell
.\scripts\windows\install-host-tools.ps1
```

### 2) Set up environment

```powershell
.\scripts\windows\setup-env.ps1
```

### 3) Build

```powershell
.\scripts\windows\build.ps1
```

*(Defaults target to **rpi_pico2/rp2350a/m33/w**; adjust as needed.)*

### 4) Flash

```powershell
.\scripts\windows\flash.ps1
```

### 5) Developer shell

Open an environment shell for ad-hoc commands:

```powershell
.\scripts\windows\shell.ps1
```

> **Note:** On Windows, use the scripts above for flashing/debugging. The OpenOCD paths and flags below are for **Linux**.

---

## Linux Setup and Usage

The following steps are based on the official [Zephyr Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html), tailored for **Ubuntu 22.04**.

### 0) Install prerequisites

```bash
sudo apt update
sudo apt install --no-install-recommends \
  git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc g++ pkg-config libsdl2-dev libmagic1
```

### 1) Create and activate a Python virtual environment

```bash
python3 -m venv .venv
. .venv/bin/activate
```

### 2) Upgrade pip and install west

```bash
python -m pip install --upgrade pip
pip install west
```

### 3) Initialize west (use the repo’s manifest) and fetch dependencies

```bash
# From the repository root:
west init -l manifest
west update
west zephyr-export
```

### 4) Fetch required firmware blobs (Infineon AIROC)

```bash
west blobs fetch hal_infineon --allow-regex 'img/whd/resources/firmware/COMPONENT_43439/43439a0_bin.c'
west blobs fetch hal_infineon --allow-regex 'img/whd/resources/clm/COMPONENT_43439/43439A0_clm_blob.c'
```

### 5) Install Zephyr SDK (ARM toolchain)

```bash
export ZEPHYR_SDK_INSTALL_DIR="$HOME/zephyr-sdk"
west sdk install -t arm-zephyr-eabi --install-dir "$ZEPHYR_SDK_INSTALL_DIR"
```

### 6) Build

```bash
west build -p always -d build -b rpi_pico2/rp2350a/m33/w .
```

If you need to override OpenOCD paths:

```bash
west build -p always -d build -b rpi_pico2/rp2350a/m33/w . -- \
  -DOPENOCD=/usr/local/bin/openocd \
  -DOPENOCD_DEFAULT_PATH=/usr/local/share/openocd/scripts \
  -DRPI_PICO_DEBUG_ADAPTER=cmsis-dap
```

### 7) Flash

```bash
west flash
```

### 8) Deactivate the venv (optional)

```bash
deactivate
```

---

## Note on Infineon (AIROC) Driver

Until the Infineon driver changes are fully merged upstream, the build uses a Zephyr fork/branch specified in the **west manifest**.

Reference (already listed in the manifest):

* [https://github.com/ThreeEights/zephyr/tree/airoc-spi-wifi](https://github.com/ThreeEights/zephyr/tree/airoc-spi-wifi)

You do **not** need to fetch this manually—`west update` will resolve it per the manifest.

---

## Testing

1. Connect UART to **GP0 (TX)** and **GP1 (RX)**, **BAUD = 115200**.

2. Flash the board.

3. After boot, the device creates a WiFi AP:

   ```
   webblinky-<MAC-ADDR>
   ```

4. Connect to this SSID. A **captive WiFi portal** will prompt for your network SSID and PSK.

5. Once connected to your network, open the UART shell and test connectivity:

   ```text
   uart:~$ net ping 8.8.8.8
   ```

   You should see successful ping responses.

---

## Troubleshooting

* **Windows Execution Policy**
  If you see errors running `.ps1` files, allow script execution for the current session:

  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
  ```

* **Linux USB Permissions**
  On Ubuntu, you may need to create a udev rule for your debug probe (CMSIS-DAP/J-Link).
  Example rule for CMSIS-DAP:

  ```bash
  echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="2e8a", MODE="0666"' | sudo tee /etc/udev/rules.d/99-rpi-pico.rules
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  ```

  Then unplug and replug the probe.

* **Toolchain not found**
  Verify `$ZEPHYR_SDK_INSTALL_DIR` is set correctly and run:

  ```bash
  west zephyr-export
  ```

* **OpenOCD not detected**
  On Linux, install or build OpenOCD with RP2040/Pico support and ensure it’s in your `PATH`.
  On Windows, use the included portable build (`external/openocd`).

---
