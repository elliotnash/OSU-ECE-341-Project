import { render } from "preact";
import "./style.css";
import { ThemeProvider } from "./components/theme-provider";
import { Dashboard } from "./modules/dashboard";

export function App() {
  return (
    <ThemeProvider defaultTheme="system" storageKey="theme">
      <div class="min-h-screen bg-background text-foreground p-8">
        <h1 class="text-3xl font-semibold text-center mb-6">
          ESP32 Distance Sensor Dashboard
        </h1>
        <Dashboard />
      </div>
    </ThemeProvider>
  );
}

render(<App />, document.getElementById("app"));
