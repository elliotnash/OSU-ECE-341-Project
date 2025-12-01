#include <cmath>
#include "distance.hpp"

DistanceSensor::DistanceSensor(){
    this->filteredMutex = xSemaphoreCreateMutex();
    for(int k=0; k<EMA_DATA; k++){
        weights[k] = pow(e,k-EMA_DATA);
        //weights[k] = k - EMA_DATA;
    }
    float weight_sum = 0.0;
    for(int k=0; k<EMA_DATA; k++){
      weight_sum += weights[k];
    }
    for(int k=0; k<EMA_DATA; k++){
      weights[k] /= weight_sum;
    }
}

void DistanceSensor::init(){
    calibration.init();

    if (!sensor.init())
    {
      Serial.println("Failed to detect and initialize sensor!");
      sensor_initialized = false;
      return;
    }
    sensor.startContinuous(sample_rate_ms);
    sensor_initialized = true;
}

void DistanceSensor::update(){
  if(!sensor_initialized) return;
    unsigned long current_time = millis();
    if(current_time - last_sample_time >= sample_rate_ms){
        last_distance = calibration.getCalibratedValue(sensor.readRangeContinuousMillimeters());
        data_array(last_distance);
        last_sample_time = current_time;
        xSemaphoreTake(filteredMutex, portMAX_DELAY);
        windowHead++;
        if(windowHead>=DISTANCE_WINDOW_SIZE) windowHead=0;
        filtered[windowHead] = ema();
        xSemaphoreGive(filteredMutex);
        for(int k=0; k<MAX_CALLBACKS; k++){
            if (callbacks[k] != nullptr) {
                callbacks[k](last_distance);
            }
        }
    }
}

void DistanceSensor::data_array(uint16_t last_distance){
    lastDistances[dataHead]=last_distance;
    dataHead++;
    if(dataHead>=EMA_DATA) dataHead=0;
}

float DistanceSensor::ema(){
    if(!sensor_initialized) return -1;
    float filtered = 0.0;
    for(int k=0; k<EMA_DATA; k++){
        filtered += lastDistances[(dataHead + k) % EMA_DATA] * weights[k];
    }
    return filtered;
}

uint16_t DistanceSensor::getDistance(){
    if(!sensor_initialized) return 0;
    return last_distance;
}

void DistanceSensor::addDistanceCallback(void (*callback)(uint16_t)){
    if(!sensor_initialized) return;

    if(!callback) return;

    // avoid duplicates
    for(int i = 0; i < MAX_CALLBACKS; ++i) {
      if(callbacks[i] == callback) return;
    }

    for(int i = 0; i < MAX_CALLBACKS; ++i) {
        if(callbacks[i] == nullptr) {
            callbacks[i] = callback;
            return;
        }
    }
}

void DistanceSensor::removeDistanceCallback(void (*callback)(uint16_t)){
    for (int i = 0; i < MAX_CALLBACKS; ++i) {
      if (callbacks[i] == callback) {
        callbacks[i] = nullptr;
      }
    }
}

