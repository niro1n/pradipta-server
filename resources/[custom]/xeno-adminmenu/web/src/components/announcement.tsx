import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Megaphone, AlertTriangle } from "lucide-react";
import announcementSound from "../../assets/annoucement.wav";

export default function Announcement() {
  const [announcement, setAnnouncement] = useState<{
    msg: string;
    type: string;
    duration?: number;
  } | null>(null);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data && event.data.action === "showAnnouncement") {
        const data = event.data.data;
        if (!data || !data.msg) return;
        setAnnouncement(data);

        const parsed = Number(data.duration);
        const duration =
          parsed && parsed > 0
            ? parsed <= 120
              ? parsed * 1000
              : parsed
            : 10000;

        setTimeout(() => {
          setAnnouncement(null);
        }, duration);
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useEffect(() => {
    let audio: HTMLAudioElement | null = null;
    if (announcement) {
      try {
        audio = new Audio(announcementSound);
        audio.volume = 0.3;
        audio.play().catch(() => {});
      } catch (e) {}
    }

    return () => {
      if (audio) {
        audio.pause();
        audio.currentTime = 0;
      }
    };
  }, [announcement]);

  return (
    <div className="fixed top-2 left-1/2 -translate-x-1/2 z-[100] w-auto min-w-[400px] max-w-[80vw] pointer-events-none">
      <AnimatePresence>
        {announcement && (
          <motion.div
            initial={{ opacity: 0, y: -50, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -20, scale: 0.95 }}
            transition={{ type: "spring", bounce: 0.4 }}
            className={`overflow-hidden rounded-md border
                            ${
                              announcement.type === "warning"
                                ? "bg-gray-900 border-red-500/30 shadow-[0_0_50px_rgba(239,68,68,0.2)]"
                                : "bg-gray-900 border-amber-500/30 shadow-[0_0_50px_rgba(245,158,11,0.2)]"
                            }`}
          >
            <div
              className={`absolute top-0 left-0 w-full h-1 ${announcement.type === "warning" ? "bg-gradient-to-r from-red-500 via-orange-500 to-red-500" : "bg-gradient-to-r from-amber-500 via-yellow-500 to-amber-500"}`}
            />
            <div className="px-8 py-6 flex gap-6 items-center relative">
              <div
                className={`shrink-0 flex items-center justify-center w-16 h-16 rounded-full border 
                                ${announcement.type === "warning" ? "bg-red-500/10 border-red-500/20 text-red-500" : "bg-amber-500/10 border-amber-500/20 text-amber-500"}`}
              >
                {announcement.type === "warning" ? (
                  <AlertTriangle size={32} />
                ) : (
                  <Megaphone size={32} />
                )}
              </div>
              <div className="flex flex-col">
                <h2
                  className={`text-xl font-extrabold mb-1 uppercase tracking-tight
                                    ${announcement.type === "warning" ? "text-red-400" : "text-amber-400"}`}
                >
                  {announcement.type === "warning"
                    ? "Server Warning"
                    : "Server Announcement"}
                </h2>
                <p className="text-gray-100 text-lg leading-relaxed whitespace-pre-wrap font-medium">
                  {typeof announcement.msg === "string"
                    ? announcement.msg.trim()
                    : String(announcement.msg || "")}
                </p>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
