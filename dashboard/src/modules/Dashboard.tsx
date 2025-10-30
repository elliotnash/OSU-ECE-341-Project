import { useEffect, useMemo, useRef, useState } from 'preact/hooks';
import { LineChart, type LineChartOptions } from 'chartist';

type AlarmType = 'greater' | 'less';

type DataPoint = {
    timeLabel: string;
    valueCm: number;
};

const SAMPLE_RATE_HZ = 10;
const BUFFER_SIZE = 100;

function formatNow(): string {
    return new Date().toLocaleTimeString();
}

function cmToInches(valueCm: number): number {
    return valueCm / 2.54;
}

export function Dashboard() {
    const [unit, setUnit] = useState<'cm' | 'in'>('cm');
    const [alarmType, setAlarmType] = useState<AlarmType>('greater');
    const [alarmValue, setAlarmValue] = useState<number | ''>('');
    const [points, setPoints] = useState<DataPoint[]>([]);

    // Build a 100-sample buffer of DataPoint from raw cm values (last value most recent)
    function buildPointsFromArray(valuesCm: number[]): DataPoint[] {
        const intervalMs = Math.round(1000 / SAMPLE_RATE_HZ);
        const now = Date.now();
        const len = valuesCm.length;
        const pts: DataPoint[] = new Array(len);
        for (let i = 0; i < len; i++) {
            const t = now - (len - 1 - i) * intervalMs;
            pts[i] = { timeLabel: new Date(t).toLocaleTimeString(), valueCm: valuesCm[i] };
        }
        return pts;
    }

    // Connect to WebSocket /ws and handle incoming data
    useEffect(() => {
        const protocol = location.protocol === 'https:' ? 'wss' : 'ws';
        const url = `${protocol}://${location.host}/ws`;
        const socket = new WebSocket(url);

        socket.onmessage = (event) => {
            try {
                const msg = JSON.parse(event.data);
                if (msg?.event === 'data' && Array.isArray(msg.data)) {
                    // Replace entire buffer
                    const values = (msg.data as number[]).slice(-BUFFER_SIZE);
                    setPoints(buildPointsFromArray(values));
                } else if (msg?.event === 'update' && typeof msg.data === 'number') {
                    // Append new sample and trim to 100
                    setPoints(prev => {
                        const nextPoint: DataPoint = { timeLabel: formatNow(), valueCm: msg.data as number };
                        if (prev.length === 0) return [nextPoint];
                        const updated = [...prev, nextPoint];
                        if (updated.length > BUFFER_SIZE) updated.shift();
                        return updated;
                    });
                }
            } catch {
                // ignore malformed messages
            }
        };

        return () => {
            try { socket.close(); } catch {}
        };
    }, []);

    const latestDisplayValue = useMemo(() => {
        const last = points[points.length - 1]?.valueCm ?? null;
        if (last == null) return null;
        return unit === 'in' ? cmToInches(last) : last;
    }, [points, unit]);

    const thresholdTriggered = useMemo(() => {
        if (alarmValue === '' || points.length === 0) return false;
        const lastCm = points[points.length - 1].valueCm;
        const lastIn = cmToInches(lastCm);
        const last = unit === 'in' ? lastIn : lastCm;
        const threshold = alarmValue as number;
        if (alarmType === 'greater') return last > threshold;
        return last < threshold;
    }, [alarmValue, alarmType, points, unit]);

    // points are now driven by websocket messages

    return (
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-5xl mx-auto">
            <DistanceCard
                unit={unit}
                value={latestDisplayValue}
                onUnitChange={setUnit}
            />
            <AlarmSettings
                unit={unit}
                alarmType={alarmType}
                alarmValue={alarmValue}
                onAlarmTypeChange={setAlarmType}
                onAlarmValueChange={setAlarmValue}
                triggered={thresholdTriggered}
            />
            <ChartCard unit={unit} points={points} />
        </div>
    );
}

function Card(props: { children: preact.ComponentChildren; class?: string }) {
    return (
        <div class={`bg-card rounded-2xl shadow-md p-6 border border-border ${props.class ?? ''}`}>{props.children}</div>
    );
}

function DistanceCard(props: {
    unit: 'cm' | 'in';
    value: number | null;
    onUnitChange: (u: 'cm' | 'in') => void;
}) {
    return (
        <Card>
            <div class="uppercase text-xs tracking-wide text-muted-foreground text-center">Current Distance</div>
            <div class="text-5xl font-bold text-center my-4">
                {props.value == null ? '--' : props.value.toFixed(1)} {props.unit}
            </div>
            <div class="flex flex-col gap-2">
                <label class="text-sm" for="unitSelect">Units</label>
                <select
                    id="unitSelect"
                    class="border border-border bg-background text-foreground rounded-xl px-3 py-2"
                    value={props.unit}
                    onInput={(e: any) => props.onUnitChange((e.currentTarget.value as 'cm' | 'in'))}
                >
                    <option value="cm">Centimeters</option>
                    <option value="in">Inches</option>
                </select>
            </div>
        </Card>
    );
}

