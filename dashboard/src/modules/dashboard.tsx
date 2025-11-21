import { LineChart, type LineChartOptions } from "chartist";
import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "preact/hooks";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { NumberInput } from "@/components/ui/number-input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { convertUnit, Unit } from "@/lib/units";

const HOST = import.meta.env.DEV ? "localhost:3000" : location.host;
const WS_URL = `ws://${HOST}/ws`;

type AlarmType = "greater" | "less";

type DataPoint = {
  timeLabel: string;
  valueMm: number;
};

const SAMPLE_RATE_HZ = 10;
const BUFFER_SIZE = 100;

const OUT_OF_RANGE_VALUE = 1000;

export function Dashboard() {
  const [unit, setUnit] = useState<Unit>(Unit.MILLIMETER);
  const [alarmType, setAlarmType] = useState<AlarmType>("greater");
  const [alarmValue, setAlarmValue] = useState<number | null>(null);
  const [points, setPoints] = useState<DataPoint[]>([]);

  // Build a 100-sample buffer of DataPoint from raw mm values (last value most recent)
  function buildPointsFromArray(valuesMm: number[]): DataPoint[] {
    const intervalMs = Math.round(1000 / SAMPLE_RATE_HZ);
    const now = Date.now();
    const len = valuesMm.length;
    const pts: DataPoint[] = new Array(len);
    for (let i = 0; i < len; i++) {
      const t = now - (len - 1 - i) * intervalMs;
      pts[i] = {
        timeLabel: new Date(t).toLocaleTimeString(),
        valueMm: valuesMm[i] > OUT_OF_RANGE_VALUE ? NaN : valuesMm[i],
      };
    }
    return pts;
  }

  const [ws, setWs] = useState<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<number | null>(null);
  const reconnectAttemptsRef = useRef(0);
  const isManuallyDisconnectedRef = useRef(false);
  const wsRef = useRef<WebSocket | null>(null);

  const connectWebSocket = useCallback(() => {
    // Don't connect if already connected or manually disconnected
    if (
      wsRef.current?.readyState === WebSocket.OPEN ||
      isManuallyDisconnectedRef.current
    ) {
      return;
    }

    // Clear any pending reconnection attempts
    if (reconnectTimeoutRef.current !== null) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }

    try {
      const socket = new WebSocket(WS_URL);
      wsRef.current = socket;
      setWs(socket);

      socket.onopen = () => {
        console.log("WebSocket connected");
        reconnectAttemptsRef.current = 0; // Reset reconnect attempts on successful connection
      };

      socket.onmessage = (event) => {
        try {
          const msg = JSON.parse(event.data);
          if (msg?.event === "data" && Array.isArray(msg.data)) {
            // Replace entire buffer
            const values = (msg.data as number[]).slice(-BUFFER_SIZE);
            setPoints(buildPointsFromArray(values));
          } else if (
            msg?.event === "unit" &&
            ["m", "cm", "mm", "in", "ft"].includes(msg.data)
          ) {
            setUnit(Unit.fromSymbol(msg.data));
          } else if (msg?.event === "update" && Array.isArray(msg.data)) {
            // Append all new samples from array (last element is most recent) and trim to BUFFER_SIZE
            setPoints((prev) => {
              const values = msg.data as number[];
              const intervalMs = Math.round(1000 / SAMPLE_RATE_HZ);
              const now = Date.now();
              // Create points with timestamps, where last element is most recent (now)
              const newPoints: DataPoint[] = values.map((valueMm, index) => {
                const timeOffset = (values.length - 1 - index) * intervalMs;
                const timestamp = now - timeOffset;
                return {
                  timeLabel: new Date(timestamp).toLocaleTimeString(),
                  valueMm: valueMm > OUT_OF_RANGE_VALUE ? NaN : valueMm,
                };
              });
              if (prev.length === 0) {
                // If no previous points, return the new points (trimmed to BUFFER_SIZE)
                return newPoints.slice(-BUFFER_SIZE);
              }
              // Append new points and trim to BUFFER_SIZE
              const updated = [...prev, ...newPoints];
              if (updated.length > BUFFER_SIZE) {
                return updated.slice(-BUFFER_SIZE);
              }
              return updated;
            });
          }
        } catch {
          // ignore malformed messages
        }
      };

      socket.onerror = (error) => {
        console.error("WebSocket error:", error);
      };

      socket.onclose = (event) => {
        console.log("WebSocket closed", event.code, event.reason);
        wsRef.current = null;
        setWs(null);

        // Only reconnect if not manually disconnected and not a normal closure
        if (!isManuallyDisconnectedRef.current && event.code !== 1000) {
          // Exponential backoff: start at 1s, max at 30s
          const baseDelay = 1000;
          const maxDelay = 30000;
          const delay = Math.min(
            baseDelay * 2 ** reconnectAttemptsRef.current,
            maxDelay,
          );
          reconnectAttemptsRef.current++;

          console.log(
            `Reconnecting in ${delay}ms (attempt ${reconnectAttemptsRef.current})`,
          );
          reconnectTimeoutRef.current = window.setTimeout(() => {
            connectWebSocket();
          }, delay);
        }
      };
    } catch (error) {
      console.error("Failed to create WebSocket:", error);
      // Retry connection after a delay
      reconnectTimeoutRef.current = window.setTimeout(() => {
        connectWebSocket();
      }, 1000);
    }
  }, []);

  const disconnectWebSocket = useCallback(() => {
    isManuallyDisconnectedRef.current = true;
    if (reconnectTimeoutRef.current !== null) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }
    if (wsRef.current) {
      try {
        wsRef.current.close();
      } catch {}
      wsRef.current = null;
      setWs(null);
    }
  }, []);

  // Connect to WebSocket /ws and handle incoming data
  useEffect(() => {
    connectWebSocket();

    return () => {
      disconnectWebSocket();
    };
  }, [connectWebSocket, disconnectWebSocket]);

  // Handle page visibility changes (background/foreground)
  useEffect(() => {
    const handleVisibilityChange = () => {
      if (document.hidden) {
        // Page is backgrounded - disconnect
        console.log("Page backgrounded, disconnecting WebSocket");
        disconnectWebSocket();
      } else {
        // Page is foregrounded - reconnect
        console.log("Page foregrounded, reconnecting WebSocket");
        isManuallyDisconnectedRef.current = false;
        reconnectAttemptsRef.current = 0; // Reset attempts when manually reconnecting
        connectWebSocket();
      }
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);

    return () => {
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [connectWebSocket, disconnectWebSocket]);

  const latestDisplayValue = useMemo(() => {
    const last = points[points.length - 1]?.valueMm ?? null;
    if (last == null) return null;
    return convertUnit(last, Unit.MILLIMETER, unit);
  }, [points, unit]);

  const thresholdTriggered = useMemo(() => {
    if (alarmValue === null || points.length === 0) return false;
    const last = points[points.length - 1].valueMm;
    const threshold = convertUnit(alarmValue as number, unit, Unit.MILLIMETER);
    if (alarmType === "greater") return last > threshold;
    return last < threshold;
  }, [alarmValue, alarmType, points, unit]);

  const setDeviceUnit = useCallback((u: Unit) => {
    setUnit(u);
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({ event: "unit", data: u.symbol }));
    }
  }, []);

  return (
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-5xl mx-auto">
      <DistanceCard
        unit={unit}
        value={Number.isNaN(latestDisplayValue) ? null : latestDisplayValue}
        onUnitChange={setDeviceUnit}
      />
      <AlarmSettings
        unit={unit}
        alarmType={alarmType}
        alarmValue={alarmValue}
        onAlarmTypeChange={setAlarmType}
        onAlarmValueChange={(v) => setAlarmValue(v)}
        triggered={thresholdTriggered}
      />
      <ChartCard unit={unit} points={points} />
    </div>
  );
}

