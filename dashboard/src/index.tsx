import { render } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import './style.css';
import { Dashboard } from './modules/Dashboard';

function useTheme() {
    const [theme, setTheme] = useState<'light' | 'dark' | 'system'>(() => {
        const stored = localStorage.getItem('theme');
        return (stored as any) || 'system';
    });
    useEffect(() => {
        const apply = (t: 'light' | 'dark') => {
            document.documentElement.setAttribute('data-theme', t === 'dark' ? 'dark' : 'light');
        };
        if (theme === 'system') {
            const mq = window.matchMedia('(prefers-color-scheme: dark)');
            apply(mq.matches ? 'dark' : 'light');
            const onChange = (e: MediaQueryListEvent) => apply(e.matches ? 'dark' : 'light');
            mq.addEventListener('change', onChange);
            return () => mq.removeEventListener('change', onChange);
        } else {
            apply(theme);
        }
    }, [theme]);
    useEffect(() => {
        if (theme === 'system') localStorage.removeItem('theme');
        else localStorage.setItem('theme', theme);
    }, [theme]);
    return { theme, setTheme } as const;
}

function ThemeToggle() {
    const { theme, setTheme } = useTheme();
    return (
        <div class="flex items-center justify-end gap-2 mb-6">
            <button
                class="px-3 py-1.5 rounded-lg border border-border text-sm bg-card text-foreground hover:opacity-90"
                onClick={() => setTheme('light')}
                aria-pressed={theme === 'light'}
            >
                Light
            </button>
            <button
                class="px-3 py-1.5 rounded-lg border border-border text-sm bg-card text-foreground hover:opacity-90"
                onClick={() => setTheme('dark')}
                aria-pressed={theme === 'dark'}
            >
                Dark
            </button>
            <button
                class="px-3 py-1.5 rounded-lg border border-border text-sm bg-card text-foreground hover:opacity-90"
                onClick={() => setTheme('system')}
                aria-pressed={theme === 'system'}
            >
                System
            </button>
        </div>
    );
}

export function App() {
    return (
        <div class="min-h-screen bg-background text-foreground p-8">
            <h1 class="text-3xl font-semibold text-center mb-6">ESP32 Distance Sensor Dashboard</h1>
            <ThemeToggle />
            <Dashboard />
        </div>
    );
}

render(<App />, document.getElementById('app'));
