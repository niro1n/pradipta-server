import React, { useState, useEffect } from "react";
import ReportForm from "./report-form";
import { AnimatePresence } from "framer-motion";

export default function ReportApp() {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === "openReportForm") {
        setIsVisible(true);
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && isVisible) {
        setIsVisible(false);
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isVisible]);

  return (
    <AnimatePresence>
      {isVisible && <ReportForm onClose={() => setIsVisible(false)} />}
    </AnimatePresence>
  );
}
