import { AlertTriangle, ShieldAlert } from "lucide-react";
import { useState, useEffect } from "react";
import announcementSound from "../../assets/annoucement.wav";
import { motion, AnimatePresence } from "framer-motion";
import { useTranslation } from "../lib/translation";
import { Button } from "./ui/button";

export default function Warn() {
  const translation = useTranslation();
  const [showWarn, setShowWarn] = useState<boolean>(false);
  const [info, setInfo] = useState<Record<string, string>>({});

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const { data } = event;
      if (data.action === "warn") {
        setShowWarn(true);
        setInfo({
          reason: data.reason,
          author: data.author,
        });
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useEffect(() => {
    let audio: HTMLAudioElement | null = null;
    if (showWarn) {
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
  }, [showWarn]);

  return (
    <AnimatePresence>
      {showWarn && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 flex items-center justify-center z-[100] bg-black/80 backdrop-blur-md p-4"
        >
          <motion.div
            initial={{ scale: 0.9, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0.9, opacity: 0, y: 20 }}
            className="bg-gray-900 border border-red-500/30 p-8 rounded-2xl shadow-[0_0_50px_rgba(239,68,68,0.2)] w-full max-w-lg relative overflow-hidden"
          >
            <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-red-500 via-orange-500 to-red-500" />

            <div className="flex flex-col items-center text-center">
              <div className="w-16 h-16 rounded-full bg-red-500/10 flex items-center justify-center mb-6 border border-red-500/20">
                <ShieldAlert size={32} className="text-red-500" />
              </div>

              <h2 className="text-3xl font-extrabold text-white tracking-tight mb-2">
                {translation.warnTitle || "OFFICIAL WARNING"}
              </h2>

              <p className="text-gray-400 font-medium mb-6">
                {translation.warnAuthorPrefix ||
                  "You have received a warning from"}{" "}
                <span className="text-red-400 font-bold">{info.author}</span>
              </p>

              <div className="w-full bg-red-950/30 border border-red-900/50 rounded-xl p-5 mb-8">
                <div className="flex items-center gap-2 mb-3 text-red-400 font-semibold text-sm uppercase tracking-wider">
                  <AlertTriangle size={16} />
                  <span>{translation.reason || "Reason"}</span>
                </div>
                <p className="text-gray-200 text-lg leading-relaxed text-left break-words">
                  {info.reason}
                </p>
              </div>

              <Button
                onClick={() => {
                  setShowWarn(false);
                  setInfo({});
                }}
                className="w-full bg-red-600 hover:bg-red-500 text-white font-bold h-12 rounded-xl text-lg transition-all active:scale-[0.98]"
              >
                I Understand
              </Button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
