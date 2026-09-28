import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Card, CardContent } from "./ui/card";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "./ui/tabs";
import { Button } from "./ui/button";
import {
  Bug,
  UserX,
  ShieldAlert,
  CheckCircle,
  Clock,
  Trash2,
  Search,
  Filter,
} from "lucide-react";
import { Input } from "./ui/input";
import { sendNui } from "../lib/sendNui";
import { useTranslation } from "../lib/translation";

export default function Reports() {
  const translation = useTranslation();
  const [searchTerm, setSearchTerm] = useState("");
  const [reports, setReports] = useState<any[]>([]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === "loadReports") {
        setReports(event.data.reports || []);
      }
    };
    window.addEventListener("message", handleMessage);
    sendNui("fetchReports");
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  const handleUpdateStatus = (id: number, status: string) => {
    sendNui("updateReportStatus", { reportId: id, status });
  };

  const container = {
    hidden: { opacity: 0 },
    show: { opacity: 1, transition: { staggerChildren: 0.05 } },
  };
  const item = { hidden: { opacity: 0, y: 10 }, show: { opacity: 1, y: 0 } };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "pending":
        return "text-ui-orange bg-ui-orange/10 border-ui-orange/20";
      case "investigating":
        return "text-ui-blue bg-ui-blue/10 border-ui-blue/20";
      case "resolved":
        return "text-ui-success bg-ui-success/10 border-ui-success/20";
      default:
        return "text-gray-400 bg-gray-800 border-gray-700";
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case "pending":
        return "Pending";
      case "investigating":
        return "Investigating";
      case "resolved":
        return "Resolved";
      default:
        return status;
    }
  };

  const renderReportCard = (report: any, icon: React.ReactNode) => (
    <Card
      key={report.id}
      className="bg-ui-layer/50 border border-ui-border hover:bg-ui-layer transition-colors mb-3"
    >
      <CardContent className="p-4">
        <div className="flex justify-between items-start">
          <div className="flex gap-3">
            <div className="w-10 h-10 rounded-xl bg-black/20 flex items-center justify-center shrink-0">
              {icon}
            </div>
            <div>
              <h3 className="text-sm font-bold text-white flex items-center gap-2">
                {report.title}
                <span
                  className={`text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-full border ${getStatusColor(report.status)}`}
                >
                  {getStatusText(report.status)}
                </span>
              </h3>
              <p className="text-xs text-ui-textMuted mt-1 mb-2 line-clamp-2 break-all">
                {report.description}
              </p>
              <div className="flex gap-4 text-[10px] text-gray-500">
                <span>
                  <strong className="text-gray-400">Reporter:</strong>{" "}
                  {report.reporter}
                </span>
                {report.target && (
                  <span>
                    <strong className="text-gray-400">Target:</strong>{" "}
                    {report.target}
                  </span>
                )}
                <span className="flex items-center gap-1">
                  <Clock size={10} /> {report.date}
                </span>
              </div>
            </div>
          </div>
          <div className="flex flex-col gap-2 shrink-0">
            <div className="flex gap-1">
              <Button
                size="icon"
                onClick={() => handleUpdateStatus(report.id, "resolved")}
                className="h-7 w-7 bg-ui-success/10 text-ui-success hover:bg-ui-success hover:text-white transition-colors"
              >
                <CheckCircle size={12} />
              </Button>
              <Button
                size="icon"
                onClick={() => handleUpdateStatus(report.id, "delete")}
                className="h-7 w-7 bg-ui-danger/10 text-ui-danger hover:bg-ui-danger hover:text-white transition-colors"
              >
                <Trash2 size={12} />
              </Button>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  const bugReports = reports.filter(
    (r) =>
      r.type === "bug" &&
      (r.title || "").toLowerCase().includes(searchTerm.toLowerCase()),
  );
  const playerReports = reports.filter(
    (r) =>
      r.type === "player" &&
      (r.title || "").toLowerCase().includes(searchTerm.toLowerCase()),
  );
  const staffReports = reports.filter(
    (r) =>
      r.type === "staff" &&
      (r.title || "").toLowerCase().includes(searchTerm.toLowerCase()),
  );

  return (
    <motion.div
      initial="hidden"
      animate="show"
      variants={container}
      className="h-full flex flex-col pb-0"
    >
      <motion.div
        variants={item}
        className="flex flex-col md:flex-row md:items-center justify-between gap-4 shrink-0"
      >
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            <span className="w-8 h-8 rounded-lg bg-ui-orange/10 flex items-center justify-center">
              <ShieldAlert size={16} className="text-ui-orange" />
            </span>
            Server Reports
          </h1>
          <p className="text-gray-400 mt-1">
            Manage player submitted reports, bugs, and complaints.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <div className="relative">
            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
              size={16}
            />
            <Input
              placeholder="Search reports..."
              className="pl-9 bg-ui-layer/50 border-ui-border text-white w-64"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <Button
            variant="outline"
            className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white"
          >
            <Filter size={16} />
          </Button>
        </div>
      </motion.div>

      <motion.div
        variants={item}
        className="flex-1 flex flex-col mt-6 overflow-hidden"
      >
        <Tabs
          defaultValue="player"
          className="w-full flex-1 flex flex-col overflow-hidden"
        >
          <TabsList className="bg-ui-layer/50 border border-ui-border p-1 rounded-xl h-auto flex flex-wrap justify-start gap-1 mb-6 shrink-0">
            <TabsTrigger
              value="player"
              className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange py-2 px-4 transition-all"
            >
              <UserX size={16} />{" "}
              <span className="font-medium text-sm">
                {translation.rpPlayerReports || "Player Reports"}
              </span>
              <span className="ml-1 bg-ui-layer px-1.5 py-0.5 rounded text-[10px]">
                {reports.filter((r) => r.type === "player").length}
              </span>
            </TabsTrigger>
            <TabsTrigger
              value="bug"
              className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange py-2 px-4 transition-all"
            >
              <Bug size={16} />{" "}
              <span className="font-medium text-sm">
                {translation.rpBugReports || "Bug Reports"}
              </span>
              <span className="ml-1 bg-ui-layer px-1.5 py-0.5 rounded text-[10px]">
                {reports.filter((r) => r.type === "bug").length}
              </span>
            </TabsTrigger>
            <TabsTrigger
              value="staff"
              className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange py-2 px-4 transition-all"
            >
              <ShieldAlert size={16} />{" "}
              <span className="font-medium text-sm">
                {translation.rpStaffReports || "Staff Reports"}
              </span>
              <span className="ml-1 bg-ui-layer px-1.5 py-0.5 rounded text-[10px]">
                {reports.filter((r) => r.type === "staff").length}
              </span>
            </TabsTrigger>
          </TabsList>

          <div className="bg-ui-panel border-ui-border border rounded-xl p-6 flex-1 overflow-y-auto custom-scrollbar">
            <TabsContent
              value="player"
              className="h-full mt-0 focus-visible:outline-none"
            >
              {playerReports.length > 0 ? (
                playerReports.map((r) =>
                  renderReportCard(
                    r,
                    <UserX size={18} className="text-gray-400" />,
                  ),
                )
              ) : (
                <div className="flex flex-col items-center justify-center h-full text-gray-500">
                  <UserX size={32} className="mb-2 opacity-50" />
                  <p>No player reports found.</p>
                </div>
              )}
            </TabsContent>

            <TabsContent
              value="bug"
              className="h-full mt-0 focus-visible:outline-none"
            >
              {bugReports.length > 0 ? (
                bugReports.map((r) =>
                  renderReportCard(
                    r,
                    <Bug size={18} className="text-gray-400" />,
                  ),
                )
              ) : (
                <div className="flex flex-col items-center justify-center h-full text-gray-500">
                  <Bug size={32} className="mb-2 opacity-50" />
                  <p>No bug reports found.</p>
                </div>
              )}
            </TabsContent>

            <TabsContent
              value="staff"
              className="h-full mt-0 focus-visible:outline-none"
            >
              {staffReports.length > 0 ? (
                staffReports.map((r) =>
                  renderReportCard(
                    r,
                    <ShieldAlert size={18} className="text-gray-400" />,
                  ),
                )
              ) : (
                <div className="flex flex-col items-center justify-center h-full text-gray-500">
                  <ShieldAlert size={32} className="mb-2 opacity-50" />
                  <p>No staff reports found.</p>
                </div>
              )}
            </TabsContent>
          </div>
        </Tabs>
      </motion.div>
    </motion.div>
  );
}
