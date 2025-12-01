#pragma once

#include <CSV_Parser.h>

class Calibration {
    private:
    CSV_Parser *parser;
    char *csv_data;
    float *distances;
    float *values;
    int rows;
    public:
    Calibration();
    ~Calibration();
    void init();
    float getCalibratedValue(float distance);
};
