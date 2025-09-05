# webblinky
This is a simple application that allows the user to control the blinking of the ready light via a web page.
It is an example of how an application can add a web page to the onboarding web server.

After boot the ready led will blink slowly until the wifi is connect to an AP


## Setup
This repository has submodules. Either clone with the --recursive flag or do a git submodule init ; git submodule update after cloning

### local.conf
This repository optionally supports the creation of a local.conf file in the root directory of the application.

The local.conf may contain the following lines  
- CONFIG_PRECONFIG_WIFI is a boolean which if true sets the initial SSID and PSK to the values in CONFIG_ONBOARDING_WIFI_SSID and CONFIG_ONBOARDING_WIFI_PSK if false it will default to bringing up the wifi as an AP for configuration
- CONFIG_ONBOARDING_WIFI_SSID=\"<Your SSID\>"
- CONFIG_ONBOARDING_WIFI_PSK="\<PreShared Key to Your SSID\>"
- CONFIG_ONBOARDING_WIFI_AP_SSID is set to webblinky, change this if you prefer a differnt AP advertised.  
Please do not check local.conf into the repository as it contains site specific proriaitary information.

