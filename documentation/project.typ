#import "template.typ": *
#import "@preview/subpar:0.2.2"
#import "@preview/zebraw:0.6.1": zebraw
#import "@preview/oxifmt:1.0.0": strfmt
#import "block-diagram.typ": *
#import "authors.typ": authors

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Project Title",
  authors: authors,
  team-number: "Team Number: 21"
)

#show: zebraw

#v(2em)

#show outline.entry.where(level: 1): strong
#show outline.entry.where(level: 3): emph
#outline(title: none, depth: 3)

#pagebreak()

= Video link <video-link>

#TODO[Put the link to the demonstration video here. Ensure it has sharing settings that allow the instructional team to view it]

= Team Member Work Distribution <team-member-work-distribution>

#let wd-name = (name) => [#authors.at(name).at("name") \ ID: #authors.at(name).at("id")]

#figure(table(
  columns: 3,
  align: left,
  table.header(
    [
      *Name* // Put the name of each member and their ID number in the cells below.
    ],
    [
      *Contributions* // Put a brief description of what tasks each member contributed to in the cells below.
    ],
    [
      *Hours worked (total)* // {Estimate and include the total hours worked by each team member on the team in the cells below.
    ],
  ),
  
  wd-name("yahir"),
  [Designed and built the power block hardware. Designed the 3d printed external case.],
  [#TODO[TBD]], 
  
  wd-name("oliver"),
  [Designed and built the distance sensor block. Wrote the distance data filtering algorithm.],
  [#TODO[TBD]],
  
  wd-name("elliot"),
  [Designed and built the display and dashboard blocks. Designed the 3d printed internal skeleton.],
  [15],
)) <work-dist-table>

= System Level Block Diagram <system-level-block-diagram>

#TODO[Create a system level block diagram with all system level interfaces labeled.]

#TODO[Fig. 1: System level block diagram for the portable sensor.]

= System Description <system-description>
#TODO[Describe what the system does, make sure to include the names and functions of all system level interfaces. Make sure the system level interfaces are created directly from the functionality described in the engineering requirements.]

= System Design Details and Validation <system-design-details-and-validation>
== Top Level Architecture <top-level-architecture>

#TODO[Insert figure here of the top-level architecture associated with your project. Make sure it includes the system level interfaces AND any internal interfaces.]

#figure(scale(system-diagram, reflow: true, 70%), caption: [Top level block diagram.]) <top-block-fig>

#TODO[Make sure to label all figures and include a thorough description of each.]

== Power Block Design Details, Yahir Raygoza Cortez <block-1-design-details-name-of-block-owner>

#TODO[Insert Block Design Document details for block 1 here. Include at a minimum the block diagram, description, interface validation table, and artifacts.]

