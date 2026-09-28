import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Check, X, Search, Shield, User, Clock, Info } from "lucide-react";
import { sendNui } from "../lib/sendNui";
import { useTranslation } from "../lib/translation";

interface PendingRegistration {
  id: number;
  name: string;
  identifier: string;
  status: string;
  apply_reason?: string;
  created_at: string;
}

export default function Approvals() {
  const translation = useTranslation();
  const [registrations, setRegistrations] = useState<PendingRegistration[]>([]);
  const [search, setSearch] = useState("");
  const [selectedReg, setSelectedReg] = useState<PendingRegistration | null>(
    null,
  );
  const [selectedReasonReg, setSelectedReasonReg] =
    useState<PendingRegistration | null>(null);
  const [rejectReason, setRejectReason] = useState("");

  useEffect(() => {
    sendNui("getPendingRegistrations");

    const handleMessage = (e: MessageEvent) => {
      if (e.data.action === "receivePendingRegistrations") {
        setRegistrations(e.data.data);
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  const handleApprove = (identifier: string) => {
    sendNui("approveRegistration", { identifier });
    setSelectedReg(null);
  };

  const handleReject = (identifier: string) => {
    if (rejectReason.trim() === "") return;
    sendNui("rejectRegistration", { identifier, reason: rejectReason });
    setSelectedReg(null);
    setRejectReason("");
  };

  const filtered = registrations.filter(
    (r) =>
      r.name.toLowerCase().includes(search.toLowerCase()) ||
      r.identifier.toLowerCase().includes(search.toLowerCase()),
  );

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="flex flex-col h-full gap-4 text-white p-2"
    >
      <div className="flex items-center justify-between bg-ui-panel p-6 rounded-xl border border-ui-border">
        <div>
          <h2 className="text-2xl font-bold text-white flex items-center gap-2">
            <Shield className="text-blue-400" />
            {translation.pendingApplications || "Pending Applications"}
          </h2>
          <p className="text-sm text-ui-textMuted mt-1">
            {translation.reviewAdminRequests ||
              "Review and manage admin access requests"}
          </p>
        </div>

        <div className="relative w-64">
          <Search
            className="absolute left-3 top-1/2 -translate-y-1/2 text-ui-textMuted"
            size={18}
          />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={
              translation.searchNameOrId || "Search by name or ID..."
            }
            className="w-full bg-black/40 border border-white/10 rounded-lg pl-10 pr-4 py-2 text-sm focus:outline-none focus:border-blue-500"
          />
        </div>
      </div>

      <div className="flex-1 overflow-auto bg-ui-panel rounded-xl border border-ui-border custom-scrollbar">
        <table className="w-full text-left border-collapse">
          <thead className="bg-ui-layer/50 sticky top-0 z-10">
            <tr>
              <th className="p-4 text-sm font-semibold text-ui-textMuted uppercase">
                {translation.playerNameCol || "Player Name"}
              </th>
              <th className="p-4 text-sm font-semibold text-ui-textMuted uppercase">
                {translation.identifierCol || "Identifier"}
              </th>
              <th className="p-4 text-sm font-semibold text-ui-textMuted uppercase">
                {translation.appliedAtCol || "Applied At"}
              </th>
              <th className="p-4 text-sm font-semibold text-ui-textMuted uppercase text-right">
                {translation.actionsCol || "Actions"}
              </th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr>
                <td colSpan={4} className="p-8 text-center text-ui-textMuted">
                  {translation.noPendingApplications ||
                    "No pending applications found."}
                </td>
              </tr>
            ) : (
              filtered.map((reg) => (
                <tr
                  key={reg.id}
                  className="border-t border-white/5 hover:bg-white/5 transition-colors"
                >
                  <td className="p-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-blue-500/20 flex items-center justify-center text-blue-400">
                        <User size={16} />
                      </div>
                      <span className="font-medium">{reg.name}</span>
                    </div>
                  </td>
                  <td className="p-4 text-sm text-ui-textMuted font-mono">
                    {reg.identifier}
                  </td>
                  <td className="p-4 text-sm text-ui-textMuted flex items-center gap-2">
                    <Clock size={14} />
                    {new Date(reg.created_at).toLocaleString()}
                  </td>
                  <td className="p-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => setSelectedReasonReg(reg)}
                        className="p-2 bg-blue-500/20 text-blue-400 hover:bg-blue-500 hover:text-white rounded-lg transition-colors"
                        title="View Reason"
                      >
                        <Info size={18} />
                      </button>
                      <button
                        onClick={() => handleApprove(reg.identifier)}
                        className="p-2 bg-green-500/20 text-green-400 hover:bg-green-500 hover:text-white rounded-lg transition-colors"
                        title="Approve"
                      >
                        <Check size={18} />
                      </button>
                      <button
                        onClick={() => {
                          setSelectedReg(reg);
                          setRejectReason("");
                        }}
                        className="p-2 bg-red-500/20 text-red-400 hover:bg-red-500 hover:text-white rounded-lg transition-colors"
                        title="Reject"
                      >
                        <X size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Reject Modal */}
      <AnimatePresence>
        {selectedReg && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="bg-ui-layer border border-ui-border rounded-xl w-full max-w-md p-6 shadow-2xl"
            >
              <h3 className="text-xl font-bold mb-4 text-white">
                {translation.rejectApplicationTitle || "Reject Application"}
              </h3>
              <p className="text-sm text-ui-textMuted mb-4">
                {translation.provideRejectReason ||
                  "Please provide a reason for rejecting"}{" "}
                <span className="text-white font-semibold">
                  {selectedReg.name}
                </span>
                's application.
              </p>

              <textarea
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder={
                  translation.enterRejectionReason ||
                  "Enter rejection reason..."
                }
                className="w-full h-32 bg-black/40 border border-white/10 rounded-lg p-3 text-sm text-white focus:outline-none focus:border-red-500 custom-scrollbar resize-none mb-4"
              />

              <div className="flex items-center justify-end gap-3">
                <button
                  onClick={() => setSelectedReg(null)}
                  className="px-4 py-2 rounded-lg bg-ui-layer/50 hover:bg-ui-layer text-white text-sm font-medium transition-colors"
                >
                  {translation.cancel || "Cancel"}
                </button>
                <button
                  onClick={() => handleReject(selectedReg.identifier)}
                  disabled={!rejectReason.trim()}
                  className="px-4 py-2 rounded-lg bg-red-500 hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-medium transition-colors"
                >
                  {translation.confirmRejectBtn || "Confirm Reject"}
                </button>
              </div>
            </motion.div>
          </div>
        )}

        {}
        {selectedReasonReg && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="bg-ui-layer border border-ui-border rounded-xl w-full max-w-lg p-6 shadow-2xl"
            >
              <h3 className="text-xl font-bold mb-4 text-white flex items-center gap-2">
                <Info className="text-blue-400" />
                {translation.applicationReasonTitle || "Application Reason"}
              </h3>
              <p className="text-sm text-ui-textMuted mb-4">
                {translation.applicationSubmittedBy ||
                  "Application submitted by"}{" "}
                <span className="text-white font-semibold">
                  {selectedReasonReg.name}
                </span>
              </p>

              <div className="w-full min-h-[120px] max-h-[300px] overflow-y-auto bg-ui-layer/50 border border-ui-border rounded-lg p-4 text-sm text-white/90 whitespace-pre-wrap custom-scrollbar mb-6">
                {selectedReasonReg.apply_reason || (
                  <span className="text-ui-textMuted italic">
                    {translation.noReasonProvided || "No reason was provided."}
                  </span>
                )}
              </div>

              <div className="flex items-center justify-end">
                <button
                  onClick={() => setSelectedReasonReg(null)}
                  className="px-6 py-2 rounded-lg bg-ui-layer/50 border border-ui-border hover:bg-ui-layer text-white text-sm font-medium transition-colors"
                >
                  {translation.close || "Close"}
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
