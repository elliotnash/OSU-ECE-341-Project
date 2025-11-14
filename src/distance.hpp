#include <VL53L0X.h>

#define EMA_DATA 50
#define e 2.71828
#define MAX_CALLBACKS 8

class DistanceSensor{
  private:
    VL53L0X sensor;
    const int sample_rate_ms = 20;
    unsigned long last_sample_time = 0;
    uint16_t last_distance = 0;
    const int sensor_address = 0x29;
    bool sensor_initialized = false;
    int lastDistances[EMA_DATA];
    int windowHead = 0;
    float weights[EMA_DATA];
    void (*callbacks[MAX_CALLBACKS])(uint16_t);
    int dataHead = 0;
  public:
    DistanceSensor();
    void init();
    void data_array(uint16_t last_distance);
    uint16_t getDistance();
    void update();
    float ema();
    void addDistanceCallback(void (*callback)(uint16_t));
    void removeDistanceCallback(void (*callback)(uint16_t));
    xSemaphoreHandle filteredMutex;
    float filtered[DISTANCE_WINDOW_SIZE];
};