#figure(scale(power-diagram, 150%, reflow: true), caption: [#TODO[CAPTION ME]]) <power-block-fig>

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  
  table.header(level: 2, table.cell(colspan: 3)[*outside\_power\_dcpwr: Input*]),
  
  [Vmin: 4.75V],
  [The tolerance range for input voltages of usb 1.0 is 5v +/- 5% @usb_spec_1_0],
  [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  
  [Vmax: 5.25V],
  [The tolerance range for input voltages of usb 1.0 is 5v +/- 5% @usb_spec_1_0],
  [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  
  [Inominal: 425mA],
  [The standard charging rate of our 850mAh battery is 0.5C @lipo_battery_803035],
  [We set our battery charging board to charge our 850mAh battery at 0.5C],
  
  [Ipeak: 500mA],
  [The maximum current draw for high power usb 1.0 decives is 500mA @usb_spec_1_0],
  [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],

  
  table.header(level: 2, table.cell(colspan:3)[*regulator_mcu_dcpwr: Output*]),
  
  [Vmin: 4.9V],
  [The minimum voltage output of the ncp1117 voltage regulator is 5v - 2% @ncp1117_datasheet],
  [The voltage regulator utilizes an NCP1117 IC that takes an input voltage of 6.5V to 12V which will convert it to a fixed output voltage of 4.9V minimum. This was verified through testing and is also specified in the datasheet @ncp1117_datasheet],
  
  [Vmax: 5.1V],
  [The maximum voltage output of the ncp1117 voltage regulator is 5v + 2% @ncp1117_datasheet],
  [The voltage regulator utilizes an NCP1117 IC that takes an input voltage of 6.5V to 12V which will convert it to a fixed output voltage of 5.1V maximum. This was verified through testing and is also specified in the datasheet @ncp1117_datasheet],
  
  [Inominal: 100mA],
  [The esp32 board draws an average current of 100mA @esp32_wroom_32_datasheet],
  [The ncp1117 can supply a maximum current of 800mA @ncp1117_datasheet, and the lipo battery can supply a maximum of 1C of discharge (850mA) @lipo_battery_803035, which will be used by the buck converter to increase the voltage from 5v to 7v, and decrease the current by the same ratio (1.4), so the power block supplies 600mA], 
  
  [Ipeak: 500mA],
  [The esp32 board draws a maximum current of 500mA @esp32_wroom_32_datasheet],
  [The ncp1117 can supply a maximum current of 800mA @ncp1117_datasheet, and the lipo battery can supply a maximum of 1C of discharge (850mA) @lipo_battery_803035, which will be used by the buck converter to increase the voltage from 5v to 7v, and decrease the current by the same ratio (1.4), so the power block supplies 600mA]
))

=== Artifacts
#figure(image("images/LinearRegulator.svg"), caption: [Linear Voltage Regulator Circuit Layout])

=== Description
The Power Block is a highly customized, multi-stage energy management system designed for robust operation with a 1-cell LiPo battery. This circuitry guarantees stable power delivery across the system while safely managing the battery charge cycle. 

=== Theory of Operation
The block begins with a dedicated LiPo Charger that safely manages the incoming 5V external input (typically from USB) to control the voltage and current flow for the battery. For system operation, the varying voltage of the 1-cell LiPo battery (approx. 3.7V to 4.2V) is first sent through a Boost Converter that actively upconverts the voltage to an intermediate 7.5V. This 7.5V is then fed into a highly efficient Buck Converter that downconverts the voltage to a stable 5V, which is supplied as the primary input to the ESP32 development board. Finally, the 5V is channeled through the ESP32's internal Linear Voltage Regulator (LDO), which performs the final regulation step to produce the required, highly stable 3.3V operating rail. This intricate, stepped conversion process ensures the 3.3V rail remains constant (within the 3.0V to 3.6V tolerance) and possesses sufficient current capacity to reliably power the ESP32-C6 MCU—which demands up to 354 mA peak current—along with the external sensor and display loads.

== MCU Block Design Details, Oliver Siemens <block-2-design-details-name-of-block-owner>

#TODO[Insert Block Design Document details for block 2 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.]

