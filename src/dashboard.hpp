#pragma once

#include <ESPAsyncWebServer.h>
#include <DNSServer.h>
#include "units.hpp"

#define MAX_CALLBACKS 8
class Dashboard {
  private:
  AsyncWebServer server;
  AsyncWebSocket ws;
  DNSServer dnsServer;
  IPAddress espIP;
  bool isAP = false;
  Unit unit = Unit::Centimeter;
  String getDistanceData();
  float (*distances)[DISTANCE_WINDOW_SIZE];
  void (*unitCallbacks[MAX_CALLBACKS])(Unit);
  SemaphoreHandle_t distancesMutex;
  const unsigned long cleanupInterval = 1000;
  unsigned long lastCleanup;
  void setupWiFi();
  void setupServer();
  void onWSConnect(AsyncWebSocket *server, AsyncWebSocketClient *client);
  void onWSDisconnect(AsyncWebSocket *server, AsyncWebSocketClient *client);
  void onWSData(AsyncWebSocket *server, AsyncWebSocketClient *client, uint8_t *data, size_t len);
  public:
  Dashboard();
  void init();
  void update();
  void broadcastDistance(float distance);
  void setDistances(float (*distances)[DISTANCE_WINDOW_SIZE]);
  void setDistancesMutex(SemaphoreHandle_t &mutex);
  void addUnitChangeCallback(void (*callback)(Unit));
  void removeUnitChangeCallback(void (*callback)(Unit));
};