// function Card(props: { children: preact.ComponentChildren; class?: string }) {
//     return (
//         <div class={`bg-card rounded-2xl shadow-md p-6 border border-border ${props.class ?? ''}`}>{props.children}</div>
//     );
// }

function DistanceCard(props: {
  unit: Unit;
  value: number | null;
  onUnitChange: (u: Unit) => void;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Current Distance</CardTitle>
      </CardHeader>
      <CardContent className="h-full">
        <div className="flex flex-col justify-between h-full pt-4">
          <div class="text-5xl font-bold text-center my-4">
            {props.value == null
              ? "--"
              : props.value.toFixed(props.unit.displayDecimals)}{" "}
            {props.unit.symbol}
          </div>
          <div class="flex flex-col gap-2">
            <Label htmlFor="unitSelect">Units</Label>
            <Select
              value={props.unit.symbol}
              onValueChange={(value) =>
                props.onUnitChange(
                  Unit.fromSymbol(value as "m" | "cm" | "mm" | "in" | "ft"),
                )
              }
            >
              <SelectTrigger id="unitSelect" className="w-full">
                <SelectValue placeholder="Select a unit" />
              </SelectTrigger>
              <SelectContent>
                {/* TODO: Make this dynamic */}
                <SelectItem value={Unit.METER.symbol}>
                  {Unit.METER.name}
                </SelectItem>
                <SelectItem value={Unit.CENTIMETER.symbol}>
                  {Unit.CENTIMETER.name}
                </SelectItem>
                <SelectItem value={Unit.MILLIMETER.symbol}>
                  {Unit.MILLIMETER.name}
                </SelectItem>
                <SelectItem value={Unit.INCH.symbol}>
                  {Unit.INCH.name}
                </SelectItem>
                <SelectItem value={Unit.FOOT.symbol}>
                  {Unit.FOOT.name}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

function AlarmSettings(props: {
  unit: Unit;
  alarmType: AlarmType;
  alarmValue: number | null;
  onAlarmTypeChange: (t: AlarmType) => void;
  onAlarmValueChange: (v: number | null) => void;
  triggered: boolean;
}) {
  const stepMm = 1;
  const convertedStep = useMemo(() => {
    const stepConv = convertUnit(stepMm, Unit.MILLIMETER, props.unit);
    return 1 - Math.floor(Math.log(stepConv) / Math.log(10));
  }, [props.unit]);

  useEffect(() => {
    props.onAlarmValueChange(
      convertUnit(props.alarmValue ?? null, Unit.MILLIMETER, props.unit),
    );
  }, [props.unit, props.onAlarmValueChange]);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Alarm Settings</CardTitle>
      </CardHeader>
      <CardContent>
        {/* <div class="uppercase text-xs tracking-wide text-muted-foreground text-center">Alarm Settings</div> */}
        <div class="flex flex-col gap-3 mt-4">
          <div class="flex flex-col gap-2">
            <Label htmlFor="alarmType">Alarm Type</Label>
            <Select
              value={props.alarmType}
              onValueChange={props.onAlarmTypeChange}
            >
              <SelectTrigger id="alarmType" className="w-full">
                <SelectValue placeholder="Select a type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="greater">Greater than</SelectItem>
                <SelectItem value="less">Less than</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="flex flex-col gap-2">
            <Label htmlFor="alarmValue">Threshold Distance</Label>
            <NumberInput
              id="alarmValue"
              maxLen={10}
              step={convertedStep}
              value={props.alarmValue}
              onValueChange={props.onAlarmValueChange}
            />
          </div>
          <Button
            onClick={() => {
              if (props.alarmValue === null) return;
              const txt = `Alarm set: ${props.alarmType} than ${props.alarmValue} ${props.unit.symbol}`;
              alert(txt);
            }}
          >
            Set Alarm
          </Button>
          {props.triggered && (
            <div class="bg-destructive text-destructive-foreground rounded px-3 py-3 text-center animate-[fadeIn_0.3s_ease-in-out]">
              ⚠️ Distance threshold triggered!
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}

function ChartCard(props: { unit: Unit; points: DataPoint[] }) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const chartRef = useRef<LineChart | null>(null);

  // Compute relative time labels in seconds: rightmost is 0, leftwards are negative
  const labels = props.points.map(
    (_, i, arr) => (i - (arr.length - 1)) / SAMPLE_RATE_HZ,
  );
  const values = props.points.map((p) =>
    convertUnit(p.valueMm, Unit.MILLIMETER, props.unit),
  );

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
          if (index === labels.length - 1) return "0s";
          if (index % SAMPLE_RATE_HZ === 0) return `${Math.round(value)}s`;
          return null;
        },
      },
      axisY: { onlyInteger: false, low: 0 },
      chartPadding: { top: 10, right: 10, bottom: 10, left: 10 },
    };
    if (!chartRef.current) {
      chartRef.current = new LineChart(
        containerRef.current,
        { labels, series: [values] },
        options,
      );
    } else {
      chartRef.current.update({ labels, series: [values] }, options);
    }
  }, [labels.join("|"), values.join("|")]);

  useEffect(() => {
    return () => {
      chartRef.current = null;
    };
  }, []);

  return (
    <Card className="col-span-2">
      <CardHeader>
        <CardTitle>Distance ({props.unit.symbol})</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="w-full">
          <div ref={containerRef} class="ct-chart"></div>
        </div>
      </CardContent>
    </Card>
  );
}
