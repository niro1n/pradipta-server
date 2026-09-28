import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { GiveItemModal } from "./give-item-modal";

import {
  X,
  UserX,
  Ban,
  Zap,
  Eye,
  Heart,
  MessageSquare,
  Shield,
  Wallet,
  Briefcase,
  MapPin,
  User,
  Clock,
  Gauge,
  Activity,
  Car,
  DollarSign,
  Key,
  Crosshair,
  Sparkles,
  Flame,
  Droplet,
  Snowflake,
  Skull,
  Gift,
  PenIcon as Gun,
  Trash,
  Sword,
  Backpack,
  Pill,
  AlertTriangle,
  Search,
  Filter,
  Wifi,
  Beer,
  ArrowUpFromLine,
  ArrowDownFromLine,
  BadgeMinus,
  PanelLeftOpen,
  ClipboardList,
} from "lucide-react";
import { Button } from "./ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Progress } from "./ui/progress";
import type { Player, Warn } from "../types";
import { useTranslation } from "../lib/translation";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "./ui/select";
import { CopyableText } from "./ui/copyable-text";
import {
  ToastProvider as ToastProviderComponent,
  ToastViewport,
} from "./ui/toast";
import { SeeMore } from "./ui/see-more";
import { sendNui } from "../lib/sendNui";
import { closeAdminMenu } from "../lib/closeAdminMenu";

import { SpawnVehicleModal } from "./spawn-vehicle-modal";

type PlayerModalProps = {
  players: Player[];
  playerId: number;
  warns: Warn[];
  items: {
    name: string;
    label: string;
  }[];
  vehicles: { name: string; label: string; brand?: string }[];
  onClose: () => void;
  onPlayerAction: (action: string, playerId: number) => void;
  setIsVisible: (state: boolean) => void;
};

function LiveDataModal({
  liveData,
  translation,
  onClose,
}: {
  liveData: any;
  translation: Record<string, string>;
  onClose: () => void;
}) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[70] flex items-center justify-center bg-black/50 p-4"
      onClick={onClose}
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        className="bg-ui-panel backdrop-blur-panel border border-ui-border rounded-lg shadow-xl w-[33rem] h-[38rem] max-w-2xl overflow-hidden relative"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-4 border-b border-ui-border">
          <h2 className="text-xl font-bold text-ui-blue">
            {translation.liveDataTitle || "Live Data"}
          </h2>
          <Button
            variant="ghost"
            size="icon"
            onClick={onClose}
            className="text-gray-400 hover:text-white hover:bg-gray-700/50"
          >
            <X size={20} />
          </Button>
        </div>
        <div className="p-4 space-y-6">
          <div className="space-y-4">
            <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
              <Activity size={14} className="text-cyan-400" />
              {translation.playerStatsInLiveDataTitle || "Player Stats"}
            </h3>
            <div className="space-y-4">
              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-gray-300 flex items-center gap-1.5">
                    <Heart size={14} className="text-rose-400" />
                    {translation.liveDataHealthTitle || "Health"}
                  </span>
                  <span className="text-sm text-gray-300">
                    {liveData.health
                      ? liveData.health.toString() + "%"
                      : translation.unknownValue || ""}
                  </span>
                </div>
                <Progress
                  value={liveData.health || 0}
                  className="h-2 bg-gray-700"
                  indicatorClassName="bg-ui-pink"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-gray-300 flex items-center gap-1.5">
                    <Flame size={14} className="text-amber-400" />
                    {translation.liveDataHungerTitle || "Hunger"}
                  </span>
                  <span className="text-sm text-gray-300">
                    {liveData.hunger
                      ? liveData.hunger.toString() + "%"
                      : translation.unknownValue || ""}
                  </span>
                </div>
                <Progress
                  value={liveData.hunger || 0}
                  className="h-2 bg-gray-700"
                  indicatorClassName="bg-ui-amber"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-gray-300 flex items-center gap-1.5">
                    <Droplet size={14} className="text-cyan-400" />
                    {translation.liveDataThirstTitle || "Thirst"}
                  </span>
                  <span className="text-sm text-gray-300">
                    {liveData.thirst
                      ? liveData.thirst.toString() + "%"
                      : translation.unknownValue || ""}
                  </span>
                </div>
                <Progress
                  value={liveData.thirst || 0}
                  className="h-2 bg-gray-700"
                  indicatorClassName="bg-ui-blue"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-gray-300 flex items-center gap-1.5">
                    <Shield size={14} className="text-blue-400" />
                    {translation.liveDataArmorTitle || "Armor"}
                  </span>
                  <span className="text-sm text-gray-300">
                    {liveData.armor
                      ? liveData.armor.toString() + "%"
                      : translation.unknownValue || ""}
                  </span>
                </div>
                <Progress
                  value={liveData.armor || 0}
                  className="h-2 bg-gray-700"
                  indicatorClassName="bg-gradient-to-r from-blue-500 to-cyan-600"
                />
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
              <User size={14} className="text-purple-400" />
              {translation.playerDetailsInLiveDataTitle || "Player Details"}
            </h3>
            <div className="bg-white/5 border border-ui-border rounded-md p-4 space-y-3">
              <div className="flex items-center gap-2 text-sm">
                <Briefcase size={16} className="text-violet-400" />
                <span className="text-gray-300">
                  {translation.liveDataJobTitle || "Job"}:
                </span>
                <CopyableText>
                  <span className="text-white group-hover:text-cyan-400 transition-colors">
                    {liveData.job || translation.unknownValue || "Unknown"}
                  </span>
                </CopyableText>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Wallet size={16} className="text-green-400" />
                <span className="text-gray-300">
                  {translation.liveDataCashTitle || "Cash"}:
                </span>
                <CopyableText>
                  <span className="text-white group-hover:text-cyan-400 transition-colors">
                    {liveData.cash
                      ? (translation.currency || "$%s").replace(
                          "%s",
                          liveData.cash,
                        )
                      : translation.unknownValue || "Unknown"}
                  </span>
                </CopyableText>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <DollarSign size={16} className="text-emerald-400" />
                <span className="text-gray-300">
                  {translation.liveDataBankTitle || "Bank"}:
                </span>
                <CopyableText>
                  <span className="text-white group-hover:text-cyan-400 transition-colors">
                    {liveData.bank
                      ? (translation.currency || "$%s").replace(
                          "%s",
                          liveData.bank,
                        )
                      : translation.unknownValue || "Unknown"}
                  </span>
                </CopyableText>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <MapPin size={16} className="text-rose-400" />
                <span className="text-gray-300">
                  {translation.liveDataPositionTitle || "Position"}:
                </span>
                <CopyableText>
                  <span className="text-white group-hover:text-cyan-400 transition-colors">
                    {liveData.position || translation.unknownValue || "Unknown"}
                  </span>
                </CopyableText>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <Wifi
                  size={16}
                  className={
                    liveData.ping
                      ? (liveData.ping <= 33.33 && "text-green-400") ||
                        (liveData.ping <= 66.99 && "text-yellow-400") ||
                        "text-rose-400"
                      : "text-gray-500"
                  }
                />
                <span className="text-gray-300">
                  {translation.PingDataTitle || "Ping"}:
                </span>
                <CopyableText>
                  <span className="text-white group-hover:text-cyan-400 transition-colors">
                    {liveData.ping || translation.unknownValue || "Unknown"}
                  </span>
                </CopyableText>
              </div>
            </div>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}

