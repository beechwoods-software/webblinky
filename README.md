# webblinky
This is a simple application that allows the user to control the blinking of the ready light via a web page.
It is an example of how an application can add a web page to the onboarding web server.

After boot the ready led will blink slowly until the wifi is connect to an AP


## Setup
This repository has submodules. Either clone with the --recursive flag or do a git submodule init ; git submodule update after cloning
There is currently no dynamic configuration for the application, configuration data is hard coded.

### local.conf
This repository requires the creation of a local.conf file in the root directory

The local.conf may contain the following lines

- CONFIG_PRECONFIG_WIFI is a boolean which if true sets the initial SSID and PSK to the values in CONFIG_ONBOARDING_WIFI_SSID and CONFIG_ONBOARDING_WIFI_PSK if false it will default to bringing up the wifi as an AP for configuration
- CONFIG_ONBOARDING_WIFI_SSID=\"<Your SSID\>"
- CONFIG_ONBOARDING_WIFI_PSK="\<PreShared Key to Your SSID\>"

Please do not check local.conf into the repository as it contains site specific proriaitary information,

### Raspberry Pi Pico with mcuboot

This can be built using the 'west --sysbuild' option as a signed image with accompanying mcuboot image for Raspberry Pi Pico, but you need some additional build options in order to use "west flash" to flash the images onto the board (you cannot use gdb's "load" command or copy a uf2 image onto the board, because those lack the header with the mcuboot signature). 

In order to use "west flash" and "west debug" on the Pico, you'll need to build and install openocd from the https://github.com/raspberrypi/openocd.git repository on the "rp2040-v0.12.0" branch.

In order to build for the Pico, use this command:
```
west build --sysbuild -b rpi_pico/rp2040/w webblinky/ -- -DSB_CONFIG_BOOTLOADER_MCUBOOT=y -DOPENOCD=/usr/local/bin/openocd -DOPENOCD_DEFAULT_PATH=/usr/local/share/openocd/scripts -DRPI_PICO_DEBUG_ADAPTER=cmsis-dap -DEXTRA_DTC_OVERLAY_FILE=sysbuild/mcuboot_rpi_pico_w.overlay
```

Also note that, until Steve's Infineon driver changes have been fully accepted and merged into the zephyr mainline, you'll need to build against zephy from this branch/forks:

 - ssh://git@github.com/ThreeEights/zephyr.git (airoc-spi-wifi branch)

## TODO