#figure(scale(mcu-diagram, 150%, reflow: true), caption: [#TODO[CAPTION ME]]) <mcu-block-fig>

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  
  table.header(level: 2, table.cell(colspan: 3)[*regulator_mcu_dcpwr: Input*]),
  [Vmin: 4.9V],
  [The minimum voltage output of the ncp1117 voltage regulator is 5v - 2% @ncp1117_datasheet],
  [The voltage regulator utilizes an NCP1117 IC that takes an input voltage of 6.5V to 12V which will convert it to a fixed output voltage of 4.9V minimum. This was verified through testing and is also specified in the datasheet @ncp1117_datasheet],
  
  [Vmax: 5.1V],
  [The maximum voltage output of the ncp1117 voltage regulator is 5v + 2% @ncp1117_datasheet],
  [The voltage regulator utilizes an NCP1117 IC that takes an input voltage of 6.5V to 12V which will convert it to a fixed output voltage of 5.1V maximum. This was verified through testing and is also specified in the datasheet @ncp1117_datasheet],
  
  [Inominal: 100mA],
  [The esp32 board draws an average current of 100mA @esp32_wroom_32_datasheet],
  [The ncp1117 can supply a maximum current of 800mA @ncp1117_datasheet, and the lipo battery can supply a maximum of 1C of discharge (850mA) @lipo_battery_803035, which will be used by the buck converter to increase the voltage from 5v to 7v, and decrease the current by the same ratio (1.4), so the power block supplies 600mA], 
  
  [Ipeak: 500mA],
  [The esp32 board draws a maximum current of 500mA @esp32_wroom_32_datasheet],
  [The ncp1117 can supply a maximum current of 800mA @ncp1117_datasheet, and the lipo battery can supply a maximum of 1C of discharge (850mA) @lipo_battery_803035, which will be used by the buck converter to increase the voltage from 5v to 7v, and decrease the current by the same ratio (1.4), so the power block supplies 600mA],
  table.header(level: 2, table.cell(colspan: 3)[*sensor_mcu_comm: I/O*]),
  [Protocol: I2C],[I2C is the only communication protocol that the GY-530 supports @gy530_datasheet],[Our code defines the communication protocol that the esp32 c6 supermini uses, which we have set to be I2C @gh_repo],
  [Baud rate: 100kHz],[This is the default baud rate for the arduino wire library],[Our code uses the default baud rate defined by the arduino wire library @gh_repo],
  table.header(level: 2, table.cell(colspan: 3)[*mcu_sensor_dcpwr: Output*]),
  [Vmin: 3.234v],
  [The 3.3v voltage regulator on the esp32 c6 supermini has a range of - 2% @me6211_datasheet],
  [The onboard voltage regulator on the esp32 c6 supermini board is a ME6211C33. The ME6211C33 has an output range of +/- 2% when the regulated output voltage is greater than 2v.@me6211_datasheet],
  
  [Vmax: 3.366v],
  [The 3.3v voltage regulator on the esp32 c6 supermini has a range of + 2% @me6211_datasheet],
  [The onboard voltage regulator on the esp32 c6 supermini board is a ME6211C33. The ME6211C33 has an output range of +/- 2% when the regulated output voltage is greater than 2v.@me6211_datasheet],
  
  [Inominal: $5 mu$A],[The GY-530 has a nominal current draw of $5 mu$A when it is idle @gy530_datasheet],[The onboard voltage regulator on the esp32 c6 supermini board can supply up to 500mA @me6211_datasheet, and the maximum current draw for board is 354mA @esp32_c6_sm, leaving plenty of current headroom for the sensor.],
  [Ipeak: 6mA],[The GY-530 has a peak current draw of 6mA when it is reading data @gy530_datasheet],[The onboard voltage regulator on the esp32 c6 supermini board can supply up to 500mA @me6211_datasheet, and the maximum current draw for board is 354mA @esp32_c6_sm, leaving plenty of current headroom for the sensor.],
  table.header(level: 2, table.cell(colspan: 3)[*mcu_display_comm: I/O*]),
  [Protocol: I2C],[The ssd1306 display driver we used only supports I2C @ssd1306_datasheet],[Our code defines the communication protocol that the esp32 c6 supermini uses, which we have set to be I2C @gh_repo],
  [Baud rate: 100kHz],[This is the default baud rate for the arduino wire library],[Our code uses the default baud rate defined by the arduino wire library @gh_repo],
  table.header(level: 2, table.cell(colspan: 3)[*mcu_display_dcpwr: Output*]),
  [Vmin: 3.234v],
  [The 3.3v voltage regulator on the esp32 c6 supermini has a range of - 2% @me6211_datasheet],
  [The onboard voltage regulator on the esp32 c6 supermini board is a ME6211C33. The ME6211C33 has an output range of +/- 2% when the regulated output voltage is greater than 2v.@me6211_datasheet],
  
  [Vmax: 3.366v],
  [The 3.3v voltage regulator on the esp32 c6 supermini has a range of + 2% @me6211_datasheet],
  [The onboard voltage regulator on the esp32 c6 supermini board is a ME6211C33. The ME6211C33 has an output range of +/- 2% when the regulated output voltage is greater than 2v.@me6211_datasheet],
  
  [Inominal: 4.73mA],[The typical current draw for the display at 50% illuminated is 4.3mA @ug2832_datasheet. The typical current draw for the display controller is $430mu$A @ssd1306_datasheet, so the total nominal current is 4.73mA],[The onboard voltage regulator on the esp32 c6 supermini board can supply up to 500mA @me6211_datasheet, and the maximum current draw for board is 354mA @esp32_c6_sm, leaving plenty of current headroom for the display.],
  [Ipeak: 6.18mA],[The max current draw for the display at 50% illuminated is 5.4mA @ug2832_datasheet. The max current draw for the display controller is $780mu$A @ssd1306_datasheet, so the total peak current is 6.18mA],[The onboard voltage regulator on the esp32 c6 supermini board can supply up to 500mA @me6211_datasheet, and the maximum current draw for board is 354mA @esp32_c6_sm, leaving plenty of current headroom for the display.],
 
))

