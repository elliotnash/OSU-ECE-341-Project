#include <Arduino.h>
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

#include "display.hpp"
#include "dashboard.hpp"

#define I2C_SDA 22
#define I2C_SCL 23

Display display(I2C_SDA, I2C_SCL, SENSOR_REFRESH_INTERVAL);
Dashboard dashboard;

// Circular buffer to store distance readings. bufferIndex is the index of the next reading to be written.
// When the buffer is full, the oldest reading is overwritten.
// Since our HTTP handlers are async, we use a mutex to prevent race conditions when reading/writing to the buffer.
xSemaphoreHandle distanceMutex;
u16_t distanceBuffer[DISTANCE_WINDOW_SIZE];
int bufferIndex = 0;

/**
 * @brief Reads distance from sensor
 *
 * Unimplemented, currently returns a random float between 90 and 110
 * @return float distance
 */
float readDistance() {
  u16_t distance = random(100) + 950; // Random uint16_t between 950 and 1050
  return distance;
}

/**
 * @brief Read, store, and send distance
 *
 * Reads distance from sensor, stores it in a buffer, and sends it to all websocket clients.
 */
void processDistance() {
  float distance = readDistance();

  xSemaphoreTake(distanceMutex, portMAX_DELAY);
  distanceBuffer[bufferIndex] = distance;
  bufferIndex++;
  if (bufferIndex >= 100) {
    bufferIndex = 0;
  }
  xSemaphoreGive(distanceMutex);

  display.setValue(distance);
  display.update();
  dashboard.broadcastDistance(distance);
}

/**
 * @brief Main arduino setup function
 */
void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  // Wait for serial monitor to connect
  delay(2500);
  Serial.println("Starting up...");

  distanceMutex = xSemaphoreCreateMutex();

  // Initialzie modules
  display.init();
  dashboard.init();

  dashboard.setDistances(&distanceBuffer);
  dashboard.setDistancesMutex(distanceMutex);
}

/**
 * @brief Main arduino loop function
 */
void loop() {
  delay(100);
  processDistance();
  display.update();
  dashboard.update();
}
