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

void setup()
{
  // Initialize serial communication
  Serial.begin(9600);
  Serial.println("Starting up...");

  // Initialize LED pin
  pinMode(LED_BUILTIN, OUTPUT);

  // Connect to WiFi (WIFI_SSID/WIFI_PASSWORD are defined in .env)
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }

  Serial.println("Connected to WiFi");
  Serial.println(WiFi.localIP());

  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    AsyncWebServerResponse *response = request->beginResponse(200, "text/html", index_html_start, index_html_end - index_html_start);
    response->addHeader("Content-Encoding", "gzip");
    request->send(response);
  });

  server.begin();
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
  Serial.println(WiFi.localIP());
}
