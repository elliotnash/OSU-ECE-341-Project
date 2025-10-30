/**
 * Blink
 *
 * Turns on an LED on for one second,
 * then off for one second, repeatedly.
 */
#include "Arduino.h"
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

AsyncWebServer server(80);

extern const uint8_t index_html_start[] asm("_binary_dashboard_dist_index_html_gz_start");
extern const uint8_t index_html_end[] asm("_binary_dashboard_dist_index_html_gz_end");

IPAddress esp_ip;

void setup()
{
  // Initialize serial communication
  Serial.begin(9600);
  Serial.println("Starting up...");

  // Initialize LED pin
  pinMode(LED_BUILTIN, OUTPUT);

  // Connect to WiFi (WIFI_SSID/WIFI_PASSWORD are defined in .env)
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  // Attempt to connect to WiFi for 5 seconds
  for (int attempts = 0; WiFi.status() != WL_CONNECTED && attempts < 5; attempts++) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }

  // If connection fails, run in access point mode
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Connection failed, running in access point mode");
    WiFi.disconnect();
    delay(1000);
    WiFi.softAP("ESP32 Distance Sensor", "password");
    esp_ip = WiFi.softAPIP();
  } else {
    esp_ip = WiFi.localIP();
  }

  Serial.println("Connected to WiFi");

  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    AsyncWebServerResponse *response = request->beginResponse(200, "text/html", index_html_start, index_html_end - index_html_start);
    response->addHeader("Content-Encoding", "gzip");
    request->send(response);
  });

  server.begin();

  Serial.println("Dashboard running at: http://" + esp_ip.toString());
}

void loop()
{
  // turn the LED on (HIGH is the voltage level)
  digitalWrite(LED_BUILTIN, HIGH);

  // wait for a second
  delay(1000);

  // turn the LED off by making the voltage LOW
  digitalWrite(LED_BUILTIN, LOW);

   // wait for a second
  delay(1000);

  Serial.println("Dashboard running at: http://" + esp_ip.toString());
}
