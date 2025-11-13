#include "dashboard.hpp"

// These are pointers to the start and end of the compressed index.html file (in flash memory)
// Embedded files are defined in platformio.ini and can be accessed via the assembly labels
// To read, read index_html_end - index_html_start bytes from index_html_start
extern const uint8_t index_html_start[] asm("_binary_dashboard_dist_index_html_gz_start");
extern const uint8_t index_html_end[] asm("_binary_dashboard_dist_index_html_gz_end");

Dashboard::Dashboard(): server(80), ws("/ws") {}

String Dashboard::getDistanceData() {
  if (xSemaphoreTake(this->distancesMutex, portMAX_DELAY)) {
    if (this->distances == nullptr) {
      return "[]";
    }

    String data = "[";
    for (int i = 0; i < DISTANCE_WINDOW_SIZE; i++) {
      data += String((*this->distances)[i]) + ",";
    }

    xSemaphoreGive(this->distancesMutex);

    data.setCharAt(data.length() - 1, ']');
    return data;
  }
  return "[]";
}

/**
 * @brief Setup web server
 *
 * Sets up the web server to serve the dashboard at the root path
 * and starts a websocket
 */
void Dashboard::setupServer() {
  using namespace std::placeholders;

  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    AsyncWebServerResponse *response = request->beginResponse(200, "text/html", index_html_start, index_html_end - index_html_start);
    response->addHeader("Content-Encoding", "gzip");
    request->send(response);
  });
  server.on("/data", HTTP_GET, [this](AsyncWebServerRequest *request){
    AsyncWebServerResponse *response = request->beginResponse(200, "text/plain", this->getDistanceData());
    request->send(response);
  });

  ws.onEvent([this](AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
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
  });
  server.addHandler(&ws);

  server.begin();
  Serial.println("Dashboard running at: http://" + esp_ip.toString());
}

/**
 * @brief Setup WiFi connection
 *
 * Attempts to connect to the WiFi network defined in the .env file
 * If connection fails, runs in access point mode
 */
void Dashboard::setupWiFi() {
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

/**
 * @brief Setup dashboard
 *
 * Sets up the WiFi connection and web server
 */
void Dashboard::init() {
  setupWiFi();
  setupServer();
}

void Dashboard::update() {
  unsigned long now = millis();
  if (now - lastCleanup >= cleanupInterval) {
    this->ws.cleanupClients();
    lastCleanup = now;
  }
}

void Dashboard::onWSConnect(AsyncWebSocket *server, AsyncWebSocketClient *client) {
  Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
  // New client connected, send them the current distance buffer
  client->text("{\"event\":\"data\",\"data\":" + this->getDistanceData() + "}");
}

void Dashboard::onWSDisconnect(AsyncWebSocket *server, AsyncWebSocketClient *client) {
  Serial.printf("WebSocket client #%u disconnected\n", client->id());
}

void Dashboard::broadcastDistance(u16_t distance) {
  ws.textAll("{\"event\":\"update\",\"data\":" + String(distance) + "}");
}

void Dashboard::setDistances(u16_t (*distances)[DISTANCE_WINDOW_SIZE]) {
  this->distances = distances;
}

void Dashboard::setDistancesMutex(SemaphoreHandle_t &mutex) {
  this->distancesMutex = mutex;
}
