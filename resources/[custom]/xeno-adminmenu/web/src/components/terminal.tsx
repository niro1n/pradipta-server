import React from "react";
import { useState, useRef, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  TerminalIcon,
  Play,
  Square,
  RotateCcw,
  Copy,
  Trash2,
  Download,
  Settings,
  Users,
  Activity,
  Server,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Clock,
  Search,
  Filter,
  InfoIcon,
} from "lucide-react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { ScrollArea } from "./ui/scroll-area";
import { Separator } from "./ui/separator";
import type { Player, ServerResource, LogEntry } from "../types";

import { sendNui } from "../lib/sendNui";
import { useTranslation } from "../lib/translation";

export type ServerStats = {
  status: "online" | "offline" | "starting" | "stopping";
  players: number;
  maxPlayers: number;
  uptime: string;
  cpu: number;
  memory: number;
  resources: number;
};

type AdvancedTerminalProps = {
  players: Player[];
  resources: ServerResource[];
  logs: LogEntry[];
  setLogs: React.Dispatch<React.SetStateAction<LogEntry[]>>;
  serverStats: ServerStats;
  onPlayerSelect?: (player: Player) => void;
};

export default function AdvancedTerminal({
  players,
  resources,
  logs,
  setLogs,
  serverStats,
  onPlayerSelect,
}: AdvancedTerminalProps) {
  const translation = useTranslation();
  const [command, setCommand] = useState("");
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [isRunning, setIsRunning] = useState(false);
  const [filteredLogs, setFilteredLogs] = useState<LogEntry[]>([]);
  const [logFilter, setLogFilter] = useState<string | "all">("all");
  const [searchTerm, setSearchTerm] = useState("");
  const [autoScroll, setAutoScroll] = useState(true);

  const terminalRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const COMMON_COMMANDS = [
    { cmd: "help", desc: "Show available commands" },
    { cmd: "status", desc: "Show server status" },
    { cmd: "players", desc: "List online players" },
    { cmd: "kick", desc: "Kick a player", syntax: "kick <id> [reason]" },
    { cmd: "ban", desc: "Ban a player", syntax: "ban <id> [reason]" },
    { cmd: "unban", desc: "Unban a player", syntax: "unban <identifier>" },
    {
      cmd: "giveitem",
      desc: "Give item to a player",
      syntax: "giveitem <id> <item> <amount>",
    },
    {
      cmd: "setjob",
      desc: "Set player job",
      syntax: "setjob <id> <job> <grade>",
    },
    { cmd: "resources", desc: "List all resources" },
    {
      cmd: "ensure",
      desc: "Start or restart a resource",
      syntax: "ensure <resource>",
    },
    { cmd: "start", desc: "Start a resource", syntax: "start <resource>" },
    { cmd: "stop", desc: "Stop a resource", syntax: "stop <resource>" },
    {
      cmd: "restart",
      desc: "Restart a resource",
      syntax: "restart <resource>",
    },
    { cmd: "refresh", desc: "Refresh resource list" },
    {
      cmd: "announce",
      desc: "Send server announcement",
      syntax: "announce <message>",
    },
    { cmd: "weather", desc: "Change weather", syntax: "weather <type>" },
    { cmd: "time", desc: "Set server time", syntax: "time <hour> <minute>" },
    { cmd: "clear", desc: "Clear terminal logs" },
  ];

  useEffect(() => {
    let filtered = logs;

    if (logFilter !== "all") {
      filtered = filtered.filter((log) => log.type === logFilter);
    }

    if (searchTerm) {
      filtered = filtered.filter((log) =>
        log.message.toLowerCase().includes(searchTerm.toLowerCase()),
      );
    }

    setFilteredLogs(filtered);
  }, [logs, logFilter, searchTerm]);

  useEffect(() => {
    if (autoScroll && terminalRef.current) {
      terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
    }
  }, [filteredLogs, autoScroll]);

  useEffect(() => {
    if (inputRef.current) {
      inputRef.current.focus();
    }
  }, []);

  const executeCommand = async (
    cmd: string,
  ): Promise<{ type: "output" | "error"; content: string } | null> => {
    const args = cmd.trim().split(" ");
    const command = args[0].toLowerCase();

    if (command === "clear") {
      setLogs([]);
      return null;
    }

    sendNui("executeCommand", { command: cmd });

    return null;
  };

  const handleCommandSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!command.trim()) return;

    const timestamp = new Date().toLocaleTimeString();

    const commandLog: LogEntry = {
      id: Math.random() * 1000000000000000000,
      timestamp,
      type: "admin",
      message: `$ ${command}`,
    };

    setLogs((prev) => [...prev, commandLog]);
    setCommandHistory((prev) => [...prev, command]);
    setHistoryIndex(-1);

    setIsRunning(true);

    try {
      const result = await executeCommand(command);

      if (result && result.content) {
        const outputLog: LogEntry = {
          id: Math.random() * 1000000000000000000,
          timestamp: new Date().toLocaleTimeString(),
          type: result.type === "error" ? "error" : "info",
          message: result.content,
        };
        setLogs((prev) => [...prev, outputLog]);
      }
    } catch (error) {
      const errorLog: LogEntry = {
        id: Math.random() * 1000000000000000000,
        timestamp: new Date().toLocaleTimeString(),
        type: "error",
        message: "Command execution failed",
      };
      setLogs((prev) => [...prev, errorLog]);
    }

    setIsRunning(false);
    setCommand("");
  };

  const handleQuickCommand = (cmd: string) => {
    setCommand(cmd);
    const syntheticEvent = { preventDefault: () => {} } as React.FormEvent;
    // Execute immediately with the new command
    const timestamp = new Date().toLocaleTimeString();
    const commandLog: LogEntry = {
      id: Math.random() * 1000000000000000000,
      timestamp,
      type: "admin",
      message: `$ ${cmd}`,
    };
    setLogs((prev) => [...prev, commandLog]);
    executeCommand(cmd);
    setCommand("");
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowUp") {
      e.preventDefault();
      if (historyIndex < commandHistory.length - 1) {
        const newIndex = historyIndex + 1;
        setHistoryIndex(newIndex);
        setCommand(commandHistory[commandHistory.length - 1 - newIndex]);
      }
    } else if (e.key === "ArrowDown") {
      e.preventDefault();
      if (historyIndex > 0) {
        const newIndex = historyIndex - 1;
        setHistoryIndex(newIndex);
        setCommand(commandHistory[commandHistory.length - 1 - newIndex]);
      } else if (historyIndex === 0) {
        setHistoryIndex(-1);
        setCommand("");
      }
    }
  };

  const getLogLevelColor = (type: string) => {
    switch (type) {
      case "error":
        return "text-red-400";
      case "warn":
        return "text-yellow-400";
      case "info":
        return "text-blue-400";
      case "debug":
        return "text-gray-400";
      case "chat":
        return "text-green-400";
      case "join":
        return "text-emerald-400";
      case "leave":
        return "text-orange-400";
      case "admin":
        return "text-purple-400";
      default:
        return "text-white";
    }
  };

  const getLogLevelIcon = (type: string) => {
    switch (type) {
      case "error":
        return <XCircle size={12} />;
      case "warn":
        return <AlertTriangle size={12} />;
      case "info":
        return <CheckCircle size={12} />;
      case "debug":
        return <Settings size={12} />;
      case "chat":
        return <Users size={12} />;
      case "join":
        return <Users size={12} />;
      case "leave":
        return <Users size={12} />;
      case "admin":
        return <TerminalIcon size={12} />;
      default:
        return <CheckCircle size={12} />;
    }
  };

  const renderLogMessage = (message: string) => {
    const regex =
      /(\b(?:ID:\s*|id\s+|Player\s+)#?\d+\b|\[\d+\]|\[[a-zA-Z0-9_-]+\])/gi;
    const parts = message.split(regex);

    return parts.map((part, index) => {
      if (!part) return null;

      const playerMatch = part.match(
        /^(?:ID:\s*|id\s+|Player\s+|\[)#?(\d+)\]?$/i,
      );
      if (playerMatch && playerMatch[1]) {
        const playerId = parseInt(playerMatch[1]);
        const player = players.find((p) => p.id === playerId);
        if (player && onPlayerSelect) {
          return (
            <span
              key={index}
              className="text-blue-400 hover:text-blue-300 cursor-pointer underline decoration-dotted font-bold"
              onClick={() => onPlayerSelect(player)}
              title={`Manage ${player.name}`}
            >
              {part}
            </span>
          );
        }
      }

      const resMatch = part.match(/^\[([a-zA-Z0-9_-]+)\]$/);
      if (resMatch && resMatch[1] && !part.match(/^\[\d+\]$/)) {
        const resName = resMatch[1];
        const resource = resources.find(
          (r) => r.name.toLowerCase() === resName.toLowerCase(),
        );
        if (resource) {
          return (
            <span
              key={index}
              className="text-orange-400 hover:text-orange-300 cursor-pointer font-bold underline decoration-dotted"
              onClick={() => {
                setCommand(`restart ${resName}`);
                if (inputRef.current) inputRef.current.focus();
              }}
              title={`Click to prepare restart for ${resName}`}
            >
              {part}
            </span>
          );
        }
      }

      return <span key={index}>{part}</span>;
    });
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0 }}
      className="space-y-6"
    >
      {}
      <div>
        <h1 className="text-2xl font-bold text-white flex items-center gap-2">
          <span className="w-8 h-8 rounded-lg bg-ui-success/10 flex items-center justify-center ">
            <TerminalIcon size={16} className="text-white" />
          </span>
          Live Console
          <span className="ml-auto flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                const logsText = filteredLogs
                  .map(
                    (l) =>
                      `[${l.timestamp}] [${l.type.toUpperCase()}] ${l.message}`,
                  )
                  .join("\n");
                navigator.clipboard.writeText(logsText);
              }}
              className="h-8 bg-gray-800 border-ui-border hover:bg-gray-700 text-white"
              title="Copy All Logs"
            >
              <Copy size={14} />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                const logsText = filteredLogs
                  .map(
                    (l) =>
                      `[${l.timestamp}] [${l.type.toUpperCase()}] ${l.message}`,
                  )
                  .join("\n");
                const blob = new Blob([logsText], { type: "text/plain" });
                const url = URL.createObjectURL(blob);
                const a = document.createElement("a");
                a.href = url;
                a.download = `terminal-logs-${new Date().toISOString().split("T")[0]}.txt`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
              }}
              className="h-8 bg-gray-800 border-ui-border hover:bg-gray-700 text-white"
              title="Export Logs as TXT"
            >
              <Download size={14} />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setAutoScroll(!autoScroll)}
              className={`h-8 ${autoScroll ? "bg-green-800 border-green-600" : "bg-gray-800 border-ui-border"} hover:bg-gray-700 text-white`}
              title={autoScroll ? "Pause Auto-Scroll" : "Resume Auto-Scroll"}
            >
              {autoScroll ? "Auto" : "Paused"}
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setLogs([])}
              className="h-8 bg-gray-800 border-ui-border hover:bg-gray-700 text-white"
              title="Clear Terminal"
            >
              <Trash2 size={14} />
            </Button>
          </span>
        </h1>
        <p className="text-gray-400 ml-10">
          {translation.tmManageMonitor ||
            "Manage and monitor your FiveM server in real time"}
        </p>
      </div>

      <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
        <div className="absolute right-0 top-0 w-64 h-64 bg-ui-success/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
        <CardContent className="relative z-10 pt-6">
          {}
          <div className="flex items-center gap-2 mb-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
              <Input
                placeholder="Search logs..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-9 bg-black/40 border-ui-border text-sm h-9"
              />
            </div>
            <div className="flex items-center gap-1 bg-black/40 p-1 rounded-md border border-ui-border overflow-x-auto">
              {["all", "error", "warn", "info", "chat", "admin"].map(
                (filter) => (
                  <button
                    key={filter}
                    onClick={() => setLogFilter(filter)}
                    className={`px-3 py-1 rounded-sm text-xs font-medium capitalize transition-colors ${logFilter === filter ? "bg-ui-layer text-white shadow-sm" : "text-gray-400 hover:text-white hover:bg-white/5"}`}
                  >
                    {filter}
                  </button>
                ),
              )}
            </div>
          </div>

          {}
          <ScrollArea
            ref={terminalRef}
            className="h-[450px] w-full rounded-md border border-ui-border bg-black/60 backdrop-blur-sm p-4"
          >
            <div className="font-mono text-sm space-y-1">
              {filteredLogs.length === 0 && (
                <div className="text-gray-500 space-y-1">
                  <div>FiveM Server Console v2.0.0</div>
                  <div>Type 'help' for available commands</div>
                  <div className="mt-4 text-ui-success">root@fivem:~$ _</div>
                </div>
              )}

              <AnimatePresence>
                {filteredLogs.map((log) => (
                  <motion.div
                    key={log.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0 }}
                    className={`flex items-start gap-2 py-0.5 group ${log.type === "error" ? "bg-red-500/10 border-l-2 border-red-500 pl-2 -ml-2 rounded-r" : ""}`}
                  >
                    <span className="text-gray-500 text-xs mt-0.5 min-w-[80px]">
                      [{log.timestamp}]
                    </span>
                    <div
                      className={`flex items-center gap-1 min-w-[60px] ${getLogLevelColor(log.type)}`}
                    >
                      {getLogLevelIcon(log.type)}
                      <span className="text-xs font-medium uppercase">
                        {log.type}
                      </span>
                    </div>
                    <span
                      className={`text-sm ${log.type === "admin" ? "text-ui-success" : "text-white"} whitespace-pre-wrap flex-1`}
                    >
                      {renderLogMessage(log.message)}
                    </span>
                    <button
                      onClick={() =>
                        navigator.clipboard.writeText(
                          `[${log.timestamp}] [${log.type.toUpperCase()}] ${log.message}`,
                        )
                      }
                      className="opacity-0 group-hover:opacity-100 text-gray-500 hover:text-white transition-opacity p-1"
                      title="Copy Log"
                    >
                      <Copy size={12} />
                    </button>
                  </motion.div>
                ))}
              </AnimatePresence>

              {isRunning && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="text-ui-orange animate-pulse flex items-center gap-2"
                >
                  <div className="w-2 h-2 bg-ui-orange rounded-full animate-bounce" />
                  Executing command...
                </motion.div>
              )}
            </div>
          </ScrollArea>

          {}
          <form
            onSubmit={handleCommandSubmit}
            className="flex gap-2 mt-4 relative"
          >
            <div className="flex-1 relative">
              {command.trim() &&
                document.activeElement === inputRef.current &&
                (() => {
                  const currentWord = command
                    .trim()
                    .toLowerCase()
                    .split(" ")[0];
                  const isTypingArgs = command.includes(" ");
                  const matchingCommand = COMMON_COMMANDS.find(
                    (c) => c.cmd === currentWord,
                  );
                  const autocompleteList =
                    isTypingArgs && matchingCommand
                      ? [matchingCommand]
                      : COMMON_COMMANDS.filter((c) =>
                          c.cmd.startsWith(currentWord),
                        );

                  if (autocompleteList.length === 0) return null;

                  return (
                    <div className="absolute bottom-full mb-2 left-0 w-full bg-ui-layer/95 backdrop-blur-md border border-ui-border rounded-lg shadow-xl overflow-hidden max-h-48 overflow-y-auto z-50">
                      {autocompleteList.map((c, i) => (
                        <button
                          key={i}
                          className="w-full text-left px-3 py-2 hover:bg-white/10 flex items-center justify-between"
                          onMouseDown={(e) => e.preventDefault()}
                          onClick={() => {
                            setCommand(c.cmd + " ");
                            inputRef.current?.focus();
                          }}
                          type="button"
                        >
                          <div className="flex flex-col">
                            <span className="text-ui-success font-mono font-bold text-sm">
                              {c.cmd}
                            </span>
                            {c.syntax && (
                              <span className="text-gray-500 text-[10px] font-mono mt-0.5">
                                {c.syntax}
                              </span>
                            )}
                          </div>
                          <span className="text-gray-400 text-xs text-right max-w-[50%] leading-tight">
                            {c.desc}
                          </span>
                        </button>
                      ))}
                    </div>
                  );
                })()}
              <Input
                ref={inputRef}
                placeholder="Enter command..."
                className="bg-black/60 border-ui-border text-white font-mono focus:border-ui-success h-11"
                value={command}
                onChange={(e) => setCommand(e.target.value)}
                onKeyDown={handleKeyDown}
                disabled={isRunning}
              />
            </div>
            <Button
              type="submit"
              disabled={isRunning || !command.trim()}
              className="bg-ui-success hover:bg-ui-success/80 text-white px-6 h-11 "
            >
              <Play size={16} />
            </Button>
          </form>

          {}
          <div className="mt-8">
            <div className="flex items-center gap-2 mb-4">
              <TerminalIcon className="h-5 w-5 text-ui-success" />
              <h3 className="text-lg font-bold text-white tracking-wide">
                {translation.tmExtraCommands || "Extra Commands"}
              </h3>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-3">
              {[
                {
                  cmd: "help",
                  label: "Help",
                  icon: <InfoIcon className="w-4 h-4 mr-2" />,
                },
                {
                  cmd: "status",
                  label: "Status",
                  icon: <Activity className="w-4 h-4 mr-2" />,
                },
                {
                  cmd: "players",
                  label: "Players",
                  icon: <Users className="w-4 h-4 mr-2" />,
                },
                {
                  cmd: "resources",
                  label: "Resources",
                  icon: <Server className="w-4 h-4 mr-2" />,
                },
                {
                  cmd: "performance",
                  label: "Performance",
                  icon: <Activity className="w-4 h-4 mr-2" />,
                },
                {
                  cmd: "logs",
                  label: "Logs",
                  icon: <Search className="w-4 h-4 mr-2" />,
                },
                {
                  cmd: "clear",
                  label: "Clear",
                  icon: <Trash2 className="w-4 h-4 mr-2" />,
                },
              ].map(({ cmd, label, icon }) => (
                <button
                  key={cmd}
                  type="button"
                  onClick={() => handleQuickCommand(cmd)}
                  className="flex items-center w-full px-4 py-3 rounded-lg bg-ui-layer/50 border border-ui-border shadow-sm hover:bg-ui-layer hover:border-ui-success transition-all duration-150 text-white font-medium text-sm gap-2 group"
                  style={{ minHeight: 44 }}
                >
                  <span className="text-ui-textMuted group-hover:text-ui-success group-hover:scale-110 transition-all duration-150">
                    {icon}
                  </span>
                  {label}
                </button>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  );
}
