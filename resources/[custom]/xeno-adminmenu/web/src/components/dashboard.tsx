import React from "react";
import { motion } from "framer-motion";
import {
  Users,
  Shield,
  Activity,
  Zap,
  Server,
  Wifi,
  Gauge,
  LayoutDashboard,
  RefreshCw,
  DoorOpen,
  Ban,
  Megaphone,
  AlertTriangle,
  Cpu,
} from "lucide-react";
import { Card, CardContent } from "./ui/card";
import { Button } from "./ui/button";
import { Progress } from "./ui/progress";
import type { LogEntry } from "../types";
import { useTranslation } from "../lib/translation";
import { sendNui } from "../lib/sendNui";

type DashboardProps = {
  stats: {
    onlinePlayers: number;
    activeAdmins: number;
    maxPlayers: number;
    averagePing: number;
    mapResources: number;
    topPlayers:
      | { index: number; playerName: string; playtime: number }[]
      | string;
    serverName?: string;
    serverUptime?: string;
  };
  recentLogs: LogEntry[];
  economyStatus: Record<string, any>;
};

export default function Dashboard({
  stats,
  recentLogs,
  economyStatus,
}: DashboardProps) {
  const translation = useTranslation();

  const container = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: { staggerChildren: 0.1 },
    },
  };

  const item = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0 },
  };

  return (
    <motion.div
      variants={container}
      initial="hidden"
      animate="show"
      className="space-y-4 pb-10"
    >
      {}
      <motion.div variants={item}>
        <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white p-6 relative overflow-hidden">
          <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />

          <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl bg-ui-layer/50 flex items-center justify-center border border-ui-border relative z-10">
                <Server size={24} className="text-ui-blue" />
              </div>
              <div className="relative z-10">
                <span className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted">
                  {translation.dbServer || "SERVER"}
                </span>
                <h2 className="text-xl font-bold text-white tracking-wide">
                  {stats.serverName || "change-me | Server"}
                </h2>
                <div className="flex items-center gap-2 mt-1">
                  <Activity size={12} className="text-ui-success" />
                  <span className="text-xs text-ui-textMuted">
                    Uptime:{" "}
                    <span className="text-white font-medium">
                      {stats.serverUptime || "0m"}
                    </span>
                  </span>
                </div>
              </div>
            </div>
            <Button
              variant="outline"
              className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white flex items-center gap-2 relative z-10"
              onClick={() => sendNui("refreshDashboard")}
            >
              <RefreshCw size={14} /> Refresh
            </Button>
          </div>

          <div className="relative z-10">
            <div className="flex items-center justify-between mb-3">
              <span className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted">
                {translation.dbPlayerCapacity || "Player Capacity"}
              </span>
              <span className="text-sm font-bold text-ui-blue">
                {stats.onlinePlayers}{" "}
                <span className="text-ui-textMuted font-normal">
                  / {stats.maxPlayers}
                </span>
              </span>
            </div>
            <Progress
              value={(stats.onlinePlayers / stats.maxPlayers) * 100}
              className="h-2.5 bg-ui-layer/80"
              indicatorClassName="bg-ui-blue"
            />
          </div>
        </Card>
      </motion.div>

      {}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <motion.div variants={item}>
          <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white p-5 flex items-center justify-between">
            <div>
              <span className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted mb-1 block">
                {translation.dbOnlinePlayers || "ONLINE PLAYERS"}
              </span>
              <div className="text-2xl font-black text-white leading-none">
                {stats.onlinePlayers}
              </div>
              <span className="text-xs text-ui-textMuted mt-1.5 block">
                {stats.maxPlayers - stats.onlinePlayers} slots free
              </span>
            </div>
            <div className="w-12 h-12 rounded-xl bg-ui-blue/10 flex items-center justify-center ">
              <Users size={20} className="text-ui-blue" />
            </div>
          </Card>
        </motion.div>

        <motion.div variants={item}>
          <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white p-5 flex items-center justify-between">
            <div>
              <span className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted mb-1 block">
                MAX PLAYERS
              </span>
              <div className="text-2xl font-black text-white leading-none">
                {stats.maxPlayers}
              </div>
              <span className="text-xs text-ui-textMuted mt-1.5 block">
                {translation.dbPlayerCapacity || "Player Capacity"}
              </span>
            </div>
            <div className="w-12 h-12 rounded-xl bg-ui-violet/10 flex items-center justify-center ">
              <Activity size={20} className="text-ui-violet" />
            </div>
          </Card>
        </motion.div>

        <motion.div variants={item}>
          <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white p-5 flex items-center justify-between">
            <div>
              <span className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted mb-1 block">
                RESOURCES
              </span>
              <div className="text-2xl font-black text-white leading-none">
                {stats.mapResources}
              </div>
              <span className="text-xs text-ui-textMuted mt-1.5 block">
                Active resources
              </span>
            </div>
            <div className="w-12 h-12 rounded-xl bg-ui-success/10 flex items-center justify-center ">
              <Server size={20} className="text-ui-success" />
            </div>
          </Card>
        </motion.div>

        <motion.div variants={item}>
          <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white p-5 flex items-center justify-between">
            <div>
              <span className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted mb-1 block">
                PING
              </span>
              <div className="text-2xl font-black text-white leading-none">
                {stats.averagePing}
                <span className="text-sm text-ui-textMuted font-normal ml-1">
                  ms
                </span>
              </div>
              <span className="text-xs text-ui-textMuted mt-1.5 block">
                Average response
              </span>
            </div>
            <div className="w-12 h-12 rounded-xl bg-ui-amber/10 flex items-center justify-center ">
              <Wifi size={20} className="text-ui-amber" />
            </div>
          </Card>
        </motion.div>
      </div>

      {}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {}
        <motion.div variants={item} className="lg:col-span-2">
          <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white p-6 h-full">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-8 h-8 rounded-lg bg-ui-pink/10 flex items-center justify-center ">
                <Gauge size={16} className="text-ui-pink" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-white">
                  System Performance
                </h3>
                <p className="text-[10px] text-ui-textMuted uppercase tracking-wider mt-0.5">
                  Network & Map status
                </p>
              </div>
            </div>

            <div className="space-y-6">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-ui-textMuted">
                    Average Ping
                  </span>
                  <span className="text-xs font-bold text-white">
                    {stats.averagePing}{" "}
                    <span className="text-ui-textMuted">ms</span>
                  </span>
                </div>
                <Progress
                  value={Math.min((stats.averagePing / 100) * 100, 100)}
                  className="h-1.5 bg-ui-layer"
                  indicatorClassName="bg-ui-pink"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-ui-textMuted">
                    Map Resources
                  </span>
                  <span className="text-xs font-bold text-white">
                    {stats.mapResources}%
                  </span>
                </div>
                <Progress
                  value={stats.mapResources}
                  className="h-1.5 bg-ui-layer"
                  indicatorClassName="bg-ui-violet"
                />
              </div>

              <div className="grid grid-cols-2 gap-4 mt-6">
                <div className="bg-ui-layer/50 border border-ui-border rounded-xl p-4 flex flex-col justify-between">
                  <div className="flex items-center gap-2 mb-2">
                    <div className="w-4 h-4 rounded-full bg-ui-success/20 flex items-center justify-center">
                      <div className="w-1.5 h-1.5 rounded-full bg-ui-success"></div>
                    </div>
                    <span className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted">
                      TOTAL MONEY
                    </span>
                  </div>
                  <div className="text-lg font-black text-white">
                    ${economyStatus.totalMoney}
                  </div>
                </div>
                <div className="bg-ui-layer/50 border border-ui-border rounded-xl p-4 flex flex-col justify-between">
                  <div className="flex items-center gap-2 mb-2">
                    <div className="w-4 h-4 rounded-full bg-ui-blue/20 flex items-center justify-center">
                      <div className="w-1.5 h-1.5 rounded-full bg-ui-blue"></div>
                    </div>
                    <span className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted">
                      RICHEST
                    </span>
                  </div>
                  <div className="text-lg font-black text-white">
                    {economyStatus.richestPlayer}
                  </div>
                </div>
              </div>
            </div>
          </Card>
        </motion.div>

        {}
        <motion.div variants={item}>
          <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white p-6 h-full">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-8 h-8 rounded-lg bg-ui-blue/10 flex items-center justify-center ">
                <LayoutDashboard size={16} className="text-ui-blue" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-white">
                  Server Overview
                </h3>
                <p className="text-[10px] text-ui-textMuted uppercase tracking-wider mt-0.5">
                  Live server status
                </p>
              </div>
            </div>

            <div className="space-y-0">
              <div className="flex items-center justify-between py-3 border-b border-ui-border/50">
                <span className="text-xs font-medium text-ui-textMuted">
                  Server
                </span>
                <span className="text-xs font-bold text-white">
                  {stats.serverName || "change-me | Server"}
                </span>
              </div>
              <div className="flex items-center justify-between py-3 border-b border-ui-border/50">
                <span className="text-xs font-medium text-ui-textMuted">
                  Online Players
                </span>
                <span className="text-xs font-bold text-ui-blue">
                  {stats.onlinePlayers} / {stats.maxPlayers}
                </span>
              </div>
              <div className="flex items-center justify-between py-3 border-b border-ui-border/50">
                <span className="text-xs font-medium text-ui-textMuted">
                  Active Admins
                </span>
                <span className="text-xs font-bold text-white">
                  {stats.activeAdmins}
                </span>
              </div>
              <div className="flex items-center justify-between py-3 border-b border-ui-border/50">
                <span className="text-xs font-medium text-ui-textMuted">
                  Resources
                </span>
                <span className="text-xs font-bold text-white">
                  {stats.mapResources}
                </span>
              </div>
              <div className="flex items-center justify-between py-3">
                <span className="text-xs font-medium text-ui-textMuted">
                  Uptime
                </span>
                <span className="text-xs font-bold text-white">
                  {stats.serverUptime || "0m"}
                </span>
              </div>
            </div>
          </Card>
        </motion.div>
      </div>

      {}
      <div className="grid grid-cols-1 gap-4">
        <motion.div variants={item}>
          <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white h-full">
            <CardContent className="p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-8 h-8 rounded-lg bg-ui-violet/10 flex items-center justify-center ">
                  <AlertTriangle size={16} className="text-ui-violet" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-white">Recent Logs</h3>
                  <p className="text-[10px] text-ui-textMuted uppercase tracking-wider mt-0.5">
                    {translation.latestActivity || "Latest server activity"}
                  </p>
                </div>
              </div>

              <div className="space-y-3 h-[180px] overflow-y-auto pr-2 custom-scrollbar">
                {recentLogs.slice(0, 4).map((log) => (
                  <div
                    key={log.id}
                    className={`flex items-start gap-3 p-3 rounded-lg border ${
                      log.type === "error"
                        ? "bg-ui-danger/5 border-ui-danger/20"
                        : log.type === "admin"
                          ? "bg-ui-violet/5 border-ui-violet/20"
                          : log.type === "player"
                            ? "bg-ui-blue/5 border-ui-blue/20"
                            : "bg-ui-success/5 border-ui-success/20"
                    }`}
                  >
                    <div
                      className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${
                        log.type === "error"
                          ? "bg-ui-danger/20 text-ui-danger"
                          : log.type === "admin"
                            ? "bg-ui-violet/20 text-ui-violet"
                            : log.type === "player"
                              ? "bg-ui-blue/20 text-ui-blue"
                              : "bg-ui-success/20 text-ui-success"
                      }`}
                    >
                      {log.type === "error" && <AlertTriangle size={14} />}
                      {log.type === "admin" && <Shield size={14} />}
                      {log.type === "player" && <Users size={14} />}
                      {log.type === "system" && <Cpu size={14} />}
                    </div>

                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-white truncate">
                        {log.message}
                      </p>
                      <p className="text-xs text-ui-textMuted mt-1">
                        {log.timestamp}
                      </p>
                    </div>
                  </div>
                ))}
                {recentLogs.length === 0 && (
                  <div className="flex flex-col items-center justify-center h-full text-ui-textMuted">
                    <span className="text-sm">No recent logs available</span>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </motion.div>
  );
}
