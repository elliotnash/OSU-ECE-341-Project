#include "display.hpp"

// Display class implementations
Display::Display(int sda, int scl, int refresh_interval) {
  unsigned long now = millis();

  this->sda = sda;
  this->scl = scl;
  this->refresh_interval = refresh_interval;
  this->last_update = now;
  this->last_flash = now;
  this->driver = Adafruit_SSD1306(screen_width, screen_height, &Wire, oled_reset);
}

// Display class methods
void Display::init() {
  Wire.setPins(sda, scl);
  if (!driver.begin(SSD1306_SWITCHCAPVCC, screen_address)) {
    Serial.println(F("Display allocation failed"));
  }
}

void Display::display() {
  driver.display();
}

void Display::clear() {
  driver.clearDisplay();
}

void Display::setValue(float value) {
  this->value = value;
}

void Display::setUnit(Unit unit) {
  this->unit = unit;
}

void Display::setAlert(bool alert) {
  this->alert = alert;
}

void Display::update() {
  // Update the display every refresh_interval milliseconds.
  unsigned long now = millis();
  if (now - last_update < refresh_interval) {
    return;
  }
  last_update = now;

  // If alert is active, then flash the display every flash_interval milliseconds.
  if (alert && now - last_flash >= flash_interval) {
    flash_on = !flash_on;
    last_flash = now;
  }

  // If alert is not active or flash is on, display the value
  if (!alert || flash_on) {
    String displayValue = String(convertUnit(value, Unit::Millimeter, unit)).substring(0, 4);
    // Remove trailing dot
    if (displayValue.charAt(3) == '.') {
      displayValue.setCharAt(3, ' ');
    }

    clear();
    driver.setTextSize(3);
    driver.setTextColor(WHITE);
    driver.setCursor(2, 5);
    driver.print(displayValue + " " + getUnitSymbol(unit));
    display();
  } else {
    // Otherwise we should flash the display by clearing.
    clear();
    display();
  }
}
