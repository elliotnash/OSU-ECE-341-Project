import { Minus, Plus } from "lucide-react";
import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "preact/hooks";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useRepeatablePress } from "@/lib/hooks/repeatable-press";

const numberRegex = /^\d+(\.\d*)?$/;

const NumberInput = ({
  id,
  step = 1,
  maxLen = Number.POSITIVE_INFINITY,
  value,
  onValueChange,
}: {
  id: string;
  step?: number;
  maxLen?: number;
  value: number | null;
  onValueChange: (value: number | null) => void;
}) => {
  const [internalVal, setInternalVal] = useState("");
  const isInternalChangeRef = useRef(false);

  const handleLeave = useCallback(() => {
    if (internalVal.endsWith(".")) {
      setInternalVal(internalVal.slice(0, -1));
    }
  }, [internalVal]);

  const modifyValue = useCallback(
    (inc: number) => {
      isInternalChangeRef.current = true;
      const numVal = Number(internalVal) + inc;
      if (numVal < step) {
        setInternalVal("");
        return;
      }
      const strVal = (Math.round(numVal * 100000) / 100000).toString();
      if (strVal.length <= maxLen) {
        setInternalVal(strVal);
      }
    },
    [internalVal, step, maxLen],
  );

  const decrementHandlers = useRepeatablePress(
    () => modifyValue(-step),
    400,
    50,
  );
  const incrementHandlers = useRepeatablePress(
    () => modifyValue(step),
    400,
    50,
  );

  const internalValNum = useMemo(() => {
    if (internalVal === "" || internalVal === ".") {
      return null;
    }
    if (internalVal.endsWith(".")) {
      return Number(internalVal.slice(0, -1));
    } else {
      return Number(internalVal);
    }
  }, [internalVal]);

  useEffect(() => {
    if (!isInternalChangeRef.current) {
      onValueChange(internalValNum);
    }
    isInternalChangeRef.current = false;
  }, [internalValNum, onValueChange]);

  useEffect(() => {
    if (value === null) {
      if (internalVal !== "") {
        isInternalChangeRef.current = true;
        setInternalVal("");
      }
    } else if (value.toString() !== internalVal) {
      isInternalChangeRef.current = true;
      setInternalVal(value.toString());
    }
  }, [value]);

  return (
    <div className="flex gap-2">
      <Button
        {...decrementHandlers}
        size="icon"
        type="button"
        variant="outline"
      >
        <Minus className="h-4 w-4" />
      </Button>
      <Input
        className="bg-background text-center"
        id={id}
        min="1"
        onChange={(e) => {
          const val = e.currentTarget.value;
          if ((val === "" || val.match(numberRegex)) && val.length <= maxLen) {
            isInternalChangeRef.current = true;
            setInternalVal(val);
          }
        }}
        onFocusOut={handleLeave}
        onKeyPress={(e) => {
          if (e.key === "Enter") {
            handleLeave();
          }
        }}
        value={internalVal}
      />
      <Button
        {...incrementHandlers}
        size="icon"
        type="button"
        variant="outline"
      >
        <Plus className="h-4 w-4" />
      </Button>
    </div>
  );
};

export { NumberInput };