=== Artifacts
#figure(```c
/* This example shows how to use continuous mode to take
range measurements with the VL53L0X. It is based on
vl53l0x_ContinuousRanging_Example.c from the VL53L0X API.

The range readings are in units of mm. */

#include <Wire.h>
#include <VL53L0X.h>

VL53L0X sensor;

void setup()
{
  Serial.begin(9600);
  Wire.begin();

  sensor.setTimeout(500);
  if (!sensor.init())
  {
    Serial.println("Failed to detect and initialize sensor!");
    while (1) {}
  }

  // Start continuous back-to-back mode (take readings as
  // fast as possible).  To use continuous timed mode
  // instead, provide a desired inter-measurement period in
  // ms (e.g. sensor.startContinuous(100)).
  sensor.startContinuous();
}

void loop()
{
  Serial.print(sensor.readRangeContinuousMillimeters());
  if (sensor.timeoutOccurred()) { Serial.print(" TIMEOUT"); }

  Serial.println();
}
```, caption: [Sensor library code example #cite(<pololu_vl53l0x_lib>, supplement: [Examples/Continuous/Continuous.ino])]) <sensorlibrary-code>

#figure(```c
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 32 // OLED display height, in pixels

#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

void setup() {
  Serial.begin(9600);

  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }

void testdrawchar(void) {
  display.clearDisplay();

  display.setTextSize(1);      // Normal 1:1 pixel scale
  display.setTextColor(SSD1306_WHITE); // Draw white text
  display.setCursor(0, 0);     // Start at top-left corner
  display.cp437(true);         // Use full 256 char 'Code Page 437' font

  // Not all the characters will fit on the display. This is normal.
  // Library will draw what it can and the rest will be clipped.
  for(int16_t i=0; i<256; i++) {
    if(i == '\n') display.write(' ');
    else          display.write(i);
  }

  display.display();
  delay(2000);
}
```, caption: [Display library code example #cite(<adafruit_ssd1306_lib>, supplement: [Examples/ssd1306_128x32_i2c/ssd1306_128x32_i2c.ino])]) <displaylibrary-code>

=== Description
The MCU block (ESP32-C6) is the central processing unit and control system for the application. Its core function is to manage data acquisition, processing, and output. 

=== Theory of Operation
The MCU begins by initializing the I2C communication bus and acting as the 3.3V power source for the external sensor and display modules. The MCU continuously runs a data loop: it communicates with the sensor to read the raw distance measurement, applies custom calibration factors, and then feeds the resulting value into the Exponentially Weighted Moving Average (EWMA) filter to generate a stable, smooth reading. This final, polished data is then sent to the OLED display for visualization and simultaneously distributed to other software components via registered callbacks for real-time responsiveness.

== Display Block Design Details, Elliot Nash <block-3-design-details-name-of-block-owner>

#TODO[Insert Block Design Document details for block 3 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.]

#figure(scale(display-diagram, 150%, reflow: true), caption: [#TODO[CAPTION ME]]) <display-block-fig>

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  table.header(level: 2, table.cell(colspan: 3)[*mcu_display_dcpwr: Input*]),
  [Vmin: 3.234v],
  [The 3.3v voltage regulator on the esp32 c6 supermini has a range of - 2% @me6211_datasheet],
  [The onboard voltage regulator on the esp32 c6 supermini board is a ME6211C33. The ME6211C33 has an output range of +/- 2% when the regulated output voltage is greater than 2v.@me6211_datasheet],
  
  [Vmax: 3.366v],
  [The 3.3v voltage regulator on the esp32 c6 supermini has a range of + 2% @me6211_datasheet],
  [The onboard voltage regulator on the esp32 c6 supermini board is a ME6211C33. The ME6211C33 has an output range of +/- 2% when the regulated output voltage is greater than 2v.@me6211_datasheet],
  
  [Inominal: 4.73mA],[The typical current draw for the display at 50% illuminated is 4.3mA @ug2832_datasheet. The typical current draw for the display controller is $430mu$A @ssd1306_datasheet, so the total nominal current is 4.73mA],[The onboard voltage regulator on the esp32 c6 supermini board can supply up to 500mA @me6211_datasheet, and the maximum current draw for board is 354mA @esp32_c6_sm, leaving plenty of current headroom for the display.],
  [Ipeak: 6.18mA],[The max current draw for the display at 50% illuminated is 5.4mA @ug2832_datasheet. The max current draw for the display controller is $780mu$A @ssd1306_datasheet, so the total peak current is 6.18mA],[The onboard voltage regulator on the esp32 c6 supermini board can supply up to 500mA @me6211_datasheet, and the maximum current draw for board is 354mA @esp32_c6_sm, leaving plenty of current headroom for the display.],
  table.header(level: 2, table.cell(colspan: 3)[*mcu_display_comm: I/O*]),
  [Protocol: I2C],[The ssd1306 display driver we used only supports I2C @ssd1306_datasheet],[Our code defines the communication protocol that the esp32 c6 supermini uses, which we have set to be I2C @gh_repo],
  [Baud rate: 100kHz],[This is the default baud rate for the arduino wire library],[Our code uses the default baud rate defined by the arduino wire library @gh_repo],
  table.header(level: 2, table.cell(colspan: 3)[*display_outside_usrout: Output*]),
    [Units: mm, cm, m, ft, in],
  [These are common units the user may want the distance displayed in], [Our code allows for the distance to be displayed in these units],
  
  [Maximum distance: 1200mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 1.2m away],
  
  [Minimum distance: 100mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions], [Our device can accurately measure distances 100cm away],
))
=== Artifacts

=== Description
The display block uses an oled display board to display the distance and unit of measurement to the user. The display takes a user input (the unit to display the distance in), and gives a user output (it displays the measured distance and the units).

=== Theory of Operation
The display board is typically built around a driver IC like the SSD1306. The boards operation is purely passive until commanded by the MCU block. The MCU acts as the graphics processor, first rendering the filtered distance data and interface elements, then transmitting this pixel data to the Display Block over I2C. The display controller then displays the pixel data on the oled display.

== Distance Sensor Block Design Details, Oliver Siemens <block-4-design-details-name-of-block-owner>

#TODO[Insert Block Design Document details for block 4 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.]

#figure(scale(distance-diagram, 150%, reflow: true), caption: [#TODO[CAPTION ME]]) <distance-block-fig>

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  
  table.header(level: 2, table.cell(colspan: 3)[*mcu_sensor_dcpwr: Input*]),
  
  [Vmin: 3.234v],
  [The 3.3v voltage regulator on the esp32 c6 supermini has a range of - 2% @me6211_datasheet],
  [The onboard voltage regulator on the esp32 c6 supermini board is a ME6211C33. The ME6211C33 has an output range of +/- 2% when the regulated output voltage is greater than 2v.@me6211_datasheet],
  
  [Vmax: 3.366v],
  [The 3.3v voltage regulator on the esp32 c6 supermini has a range of + 2% @me6211_datasheet],
  [The onboard voltage regulator on the esp32 c6 supermini board is a ME6211C33. The ME6211C33 has an output range of +/- 2% when the regulated output voltage is greater than 2v.@me6211_datasheet],
  
  [Inominal: $5 mu$A],[The GY-530 has a nominal current draw of $5 mu$A when it is idle @gy530_datasheet],[The onboard voltage regulator on the esp32 c6 supermini board can supply up to 500mA @me6211_datasheet, and the maximum current draw for board is 354mA @esp32_c6_sm, leaving plenty of current headroom for the sensor.],
  [Ipeak: 6mA],[The GY-530 has a peak current draw of 6mA when it is reading data @gy530_datasheet],[The onboard voltage regulator on the esp32 c6 supermini board can supply up to 500mA @me6211_datasheet, and the maximum current draw for board is 354mA @esp32_c6_sm, leaving plenty of current headroom for the sensor.],
 
  table.header(level: 2, table.cell(colspan: 3)[*mcu_sensor_comm: I/O*]),
  
  [Protocol: I2C],[I2C is the only communication protocol that the GY-530 supports @gy530_datasheet],[Our code defines the communication protocol that the esp32 c6 supermini uses, which we have set to be I2C @gh_repo],
  [Baud rate: 100kHz],[This is the default baud rate for the arduino wire library],[Our code uses the default baud rate defined by the arduino wire library @gh_repo],

  table.header(level: 2, table.cell(colspan: 3)[*outside_sensor_envin: Input*]),
  [Maximum distance: 1200mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 1.2m away],
  
  [Minimum distance: 100mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 100cm away],
))

=== Artifacts
#figure(zebraw(lang: [Pseudocode], ```p
FUNCTION Calculate_Simple_Weighted_Average(PastDistances, WindowSize):

