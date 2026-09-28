import { useState, useEffect, useRef } from "react";
import { X } from "lucide-react";
import { AnimatePresence, motion } from "framer-motion";
import { useTranslation } from "../lib/translation";
import { cn } from "../lib/utils";
import { useMobile } from "../hooks/use-mobile";
import { useTheme } from "../hooks/ThemeContext";

import Sidebar from "./sidebar";
import Dashboard from "./dashboard";
import Players from "./players";
import Server from "./server";
import Tools from "./tools";
import Chat from "./chat";
import Terminal from "./terminal";
import Bans from "./bans";
import Settings from "./settings";
import Reports from "./reports";
import Logs from "./logs";
import PlayerModal from "./player-modal";
import ServerStats from "./server-stats";
import QuickMenu from "./quickmenu";
import Approvals from "./approvals";
import type { Player, ServerResource, LogEntry, ChatMessage } from "../types";
import { closeAdminMenu } from "../lib/closeAdminMenu";
import { sendNui } from "../lib/sendNui";
import type { Warn as WarnType } from "../types";
import RegistrationPanel from "./RegistrationPanel";

export default function AdminPanel() {
  const translation = useTranslation();
  const [registrationStatus, setRegistrationStatus] = useState<
    "loading" | "none" | "pending" | "rejected" | "disabled" | "approved"
  >("loading");
  const [registrationReason, setRegistrationReason] = useState<string>("");
  const [activeTab, setActiveTab] = useState<string>("dashboard");
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
  const [players, setPlayers] = useState<Player[]>([]);
  const [resources, setResources] = useState<ServerResource[]>([]);
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [warns, setWarns] = useState<WarnType[]>([]);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const [economyStatus, setEconomyStatus] = useState<Record<string, any>>({
    totalMoney: 0,
    richestPlayer: "Undefined",
  });
  const [isVisible, setIsVisible] = useState(false);
  const [quickMenuVisible, setQuickMenuVisible] = useState(false);
  const [allVehicles, setAllVehicles] = useState<
    { name: string; label: string; brand?: string }[]
  >([]);
  const [items, setItems] = useState<
    { name: string; label: string; image?: string }[]
  >([]);
  const [actionModal, setActionModal] = useState<{
    type: "kick" | "ban" | "warn" | null;
    playerId: number | null;
  }>({ type: null, playerId: null });
  const [actionReason, setActionReason] = useState("");
  const [actionDuration, setActionDuration] = useState("");
  const [serverStats, setServerStats] = useState({
    onlinePlayers: 0,
    activeAdmins: 0,
    maxPlayers: 48,
    averagePing: 0,
    mapResources: 0,
    topPlayers: [],
    serverName: "change-me | Server",
    serverUptime: "0m",
  });

  const isMobile = useMobile();
  const { themeSettings } = useTheme();

  useEffect(() => {
    sendNui("requestItemsList");
    sendNui("requestVehiclesList");
  }, []);

  const closePlayerModal = () => {
    setIsModalOpen(false);
    setSelectedPlayer(null);
  };

  const closeActionModal = () => {
    setActionModal({ type: null, playerId: null });
    setActionReason("");
    setActionDuration("");
    if (!isVisible) {
      sendNui("setActionModalFocus", { status: false });
    }
  };

  const handlePlayerAction = (action: string, playerId: number) => {
    if (action === "kick" || action === "ban" || action === "warn") {
      if (!isVisible) {
        sendNui("setQuickMenuStatus", { status: false });
        sendNui("setActionModalFocus", { status: true });
      }
      setActionModal({ type: action as any, playerId });
      return;
    }

    const player = players.find((p) => p.id === playerId);
    if (!player) return;

    sendNui(action, { playerId });
  };

  useEffect(() => {
    const eventFunction = function (event: any) {
      const { data } = event;
      const actionCall = function (action: string) {
        if (action === "setStatus") {
          setIsVisible(data.status);
          if (data.status) {
            sendNui("requestItemsList");
            sendNui("requestVehiclesList");
          }
          if (
            typeof data.chatMessages === "object" &&
            Array.isArray(data.chatMessages)
          ) {
            setChatMessages(data.chatMessages);
          }
        } else if (action === "setStaffData") {
          setStaffList(data.staff);
          setGroups(data.groups);
        } else if (action === "setRegistrationStatus") {
          setRegistrationStatus(data.status);
          if (data.reason) {
            setRegistrationReason(data.reason);
          }
        } else if (action === "changeStats") {
          const statsCopy = { ...serverStats };

          Object.keys(data).forEach((value) => {
            if (Object.keys(statsCopy).find((v) => v == value)) {
              statsCopy[
                value as
                  | "onlinePlayers"
                  | "activeAdmins"
                  | "maxPlayers"
                  | "averagePing"
                  | "mapResources"
                  | "topPlayers"
              ] = data[value];
            }
          });

          setServerStats({
            onlinePlayers:
              typeof data.onlinePlayers !== "undefined"
                ? data.onlinePlayers
                : serverStats.onlinePlayers,
            activeAdmins:
              typeof data.activeAdmins !== "undefined"
                ? data.activeAdmins
                : serverStats.activeAdmins,
            maxPlayers:
              typeof data.maxPlayers !== "undefined"
                ? data.maxPlayers
                : serverStats.maxPlayers,
            averagePing:
              typeof data.averagePing !== "undefined"
                ? data.averagePing
                : serverStats.averagePing,
            mapResources:
              typeof data.mapResources !== "undefined"
                ? data.mapResources
                : serverStats.mapResources,
            topPlayers:
              typeof data.topPlayers !== "undefined"
                ? data.topPlayers
                : serverStats.topPlayers,
            serverName:
              typeof data.serverName !== "undefined"
                ? data.serverName
                : serverStats.serverName,
            serverUptime:
              typeof data.serverUptime !== "undefined"
                ? data.serverUptime
                : serverStats.serverUptime,
          });
        } else if (action === "setPlayers") {
          setPlayers(data.players);
        } else if (action === "setChatMessages") {
          setChatMessages(data.messages);
        } else if (action === "setResources") {
          setResources(data.resources);
        } else if (action === "changeEconomyStatus") {
          setEconomyStatus({
            totalMoney: data.totalMoney
              ? data.totalMoney
              : economyStatus.totalMoney,
            richestPlayer: data.richestPlayer
              ? data.richestPlayer
              : economyStatus.richestPlayer,
          });
        } else if (action === "setQuickMenuStatus") {
          setQuickMenuVisible(data.status);
        } else if (action === "loadWarns") {
          setWarns(data.warns);
        } else if (action === "loadAllVehicles") {
          setAllVehicles(data.vehicles);
        } else if (action === "loadAllItems") {
          setItems(data.items);
        } else if (action === "updateLiveData") {
          setPlayers((prevPlayers) =>
            prevPlayers.map((p) =>
              p.id === data.playerId
                ? { ...p, liveData: { ...p.liveData, ...data.data } }
                : p,
            ),
          );
        } else if (action === "terminalLog") {
          setLogs((prev) => {
            const newLog = {
              id: data.id || Math.random() * 1000000000000000000,
              timestamp: data.timestamp || new Date().toLocaleTimeString(),
              type: data.type || "info",
              message: data.message || "",
            };
            return [...prev, newLog];
          });
        } else if (action === "copyToClipboard") {
          const str = data.string || data.text;
          if (str) {
            navigator.clipboard.writeText(str);
          }
        }
      };

      if (data.action == "multipleActions") {
        if (Array.isArray(data.actions)) {
          data.actions.forEach(function (value: string) {
            actionCall(value);
          });
        }
      } else {
        actionCall(data.action);
      }
    };

    window.addEventListener("message", eventFunction);

    return () => window.removeEventListener("message", eventFunction);
  }, [serverStats]);

  useEffect(() => {
    const keyHandler = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        if (isModalOpen && selectedPlayer) {
          closePlayerModal();
        } else if (isVisible) {
          closeAdminMenu(setIsVisible);
        }
      }
    };

    window.addEventListener("keydown", keyHandler);
    return () => window.removeEventListener("keydown", keyHandler);
  }, [
    isModalOpen,
    selectedPlayer,
    closePlayerModal,
    isVisible,
    closeAdminMenu,
    setIsVisible,
    quickMenuVisible,
    setQuickMenuVisible,
  ]);

  return (
    <>
      <AnimatePresence>
        {isVisible && (
          <motion.div
            key="dashboard"
            id="dashboard"
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.95 }}
            transition={{ duration: 0.1 }}
            className="fixed inset-0 flex items-center justify-center p-4 bg-gradient-to-br select-none z-[50]"
          >
            <div className="relative w-full max-w-[1400px]">
              <div className="absolute -top-[41px] right-[-1px] z-[100]">
                <button
                  onClick={() => closeAdminMenu(setIsVisible)}
                  className="group px-5 py-2.5 rounded-tl-md rounded-tr-md bg-ui-panel border border-ui-border border-b-0 text-gray-400 hover:text-ui-danger hover:bg-ui-danger/10 hover:border-ui-danger/50 transition-all flex items-center justify-center shadow-[0_-4px_20px_-10px_rgba(0,0,0,0.5)]"
                >
                  <X
                    size={20}
                    className="group-hover:rotate-90 transition-transform duration-300"
                  />
                </button>
              </div>
              <div
                className={cn(
                  "admin-panel menu-bg isolate relative flex h-[819.891px] w-full rounded-lg rounded-tr-none overflow-hidden shadow-2xl border border-ui-border",
                )}
              >
                {registrationStatus === "loading" && (
                  <div className="w-full h-full flex items-center justify-center text-white text-xl">
                    Loading...
                  </div>
                )}

                {registrationStatus !== "loading" &&
                  registrationStatus !== "approved" && (
                    <RegistrationPanel
                      status={registrationStatus as any}
                      reason={registrationReason}
                    />
                  )}

                {registrationStatus === "approved" && (
                  <>
                    {themeSettings.sidebarPosition === "left" && (
                      <Sidebar
                        activeTab={activeTab}
                        onTabChange={(tab) => setActiveTab(tab)}
                        isMobile={isMobile}
                      />
                    )}
                    <div className="flex-1 overflow-hidden bg-transparent relative rounded-br-[24px] p-6">
                      <div className="h-full overflow-y-auto overflow-x-hidden pr-3 pb-2 custom-scrollbar">
                        <AnimatePresence mode="wait">
                          {activeTab === "dashboard" && (
                            <Dashboard
                              key="dashboard"
                              stats={serverStats}
                              recentLogs={logs.slice(0, 5)}
                              economyStatus={economyStatus}
                            />
                          )}
                          {activeTab === "players" && (
                            <Players
                              key="players"
                              players={players}
                              onOpenPlayerModal={(player: any) => {
                                setSelectedPlayer(player);
                                setIsModalOpen(true);
                              }}
                              onPlayerAction={handlePlayerAction}
                            />
                          )}
                          {activeTab === "server" && (
                            <Server key="server" resources={resources} />
                          )}
                          {activeTab === "tools" && (
                            <Tools
                              key="tools"
                              vehicles={allVehicles}
                              items={items}
                            />
                          )}
                          {activeTab === "chat" && (
                            <Chat key="chat" messages={chatMessages} />
                          )}
                          {activeTab === "terminal" && (
                            <Terminal
                              key="terminal"
                              logs={logs}
                              setLogs={setLogs}
                              players={players}
                              resources={resources}
                              onPlayerSelect={(player: any) => {
                                setSelectedPlayer(player);
                                setIsModalOpen(true);
                              }}
                              serverStats={{
                                status: "online",
                                players: serverStats.onlinePlayers,
                                maxPlayers: serverStats.maxPlayers,
                                uptime: "0",
                                cpu: 0,
                                memory: 0,
                                resources: resources.length,
                              }}
                            />
                          )}
                          {activeTab === "reports" && <Reports key="reports" />}
                          {activeTab === "logs" && <Logs key="logs" />}
                          {activeTab === "bans" && <Bans key="bans" />}
                          {activeTab === "approvals" && (
                            <Approvals key="approvals" />
                          )}
                          {activeTab === "settings" && (
                            <Settings key="settings" />
                          )}
                        </AnimatePresence>
                      </div>
                    </div>
                    {themeSettings.sidebarPosition === "right" && (
                      <Sidebar
                        activeTab={activeTab}
                        onTabChange={(tab) => setActiveTab(tab)}
                        isMobile={isMobile}
                      />
                    )}
                    {isModalOpen && selectedPlayer && (
                      <PlayerModal
                        players={players}
                        playerId={selectedPlayer.id}
                        warns={
                          (warns[
                            selectedPlayer.identifiers.find((id: string) =>
                              id.startsWith("license:"),
                            ) as any
                          ] as any) || []
                        }
                        items={items}
                        vehicles={allVehicles}
                        onClose={closePlayerModal}
                        onPlayerAction={handlePlayerAction}
                        setIsVisible={setIsVisible}
                      />
                    )}
                  </>
                )}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {!isVisible && (
        <QuickMenu
          isVisible={quickMenuVisible}
          players={players}
          onPlayerAction={handlePlayerAction}
          allVehicles={allVehicles}
          setIsVisible={setIsVisible}
        />
      )}

      {}
      <AnimatePresence>
        {actionModal.type === "kick" && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 flex items-center justify-center z-[200] bg-black/50"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-ui-layer border border-ui-border p-6 rounded-2xl shadow-2xl w-full max-w-md mx-4"
            >
              <h2 className="text-xl font-bold text-white mb-4">
                {translation.apKickPlayer || "Kick Player"}
              </h2>
              <p className="text-gray-400 mb-4">
                Please enter a reason for kicking this player.
              </p>
              <input
                autoFocus
                value={actionReason}
                onChange={(e) => setActionReason(e.target.value)}
                placeholder="Reason..."
                className="w-full px-3 py-2 bg-ui-layer/50 border border-ui-border text-white rounded-md mb-6 focus:outline-none focus:border-ui-danger"
              />
              <div className="flex justify-end gap-2">
                <button
                  className="px-4 py-2 rounded-lg bg-ui-layer/50 border border-ui-border hover:bg-ui-layer text-white transition-all"
                  onClick={closeActionModal}
                >
                  {translation.apCancel || "Cancel"}
                </button>
                <button
                  className="px-4 py-2 rounded-lg bg-ui-danger hover:bg-ui-danger/90 text-white transition-all"
                  onClick={() => {
                    sendNui("kick", {
                      playerId: actionModal.playerId,
                      reason: actionReason || "No reason provided",
                    });
                    closeActionModal();
                  }}
                >
                  {translation.apConfirmKick || "Confirm Kick"}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}

        {actionModal.type === "ban" && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 flex items-center justify-center z-[200] bg-black/50"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-ui-layer border border-ui-border p-6 rounded-2xl shadow-2xl w-full max-w-md mx-4"
            >
              <h2 className="text-xl font-bold text-white mb-4">
                {translation.apBanPlayer || "Ban Player"}
              </h2>
              <p className="text-gray-400 mb-4">
                Please enter a reason and duration for banning this player.
              </p>
              <div className="space-y-4 mb-6">
                <div>
                  <label className="text-sm text-gray-400 mb-1 block">
                    Reason
                  </label>
                  <input
                    autoFocus
                    value={actionReason}
                    onChange={(e) => setActionReason(e.target.value)}
                    placeholder="Reason..."
                    className="w-full px-3 py-2 bg-ui-layer/50 border border-ui-border text-white rounded-md focus:outline-none focus:border-ui-danger"
                  />
                </div>
                <div>
                  <label className="text-sm text-gray-400 mb-1 block">
                    Duration (Hours, 0 for Permanent)
                  </label>
                  <input
                    type="text"
                    value={actionDuration}
                    onChange={(e) =>
                      setActionDuration(e.target.value.replace(/[^0-9]/g, ""))
                    }
                    placeholder="0"
                    className="w-full px-3 py-2 bg-ui-layer/50 border border-ui-border text-white rounded-md focus:outline-none focus:border-ui-danger"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2">
                <button
                  className="px-4 py-2 rounded-lg bg-ui-layer/50 border border-ui-border hover:bg-ui-layer text-white transition-all"
                  onClick={closeActionModal}
                >
                  {translation.apCancel || "Cancel"}
                </button>
                <button
                  className="px-4 py-2 rounded-lg bg-ui-danger hover:bg-ui-danger/90 text-white transition-all"
                  onClick={() => {
                    sendNui("banPlayer", {
                      playerId: actionModal.playerId,
                      isOffline: false,
                      reason: actionReason || "No reason provided",
                      durationHours: Number(actionDuration) || 0,
                    });
                    closeActionModal();
                  }}
                >
                  {translation.apConfirmBan || "Confirm Ban"}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}

        {actionModal.type === "warn" && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 flex items-center justify-center z-[200] bg-black/50"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-ui-layer border border-ui-border p-6 rounded-2xl shadow-2xl w-full max-w-md mx-4"
            >
              <h2 className="text-xl font-bold text-white mb-4">
                {translation.apWarnPlayer || "Warn Player"}
              </h2>
              <p className="text-gray-400 mb-4">
                Please enter a reason for warning this player.
              </p>
              <input
                autoFocus
                value={actionReason}
                onChange={(e) => setActionReason(e.target.value)}
                placeholder="Reason..."
                className="w-full px-3 py-2 bg-ui-layer/50 border border-ui-border text-white rounded-md mb-6 focus:outline-none focus:border-amber-500"
              />
              <div className="flex justify-end gap-2">
                <button
                  className="px-4 py-2 rounded-lg bg-ui-layer/50 border border-ui-border hover:bg-ui-layer text-white transition-all"
                  onClick={closeActionModal}
                >
                  {translation.apCancel || "Cancel"}
                </button>
                <button
                  className="px-4 py-2 rounded-lg bg-amber-500 hover:bg-amber-600 text-white transition-all"
                  onClick={() => {
                    sendNui("actionWithInput", {
                      action: "warn",
                      playerId: actionModal.playerId,
                      input: actionReason || "No reason provided",
                    });
                    closeActionModal();
                  }}
                >
                  {translation.apConfirmWarn || "Confirm Warn"}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
