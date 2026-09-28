import React, { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Crosshair } from "lucide-react";

interface CoordsData {
  x: number;
  y: number;
  z: number;
  h: number;
}

export function CoordsHud() {
  const [visible, setVisible] = useState(false);
  const [coords, setCoords] = useState<CoordsData>({ x: 0, y: 0, z: 0, h: 0 });

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === "updateCoords") {
        setVisible(event.data.visible);
        if (event.data.coords) {
          setCoords(event.data.coords);
        }
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          className="fixed top-2 left-[41.5%] -translate-x-1/2 bg-black/80 rounded-md px-4 py-1.5 w-max flex items-center gap-4 text-white font-mono text-[13px] font-bold z-50"
        >
          <Crosshair size={16} className="text-amber-400" />
          <div className="flex gap-3">
            <span>
              <span className="text-gray-400">X:</span> {coords.x.toFixed(2)}
            </span>
            <span>
              <span className="text-gray-400">Y:</span> {coords.y.toFixed(2)}
            </span>
            <span>
              <span className="text-gray-400">Z:</span> {coords.z.toFixed(2)}
            </span>
            <span className="text-amber-400 border-l border-white/20 pl-3">
              H: {coords.h.toFixed(2)}
            </span>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