function ActionInputModal({
  title,
  placeholder,
  action,
  playerId,
  onClose,
  isBan = false,
}: {
  title: string;
  placeholder: string;
  action: string;
  playerId: number;
  onClose: () => void;
  isBan?: boolean;
}) {
  const translation = useTranslation();
  const [input, setInput] = useState("");
  const [duration, setDuration] = useState("1");

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[80] flex items-center justify-center bg-black/50 p-4"
      onClick={onClose}
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        className="bg-ui-panel backdrop-blur-panel border border-ui-border rounded-lg shadow-xl w-[30rem] max-w-full overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-4 border-b border-ui-border">
          <h2 className="text-xl font-bold text-ui-blue">{title}</h2>
          <Button
            variant="ghost"
            size="icon"
            onClick={onClose}
            className="text-gray-400 hover:text-white"
          >
            <X size={20} />
          </Button>
        </div>
        <div className="p-4 space-y-4">
          {action === "warn" && (
            <div className="bg-red-500/10 border border-red-500/20 p-3 rounded-md flex items-start gap-3">
              <AlertTriangle className="text-red-400 mt-0.5" size={18} />
              <div className="text-sm text-red-200">
                <p className="font-medium text-red-300">
                  {translation.pmWarningPlayer || "Warning Player"}
                </p>
                <p className="text-xs opacity-80 mt-1">
                  Please provide a detailed reason for warning this player. They
                  will see this reason on their screen.
                </p>
              </div>
            </div>
          )}
          {action === "warn" || action === "banPlayer" ? (
            <textarea
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder={placeholder}
              className="w-full bg-ui-layer/50 border border-ui-border rounded-md px-3 py-2 text-white min-h-[100px] resize-y"
              autoFocus
            />
          ) : (
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder={placeholder}
              className="w-full bg-ui-layer/50 border border-ui-border rounded-md px-3 py-2 text-white"
              autoFocus
            />
          )}
          {isBan && (
            <input
              type="number"
              value={duration}
              onChange={(e) => setDuration(e.target.value)}
              placeholder="Duration (hours)"
              className="w-full bg-ui-layer/50 border border-ui-border rounded-md px-3 py-2 text-white"
            />
          )}
          <div className="flex justify-end gap-2 mt-4 pt-2">
            <Button
              variant="outline"
              onClick={onClose}
              className="text-white bg-ui-layer hover:bg-ui-layer/80 border-ui-border"
            >
              {translation.pmCancel || "Cancel"}
            </Button>
            <Button
              className={`text-white ${action === "warn" || action === "banPlayer" ? "bg-red-500 hover:bg-red-600" : "bg-ui-blue hover:bg-ui-blue/80"}`}
              onClick={() => {
                if (action === "banPlayer") {
                  sendNui("banPlayer", {
                    playerId,
                    reason: input,
                    durationHours: Number(duration),
                  });
                } else if (action === "warn") {
                  sendNui("actionWithInput", {
                    action: "warn",
                    playerId,
                    input,
                  });
                } else {
                  sendNui("actionWithInput", { action, playerId, input });
                }
                onClose();
              }}
            >
              Confirm
            </Button>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}

