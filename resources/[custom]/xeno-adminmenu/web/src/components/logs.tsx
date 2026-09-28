import { useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import {
  Search,
  Filter,
  AlertTriangle,
  Shield,
  Users,
  Cpu,
  Trash2,
  RefreshCw,
  ChevronDown,
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
import { Badge } from "./ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "./ui/dropdown-menu";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "./ui/alert-dialog";
import { sendNui } from "../lib/sendNui";
import { useTranslation } from "../lib/translation";

type LogEntry = {
  id: number;
  type: string;
  message: string;
  admin_name?: string;
  target_name?: string;
  details?: any;
  created_at: string;
};

export default function Logs() {
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterType, setFilterType] = useState<string>("all");
  const [currentPage, setCurrentPage] = useState(1);
  const [isLoading, setIsLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [showClearConfirm, setShowClearConfirm] = useState(false);

  const translation = useTranslation();

  const fetchLogs = useCallback(
    (page: number, filter: string, append = false) => {
      setIsLoading(true);
      sendNui("fetchLogs", { filter, page });
    },
    [],
  );

  useEffect(() => {
    fetchLogs(1, "all");

    const handleMessage = (event: MessageEvent) => {
      const { action, logs: receivedLogs, page } = event.data;
      if (action === "receiveLogs") {
        setIsLoading(false);
        if (page === 1) {
          setLogs(receivedLogs || []);
        } else {
          setLogs((prev) => [...prev, ...(receivedLogs || [])]);
        }
        setHasMore((receivedLogs || []).length >= 50);
        setCurrentPage(page || 1);
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  const handleFilterChange = useCallback(
    (filter: string) => {
      setFilterType(filter);
      setCurrentPage(1);
      setLogs([]);
      fetchLogs(1, filter);
    },
    [fetchLogs],
  );

  const handleLoadMore = useCallback(() => {
    const nextPage = currentPage + 1;
    fetchLogs(nextPage, filterType, true);
  }, [currentPage, filterType, fetchLogs]);

  const handleRefresh = useCallback(() => {
    setCurrentPage(1);
    setLogs([]);
    fetchLogs(1, filterType);
  }, [filterType, fetchLogs]);

  const handleClearLogs = useCallback(() => {
    sendNui("clearLogs", {});
    setLogs([]);
    setShowClearConfirm(false);
  }, []);

  const filteredLogs = logs.filter((log) => {
    if (!searchQuery) return true;
    const q = searchQuery.toLowerCase();
    return (
      log.message.toLowerCase().includes(q) ||
      (log.admin_name && log.admin_name.toLowerCase().includes(q)) ||
      (log.target_name && log.target_name.toLowerCase().includes(q))
    );
  });

  const getTypeIcon = (type: string) => {
    switch (type) {
      case "error":
        return <AlertTriangle size={14} className="text-white" />;
      case "admin":
        return <Shield size={14} className="text-white" />;
      case "player":
        return <Users size={14} className="text-white" />;
      case "ban":
        return <Shield size={14} className="text-white" />;
      default:
        return <Cpu size={14} className="text-white" />;
    }
  };

  const getTypeStyle = (type: string) => {
    switch (type) {
      case "error":
        return "bg-gradient-to-r from-red-500/10 to-rose-500/5 border border-red-500/20";
      case "admin":
        return "bg-gradient-to-r from-violet-500/10 to-purple-500/5 border border-violet-500/20";
      case "player":
        return "bg-gradient-to-r from-blue-500/10 to-cyan-500/5 border border-blue-500/20";
      case "ban":
        return "bg-gradient-to-r from-orange-500/10 to-amber-500/5 border border-orange-500/20";
      case "staff":
        return "bg-gradient-to-r from-emerald-500/10 to-green-500/5 border border-emerald-500/20";
      case "group":
        return "bg-gradient-to-r from-pink-500/10 to-rose-500/5 border border-pink-500/20";
      default:
        return "bg-gradient-to-r from-green-500/10 to-emerald-500/5 border border-green-500/20";
    }
  };

  const getIconBgStyle = (type: string) => {
    switch (type) {
      case "error":
        return "bg-ui-danger/10";
      case "admin":
        return "bg-gradient-to-br from-violet-500 to-purple-600";
      case "player":
        return "bg-gradient-to-br from-blue-500 to-cyan-600";
      case "ban":
        return "bg-gradient-to-br from-orange-500 to-amber-600";
      case "staff":
        return "bg-gradient-to-br from-emerald-500 to-green-600";
      case "group":
        return "bg-gradient-to-br from-pink-500 to-rose-600";
      default:
        return "bg-ui-success/10";
    }
  };

  const formatTimestamp = (ts: string) => {
    try {
      const date = new Date(ts);
      return date.toLocaleString();
    } catch {
      return ts;
    }
  };

  const filterOptions = [
    { value: "all", label: "All Logs" },
    { value: "admin", label: "Admin Actions" },
    { value: "player", label: "Player Events" },
    { value: "ban", label: "Ban Events" },
    { value: "staff", label: "Staff Changes" },
    { value: "group", label: "Group Changes" },
    { value: "system", label: "System Events" },
    { value: "error", label: "Errors" },
  ];

  return (
    <>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0 }}
        className="space-y-4"
      >
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            <span className="w-8 h-8 rounded-lg bg-ui-amber/10 flex items-center justify-center ">
              <AlertTriangle size={16} className="text-white" />
            </span>
            {translation.logsHeader || "Server Logs"}
          </h1>
          <p className="text-gray-400 ml-10">
            {translation.afterHeaderLogs ||
              "View and analyze server activity logs"}
          </p>
        </div>

        <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white">
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <AlertTriangle className="h-5 w-5 text-amber-400" />
                  {translation.logsHeaderTwo || "Activity Logs"}
                </CardTitle>
                <CardDescription className="text-gray-400">
                  {filteredLogs.length} {translation.logsFound || "logs found"}
                </CardDescription>
              </div>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  className="bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer hover:text-white"
                  onClick={handleRefresh}
                >
                  <RefreshCw size={14} className="mr-1" />
                  Refresh
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  className="bg-ui-danger/10 border-ui-danger/30 text-ui-danger hover:bg-ui-danger/20"
                  onClick={() => setShowClearConfirm(true)}
                >
                  <Trash2 size={14} className="mr-1" />
                  Clear All
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col md:flex-row gap-4 mb-6">
              <div className="relative flex-1">
                <Search
                  className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                  size={16}
                />
                <Input
                  placeholder="Search logs by message, admin, or target..."
                  className="pl-9 bg-ui-layer/50 border-ui-border text-white"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>

              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button
                    variant="outline"
                    className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white flex items-center gap-2"
                  >
                    <Filter size={16} />
                    {filterOptions.find((f) => f.value === filterType)?.label ||
                      "Filter"}
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent className="bg-ui-layer border-ui-border text-white">
                  {filterOptions.map((opt) => (
                    <DropdownMenuItem
                      key={opt.value}
                      onClick={() => handleFilterChange(opt.value)}
                      className={`cursor-pointer ${filterType === opt.value ? "bg-ui-blue/20 text-ui-blue" : "hover:bg-ui-layer"}`}
                    >
                      {opt.label}
                    </DropdownMenuItem>
                  ))}
                </DropdownMenuContent>
              </DropdownMenu>
            </div>

            <div className="space-y-3 max-h-[500px] overflow-y-auto scrollbar-hide pr-2">
              {filteredLogs.length === 0 && !isLoading ? (
                <div className="text-center py-12 text-gray-400">
                  <div className="w-16 h-16 mx-auto mb-4 bg-ui-layer/50 rounded-full flex items-center justify-center">
                    <AlertTriangle size={32} className="opacity-50" />
                  </div>
                  <h3 className="text-lg font-semibold mb-2">
                    {translation.lgNoLogsFound || "No logs found"}
                  </h3>
                  <p className="text-sm">
                    {translation.lgServerActivity ||
                      "Server activity logs will appear here"}
                  </p>
                </div>
              ) : (
                filteredLogs.map((log) => (
                  <div
                    key={log.id}
                    className={`flex items-start gap-3 p-3 rounded-md ${getTypeStyle(log.type)}`}
                  >
                    <div
                      className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${getIconBgStyle(log.type)}`}
                    >
                      {getTypeIcon(log.type)}
                    </div>

                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <Badge
                          variant="outline"
                          className="text-[10px] border-ui-border/50 text-gray-400 px-1.5 py-0"
                        >
                          {log.type}
                        </Badge>
                        {log.admin_name && (
                          <span className="text-xs text-gray-400">
                            by{" "}
                            <span className="text-gray-300 font-medium">
                              {log.admin_name}
                            </span>
                          </span>
                        )}
                        {log.target_name && (
                          <span className="text-xs text-gray-400">
                            →{" "}
                            <span className="text-gray-300 font-medium">
                              {log.target_name}
                            </span>
                          </span>
                        )}
                      </div>
                      <p className="text-sm text-white">{log.message}</p>
                      <p className="text-xs text-gray-400 mt-1">
                        {formatTimestamp(log.created_at)}
                      </p>
                    </div>
                  </div>
                ))
              )}

              {isLoading && (
                <div className="text-center py-4 text-gray-400">
                  <div className="w-6 h-6 border-2 border-ui-blue/30 border-t-ui-blue rounded-full animate-spin mx-auto mb-2" />
                  Loading logs...
                </div>
              )}
            </div>

            {hasMore && filteredLogs.length > 0 && !isLoading && (
              <div className="text-center pt-4">
                <Button
                  variant="outline"
                  className="bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer hover:text-white"
                  onClick={handleLoadMore}
                >
                  <ChevronDown size={16} className="mr-2" />
                  Load More
                </Button>
              </div>
            )}
          </CardContent>
        </Card>
      </motion.div>

      <AlertDialog open={showClearConfirm} onOpenChange={setShowClearConfirm}>
        <AlertDialogContent className="bg-ui-layer border-ui-border text-white">
          <AlertDialogHeader>
            <AlertDialogTitle>Clear All Logs?</AlertDialogTitle>
            <AlertDialogDescription className="text-gray-400">
              This action cannot be undone. All server logs will be permanently
              deleted from the database.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="bg-ui-layer/50 border-ui-border text-white hover:bg-ui-layer hover:text-white">
              {translation.lgCancel || "Cancel"}
            </AlertDialogCancel>
            <AlertDialogAction
              className="bg-ui-danger text-white hover:bg-ui-danger/80"
              onClick={handleClearLogs}
            >
              Clear All Logs
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
