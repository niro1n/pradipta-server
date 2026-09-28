import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  CheckCircle,
  XCircle,
  AlertTriangle,
  ShieldAlert,
  Send,
  Clock,
  KeyRound,
} from "lucide-react";
import { sendNui } from "../lib/sendNui";
import { useTranslation } from "../lib/translation";
import { cn } from "../lib/utils";

type RegistrationStatus = "none" | "pending" | "rejected" | "disabled";

interface RegistrationPanelProps {
  status: RegistrationStatus;
  reason?: string;
}

export default function RegistrationPanel({
  status,
  reason: rejectReason,
}: RegistrationPanelProps) {
  const translation = useTranslation();
  const [reason, setReason] = useState("");
  const [isFocused, setIsFocused] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = () => {
    if (reason.trim().length < 10) return;
    setIsSubmitting(true);
    sendNui("submitRegistration", { reason: reason }).finally(() =>
      setIsSubmitting(false),
    );
  };

  const containerVariants = {
    hidden: { opacity: 0, scale: 0.95, y: 10 },
    visible: {
      opacity: 1,
      scale: 1,
      y: 0,
      transition: { type: "spring", damping: 25, stiffness: 200 },
    },
  };

  return (
    <div className="flex w-full h-full items-center justify-center bg-[#070a13] relative overflow-hidden">
      {}
      <div className="absolute inset-0 pointer-events-none">
        <div
          className="absolute top-[20%] left-[20%] w-[500px] h-[500px] bg-blue-600/10 rounded-full blur-[120px] animate-pulse"
          style={{ animationDuration: "4s" }}
        />
        <div
          className="absolute bottom-[20%] right-[20%] w-[400px] h-[400px] bg-indigo-600/10 rounded-full blur-[100px] animate-pulse"
          style={{ animationDuration: "6s", animationDelay: "1s" }}
        />

        {}
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGNpcmNsZSBjeD0iMSIgY3k9IjEiIHI9IjEiIGZpbGw9InJnYmEoMjU1LDI1NSwyNTUsMC4wMykiLz48L3N2Zz4=')] opacity-50" />
      </div>

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="w-full max-w-[480px] z-10 relative"
      >
        {}
        <div className="bg-[#0f1423]/90 backdrop-blur-2xl border border-white/[0.08] rounded-2xl p-8 shadow-[0_0_80px_-20px_rgba(37,99,235,0.2)]">
          <AnimatePresence mode="wait">
            {status === "none" && (
              <motion.div
                key="none"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="flex flex-col items-center text-center"
              >
                <div className="relative mb-6">
                  <div className="absolute inset-0 bg-blue-500/20 blur-xl rounded-full" />
                  <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-blue-500/20 to-indigo-500/10 border border-blue-500/20 flex items-center justify-center relative shadow-inner">
                    <KeyRound
                      size={36}
                      className="text-blue-400"
                      strokeWidth={1.5}
                    />
                  </div>
                </div>

                <h2 className="text-2xl font-black text-white tracking-tight mb-2">
                  {translation.authorizationRequired ||
                    "Authorization Required"}
                </h2>
                <p className="text-ui-textMuted text-sm leading-relaxed px-4 mb-8">
                  {translation.noAdminPrivileges ||
                    "You do not currently have administrative privileges. Please submit an application to request access."}
                </p>

                <div className="w-full text-left space-y-3">
                  <div className="flex items-center justify-between">
                    <label className="text-[11px] uppercase font-bold text-blue-400 tracking-widest flex items-center gap-2">
                      {translation.applicationReason || "Application Reason"}
                    </label>
                    <span
                      className={cn(
                        "text-xs font-mono transition-colors",
                        reason.length < 10
                          ? "text-red-400/80"
                          : "text-green-400/80",
                      )}
                    >
                      {reason.length}/500
                    </span>
                  </div>

                  <div
                    className={cn(
                      "relative rounded-md overflow-hidden transition-all duration-300",
                      isFocused
                        ? "ring-2 ring-blue-500/50"
                        : "ring-1 ring-white/10",
                    )}
                  >
                    <textarea
                      value={reason}
                      onChange={(e) => setReason(e.target.value.slice(0, 500))}
                      onFocus={() => setIsFocused(true)}
                      onBlur={() => setIsFocused(false)}
                      placeholder={
                        translation.describeAdminNeed ||
                        "Please describe why you need admin access in detail..."
                      }
                      className="w-full h-32 bg-black/40 p-4 text-sm text-white/90 placeholder:text-white/20 resize-none focus:outline-none custom-scrollbar"
                    />
                    <div
                      className="absolute bottom-0 left-0 h-1 bg-gradient-to-r from-blue-500 to-indigo-500 transition-all duration-300"
                      style={{
                        width: `${Math.min(100, (reason.length / 500) * 100)}%`,
                      }}
                    />
                  </div>
                </div>

                <button
                  onClick={handleSubmit}
                  disabled={isSubmitting || reason.trim().length < 10}
                  className="w-full mt-8 py-3.5 px-4 bg-white text-black hover:bg-gray-100 rounded-xl font-bold transition-all shadow-[0_0_20px_rgba(255,255,255,0.1)] disabled:opacity-50 disabled:shadow-none flex items-center justify-center gap-2 group"
                >
                  <span>
                    {isSubmitting
                      ? "..."
                      : translation.submitRequest || "Submit Request"}
                  </span>
                  <Send
                    size={18}
                    className="group-hover:translate-x-1 transition-transform"
                  />
                </button>
              </motion.div>
            )}

            {status === "pending" && (
              <motion.div
                key="pending"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="flex flex-col items-center text-center py-6"
              >
                <div className="relative mb-6">
                  <div className="absolute inset-0 bg-amber-500/20 blur-xl rounded-full" />
                  <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-amber-500/20 to-orange-500/10 border border-amber-500/20 flex items-center justify-center relative">
                    <Clock
                      size={36}
                      className="text-amber-400"
                      strokeWidth={1.5}
                    />
                  </div>
                </div>
                <h2 className="text-2xl font-black text-white tracking-tight mb-3">
                  {translation.underReview || "Under Review"}
                </h2>
                <p className="text-ui-textMuted text-sm leading-relaxed px-4">
                  {translation.waitingForApproval ||
                    "Your application has been received and is currently waiting for approval from the server management."}
                </p>
              </motion.div>
            )}

            {status === "rejected" && (
              <motion.div
                key="rejected"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="flex flex-col items-center text-center"
              >
                <div className="relative mb-6">
                  <div className="absolute inset-0 bg-red-500/20 blur-xl rounded-full" />
                  <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-red-500/20 to-pink-500/10 border border-red-500/20 flex items-center justify-center relative">
                    <XCircle
                      size={36}
                      className="text-red-400"
                      strokeWidth={1.5}
                    />
                  </div>
                </div>
                <h2 className="text-2xl font-black text-white tracking-tight mb-2">
                  {translation.requestDenied || "Request Denied"}
                </h2>

                <div className="bg-black/30 border border-red-500/20 rounded-xl p-5 w-full text-left mt-4 mb-6 shadow-inner">
                  <h3 className="text-red-400 font-bold mb-2 text-[11px] uppercase tracking-widest flex items-center gap-2">
                    <ShieldAlert size={14} />{" "}
                    {translation.reasonForDenial || "Reason for Denial"}
                  </h3>
                  <p className="text-red-100/70 text-sm whitespace-pre-wrap leading-relaxed">
                    {rejectReason || "No specific reason provided."}
                  </p>
                </div>

                <div className="w-full text-left space-y-3">
                  <label className="text-[11px] uppercase font-bold text-ui-textMuted tracking-widest">
                    {translation.submitNewAppeal || "Submit New Appeal"}
                  </label>
                  <div
                    className={cn(
                      "relative rounded-xl overflow-hidden transition-all duration-300",
                      isFocused
                        ? "ring-2 ring-red-500/50"
                        : "ring-1 ring-white/10",
                    )}
                  >
                    <textarea
                      value={reason}
                      onChange={(e) => setReason(e.target.value.slice(0, 500))}
                      onFocus={() => setIsFocused(true)}
                      onBlur={() => setIsFocused(false)}
                      placeholder={
                        translation.explainReconsideration ||
                        "Explain why your request should be reconsidered..."
                      }
                      className="w-full h-28 bg-black/40 p-4 text-sm text-white/90 placeholder:text-white/20 resize-none focus:outline-none custom-scrollbar"
                    />
                  </div>
                </div>

                <button
                  onClick={handleSubmit}
                  disabled={isSubmitting || reason.trim().length < 10}
                  className="w-full mt-6 py-3.5 px-4 bg-red-500/10 hover:bg-red-500 text-red-400 hover:text-white border border-red-500/20 rounded-xl font-bold transition-all disabled:opacity-50 flex items-center justify-center gap-2 group"
                >
                  <span>
                    {isSubmitting
                      ? "..."
                      : translation.appealDecision || "Appeal Decision"}
                  </span>
                  <Send
                    size={18}
                    className="group-hover:translate-x-1 transition-transform"
                  />
                </button>
              </motion.div>
            )}

            {status === "disabled" && (
              <motion.div
                key="disabled"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="flex flex-col items-center text-center py-6"
              >
                <div className="relative mb-6">
                  <div className="absolute inset-0 bg-red-500/20 blur-xl rounded-full" />
                  <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-red-600/20 to-red-900/20 border border-red-500/30 flex items-center justify-center relative">
                    <ShieldOff
                      size={36}
                      className="text-red-500"
                      strokeWidth={1.5}
                    />
                  </div>
                </div>
                <h2 className="text-2xl font-black text-white tracking-tight mb-3">
                  {translation.accountSuspended || "Account Suspended"}
                </h2>
                <p className="text-ui-textMuted text-sm leading-relaxed px-4">
                  {translation.adminAccessRevoked ||
                    "Your administrative access has been permanently revoked by the server owner."}
                </p>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </motion.div>
    </div>
  );
}