export default function PlayerModal({
  players,
  playerId,
  warns,
  items,
  vehicles,
  onClose,
  onPlayerAction,
  setIsVisible,
}: PlayerModalProps) {
  const translation = useTranslation();
  const [showLiveData, setShowLiveData] = useState(false);
  const [inputAction, setInputAction] = useState<{
    action: string;
    title: string;
    placeholder: string;
  } | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterActive, setFilterActive] = useState<boolean | null>(null);
  const [plIndex, setPlIndex] = useState<number>(
    players.findIndex((player) => player.id === playerId),
  );
  const [giveItemModalVisible, setGiveItemModalVisible] = useState(false);
  const [spawnVehModalVisible, setSpawnVehModalVisible] = useState(false);
  const giveOrRemItemsFns = {
    selectedGiveItem: useState<string | undefined>(),
    selectedGiveItemCount: useState<number>(1),
    giveItemText: useState<string | undefined>(),
    selectedRemoveItem: useState<string | undefined>(),
    selectedRemoveItemCount: useState<number>(0),
    removeItemText: useState<string | undefined>(),
    showSuggestions: useState<boolean>(false),
    showSuggestions2: useState<boolean>(false),
  };

  const filteredWarns = warns.filter((warn) => {
    const matchesSearch =
      warn.reason.toLowerCase().includes(searchQuery.toLowerCase()) ||
      warn.author.toLowerCase().includes(searchQuery.toLowerCase()) ||
      warn.executionTime.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesFilter = filterActive === null || warn.active === filterActive;
    return matchesSearch && matchesFilter;
  });

  useEffect(() => {
    sendNui("setLiveDataStatus", { status: showLiveData, playerId: playerId });
  }, [showLiveData]);

  useEffect(() => {
    setPlIndex(players.findIndex((player) => player.id === playerId));
  }, []);

  return (
    <ToastProviderComponent>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="absolute inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
        onMouseDown={onClose}
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.9, opacity: 0 }}
          className="bg-ui-panel backdrop-blur-panel border border-ui-border rounded-lg shadow-xl w-[789px] overflow-hidden relative"
          onMouseDown={(e) => e.stopPropagation()}
        >
          <div className="flex items-center justify-between p-4 border-b border-ui-border bg-ui-layer/50">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-xl bg-ui-blue/10 flex items-center justify-center ">
                <User size={24} className="text-white" />
              </div>
              <div>
                <h2 className="text-xl font-bold text-ui-blue">
                  {players[plIndex].name}
                </h2>
                <div className="flex items-center gap-2">
                  <span className="text-sm text-gray-400">
                    {translation.playerIDModal || "ID"}: {playerId}
                  </span>
                  <div
                    className={`w-1.5 h-1.5 rounded-full bg-${players[plIndex].isDead ? "red" : "emerald"}-500`}
                  ></div>
                  <span
                    className={`text-sm text-${players[plIndex].isDead ? "red" : "emerald"}-400`}
                  >
                    {players[plIndex].isDead
                      ? translation.dead || "Dead"
                      : translation.alive || "Alive"}
                  </span>
                </div>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                className="bg-gray-700 border-ui-border hover:bg-gray-600 text-white h-8 text-xs px-3"
                onClick={() => setShowLiveData(true)}
              >
                {translation.liveData || "Live Data"}
              </Button>
              <Button
                variant="ghost"
                size="icon"
                onClick={onClose}
                className="text-gray-400 hover:text-white hover:bg-gray-700/50"
              >
                <X size={20} />
              </Button>
            </div>
          </div>

          <Tabs defaultValue="info" className="w-full">
            <div className="px-4 pt-4">
              <TabsList className="bg-gray-700/50 border-ui-border text-gray-400 p-1 w-full">
                <TabsTrigger
                  value="info"
                  className="data-[state=active]:bg-ui-blue data-[state=active]:text-white rounded-md w-full"
                >
                  <User size={14} className="mr-1" />
                  {translation.playerTab || "Info"}
                </TabsTrigger>
                <TabsTrigger
                  value="actions"
                  className="data-[state=active]:bg-ui-violet data-[state=active]:text-white rounded-md w-full"
                >
                  <Zap size={14} className="mr-1" />
                  {translation.playerActions || "Actions"}
                </TabsTrigger>
                <TabsTrigger
                  value="inventory"
                  className="data-[state=active]:bg-ui-amber data-[state=active]:text-white rounded-md w-full"
                >
                  <Briefcase size={14} className="mr-1" />
                  {translation.inventory || "Inventory"}
                </TabsTrigger>
                <TabsTrigger
                  value="warns"
                  className="data-[state=active]:bg-ui-danger data-[state=active]:text-white rounded-md w-full"
                >
                  <AlertTriangle size={14} className="mr-1" />
                  {translation.warns || "Warns"}
                </TabsTrigger>
              </TabsList>
            </div>

            <TabsContent
              value="info"
              className="p-4 overflow-auto max-h-[450px]"
            >
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div className="space-y-4">
                    <div>
                      <h3 className="text-sm font-medium text-gray-400 mb-2 flex items-center gap-2">
                        <Key size={14} className="text-amber-400" />
                        {translation.playerIdentifiers || "Identifiers"}
                      </h3>
                      <div className="bg-white/5 border border-ui-border rounded-md p-3 w-fit">
                        <div className="flex flex-col gap-2">
                          {players[plIndex].identifiers.map((value) => (
                            <CopyableText key={value}>
                              <span className="text-white font-mono text-xs bg-gray-800 px-2 py-1 rounded group-hover:text-cyan-400 transition-colors w-full block">
                                {value}
                              </span>
                            </CopyableText>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="space-y-4">
                  <div>
                    <h3 className="text-sm font-medium text-gray-400 mb-2 flex items-center gap-2">
                      <Clock size={14} className="text-purple-400" />
                      {translation.playerHistory || "History"}
                    </h3>
                    <div className="bg-white/5 border border-ui-border rounded-md p-3 space-y-2 max-h-40 overflow-y-auto scrollbar-hide">
                      <div className="text-sm">
                        <span className="text-gray-400 text-xs flex items-center gap-1.5">
                          <Clock size={10} />
                          2023-06-15 14:32:45
                        </span>
                        <p className="text-white">
                          {translation.playerConnected ||
                            "Player connected to the server"}
                        </p>
                      </div>
                      <div className="text-sm">
                        <span className="text-gray-400 text-xs flex items-center gap-1.5">
                          <Clock size={10} />
                          2023-06-15 14:35:12
                        </span>
                        <p className="text-white">
                          {translation.playerReceivedMoney ||
                            "Received $5,000 from bank transfer"}
                        </p>
                      </div>
                      <div className="text-sm">
                        <span className="text-gray-400 text-xs flex items-center gap-1.5">
                          <Clock size={10} />
                          2023-06-15 14:40:23
                        </span>
                        <p className="text-white">
                          {translation.playerChangedJob ||
                            "Changed job to Police"}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </TabsContent>

            <TabsContent
              value="actions"
              className="p-4 overflow-auto max-h-[450px]"
            >
              <div className="mb-2">
                <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
                  <User size={14} className="text-gray-300" />{" "}
                  {translation.mainActions || "Main Actions"}
                </h3>
              </div>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() => onPlayerAction("kick", playerId)}
                >
                  <div className="w-6 h-6 rounded-full bg-ui-danger/10 flex items-center justify-center shadow-md mr-2">
                    <UserX size={12} className="text-white" />
                  </div>
                  {translation.kickPlayer || "Kick Player"}
                </Button>

                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() => onPlayerAction("ban", playerId)}
                >
                  <div className="w-6 h-6 rounded-full bg-ui-danger/10 flex items-center justify-center shadow-md mr-2">
                    <Ban size={12} className="text-white" />
                  </div>
                  {translation.banPlayer || "Ban Player"}
                </Button>

                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() => onPlayerAction("spectate", playerId)}
                >
                  <div className="w-6 h-6 rounded-full bg-ui-blue/10 flex items-center justify-center shadow-md mr-2">
                    <Eye size={12} className="text-white" />
                  </div>
                  {translation.spectatePlayer || "Spectate"}
                </Button>

                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() => onPlayerAction("heal", playerId)}
                >
                  <div className="w-6 h-6 rounded-full bg-ui-pink/10 flex items-center justify-center shadow-md mr-2">
                    <Heart size={12} className="text-white" />
                  </div>
                  {translation.healPlayer || "Heal Player"}
                </Button>

                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() =>
                    setInputAction({
                      action: "message",
                      title: translation.messagePlayerTitle || "Message Player",
                      placeholder:
                        translation.messagePlayerPlaceholder ||
                        "Message to send...",
                    })
                  }
                >
                  <div className="w-6 h-6 rounded-full bg-ui-success/10 flex items-center justify-center shadow-md mr-2">
                    <MessageSquare size={12} className="text-white" />
                  </div>
                  {translation.messagePlayer || "Message"}
                </Button>

                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() => onPlayerAction("fixVehicle", playerId)}
                >
                  <div className="w-6 h-6 rounded-full bg-ui-success/10 flex items-center justify-center shadow-md mr-2">
                    <Car size={12} className="text-white" />
                  </div>
                  {translation.fixPlayerVeh || "Fix Vehicle"}
                </Button>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-3 gap-3 mt-3">
                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() => onPlayerAction("freeze", playerId)}
                >
                  <div className="w-6 h-6 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center shadow-md mr-2">
                    <Snowflake size={12} className="text-white" />
                  </div>
                  {translation.freezePlayer || "Freeze Player"}
                </Button>

                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() => onPlayerAction("goto", playerId)}
                >
                  <div className="w-6 h-6 rounded-full bg-ui-violet/10 flex items-center justify-center shadow-md mr-2">
                    <ArrowUpFromLine size={12} className="text-white" />
                  </div>
                  {translation.gotoPlayer || "Go To"}
                </Button>

                <Button
                  variant="outline"
                  className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                  onClick={() => onPlayerAction("bring", playerId)}
                >
                  <div className="w-6 h-6 rounded-full bg-gradient-to-br from-emerald-500 to-green-600 flex items-center justify-center shadow-md mr-2">
                    <ArrowDownFromLine size={12} className="text-white" />
                  </div>
                  {translation.bringPlayer || "Bring Player"}
                </Button>
              </div>

              <div className="mt-4 space-y-3">
                <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
                  🧌 {translation.trollActions || "Troll Actions"}
                </h3>

                <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                  <Button
                    variant="outline"
                    className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                    onClick={() => {
                      sendNui("trollAction", {
                        action: "slap",
                        playerId: playerId,
                      });
                    }}
                  >
                    <div className="w-6 h-6 rounded-full bg-ui-amber/10 flex items-center justify-center shadow-md mr-2">
                      <Zap size={12} className="text-white" />
                    </div>
                    {translation.slapPlayer || "Slap Player"}
                  </Button>

                  <Button
                    variant="outline"
                    className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                    onClick={() => {
                      sendNui("trollAction", {
                        action: "kill",
                        playerId: playerId,
                      });
                    }}
                  >
                    <div className="w-6 h-6 rounded-full bg-ui-danger/10 flex items-center justify-center shadow-md mr-2">
                      <Skull size={12} className="text-white" />
                    </div>
                    {translation.killPlayer || "Kill Player"}
                  </Button>

                  <Button
                    variant="outline"
                    className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start h-10"
                    onClick={() => {
                      sendNui("trollAction", {
                        action: "toggleDrunk",
                        playerId: playerId,
                      });
                    }}
                  >
                    <div className="w-6 h-6 rounded-full bg-ui-danger/10 flex items-center justify-center shadow-md mr-2">
                      <Beer size={12} className="text-white" />
                    </div>
                    {translation.toggleDrunk || "Toggle Drunk Status"}
                  </Button>
                </div>
              </div>

              <div className="mt-4 space-y-3">
                <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
                  <Sparkles size={14} className="text-amber-400" />
                  {translation.specialActions || "Special Actions"}
                </h3>

                <div className="grid grid-cols-2 gap-2">
                  <Button
                    variant="outline"
                    className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start"
                    onClick={() => sendNui("setWaypoint", { playerId })}
                  >
                    <Crosshair size={14} className="mr-1 text-cyan-400" />
                    {translation.setWaypoint || "Set Waypoint"}
                  </Button>

                  <Button
                    variant="outline"
                    className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start"
                    onClick={() => setSpawnVehModalVisible(true)}
                  >
                    <Car size={14} className="mr-1 text-purple-400" />
                    {translation.spawnVehicleModal || "Spawn Vehicle"}
                  </Button>

                  <Button
                    variant="outline"
                    className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start"
                    onClick={() =>
                      setInputAction({
                        action: "setJob",
                        title: translation.setJobTitle || "Set Job",
                        placeholder:
                          translation.setJobPlaceholder ||
                          "Job name (e.g. police)",
                      })
                    }
                  >
                    <Gauge size={14} className="mr-1 text-rose-400" />
                    {translation.setJob || "Set Job"}
                  </Button>

                  <Button
                    variant="outline"
                    className="bg-ui-layer hover:bg-ui-layer/80 border-ui-border text-white justify-start"
                    onClick={() =>
                      setInputAction({
                        action: "changeBalance",
                        title:
                          translation.changeBalanceTitle || "Change Balance",
                        placeholder:
                          translation.changeBalancePlaceholder ||
                          "Amount to add/remove",
                      })
                    }
                  >
                    <DollarSign size={14} className="mr-1 text-green-400" />
                    {translation.changePlayerBalance || "Change Balance"}
                  </Button>
                </div>
              </div>
            </TabsContent>

            <TabsContent
              value="inventory"
              className="p-4 overflow-auto h-[450px]"
            >
              <div className="space-y-3">
                <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
                  <ClipboardList size={14} className="text-sky-400" />
                  {translation.fastSlotsUndercategoryName}
                </h3>

                <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
                  {[...Array(5)].map((_, i) => {
                    const item = players[plIndex].items[i] || {};
                    return (
                      <div className="bg-white/5 border border-ui-border rounded-md p-3 flex flex-col items-center">
                        {item.name && (
                          <div className="w-12 h-12 bg-gradient-to-br from-gray-600 to-gray-700 rounded-md mb-2 flex items-center justify-center">
                            <img
                              src={`${`nui://${item.iconPath}`}`}
                              alt={item.name}
                            />
                          </div>
                        )}
                        <span className="text-sm text-white">
                          {(item.label && item.label) ||
                            translation.empty ||
                            "Empty"}
                        </span>
                        {item.count && (
                          <span className="text-sm text-white">
                            x{item.count}
                          </span>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>

              <div className="mt-4 space-y-3">
                <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
                  <Gift size={14} className="text-pink-400" />
                  {translation.giveItem || "Give Item"}
                </h3>
                <Button
                  onClick={() => setGiveItemModalVisible(true)}
                  className="w-full bg-gradient-to-r from-pink-500 to-rose-600 hover:from-pink-600 hover:to-rose-700 text-white border-0 py-5 font-semibold text-sm shadow-md"
                >
                  <Gift size={16} className="mr-2" />
                  Open Item Spawner
                </Button>
              </div>

              {(() => {
                const text = "remove";
                const textUpper = "Remove";
                const tlsn = [
                  translation[`${text}Item`],
                  translation.giveIRemoveItemInputPlaceholder,
                  translation[text],
                ];
                const suggestFn: Function =
                  giveOrRemItemsFns[`showSuggestions2`][1];
                const giveOrRemoveItemFn: Function =
                  giveOrRemItemsFns[`${text}ItemText`][1];
                const showSuggests = giveOrRemItemsFns[`showSuggestions2`][0];
                const filteredItemsList: { name: string; label: string }[] =
                  items.filter((item) =>
                    (item.name + item.label)
                      .toLowerCase()
                      .includes(
                        giveOrRemItemsFns[`${text}ItemText`][0] as string,
                      ),
                  );
                const selectedItemCount =
                  giveOrRemItemsFns[`selected${textUpper}ItemCount`][0];
                const selectedItem: string =
                  giveOrRemItemsFns[`selected${textUpper}Item`][0];
                const itemText: string = giveOrRemItemsFns[
                  `${text}ItemText`
                ][0] as string;
                const itemActionFn = () => {
                  if (selectedItem && selectedItem.length > 0) {
                    sendNui(`${text}Item`, {
                      playerId: playerId,
                      item: selectedItem,
                      count: selectedItemCount,
                    });
                  } else if (items.find((value) => value.name === itemText)) {
                    giveOrRemItemsFns[`selected${textUpper}Item`][1](itemText);
                    sendNui(`${text}Item`, {
                      playerId: playerId,
                      item: itemText,
                      count: selectedItemCount,
                    });
                  } else {
                    console.log("temporal invalid item notification");
                  }
                };
                const iconElem = () => (
                  <BadgeMinus size={14} className="text-red-400" />
                );

                return (
                  <div className="mt-4 space-y-3">
                    <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
                      {iconElem()}
                      {tlsn[0] || `${textUpper} Item`}
                    </h3>

                    <div className="flex gap-2">
                      <div className="relative flex-1">
                        <input
                          type="text"
                          value={itemText}
                          onChange={(e) => {
                            giveOrRemoveItemFn(e.target.value);
                            suggestFn(e.target.value.length > 0);
                          }}
                          onBlur={() => setTimeout(() => suggestFn(false), 150)}
                          placeholder={tlsn[1] || "Type item name..."}
                          className="w-full bg-ui-layer/50 border border-ui-border rounded-md px-3 py-2 text-white"
                          onKeyDown={(event) =>
                            event.key == "Enter" && itemActionFn()
                          }
                        />

                        {showSuggests && filteredItemsList.length > 0 && (
                          <ul className="absolute z-10 w-full bg-gray-800 border border-ui-border text-white mt-1 rounded shadow-lg max-h-40 overflow-y-auto">
                            {filteredItemsList.map((item) => (
                              <li
                                key={item.name}
                                className="px-3 py-2 hover:bg-gray-700 cursor-pointer"
                                onMouseDown={() => {
                                  giveOrRemItemsFns[
                                    `selected${textUpper}Item`
                                  ][1](item.name);
                                  giveOrRemoveItemFn(item.name);
                                  suggestFn(false);
                                }}
                              >
                                {item.label}
                              </li>
                            ))}
                          </ul>
                        )}
                      </div>

                      <input
                        type="number"
                        placeholder={translation.amount || "Amount"}
                        className="w-24 bg-ui-layer/50 border border-ui-border rounded-md px-3 py-2 text-white"
                        min="1"
                        max={
                          (
                            players[plIndex]?.items?.find(
                              (value: any) => value.name === itemText,
                            ) as Record<string, any>
                          )?.count?.toString() || "0"
                        }
                        value={selectedItemCount}
                        onChange={(event) =>
                          giveOrRemItemsFns[`selected${textUpper}ItemCount`][1](
                            Number(event.target.value),
                          )
                        }
                        onKeyDown={(event) =>
                          event.key == "Enter" && itemActionFn()
                        }
                      />

                      <Button
                        onClick={() => itemActionFn()}
                        className="bg-gradient-to-r from-purple-500 to-violet-600 hover:from-purple-600 hover:to-violet-700 text-white border-0"
                      >
                        {iconElem()}
                        {tlsn[2] || textUpper}
                      </Button>
                    </div>
                  </div>
                );
              })()}

              <div className="mt-4 space-y-3">
                <h3 className="text-sm font-medium text-gray-400 flex items-center gap-2">
                  {<PanelLeftOpen size={14} className="text-gray-400" />}
                  {translation.inspectInventory || "Inspect Inventory"}
                </h3>

                <Button
                  onClick={async () => {
                    if (await sendNui("inspectInventory", { playerId }))
                      closeAdminMenu(setIsVisible);
                  }}
                  className="bg-gradient-to-r from-purple-500 to-violet-600 hover:from-purple-600 hover:to-violet-700 text-white border-0 w-full"
                >
                  {<PanelLeftOpen size={14} className="text-gray-400" />}
                  {translation.inspectInventory || "Inspect Inventory"}
                </Button>
              </div>
            </TabsContent>

            <TabsContent
              value="warns"
              className="p-4 overflow-auto max-h-[450px]"
            >
              <div className="space-y-4">
                <div className="flex gap-2">
                  <div className="relative flex-1">
                    <Search
                      className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                      size={16}
                    />
                    <input
                      type="text"
                      placeholder={translation.searchWarns || "Search warns..."}
                      className="w-full pl-10 pr-4 py-2 bg-ui-layer/50 border border-ui-border rounded-md text-white"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                    />
                  </div>
                  <Select
                    value={
                      filterActive === null
                        ? "all"
                        : filterActive
                          ? "active"
                          : "inactive"
                    }
                    onValueChange={(value) => {
                      if (value === "all") setFilterActive(null);
                      else if (value === "active") setFilterActive(true);
                      else setFilterActive(false);
                    }}
                  >
                    <SelectTrigger className="w-[120px] bg-ui-layer/50 border border-ui-border text-white">
                      <div className="flex items-center gap-2">
                        <Filter size={16} />
                        <span>{translation.pmFilter || "Filter"}</span>
                      </div>
                    </SelectTrigger>
                    <SelectContent className="bg-gray-800 border-ui-border text-white">
                      <SelectItem value="all">
                        {translation.all || "All"}
                      </SelectItem>
                      <SelectItem value="active">
                        {translation.active || "Active"}
                      </SelectItem>
                      <SelectItem value="inactive">
                        {translation.inactive || "Inactive"}
                      </SelectItem>
                    </SelectContent>
                  </Select>
                  <Button
                    className="bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/50 hover:border-red-400 transition-all font-medium shadow-[0_0_15px_rgba(239,68,68,0.1)] hover:shadow-[0_0_20px_rgba(239,68,68,0.2)]"
                    onClick={() =>
                      setInputAction({
                        action: "warn",
                        title: translation.addWarn || "Add Warn",
                        placeholder:
                          translation.warnReason || "Reason for warning...",
                      })
                    }
                  >
                    <AlertTriangle size={16} className="mr-2" />
                    {translation.addWarn || "Add Warn"}
                  </Button>
                </div>

                <div className="bg-white/5 border border-ui-border rounded-md overflow-hidden">
                  <div className="overflow-x-auto">
                    <table className="w-full">
                      <thead>
                        <tr className="bg-gray-800/50">
                          <th className="px-4 py-2 text-left text-sm font-medium text-gray-400">
                            {translation.reason || "Reason"}
                          </th>
                          <th className="px-4 py-2 text-left text-sm font-medium text-gray-400">
                            {translation.author || "Author"}
                          </th>
                          <th className="px-4 py-2 text-left text-sm font-medium text-gray-400">
                            {translation.warnAddDate || "Added On"}
                          </th>
                          <th className="px-4 py-2 text-left text-sm font-medium text-gray-400">
                            {translation.status || "Status"}
                          </th>
                          <th className="px-4 py-2 text-left text-sm font-medium text-gray-400">
                            {translation.actions || "Actions"}
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {filteredWarns.map((warn, index) => (
                          <tr
                            key={index}
                            className="border-t border-ui-border/50"
                          >
                            <td className="px-4 py-2 text-sm">
                              <SeeMore
                                className="text-white"
                                text={warn.reason}
                                showHeader={true}
                                headerTitle="Warn Reason"
                              />
                            </td>
                            <td className="px-4 py-2 text-sm">
                              <SeeMore
                                className="text-white"
                                text={warn.author}
                                showHeader={true}
                                headerTitle="Warn Author"
                              />
                            </td>
                            <td className="px-4 py-2 text-sm">
                              <SeeMore
                                className="text-white"
                                text={
                                  !isNaN(Number(warn.executionTime))
                                    ? new Date(
                                        Number(warn.executionTime),
                                      ).toLocaleString()
                                    : new Date(
                                          warn.executionTime,
                                        ).toLocaleString() !== "Invalid Date"
                                      ? new Date(
                                          warn.executionTime,
                                        ).toLocaleString()
                                      : warn.executionTime
                                }
                                showHeader={true}
                                headerTitle="Added On"
                              />
                            </td>
                            <td className="px-4 py-2 text-sm">
                              <span
                                className={`px-2 py-1 rounded-full text-xs ${warn.active ? "bg-green-500/20 text-green-400" : "bg-gray-500/20 text-gray-400"}`}
                              >
                                {warn.active
                                  ? translation.active || "Active"
                                  : translation.inactive || "Inactive"}
                              </span>
                            </td>
                            <td className="px-4 py-2 text-sm">
                              <div className="flex items-center gap-2">
                                <Button
                                  className={`h-7 px-3 text-xs border transition-all ${warn.active ? "bg-orange-500/10 text-orange-400 border-orange-500/20 hover:bg-orange-500/20 hover:border-orange-500/40" : "bg-green-500/10 text-green-400 border-green-500/20 hover:bg-green-500/20 hover:border-green-500/40"}`}
                                  onClick={() =>
                                    sendNui("changeWarn", {
                                      warnId: warn.id,
                                      changeType: "activeToggle",
                                      active: warn.active,
                                    })
                                  }
                                >
                                  {warn.active
                                    ? translation.deactivate || "Deactivate"
                                    : translation.activate || "Activate"}
                                </Button>
                                <Button
                                  className="h-7 px-3 text-xs bg-red-500/10 text-red-400 border border-red-500/20 hover:bg-red-500/20 hover:border-red-500/40 transition-all"
                                  onClick={() =>
                                    sendNui("changeWarn", {
                                      warnId: warn.id,
                                      changeType: "delete",
                                    })
                                  }
                                >
                                  {translation.deleteWarn || "Delete"}
                                </Button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </motion.div>
      </motion.div>
      {inputAction && (
        <ActionInputModal
          title={inputAction.title}
          placeholder={inputAction.placeholder}
          action={inputAction.action}
          playerId={playerId}
          onClose={() => setInputAction(null)}
          isBan={inputAction.action === "banPlayer"}
        />
      )}
      {showLiveData && (
        <LiveDataModal
          onClose={() => setShowLiveData(false)}
          liveData={{ ...players[plIndex].liveData }}
          translation={translation}
        />
      )}
      <AnimatePresence>
        {giveItemModalVisible && (
          <GiveItemModal
            items={items}
            translation={translation}
            onClose={() => setGiveItemModalVisible(false)}
            targetPlayerId={playerId}
          />
        )}
        {spawnVehModalVisible && (
          <SpawnVehicleModal
            vehicles={vehicles}
            translation={translation}
            onClose={() => setSpawnVehModalVisible(false)}
            targetPlayerId={playerId}
          />
        )}
      </AnimatePresence>
      <ToastViewport className="fixed top-0 left-1/2 -translate-x-1/2 flex flex-col items-center gap-5 w-full max-w-[420px] p-4 z-[60]" />
    </ToastProviderComponent>
  );
}
