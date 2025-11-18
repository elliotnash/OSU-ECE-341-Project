#include "units.hpp"

static float convertMeterToUnit(float value, Unit to) {
  switch (to) {
    case Unit::Centimeter:
      return value * 100;
    case Unit::Millimeter:
      return value * 1000;
    case Unit::Inch:
      return value * 39.3701;
    case Unit::Foot:
      return value * 3.28084;
    default:
      return value;
  }
}

static float convertUnitToMeter(float value, Unit from) {
  switch (from) {
    case Unit::Centimeter:
      return value / 100;
    case Unit::Millimeter:
      return value / 1000;
    case Unit::Inch:
      return value / 39.3701;
    case Unit::Foot:
      return value / 3.28084;
    default:
      return value;
  }
}

float convertUnit(float value, Unit from, Unit to) {
  float meterValue = convertUnitToMeter(value, from);
  return convertMeterToUnit(meterValue, to);
}

String getUnitSymbol(Unit unit) {
  switch (unit) {
    case Unit::Meter:
      return "m";
    case Unit::Centimeter:
      return "cm";
    case Unit::Millimeter:
      return "mm";
    case Unit::Inch:
      return "in";
    case Unit::Foot:
      return "ft";
    default:
      return "";
  }
}

Unit getUnitForSymbol(String symbol) {
  if (symbol == "m") return Unit::Meter;
  if (symbol == "cm") return Unit::Centimeter;
  if (symbol == "mm") return Unit::Millimeter;
  if (symbol == "in") return Unit::Inch;
  if (symbol == "ft") return Unit::Foot;
  return Unit::Centimeter;
}