function AlarmSettings(props: {
    unit: 'cm' | 'in';
    alarmType: AlarmType;
    alarmValue: number | '';
    onAlarmTypeChange: (t: AlarmType) => void;
    onAlarmValueChange: (v: number | '') => void;
    triggered: boolean;
}) {
    return (
        <Card>
            <div class="uppercase text-xs tracking-wide text-muted-foreground text-center">Alarm Settings</div>
            <div class="flex flex-col gap-3 mt-4">
                <div class="flex flex-col gap-2">
                    <label class="text-sm" for="alarmType">Alarm Type</label>
                    <select
                        id="alarmType"
                        class="border border-border bg-background text-foreground rounded-xl px-3 py-2"
                        value={props.alarmType}
                        onInput={(e: any) => props.onAlarmTypeChange(e.currentTarget.value as AlarmType)}
                    >
                        <option value="greater">Greater than</option>
                        <option value="less">Less than</option>
                    </select>
                </div>
                <div class="flex flex-col gap-2">
                    <label class="text-sm" for="alarmValue">Threshold Distance</label>
                    <input
                        id="alarmValue"
                        type="number"
                        class="border border-border bg-background text-foreground rounded-xl px-3 py-2"
                        placeholder={`Enter distance in ${props.unit}`}
                        value={props.alarmValue}
                        onInput={(e: any) => {
                            const v = e.currentTarget.value;
                            props.onAlarmValueChange(v === '' ? '' : Number(v));
                        }}
                    />
                </div>
                <button
                    class={`rounded-xl px-3 py-2 transition-colors text-primary-foreground ${props.triggered ? 'bg-destructive hover:opacity-90' : 'bg-primary hover:opacity-90'}`}
                    onClick={() => {
                        if (props.alarmValue === '') return;
                        const txt = `Alarm set: ${props.alarmType} than ${props.alarmValue} ${props.unit}`;
                        alert(txt);
                    }}
                >
                    Set Alarm
                </button>
                {props.triggered && (
                    <div class="bg-destructive text-destructive-foreground rounded-xl px-3 py-3 text-center animate-[fadeIn_0.3s_ease-in-out]">
                        ⚠️ Distance threshold triggered!
                    </div>
                )}
            </div>
        </Card>
    );
}

function ChartCard(props: { unit: 'cm' | 'in'; points: DataPoint[] }) {
    const containerRef = useRef<HTMLDivElement | null>(null);
    const chartRef = useRef<LineChart | null>(null);

    // Compute relative time labels in seconds: rightmost is 0, leftwards are negative
    const labels = props.points.map((_, i, arr) => (i - (arr.length - 1)) / SAMPLE_RATE_HZ);
    const values = props.points.map(p => (props.unit === 'in' ? cmToInches(p.valueCm) : p.valueCm));

    useEffect(() => {
        if (!containerRef.current) return;
        const options: LineChartOptions = {
            height: 250,
            showPoint: false,
            lineSmooth: true,
            axisX: {
                showLabel: true,
                showGrid: false,
                labelInterpolationFnc: (value: number, index: number) => {
                    // Show a label every second and at the last point (0s)
                    if (index === labels.length - 1) return '0s';
                    if (index % SAMPLE_RATE_HZ === 0) return `${Math.round(value)}s`;
                    return null;
                },
            },
            axisY: { onlyInteger: false, low: 0 },
            chartPadding: { top: 10, right: 10, bottom: 10, left: 10 },
        };
        if (!chartRef.current) {
            chartRef.current = new LineChart(containerRef.current, { labels, series: [values] }, options);
        } else {
            chartRef.current.update({ labels, series: [values] }, options);
        }
    }, [labels.join('|'), values.join('|')]);

    useEffect(() => {
        return () => {
            chartRef.current = null;
        };
    }, []);

    return (
        <Card class="md:col-span-2">
            <div class="w-full">
                <div class="uppercase text-xs tracking-wide text-muted-foreground text-center">Distance ({props.unit})</div>
                <div ref={containerRef} class="ct-chart"></div>
                {/* <div class="text-right text-xs text-muted-foreground mt-4">Distance ({props.unit})</div> */}
            </div>
        </Card>
    );
}
