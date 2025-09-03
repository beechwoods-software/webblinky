cmake_minimum_required(VERSION 3.20.0)
set(CMAKE_VERBOSE_MAKEFILE 1)
set(DEVICE_CERT_PREFIX webblinky_demo)
set(SERVER_NAME golioth)

set(COMPATIBLE_BOARDS qemu_cortex_m3 qemu_cortex_r5 qemu_xtensa qemu_x86_64 esp32_devkitc esp32c3_devkitm esp32c3_devkitm/esp32c3 rpi_pico/rp2040/w rpi_pico nrf52_adafruit_feather teensy41 adafruit_feather_nrf52840 esp32_devkitc/esp32/procpu  esp32c3_devkitm/esp32c3esp32c6_devkitc esp32c6_devkitc/esp32c6)

set(WIFI_BOARDS qemu_cortex_r5 qemu_xtensa esp32_devkitc_wroom esp32_devkitc_wrover esp32c3_devkitm rpi_pico/rp2040/w rpi_pico esp32_devkitc_wroom/esp32/procpu esp32_devkitc_wrover/esp32/procpu esp32c3_devkitm/esp32c3 esp32c6_devkitc esp32c6_devkitc/esp32c6)
if(NOT ${BOARD} IN_LIST COMPATIBLE_BOARDS)
    message(FATAL_ERROR "App $ENV{UROS_APP} not compatible with board ${BOARD}")
endif()

add_compile_definitions(HAS_WIFI)
if(EXISTS  ${CMAKE_CURRENT_SOURCE_DIR}/local.conf )
  set(EXTRA_CONF_FILE local.conf)
else()
  MESSAGE(WARN " ${CMAKE_CURRENT_SOURCE_DIR}/local.conf not found")
endif()
list(APPEND EXTRA_ZEPHYR_MODULES "${CMAKE_CURRENT_SOURCE_DIR}/sensors")
list(APPEND EXTRA_ZEPHYR_MODULES "${CMAKE_CURRENT_SOURCE_DIR}/onboarding")


find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

project(webblinky)
function(add_dependencies_ifdef feature_toggle)
  if(${${feature_toggle}})
    add_dependencies(${ARGN})
  endif()
endfunction()


set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c17 -pendantic")
set(gen_dir ${ZEPHYR_BINARY_DIR}/include/generated/)

if (${CONFIG_ONBOARDING_CERTS_GENERATE_CERTS} )
  if ( NOT CONFIG_ONBOARDING_CERTS_DEVICE_ID )
    message( FATAL_ERROR "DEVICE_ID not configured")
  endif()
  generate_inc_file_for_target(
    app
    root_cert/${SERVER_NAME}.crt.der
    ${gen_dir}/ca_certificate.inc
  )
  generate_inc_file_for_target(
    app
    device_certs/${DEVICE_CERT_PREFIX}-${CONFIG_ONBOARDING_CERTS_DEVICE_ID}.crt.der
    ${gen_dir}/device_cert.inc
  )

  generate_inc_file_for_target(
    app
    device_certs/${DEVICE_CERT_PREFIX}-${CONFIG_ONBOARDING_CERTS_DEVICE_ID}.key.der
    ${gen_dir}/device_privkey.inc
  )
endif()

FILE(GLOB app_sources src/main.c)



target_sources(app PRIVATE ${app_sources} )
target_link_libraries(app PUBLIC onboarding sensors)
target_link_libraries_ifdef(CONFIG_LIBST25DV app PUBLIC LIBST25DV )
