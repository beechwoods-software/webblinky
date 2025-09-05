/*
 * Copyright (c) 2024 Beechwoods Software
 *
 */

#include <zephyr/kernel.h>
#include <zephyr/net/socket.h>
#include "ob_wifi.h"
#include "ob_web_server.h"
#include "ob_nvs_data.h"
#include <zephyr/sys/reboot.h>
#include "ready_led.h"
#ifdef CONFIG_USE_BUTTON
#include "button.h"
#endif // CONFIG_USE_BUTTON
#ifdef CONFIG_ONBOARDING_OTA
#include "ob_ota.h"
#endif // CONFIG_ONBOARDING_OTA
#ifdef CONFIG_ONBOARDING_NFC
#include "ob_nfc_tag.h"
#endif
#ifdef CONFIG_ONBOARDING_CAPTIVE_PORTAL
#include "ob_captive_portal.h"
#endif // CONFIG_ONBOARDING_CAPTIVE_PORTAL

#define SECONDS_UNTIL_RESET 6

#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(webblinky, CONFIG_WEBBLINKY_LOG_LEVEL);

#define LED_ATTRIBUTE "readyled"
#define APP_WEB_PATH_NAME "/webblinky"
#define APP_WEB_TITLE "Select Blink"
static uint8_t content_body[] = {
   "<body><h2>Blink Speeds</h2><p>Select blink speed</p><form method=\"post\" enctype=\"text/plain\" action=\"" APP_WEB_PATH_NAME "\">"
  "<input type=\"radio\" id=\"off\" name=\"speed\" value=\"OFF\"><label for=\"off\">Off</label>"
  "<br><input type=\"radio\" id=\"slow\" name=\"speed\" value=\"SLOW\"><label for=\"slow\">Slow</label>"
  "<br><input type=\"radio\" id=\"medium\" name=\"speed\" value=\"MEDIUM\"><label for=\"medium\">Medium</label>"
  "<br><input type=\"radio\" id=\"fast\" name=\"speed\" value=\"FAST\"><label for=\"fast\">Fast</label>"
  "<br><input type=\"radio\" id=\"on\" name=\"speed\" value=\"ON\"><label for=\"on\">On</label>"
  "<br><br><input type=\"submit\" value=\"Submit\"></form></body></html>\r\n\r\n"
};



int app_get(int client, struct web_page * wp)
{
  int rc = -1;
  const char *header200 = CreateHeader200(sizeof(content_body), wp->title);
  if(NULL != header200) {
    rc = sendall(client, header200, strlen(header200));
    if(rc < 0) {
      LOG_ERR("HTTP Header send failed %d",errno);
    } else {
      rc = sendall(client, content_body, sizeof(content_body));
      if(rc < 0) {
        LOG_ERR("HTTP body send failed %d", errno);
      }
      LOG_HEXDUMP_DBG(content_body, sizeof(content_body),"Header200");
    }
  }

  LOG_DBG("Webblinky get called");
  return rc;
}


typedef int (*led_fun_ptr_t)(void);
int  ready_led_slow()
{
#ifdef CONFIG_USE_READY_LED
  ready_led_set(READY_LED_LONG);
#endif
  return 0;
}
int ready_led_medium()
{
#ifdef CONFIG_USE_READY_LED
  ready_led_set(READY_LED_SHORT);
#endif
  return 0;
}
int ready_led_fast()
{
#ifdef CONFIG_USE_READY_LED
  ready_led_set(READY_LED_PANIC);
#endif
  return 0;
}

post_attributes_t webblinky_attributes[] = {
  {"speed", 5}
};

#define NUM_WEBBLINKY_ATTRIBUTES ((sizeof webblinky_attributes)/sizeof(post_attributes_t))

#define LED_OFF "OFF"
#define LED_SLOW "SLOW"
#define LED_MEDIUM "MEDIUM"
#define LED_FAST "FAST"
#define LED_ON "ON"

value_action_t speed_actions[] = {
#ifdef CONFIG_USE_READY_LED
  { LED_OFF, sizeof(LED_OFF), &ready_led_off },
#endif
  { LED_SLOW, sizeof(LED_SLOW), &ready_led_slow },
  { LED_MEDIUM, sizeof(LED_MEDIUM), &ready_led_medium },
  { LED_FAST, sizeof(LED_FAST), &ready_led_fast },
#ifdef CONFIG_USE_READY_LED
  { LED_ON, sizeof(LED_ON), &ready_led_on }
#endif
};
#define NUM_SPEED_ACTIONS (sizeof(speed_actions)/sizeof(value_action_t))

