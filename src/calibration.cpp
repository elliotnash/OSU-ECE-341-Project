#include <CSV_Parser.h>
#include <cstdlib>
#include <cstring>
#include "calibration.hpp"

// These are pointers to the start and end of the compressed calibration.csv file (in flash memory)
// Embedded files are defined in platformio.ini and can be accessed via the assembly labels
// To read, read calibration_csv_end - calibration_csv_start bytes from calibration_csv_start
extern const uint8_t cal_csv_start[] asm("_binary_calibration_csv_start");
extern const uint8_t cal_csv_end[] asm("_binary_calibration_csv_end");

Calibration::Calibration() {
  this->parser = nullptr;
  this->csv_data = nullptr;
  this->distances = nullptr;
  this->values = nullptr;
  this->rows = 0;
}

Calibration::~Calibration() {
  if (this->parser != nullptr) {
    delete this->parser;
  }
  if (this->csv_data != nullptr) {
    free(this->csv_data);
  }
}

void Calibration::init() {
  this->parser = new CSV_Parser((const char*)cal_csv_start, "ff");

  this->distances = (float*)(*this->parser)["distance"];
  this->values = (float*)(*this->parser)["value"];

  this->rows = this->parser->getRowsCount();
}

float Calibration::getCalibratedValue(float distance) {
  // If smaller than the first calibration point, use the offset of the first point.
  if (distance < distances[0]) {
    float offset = values[0] - distances[0];
    return distance - offset;
  }

  // If between two calibration points, interpolate between them.
  for(int i = 0; i < rows; i++) {
    if(distance < distances[i]) {
      // Get the interpolated offset
      float range = distances[i] - distances[i-1];
      float offset1Weight = (distance - distances[i-1]) / range;
      float offset2Weight = 1 - offset1Weight;

      float offset = offset1Weight * (values[i-1] - distances[i-1]) + offset2Weight * (values[i] - distances[i]);

      return distance - offset;
    }
  }

  // If here, then the distance is larger than the last calibration point, use the offset of the last point.
  float offset = values[rows-1] - distances[rows-1];
  return distance - offset;
}
