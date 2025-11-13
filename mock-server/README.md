# Mock Server

Hono.js webserver that provides mock distance sensor data for local dashboard development. The server mimics the ESP32's WebSocket API, allowing the dashboard to be developed and tested without hardware.

## Development

Install dependencies:
```bash
pnpm install
```

Start the development server:
```bash
pnpm dev
```

The server will be available at http://localhost:3000 and provides:
- WebSocket endpoint for real-time distance updates
- HTTP endpoints matching the ESP32 API

The dashboard development server automatically starts the mock-server when running `pnpm dev` in the dashboard directory.
