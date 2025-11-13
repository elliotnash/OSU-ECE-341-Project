import { useRef, useEffect } from "preact/hooks";

const useRepeatablePress = (action: () => void, delay = 500, period = 100) => {
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const actionRef = useRef(action);

  // Update the ref whenever action changes
  useEffect(() => {
    actionRef.current = action;
  }, [action]);

  const startPress = () => {
    // Initial action on press down
    actionRef.current();
    // Set timeout for the first repeat
    timeoutRef.current = setTimeout(() => {
      // Start repeating interval after the delay
      intervalRef.current = setInterval(() => {
        actionRef.current();
      }, period);
    }, delay);
  };

  const stopPress = () => {
    // Clear the timeout and interval when the button is released or the mouse leaves
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    if (intervalRef.current) clearInterval(intervalRef.current);
  };

  // Cleanup on component unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, []);

  return { onMouseDown: startPress, onMouseUp: stopPress, onMouseLeave: stopPress };
};

export { useRepeatablePress };
