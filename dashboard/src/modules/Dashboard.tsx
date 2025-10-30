import { useEffect, useMemo, useRef, useState } from 'preact/hooks';
import { LineChart, type LineChartOptions } from 'chartist';

type AlarmType = 'greater' | 'less';

type DataPoint = {
    timeLabel: string;
    valueCm: number;
};

function useInterval(callback: () => void, delayMs: number) {
    const savedCallback = useRef(callback);
    useEffect(() => {
        savedCallback.current = callback;
    }, [callback]);
    useEffect(() => {
        const id = setInterval(() => savedCallback.current(), delayMs);
        return () => clearInterval(id);
    }, [delayMs]);
}

function generateFakeDistanceCm(): number {
    return 20 + Math.random() * 80;
}

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

    useInterval(() => {
        setPoints(prev => {
            const next: DataPoint = { timeLabel: formatNow(), valueCm: generateFakeDistanceCm() };
            const updated = [...prev, next];
            if (updated.length > 20) updated.shift();
            return updated;
        });
    }, 1000);

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
        <div class={`bg-white rounded-2xl shadow-md p-6 ${props.class ?? ''}`}>{props.children}</div>
    );
}

function DistanceCard(props: {
    unit: 'cm' | 'in';
    value: number | null;
    onUnitChange: (u: 'cm' | 'in') => void;
}) {
    return (
        <Card>
            <div class="uppercase text-xs tracking-wide text-slate-500 text-center">Current Distance</div>
            <div class="text-5xl font-bold text-center my-4">
                {props.value == null ? '--' : props.value.toFixed(1)} {props.unit}
            </div>
            <div class="flex flex-col gap-2">
                <label class="text-sm" for="unitSelect">Units</label>
                <select
                    id="unitSelect"
                    class="border border-slate-200 rounded-xl px-3 py-2"
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
            <div class="uppercase text-xs tracking-wide text-slate-500 text-center">Alarm Settings</div>
            <div class="flex flex-col gap-3 mt-4">
                <div class="flex flex-col gap-2">
                    <label class="text-sm" for="alarmType">Alarm Type</label>
                    <select
                        id="alarmType"
                        class="border border-slate-200 rounded-xl px-3 py-2"
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
                        class="border border-slate-200 rounded-xl px-3 py-2"
                        placeholder={`Enter distance in ${props.unit}`}
                        value={props.alarmValue}
                        onInput={(e: any) => {
                            const v = e.currentTarget.value;
                            props.onAlarmValueChange(v === '' ? '' : Number(v));
                        }}
                    />
                </div>
                <button
                    class={`rounded-xl px-3 py-2 text-white transition-colors ${props.triggered ? 'bg-red-500 hover:bg-red-600' : 'bg-blue-600 hover:bg-blue-700'}`}
                    onClick={() => {
                        if (props.alarmValue === '') return;
                        const txt = `Alarm set: ${props.alarmType} than ${props.alarmValue} ${props.unit}`;
                        alert(txt);
                    }}
                >
                    Set Alarm
                </button>
                {props.triggered && (
                    <div class="bg-red-500 text-white rounded-xl px-3 py-3 text-center animate-[fadeIn_0.3s_ease-in-out]">
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

    const labels = props.points.map(p => p.timeLabel);
    const values = props.points.map(p => (props.unit === 'in' ? cmToInches(p.valueCm) : p.valueCm));

    useEffect(() => {
        if (!containerRef.current) return;
        const options: LineChartOptions = {
            height: 250,
            showPoint: true,
            lineSmooth: true,
            axisX: { showLabel: false, showGrid: false },
            axisY: { onlyInteger: false },
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
                <div ref={containerRef} class="ct-chart"></div>
                <div class="text-right text-xs text-slate-500 mt-2">Distance ({props.unit})</div>
            </div>
        </Card>
    );
}
