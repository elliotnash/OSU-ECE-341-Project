#include <Arduino.h>
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

#include "display.hpp"
#include "dashboard.hpp"
#include "distance.hpp"

#define I2C_SDA 20
#define I2C_SCL 19

Display display(I2C_SDA, I2C_SCL, SENSOR_REFRESH_INTERVAL);
Dashboard dashboard;
DistanceSensor distanceSensor;

/**
 * @brief Read, store, and send distance
 *
 * Reads distance from sensor, stores it in a buffer, and sends it to all websocket clients.
 */
// void processDistance() {

//   display.setValue(distance);
//   display.update();
//   dashboard.broadcastDistance(distance);
// }

/**
 * @brief Main arduino setup function
 */
void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  // Wait for serial monitor to connect
  delay(2500);
  Serial.println("Starting up...");

  // Initialzie modules
  display.init();
  dashboard.init();
  distanceSensor.init();

  dashboard.setDistances(&distanceSensor.filtered);
  dashboard.setDistancesMutex(distanceSensor.filteredMutex);

  distanceSensor.addDistanceCallback([](uint16_t distance) {
    display.setValue(distance);
    dashboard.broadcastDistance(distance);
  });
  dashboard.addUnitChangeCallback([](Unit unit) {
    display.setUnit(unit);
  });
}

/**
 * @brief Main arduino loop function
 */
void loop() {
  display.update();
  dashboard.update();
  distanceSensor.update();
}
