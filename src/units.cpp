#include "units.hpp"

static double convertMeterToUnit(double value, Unit to) {
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

static double convertUnitToMeter(double value, Unit from) {
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

double convertUnit(double value, Unit from, Unit to) {
  double meterValue = convertUnitToMeter(value, from);
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
