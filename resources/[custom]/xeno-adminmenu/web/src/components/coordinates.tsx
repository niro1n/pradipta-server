import { useState, useEffect } from "react";

export default function Coordinates() {
  const [visible, setVisible] = useState(false);
  const [coords, setCoords] = useState<{
    x: number;
    y: number;
    z: number;
    h: number;
  } | null>(null);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const data = event.data;
      if (data.action === "updateCoords") {
        setVisible(data.visible);
        if (data.coords) {
          setCoords(data.coords);
        }
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  if (!visible || !coords) return null;

  return (
    <div className="fixed top-4 left-1/2 -translate-x-1/2 z-[9999] pointer-events-none">
      <div className="bg-black/60 border border-white/10 px-4 py-2 rounded-xl text-white text-sm font-mono shadow-xl flex gap-4">
        <div className="flex gap-1">
          <span className="text-ui-blue font-bold">X:</span>{" "}
          {coords.x.toFixed(2)}
        </div>
        <div className="flex gap-1">
          <span className="text-ui-blue font-bold">Y:</span>{" "}
          {coords.y.toFixed(2)}
        </div>
        <div className="flex gap-1">
          <span className="text-ui-blue font-bold">Z:</span>{" "}
          {coords.z.toFixed(2)}
        </div>
        <div className="flex gap-1">
          <span className="text-ui-amber font-bold">H:</span>{" "}
          {coords.h.toFixed(2)}
        </div>
      </div>
    </div>
  );
}
