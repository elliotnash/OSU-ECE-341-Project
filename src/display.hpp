#pragma once

#include <Adafruit_SSD1306.h>
#include <cc.h>

#include "units.hpp"

class Display {
  private:
    const unsigned int screen_width = 128;
    const unsigned int screen_height = 32;
    const int oled_reset = -1;
    const int screen_address = 0x3C;
    const unsigned int flash_interval = 200;
    unsigned int refresh_interval;
    int sda;
    int scl;
    unsigned long last_flash;
    unsigned long last_update;
    bool flash_on = false;
    Adafruit_SSD1306 driver;
    Unit unit = Unit::Centimeter;
    u16_t value = 0;
    bool alert = false;
  public:
    Display(int sda, int scl, int refresh_interval);
    void init();
    void display();
    void clear();
    void setUnit(Unit unit);
    void setValue(u16_t value);
    void setAlert(bool alert);
    void update();
};
