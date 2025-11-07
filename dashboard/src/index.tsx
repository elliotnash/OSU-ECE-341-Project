import { render } from 'preact';
import './style.css';
import { Dashboard } from './modules/dashboard';

export function App() {
    return (
        <div class="min-h-screen bg-background text-foreground p-8">
            <h1 class="text-3xl font-semibold text-center mb-6">ESP32 Distance Sensor Dashboard</h1>
            <Dashboard />
        </div>
    );
}

render(<App />, document.getElementById('app'));