int app_post(int client, struct web_page * wp)
{

  int rc;
  int i;
  bool found = false;
  value_action_t * vap;
  led_fun_ptr_t func;
  if((rc =  ob_ws_process_post(client, webblinky_attributes,
                               NUM_WEBBLINKY_ATTRIBUTES, wp)) >= 0) {
    for(i = 0; i < NUM_WEBBLINKY_ATTRIBUTES; i++) {
      vap = &speed_actions[i];
      LOG_DBG("Checking %s", vap->match);
      if(!strncmp(webblinky_attributes[0].valuebuffer, vap->match, vap->length)) {
        LOG_DBG("Matched %s", vap->match);
        func = (led_fun_ptr_t)vap->userdata;
        (*func)();
#ifdef CONFIG_ONBOARDING_DT
        ob_dt_set(LED_ATTRIBUTE, vap->match);
#endif // CONFIG_ONBOARDING_DT
        found=true;
        break;
      }
    }
    if(!found) {
      LOG_ERR("Bad value %s", webblinky_attributes[0].valuebuffer);
    }
    app_get(client, wp);
  }
  return rc;
}

#if 0
#define POST_BUFFER_SIZE 64

  char buffer[POST_BUFFER_SIZE];
  int rc = 0;
  char * tok;
  char * value;
  web_attributes_t * wap;
  bool found = false;
  int i;
  led_fun_ptr_t func;

  LOG_DBG("Webblinky post called");
  rc = zsock_recv(client, buffer, POST_BUFFER_SIZE-1, 0);
  if(rc < 0) {
    LOG_ERR("POST Read failed %d", rc);
  } else if (rc >0) {
    buffer[rc] = 0;
    LOG_DBG("received '%s'", buffer);
    tok = strtok(buffer, post_delims);
    if((NULL != tok) && (!strncmp("speed", tok, 5))) {
      value = strtok(NULL, post_delims);
      if(NULL != value) {
        LOG_DBG("value %s %d %d %d",value, (int)NUM_WEB_ATTRIBUTES, (int)sizeof(web_attributes_t), (int)sizeof(web_attributes));
        for(i = 0; i < NUM_WEB_ATTRIBUTES; i++) {
          wap = &web_attributes[i];
          LOG_DBG("Checking %s", wap->name);
          if(!strncmp(value, wap->name, wap->length)) {
            LOG_DBG("Matched %s", wap->name);
            func = (led_fun_ptr_t)wap->userdata;
            (*func)();
#ifdef CONFIG_ONBOARDING_DT
            ob_dt_set(LED_ATTRIBUTE, value);
#endif // CONFIG_ONBOARDING_DT
            found=true;
            break;
          }
        }
        if(!found) {
          LOG_ERR("Bad value %s", value);
        }
      }
    }
    app_get(client, wp);
  }
  return rc;
}
#endif


#ifdef CONFIG_USE_BUTTON
static uint64_t b_start = 0;
void
button_handler(button_callback_data_t * cbd)
{
  uint64_t t = k_uptime_get();
  uint64_t end;
  LOG_DBG("Now %d:%lld %d", cbd->button, t, cbd->state);
  switch(cbd->state) {
  case BUTTON_STATE_PRESSED:
    if(0 == b_start) {
      b_start = t;
    }
    break;
  case BUTTON_STATE_RELEASED:
    end = t - b_start;
    LOG_DBG("end %lld(%lld)", t, end);
    if(end > 6000) {
#ifdef CONFIG_ONBOARDING_NVS
      LOG_ERR("Factory reset");
      nvs_data_factory_reset();
#endif // CONFIG_ONBOARDING_NVS
      sys_reboot(SYS_REBOOT_WARM);
    }
    b_start = 0;
    break;
  default:
    LOG_ERR("Bad state %d", cbd->state);
    break;
  }
}
#endif // CONFIG_USE_BUTTON

int
main(void)
{
  
  int rc =0;
  printf("Starting webblinky\n");
  LOG_DBG("Webblinky");
#ifdef  CONFIG_USE_READY_LED
  ready_led_init();
  ready_led_set(READY_LED_DELAY_LONG);
#endif //CONFIG_USE_READY_LED
#ifdef CONFIG_USE_BUTTON
  button_init(button_handler);
#endif //CONFIG_USE_BUTTON
#ifdef CONFIG_ONBOARDING_NFC
  init_nfc_onboarding_module();
  start_nfc_onboarding_listener();
#endif // CONFIG_ONBOARDING_NFC
#ifdef CONFIG_ONBOARDING_WEB_SERVER
  init_web_server();
   rc = ob_ws_register_web_page(APP_WEB_PATH_NAME, APP_WEB_TITLE, app_get, app_post, true);
#ifdef CONFIG_ONBOARDING_CAPTIVE_PORTAL
   ob_cp_init();
#endif // CONFIG_ONBOARDING_CAPTIVE_PORTAL
#endif //CONFIG_ONBOARDING_WEB_SERVER
#ifdef CONFIG_ONBOARDING_WIFI
  ob_wifi_init();
#endif
#ifdef CONFIG_ONBOARDING_WEB_SERVER
  start_web_server();
#endif //CONFIG_ONBOARDING_WEB_SERVER
#ifdef CONFIG_ONBOARDING_OTA
  ota_init();
#endif // CONFIG_ONBOARDING_OTA
  LOG_DBG("Initialization complete %d", rc);
  while(1) {
    k_sleep(K_FOREVER);
  }
}
