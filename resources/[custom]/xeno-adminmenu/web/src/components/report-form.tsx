import React, { useState } from "react";
import { motion } from "framer-motion";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { ShieldAlert, Send, X, User, Bug, Shield } from "lucide-react";
import { sendNui } from "../lib/sendNui";
import { useTranslation } from "../lib/translation";

export default function ReportForm({ onClose }: { onClose: () => void }) {
  const translation = useTranslation();
  const [activeTab, setActiveTab] = useState<"create" | "my-reports">("create");
  const [myReports, setMyReports] = useState<any[]>([]);

  const [type, setType] = useState<"player" | "bug" | "staff">("player");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [target, setTarget] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  React.useEffect(() => {
    if (activeTab === "my-reports") {
      sendNui("fetchMyReports");
    }
  }, [activeTab]);

  React.useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === "loadMyReports") {
        setMyReports(event.data.reports || []);
      }
    };
    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !description.trim()) return;

    setIsSubmitting(true);
    await sendNui("submitReport", {
      type,
      title,
      reason: description,
      reported: type === "player" || type === "staff" ? target : "",
    });

    setIsSubmitting(false);
    onClose();
  };

  const handleClose = () => {
    sendNui("closeReportForm");
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/40 backdrop-blur-md p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        className="w-full max-w-4xl"
      >
        <div className="bg-[#0f0f11]/95 backdrop-blur-xl border border-ui-border shadow-2xl overflow-hidden relative rounded-2xl flex flex-col min-h-[600px]">
          {}
          <div className="flex items-center justify-between p-6 pb-4 border-b border-white/5">
            <div className="flex items-center gap-4">
              <div className="bg-ui-orange/20 p-3 rounded-xl flex items-center justify-center">
                <ShieldAlert className="text-ui-orange" size={24} />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-white tracking-wide">
                  {translation.rpReportCenter || "Report Center"}
                </h1>
                <p className="text-sm text-gray-400">
                  Report players, bugs or staff members
                </p>
              </div>
            </div>
            <button
              onClick={handleClose}
              className="p-2 text-gray-400 hover:text-white rounded-full hover:bg-white/10 transition-colors"
            >
              <X size={20} />
            </button>
          </div>

          {}
          <div className="flex items-center px-8 pt-2 border-b border-white/5">
            <button
              onClick={() => setActiveTab("create")}
              className={`pb-3 px-2 font-semibold text-sm transition-colors border-b-2 ${
                activeTab === "create"
                  ? "text-ui-orange border-ui-orange"
                  : "text-gray-500 border-transparent hover:text-gray-300"
              }`}
            >
              Create
            </button>
            <button
              onClick={() => setActiveTab("my-reports")}
              className={`pb-3 px-4 font-semibold text-sm transition-colors border-b-2 ${
                activeTab === "my-reports"
                  ? "text-ui-orange border-ui-orange"
                  : "text-gray-500 border-transparent hover:text-gray-300"
              }`}
            >
              My Reports
            </button>
          </div>

          {}
          <div className="p-6 flex-1 flex flex-col overflow-hidden">
            {activeTab === "create" && (
              <div className="bg-[#18181b]/80 border border-white/5 rounded-2xl p-6 flex-1 overflow-y-auto custom-scrollbar">
                <div className="mb-6">
                  <h2 className="text-xl font-bold text-white mb-1">
                    {translation.rpCreateNewReport || "Create a new report"}
                  </h2>
                  <p className="text-sm text-gray-400">
                    Choose a category and provide clear details to help staff
                    respond faster.
                  </p>
                </div>

                <form onSubmit={handleSubmit} className="space-y-4">
                  {}
                  <div className="grid grid-cols-3 gap-4 mb-6">
                    <button
                      type="button"
                      onClick={() => setType("player")}
                      className={`flex items-center gap-4 p-4 rounded-xl border transition-all ${
                        type === "player"
                          ? "bg-ui-blue/10 border-ui-blue/50"
                          : "bg-black/20 border-white/5 hover:bg-black/40"
                      }`}
                    >
                      <div
                        className={`p-2.5 rounded-lg ${type === "player" ? "bg-ui-blue/20 text-ui-blue" : "bg-[#27272a] text-gray-400"}`}
                      >
                        <User size={20} />
                      </div>
                      <span
                        className={`font-bold tracking-wide ${type === "player" ? "text-ui-blue" : "text-gray-300"}`}
                      >
                        {translation.rpPlayerReport || "Player Report"}
                      </span>
                    </button>

                    <button
                      type="button"
                      onClick={() => setType("bug")}
                      className={`flex items-center gap-4 p-4 rounded-xl border transition-all ${
                        type === "bug"
                          ? "bg-ui-orange/10 border-ui-orange/50"
                          : "bg-black/20 border-white/5 hover:bg-black/40"
                      }`}
                    >
                      <div
                        className={`p-2.5 rounded-lg ${type === "bug" ? "bg-ui-orange/20 text-ui-orange" : "bg-[#27272a] text-gray-400"}`}
                      >
                        <Bug size={20} />
                      </div>
                      <span
                        className={`font-bold tracking-wide ${type === "bug" ? "text-ui-orange" : "text-gray-300"}`}
                      >
                        {translation.rpBugReport || "Bug Report"}
                      </span>
                    </button>

                    <button
                      type="button"
                      onClick={() => setType("staff")}
                      className={`flex items-center gap-4 p-4 rounded-xl border transition-all ${
                        type === "staff"
                          ? "bg-ui-danger/10 border-ui-danger/50"
                          : "bg-black/20 border-white/5 hover:bg-black/40"
                      }`}
                    >
                      <div
                        className={`p-2.5 rounded-lg ${type === "staff" ? "bg-ui-danger/20 text-ui-danger" : "bg-[#27272a] text-gray-400"}`}
                      >
                        <Shield size={20} />
                      </div>
                      <span
                        className={`font-bold tracking-wide ${type === "staff" ? "text-ui-danger" : "text-gray-300"}`}
                      >
                        {translation.rpStaffReport || "Staff Report"}
                      </span>
                    </button>
                  </div>

                  {}
                  {(type === "player" || type === "staff") && (
                    <div className="bg-black/20 border border-white/5 rounded-xl p-3 px-4">
                      <label className="text-[10px] font-bold text-gray-400 uppercase tracking-wider block mb-1">
                        Target player ID
                      </label>
                      <input
                        placeholder="0"
                        value={target}
                        onChange={(e) => setTarget(e.target.value)}
                        className="w-full bg-transparent text-white text-sm focus:outline-none placeholder:text-gray-600 font-medium"
                      />
                    </div>
                  )}

                  {}
                  <div className="bg-black/20 border border-white/5 rounded-xl p-3 px-4">
                    <label className="text-[10px] font-bold text-gray-400 uppercase tracking-wider block mb-1">
                      Subject
                    </label>
                    <input
                      required
                      placeholder="Short summary of the issue"
                      value={title}
                      onChange={(e) => setTitle(e.target.value)}
                      className="w-full bg-transparent text-white text-sm focus:outline-none placeholder:text-gray-600 font-medium"
                    />
                  </div>

                  {}
                  <div className="bg-black/20 border border-white/5 rounded-xl p-3 px-4 h-[140px] flex flex-col">
                    <label className="text-[10px] font-bold text-gray-400 uppercase tracking-wider block mb-1">
                      Description
                    </label>
                    <textarea
                      required
                      placeholder="Describe what happened with as much detail as possible"
                      value={description}
                      onChange={(e) => setDescription(e.target.value)}
                      className="w-full flex-1 bg-transparent text-white text-sm focus:outline-none placeholder:text-gray-600 font-medium resize-none"
                    ></textarea>
                  </div>

                  {}
                  <div className="pt-2 flex">
                    <Button
                      type="submit"
                      disabled={
                        isSubmitting || !title.trim() || !description.trim()
                      }
                      className="bg-gradient-to-r from-ui-orange to-ui-orange/80 hover:from-ui-orange hover:to-ui-orange text-black font-bold h-12 px-6 rounded-xl shadow-lg hover:shadow-ui-orange/20 transition-all flex items-center gap-2"
                    >
                      {isSubmitting ? (
                        "Submitting..."
                      ) : (
                        <>
                          <Send size={18} />
                          Submit report
                        </>
                      )}
                    </Button>
                  </div>
                </form>
              </div>
            )}

            {activeTab === "my-reports" && (
              <div className="flex-1 overflow-y-auto space-y-3 custom-scrollbar pr-2">
                {myReports.length === 0 ? (
                  <div className="flex flex-col items-center justify-center h-full text-gray-400 gap-2">
                    <ShieldAlert size={32} className="text-gray-600" />
                    <p>You haven't submitted any reports yet.</p>
                  </div>
                ) : (
                  myReports.map((report) => (
                    <div
                      key={report.id}
                      className="bg-[#18181b]/80 border border-white/5 rounded-xl p-4 flex flex-col gap-2 relative"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <div className="flex items-center gap-2 mb-1">
                            <span
                              className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-md ${
                                report.type === "player"
                                  ? "bg-ui-blue/20 text-ui-blue"
                                  : report.type === "bug"
                                    ? "bg-ui-orange/20 text-ui-orange"
                                    : "bg-ui-danger/20 text-ui-danger"
                              }`}
                            >
                              {report.type} Report
                            </span>
                            <span className="text-xs text-gray-500">
                              {report.date}
                            </span>
                          </div>
                          <h3 className="font-bold text-white text-sm mt-2">
                            {report.title}
                          </h3>
                        </div>
                        <span
                          className={`text-[10px] font-bold uppercase px-2 py-1 rounded-md border ${
                            report.status === "pending"
                              ? "bg-yellow-500/10 text-yellow-500 border-yellow-500/20"
                              : report.status === "in-progress"
                                ? "bg-blue-500/10 text-blue-500 border-blue-500/20"
                                : report.status === "resolved"
                                  ? "bg-green-500/10 text-green-500 border-green-500/20"
                                  : "bg-gray-500/10 text-gray-400 border-gray-500/20"
                          }`}
                        >
                          {report.status}
                        </span>
                      </div>
                      <p className="text-xs text-gray-400 mt-2 bg-black/20 p-3 rounded-lg border border-white/5">
                        {report.reason}
                      </p>
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        </div>
      </motion.div>
    </div>
  );
}
