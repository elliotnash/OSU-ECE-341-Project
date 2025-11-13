# Dashboard

Web dashboard built with Preact and shadcn components for visualizing distance sensor data. The dashboard displays a graph of distance over time and provides controls for sensor configuration.

## Development

Install dependencies:
```bash
pnpm install
```

Start the development server (automatically starts the mock-server):
```bash
pnpm dev
```

The dashboard will be available at http://localhost:5173/

## Building

Build the dashboard for production:
```bash
pnpm build
```

This creates a single `index.html` file in `dist/` that is compressed with gzip and embedded in the ESP32 firmware during the main project build process.

Preview the production build locally:
```bash
pnpm preview
```
