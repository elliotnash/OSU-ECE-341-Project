#include <WiFi.h>
#include <ESPmDNS.h>
#include <ArduinoJson.h>

#include "dashboard.hpp"

#define MAX_QUEUED_UPDATES WS_MAX_QUEUED_MESSAGES/8

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
        onWSData(server, client, data, len);
        break;
      case WS_EVT_PONG:
      case WS_EVT_ERROR:
        break;
    }
  });
  server.addHandler(&ws);

  server.begin();
  Serial.println("Dashboard running at: http://" + espIP.toString());
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
    this->isAP = true;
    WiFi.disconnect();
    delay(1000);
    WiFi.softAP("ESP32 Distance Sensor", "password");
    espIP = WiFi.softAPIP();
  } else {
    espIP = WiFi.localIP();
  }
  WiFi.waitForConnectResult();

  // Setup MDNS responder to allow .local domain access
  if (MDNS.begin("sensor")) {
    MDNS.addService("http", "tcp", 80);
    Serial.println("MDNS responder started");
  } else {
    Serial.println("Error setting up MDNS responder!");
  }

  if (this->isAP) {
    this->dnsServer.start(53, "*", espIP);
    Serial.println("DNS server started");
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
  // Handle DNS queries
  this->dnsServer.processNextRequest();

  // Cleanup expired WebSocket clients on set interval
  unsigned long now = millis();
  if (now - lastCleanup >= cleanupInterval) {
    this->ws.cleanupClients();
    lastCleanup = now;
  }
}

void Dashboard::onWSConnect(AsyncWebSocket *server, AsyncWebSocketClient *client) {
  Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
  // New client connected, create a queue for them
  queuedUpdates[client->id()] = std::queue<float>();
  // Drop messages on full queue
  client->setCloseClientOnQueueFull(false);
  // send them the current distance buffer and unit
  client->text("{\"event\":\"data\",\"data\":" + this->getDistanceData() + "}");
  client->text("{\"event\":\"unit\",\"data\":\"" + getUnitSymbol(this->unit) + "\"}");
}

void Dashboard::onWSDisconnect(AsyncWebSocket *server, AsyncWebSocketClient *client) {
  Serial.printf("WebSocket client #%u disconnected\n", client->id());
  // Remove the client from the queue map
  queuedUpdates.erase(client->id());
}

void Dashboard::onWSData(AsyncWebSocket *server, AsyncWebSocketClient *client, uint8_t *data, size_t len) {
  JsonDocument doc;

  DeserializationError error = deserializeJson(doc, data, len);
  if (error) {
    Serial.println("Error parsing JSON");
    return;
  }

  String event = doc["event"];
  if (event == "unit") {
    Unit unit = getUnitForSymbol(doc["data"]);
    this->unit = unit;
    Serial.println("Switching to unit: " + getUnitSymbol(unit));
    // Call callbacks
    for (int i = 0; i < MAX_CALLBACKS; i++) {
      if (unitCallbacks[i] != nullptr) {
        unitCallbacks[i](unit);
      }
    }
    // Update clients
    ws.textAll("{\"event\":\"unit\",\"data\":\"" + getUnitSymbol(this->unit) + "\"}");
  } else {
    Serial.println("Unknown event: " + event);
  }
}

void Dashboard::broadcastDistance(float distance) {
  // Cleanup expired WebSocket clients
  ws.cleanupClients();

  for (auto client = ws.getClients().begin(); client != ws.getClients().end(); ++client) {
    // Queue the update for the client
    queuedUpdates[client->id()].push(distance);

    // If the message queue is not full, send all queued updates to the client (
    if (client->queueLen() < MAX_QUEUED_UPDATES) {
      String data = "[";
      while (!queuedUpdates[client->id()].empty()) {
        data += String(queuedUpdates[client->id()].front()) + ",";
        queuedUpdates[client->id()].pop();
      }
      data.setCharAt(data.length() - 1, ']');
      client->text("{\"event\":\"update\",\"data\":" + data + "}");
    }
  }
}

void Dashboard::setDistances(float (*distances)[DISTANCE_WINDOW_SIZE]) {
  this->distances = distances;
}

void Dashboard::setDistancesMutex(SemaphoreHandle_t &mutex) {
  this->distancesMutex = mutex;
}

void Dashboard::addUnitChangeCallback(void (*callback)(Unit)) {
  for (int i = 0; i < MAX_CALLBACKS; i++) {
    if (unitCallbacks[i] == nullptr) {
      unitCallbacks[i] = callback;
      return;
    }
  }
  Serial.println("Max unit change callbacks reached");
}
void Dashboard::removeUnitChangeCallback(void (*callback)(Unit)) {
  for (int i = 0; i < MAX_CALLBACKS; i++) {
    if (unitCallbacks[i] == callback) {
      unitCallbacks[i] = nullptr;
      return;
    }
  }
  Serial.println("Unit change callback not found");
}
