#pragma once

#include <Preferences.h>
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
    float value = 0;
    Preferences preferences;
  public:
    Display(int sda, int scl, int refresh_interval);
    void init();
    void display();
    void clear();
    void setUnit(Unit unit);
    Unit getUnit();
    void setValue(float value);
    void update();
};
