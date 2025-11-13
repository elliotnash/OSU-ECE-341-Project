# ECE 341 Junior Design 1 Final Project

This project is a web-enabled distance sensor using an ESP32 microcontroller. The ESP32 reads distance measurements from a sensor, displays the current reading on an OLED display, and serves a web dashboard with distance data and controls.

## Project Structure

- `src/` - Main ESP32 firmware code
- `dashboard/` - Preact web dashboard (built and embedded in ESP32 flash)
- `mock-server/` - Hono.js mock server for local dashboard development
- `scripts/` - Build scripts for dashboard compilation and environment loading

## Getting Started

### Prerequisites

- PlatformIO IDE (available as a VSCode extension or CLion plugin)
- Node.js and pnpm (for dashboard and mock-server development)

### Environment Configuration

Before building, you must create a `.env` file in the project root. Copy `.env.example` to `.env` and configure the following variables:

```
WIFI_SSID="Your WiFi Network Name"
WIFI_PASSWORD="Your WiFi Password"
DISTANCE_WINDOW_SIZE=100
SENSOR_REFRESH_INTERVAL=100
```

If `WIFI_SSID` and `WIFI_PASSWORD` are not set, the ESP32 will run in Access Point (AP) mode.

### Selecting the Environment

This project supports three ESP32 board variants:
- `env:esp32-s3` - WaveShare ESP32-S3-Zero
- `env:esp32-wroom` - NodeMCU ESP32-WROOM-32D
- `env:esp32-c6-sm` - ESP32-C6 SuperMini

Select the environment using the "Pick Project Environment" command from:
- The PlatformIO menu (sidebar icon immediately to the right of "project tasks")
- The VSCode command palette (`CMD/CTRL + SHIFT + P`)

### Building the Project

Once you've selected an environment, build the project using the build button in the PlatformIO toolbar or the build command from the PlatformIO menu. The build process will:
1. Install Node.js dependencies
2. Load environment variables from `.env`
3. Build the dashboard to a single compressed HTML file
4. Embed the dashboard in the ESP32 firmware

### Uploading to ESP32

After building, upload the firmware to your ESP32 board using the upload button in the PlatformIO toolbar.

## Development

For local dashboard development, see the `dashboard/` and `mock-server/` directories for instructions on running the development environment.