// --- Step 1: Figure out the 'Importance' (The Weights) ---

// The code first calculates a set of special weights (coefficients).
// Newest data points get the biggest weights, and
// older data points get smaller weights that decay exponentially.

// Then, all these weights are adjusted so they add up perfectly to 1.0.

DECLARE FilteredResult as FLOAT = 0.0

// --- Step 2: Calculate the Result ---

// Now, go through every distance reading in your recorded history window.
FOR EACH reading IN PastDistances:
    
    // Multiply the distance reading by its matching "importance" weight.
    // (Newest readings are multiplied by the biggest weights.)
    
    // Add that weighted result to your total.
    FilteredResult = FilteredResult + (reading \* weight)
END FOR

// The final total is your smooth, filtered reading!
RETURN FilteredResult


END FUNCTION
```), caption: [Pseudo-code for EMA filtering]) <filter-code>

=== Description

The sensor block encompasses the distance measurement sensor and the corresponding code for initialization, control, and communication. Data transfer to the microcontroller is handled through the I2C communication protocol, utilizing the SCL and SDA lines. Power for the sensor is sourced from the MCU block via the stable 3.3V output pin on the ESP32-C6 SuperMini board. Its primary function is to measure and provide external environmental data (distance).

=== Theory of Operation

The Sensor Block operates using time-of-flight (ToF) measurement, which uses emitted light to calculate the distance to an object. The core function is initiated by the microcontroller Unit (mcu) through the I2C interface, utilizing the SCL (clock) and SDA (data) lines for command and control. First, the sensor emits an invisible light pulse, then it precisely measures the time until the reflected light pulse returns to the receiver. Using the known speed of light, the sensor's internal circuitry calculates the raw distance to the target. This raw measurement is then immediately stored in the sensor's internal memory registers and is concurrently accessed by the MCU via a standard I2C read transaction. The entire process is continuous and periodic, driven by the sampling rate configured during initialization, allowing the block to provide real-time environmental data to the main system.


== Dashboard Block Design Details, Elliot Nash <block-5-design-details-name-of-block-owner>

#figure(scale(dashboard-diagram, 150%, reflow: true), caption: [#TODO[CAPTION ME]]) <dashboard-block-fig>

#TODO[Insert Block Design Document details for block 5 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.]

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  table.header(level: 2, table.cell(colspan: 3)[*outside_dashboard_usrin : Input*]),
  [Units: mm, cm, m, ft, in],
  [These are common units the user may want the distance displayed in], [Our code allows for the distance to be displayed in these units],
  table.header(level: 2, table.cell(colspan: 3)[*dashboard_outside_usrout : Output*]),
  [Units: mm, cm, m, ft, in],
  [These are common units the user may want the distance displayed in], [Our code allows for the distance to be displayed in these units],
  
  [Maximum distance: 1200mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 1.2m away],
  
  [Minimum distance: 100mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 100cm away],

  table.header(level: 2, table.cell(colspan: 3)[*mcu_dashboard_rf: Input*]),
  [],[],[],
))

=== Artifacts

=== Description

=== Theory of Operation

= System Level Interface Validation Table <system-level-interface-validation-table>

#TODO[Be sure to include only system-level interfaces. System-level interface values and properties must match their corresponding block-level interfaces.]

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  
  table.header(level: 2, table.cell(colspan: 3)[*outside\_power\_dcpwr: Input*]),
  
  [Vmin: 4.75V],
  [The tolerance range for input voltages of usb 1.0 is 5v +/- 5% @usb_spec_1_0],
  [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
 
  [Vmax: 5.25V],
  [The tolerance range for input voltages of usb 1.0 is 5v +/- 5% @usb_spec_1_0],
  [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  
  [Inominal: 425mA],
  [The standard charging rate of our 850mAh battery is 0.5C @lipo_battery_803035],
  [We set our battery charging board to charge our 850mAh battery at 0.5C],
  
  [Ipeak: 500mA],
  [The maximum current draw for high power usb 1.0 decives is 500mA @usb_spec_1_0],
  [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],

  
  table.header(level: 2, table.cell(colspan:3)[*outside_sensor_envin*]),
  
  [Maximum distance: 1200mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 1.2m away],
  
  [Minimum distance: 100mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 100cm away],

  
  table.header(level: 2, table.cell(colspan:3)[*display\_outside\_usrout: Output*]),
  
  [Units: mm, cm, m, ft, in],
  [These are common units the user may want the distance displayed in], [Our code allows for the distance to be displayed in these units],
  
  [Maximum distance: 1200mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 1.2m away],
  
  [Minimum distance: 100mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions], [Our device can accurately measure distances 100cm away],

  
  table.header(level: 2, table.cell(colspan:3)[*dashboard_outside_usrout: Output*]),
  
  [Units: mm, cm, m, ft, in],
  [These are common units the user may want the distance displayed in], [Our code allows for the distance to be displayed in these units],
  
  [Maximum distance: 1200mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 1.2m away],
  
  [Minimum distance: 100mm],
  [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions],
  [Our device can accurately measure distances 100cm away],
))

= Engineering Requirements <engineering-requirements>

+ The system must be battery operated.

+ The system must sense distances from 0.1m to 1.2m with a margin of error no greater than $plus.minus 10%$.

+ The system will visually display the current distance value and unit.

= Verification Process <verification-process>

#TODO[Enumerate a verification process here that any junior in the class could follow. Be as specific and expository as possible. Use prior lab documentation to guide your verification process. Imagine this process was handed to another team to complete who did not design your system. Write instructions they could follow]

== ER 1 Verification

=== Requirement

The system must be battery operated.

=== Objective 

Confirm the device functions without external power delivery.

=== Process

1. Disconnect Power: Visually inspect the sensor and ensure all USB cables are unplugged. The device should be completely isolated from grid power.

2. Engage Power Switch: Flip the power switch to the ON position.

3. Observe Boot Sequence: Watch the display.

=== Pass Condition 

The screen illuminates and displays the text "Booting", followed by a transition to the measurement screen where the current distance and unit are displayed.

=== Fail Condition

The screen remains black or does not display the current distance and unit.

== ER 2 Verification:

=== Requirement

The system must sense distances from 0.1m to 1.2m with a margin of error no greater than $plus.minus 10%$.

=== Objective

Quantify the accuracy of the sensor across the required range.

=== Procedure

+ Unfold the paper ruler with markings every 0.05m and place it on a flat surface.

+ Place the distance sensor on a box to ensure the ground is not in its field of view, and line up the front with the 0m mark.

+ Attach an item to prop up the soldering station board and place it on the paper ruler so its face is exactly at the 0.1m mark. 

+ Ensure the board is perpendicular (90 degrees) to the sensor.

+ Wait 5 seconds for the reading to stabilize.

+ Record the value displayed on the screen in the table below.

+ Repeat steps 3-6 for 0.5m, 0.8m, and 1.2m. 


=== Calculation

For each test point, calculate the Percent Error using the following formula:

$ "%Error" = abs(("Measued Value" - "Actual Distance")/"Actual Distance") times 100  $

=== Data Table

#let ver2-table = (data) => {
  let calc-data = data.map(e => {
    let error = (e.at(2) - e.at(1))/e.at(1) * 100
    let pass-color = red
    if (calc.abs(error) <= 10) {
      pass-color = green
    }
    (e.at(0), str(e.at(1)), str(e.at(2)), strfmt("{:.2}", error), table.cell(fill: pass-color)[])
  })
  table(
    columns: 5,
    table.header([*Test Point*], [*Actual Distance (m)*], [*Measured Distance (m)*], [*% Error*], [*Pass / Fail*]),
    ..calc-data.flatten()
  )
}

#figure(ver2-table((
  ([Min Range], 0.1, 0),
  ([Mid Range 1], 0.5, 0),
  ([Mid Range 2], 0.8, 0),
  ([Max Range], 1.2, 0),
)), caption: [#TODO[CAPTION ME]])

=== Pass Condition

The calculated % Error for all four test points is ≤10%.

=== Fail Condition

Any single test point exceeds 10% error.

== ER 3 Verification:

=== Requirement 

The system will visually display the current distance value and unit.

=== Objective 

Confirm the user interface provides distance data to the user.

=== Prodedure 

+ Powered on the system and place a target in range:

+ Verify that a numeric value is visible and a unit of measurement (e.g., "cm", "mm", "m", or "in") is displayed next to the number.

+ Slowly move the target closer/farther from the sensor

+ Observe the screen while moving the target.

=== Pass Condition

The numeric value is visible and updates in real-time to reflect the movement, and the unit label remains visible.

=== Fail condition

Either the numeric value is not displayed or updated, or the unit label is not visible.

= Artifacts <artifacts>

#TODO[Populate this section with the miscellaneous but important findings that got you to your final system. This can be prior lab work, examples found online, reference schematics, pseudocode, previous or prior version block diagrams, etc.]

#subpar.grid(
  figure(image("images/dashboard/dash_light.png"), caption: [Light dashboard]), <a>,
  figure(image("images/dashboard/dash_dark.png"), caption: [Dark dashboard]), <b>,
  columns: (1fr, 1fr),
  caption: [A figure composed of two sub figures.],
  label: <full>,
)

#TODO[Oliver: Talk about filter algorithm]

#TODO[Elliot: Talk about calibration]

#TODO[3D print photos]

// Include all relevant IEEE citations.

// Cite everything you did not create yourself for this document. This includes but is not limited to diagrams, schematics, pseudocode/code, pinout visuals, etc.

#bibliography("references.yaml", title: [References]) <references>
