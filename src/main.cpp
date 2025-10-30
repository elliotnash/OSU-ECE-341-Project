#include "Arduino.h"
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <mutex>

AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// These are pointers to the start and end of the compressed index.html file (in flash memory)
// Embedded files are defined in platformio.ini and can be accessed via the assembly labels
// To read, read index_html_end - index_html_start bytes from index_html_start
extern const uint8_t index_html_start[] asm("_binary_dashboard_dist_index_html_gz_start");
extern const uint8_t index_html_end[] asm("_binary_dashboard_dist_index_html_gz_end");

IPAddress esp_ip;

// Circular buffer to store distance readings. bufferIndex is the index of the next reading to be written.
// When the buffer is full, the oldest reading is overwritten.
// Since our HTTP handlers are async, we use a mutex to prevent race conditions when reading/writing to the buffer.
std::mutex distanceMutex;
float distanceBuffer[100];
int bufferIndex = 0;

String getDistanceData() {
  String data = "[";
  {
    std::lock_guard<std::mutex> lck(distanceMutex);
    for (int i = 0; i < 100; i++) {
      data += String(distanceBuffer[(i + bufferIndex) % 100]) + ",";
    }
  }
  data.setCharAt(data.length() - 1, ']');
  return data;
}

/**
 * @brief Setup WiFi connection
 *
 * Attempts to connect to the WiFi network defined in the .env file
 * If connection fails, runs in access point mode
 */
void setupWiFi() {
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
}

void onWSConnect(AsyncWebSocket *server, AsyncWebSocketClient *client) {
  Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
  // New client connected, send them the current distance buffer
  client->text("{\"event\":\"data\",\"data\":" + getDistanceData() + "}");
}

void onWSDisconnect(AsyncWebSocket *server, AsyncWebSocketClient *client) {
  Serial.printf("WebSocket client #%u disconnected\n", client->id());
}

/**
 * @brief Handle websocket events
 */
void onWSEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT:
      onWSConnect(server, client);
      break;
    case WS_EVT_DISCONNECT:
      onWSDisconnect(server, client);
      break;
    case WS_EVT_DATA:
    case WS_EVT_PONG:
    case WS_EVT_ERROR:
      break;
  }
}

/**
 * @brief Setup web server
 *
 * Sets up the web server to serve the dashboard at the root path
 * and starts a websocket
 */
void setupWebServer() {
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    AsyncWebServerResponse *response = request->beginResponse(200, "text/html", index_html_start, index_html_end - index_html_start);
    response->addHeader("Content-Encoding", "gzip");
    request->send(response);
  });
  server.on("/data", HTTP_GET, [](AsyncWebServerRequest *request){
    AsyncWebServerResponse *response = request->beginResponse(200, "text/plain", getDistanceData());
    request->send(response);
  });

  ws.onEvent(onWSEvent);
  server.addHandler(&ws);

  server.begin();
  Serial.println("Dashboard running at: http://" + esp_ip.toString());
}

/**
 * @brief Reads distance from sensor
 *
 * Unimplemented, currently returns a random float between 90 and 110
 * @return float distance
 */
float readDistance() {
  float distance = random(10000)/10000.0 * 20.0 + 90; // Random float between 90 and 110
  return distance;
}

/**
 * @brief Read, store, and send distance
 *
 * Reads distance from sensor, stores it in a buffer, and sends it to all websocket clients.
 */
void processDistance() {
  float distance = readDistance();
  {
    std::lock_guard<std::mutex> lck(distanceMutex);
    distanceBuffer[bufferIndex] = distance;
    bufferIndex++;
    if (bufferIndex >= 100) {
      bufferIndex = 0;
    }
  }
  ws.textAll("{\"event\":\"update\",\"data\":" + String(distance) + "}");
}

/**
 * @brief Main arduino setup function
 */
void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  Serial.println("Starting up...");

  // Initialize LED pin
  pinMode(LED_BUILTIN, OUTPUT);

  // Setup WiFi connection
  setupWiFi();
  // Start web server
  setupWebServer();
}

/**
 * @brief Main arduino loop function
 */
void loop() {
  delay(100);
  processDistance();

  ws.cleanupClients();
}
