#pragma once

#include <ESPAsyncWebServer.h>
#include <DNSServer.h>

class Dashboard {
  private:
  AsyncWebServer server;
  AsyncWebSocket ws;
  DNSServer dnsServer;
  IPAddress espIP;
  bool isAP = false;
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
  void broadcastDistance(float distance);
  void setDistances(float (*distances)[DISTANCE_WINDOW_SIZE]);
  void setDistancesMutex(SemaphoreHandle_t &mutex);
};
