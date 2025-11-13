#pragma once

#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

class Dashboard {
  private:
  AsyncWebServer server;
  AsyncWebSocket ws;
  IPAddress esp_ip;
  String getDistanceData();
  float (*distances)[DISTANCE_WINDOW_SIZE];
  SemaphoreHandle_t distancesMutex;
  const unsigned long cleanupInterval = 1000;
  unsigned long lastCleanup;
  void setupWiFi();
  void setupServer();
  void onWSConnect(AsyncWebSocket *server, AsyncWebSocketClient *client);
  void onWSDisconnect(AsyncWebSocket *server, AsyncWebSocketClient *client);
  public:
  Dashboard();
  void init();
  void update();
  void broadcastDistance(double distance);
  void setDistances(float (*distances)[DISTANCE_WINDOW_SIZE]);
  void setDistancesMutex(SemaphoreHandle_t &mutex);
};
