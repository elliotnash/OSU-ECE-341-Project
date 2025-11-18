/**
 * Utility enum class for units of measurement.
 */
export class Unit {
  static readonly METER = new Unit("Meter", "m", 1, 3);
  static readonly CENTIMETER = new Unit("Centimeter", "cm", 100, 1);
  static readonly MILLIMETER = new Unit("Millimeter", "mm", 1000, 0);
  static readonly INCH = new Unit("Inch", "in", 39.3701, 2);
  static readonly FOOT = new Unit("Foot", "ft", 3.28084, 3);

  private constructor(public readonly name: string, public readonly symbol: string, public readonly conversionFactor: number, public readonly displayDecimals: number) {}

  /**
   * Get a unit from a symbol.
   *
   * @param symbol - The symbol to get the unit for.
   * @returns The unit
   */
  public static fromSymbol(symbol: "m" | "cm" | "mm" | "in" | "ft"): Unit {
    return Object.values(Unit).find(u => u.symbol === symbol);
  }

  /**
   * Helper method to convert a value from this unit to another.
   *
   * @param to - The unit to convert to.
   * @param value - The value to convert.
   * @returns The converted value.
   */
  public convertTo(to: Unit, value: number): number {
    return convertUnit(value, this, to);
  }

  /**
   * Helper method to convert a value from another unit to this unit.
   *
   * @param from - The unit to convert from.
   * @param value - The value to convert.
   * @returns The converted value.
   */
  public convertFrom(from: Unit, value: number): number {
    return convertUnit(value, from, this);
  }

  public toString(): string {
    return this.symbol;
  }
}

/**
 * Convert a value from one unit to another.
 *
 * @param value - The value to convert.
 * @param from - The unit to convert from.
 * @param to - The unit to convert to.
 * @returns The converted value.
 */
export function convertUnit(value: number, from: Unit, to: Unit): number {
  return value * to.conversionFactor / from.conversionFactor;
}
