#pragma once

#include <WString.h>

enum class Unit {
  Meter,
  Centimeter,
  Millimeter,
  Inch,
  Foot,
};

float convertUnit(float value, Unit from, Unit to);

String getUnitSymbol(Unit unit);
Unit getUnitForSymbol(String symbol);
