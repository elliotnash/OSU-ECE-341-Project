#pragma once

#include <WString.h>

enum class Unit {
  Meter,
  Centimeter,
  Millimeter,
  Inch,
  Foot,
};

double convertUnit(double value, Unit from, Unit to);

String getUnitSymbol(Unit unit);
