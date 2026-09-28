import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { sendNui } from "../lib/sendNui";
import { useTranslation } from "../lib/translation";
import {
  ChevronRight,
  Zap,
  Shield,
  Car,
  Cloud,
  Users,
  Check,
} from "lucide-react";

type MenuItem = {
  label: string;
  icon?: React.ReactNode;
  isToggle?: boolean;
  toggleStateKey?: string;
  rightLabel?: string;
  action?: () => void;
  submenu?: MenuDef;
};

type MenuDef = {
  id: string;
  title: string;
  icon?: React.ReactNode;
  items: MenuItem[];
};

interface QuickMenuProps {
  isVisible?: boolean;
  players?: any[];
  onPlayerAction?: (action: string, targetId: number) => void;
  setIsVisible?: React.Dispatch<React.SetStateAction<boolean>>;
}

export default function QuickMenu({
  isVisible = false,
  players = [],
  onPlayerAction,
}: QuickMenuProps) {
  const translation = useTranslation();
  const [toggleStates, setToggleStates] = useState<Record<string, boolean>>({
    godmode: false,
    invisible: false,
    noclip: false,
    superJump: false,
    fastRun: false,
    infiniteStamina: false,
    vehicleGodmode: false,
    dynamicWater: false,
    instantWeather: false,
    tsunami: false,
    blackout: false,
  });

  const [menuStack, setMenuStack] = useState<MenuDef[]>([]);
  const [selectedIndex, setSelectedIndex] = useState<number>(0);

  const handleToggle = (
    toggleKey: string,
    nuiEvent: string,
    extraData: any = {},
  ) => {
    setToggleStates((prev) => {
      const newState = !prev[toggleKey];
      sendNui(nuiEvent, { state: newState, ...extraData });
      return { ...prev, [toggleKey]: newState };
    });
  };

  const handleAction = (action: string, data: any = {}) => {
    sendNui(action, data);
  };

  const handlePlayerAction = (action: string, playerId: number) => {
    sendNui(action, { playerId });
  };

  const handleActionWithClose = (actionCallback: () => void) => {
    sendNui("setQuickMenuStatus", { status: false });
    setTimeout(() => {
      actionCallback();
    }, 150);
  };

  const getMenuStructure = (): MenuDef => {
    return {
      id: "root",
      title: "QuickMenu",
      icon: <Zap size={16} className="text-blue-400" />,
      items: [
        {
          label: translation.qmSelfOptions || "Self Options",
          icon: <Shield size={14} className="text-emerald-400" />,
          submenu: {
            id: "self",
            title: translation.qmSelfOptions || "Self Options",
            icon: <Shield size={16} className="text-emerald-400" />,
            items: [
              {
                label: translation.qmGodmode || "Godmode",
                isToggle: true,
                toggleStateKey: "godmode",
                action: () => handleToggle("godmode", "godMode"),
              },
              {
                label: translation.qmInvisible || "Invisible",
                isToggle: true,
                toggleStateKey: "invisible",
                action: () => handleToggle("invisible", "invisibility"),
              },
              {
                label: translation.qmNoClip || "NoClip",
                isToggle: true,
                toggleStateKey: "noclip",
                action: () => handleToggle("noclip", "noclip"),
              },
              {
                label: translation.qmSuperJump || "Super Jump",
                isToggle: true,
                toggleStateKey: "superJump",
                action: () => handleToggle("superJump", "superJump"),
              },
              {
                label: translation.qmFastRun || "Fast Run",
                isToggle: true,
                toggleStateKey: "fastRun",
                action: () => handleToggle("fastRun", "fastRun"),
              },
              {
                label: translation.qmInfiniteStamina || "Infinite Stamina",
                isToggle: true,
                toggleStateKey: "infiniteStamina",
                action: () =>
                  handleToggle("infiniteStamina", "infiniteStamina"),
              },
              {
                label: translation.qmReviveHeal || "Revive & Heal",
                action: () => handleAction("trollAction", { action: "heal" }),
              },
              {
                label: translation.qmMaxArmor || "Max Armor",
                action: () => handleAction("trollAction", { action: "armor" }),
              },
            ],
          },
        },
        {
          label: translation.qmVehicleOptions || "Vehicle Options",
          icon: <Car size={14} className="text-amber-400" />,
          submenu: {
            id: "vehicle",
            title: translation.qmVehicleOptions || "Vehicle Options",
            icon: <Car size={16} className="text-amber-400" />,
            items: [
              {
                label: translation.qmVehicleGodmode || "Vehicle Godmode",
                isToggle: true,
                toggleStateKey: "vehicleGodmode",
                action: () =>
                  handleToggle("vehicleGodmode", "godMode", {
                    type: "vehicle",
                  }),
              },
              {
                label: translation.qmRepairVehicle || "Repair Vehicle",
                action: () => handleAction("repairVehicle"),
              },
              {
                label: translation.qmFlipVehicle || "Flip Vehicle",
                action: () => handleAction("flipVehicle"),
              },
              {
                label: translation.qmMaxUpgrade || "Max Upgrade",
                action: () => handleAction("upgradeVehicle"),
              },
              {
                label: translation.qmDeleteVehicle || "Delete Vehicle",
                action: () =>
                  handleAction("deleteObjects", { type: "vehicles" }),
              },
            ],
          },
        },
        {
          label: translation.qmEnvironment || "Environment",
          icon: <Cloud size={14} className="text-indigo-400" />,
          submenu: {
            id: "env",
            title: translation.qmEnvironment || "Environment",
            icon: <Cloud size={16} className="text-indigo-400" />,
            items: [
              {
                label: translation.qmTimeMorning || "Time: Morning (8:00)",
                action: () => handleAction("setTime", { time: "8:00" }),
              },
              {
                label: translation.qmTimeNoon || "Time: Noon (12:00)",
                action: () => handleAction("setTime", { time: "12:00" }),
              },
              {
                label: translation.qmTimeNight || "Time: Night (0:00)",
                action: () => handleAction("setTime", { time: "0:00" }),
              },
              {
                label: translation.qmWeatherClear || "Weather: Clear (Sunny)",
                action: () =>
                  handleAction("setWeather", { weather: "EXTRASUNNY" }),
              },
              {
                label: translation.qmWeatherRain || "Weather: Rain",
                action: () => handleAction("setWeather", { weather: "RAIN" }),
              },
              {
                label: translation.qmDynamicWater || "Dynamic Water",
                isToggle: true,
                toggleStateKey: "dynamicWater",
                action: () => handleToggle("dynamicWater", "dynamicWater"),
              },
              {
                label: translation.qmInstantWeather || "Instant Weather",
                isToggle: true,
                toggleStateKey: "instantWeather",
                action: () => handleToggle("instantWeather", "instantWeather"),
              },
              {
                label: translation.qmBlackout || "Blackout",
                isToggle: true,
                toggleStateKey: "blackout",
                action: () => handleToggle("blackout", "blackout"),
              },
              {
                label: translation.qmTsunami || "Tsunami",
                isToggle: true,
                toggleStateKey: "tsunami",
                action: () => handleToggle("tsunami", "tsunami"),
              },
            ],
          },
        },
        {
          label: translation.qmServerActions || "Server & Cleanup",
          icon: <Zap size={14} className="text-yellow-400" />,
          submenu: {
            id: "server",
            title: translation.qmServerActions || "Server Actions",
            icon: <Zap size={16} className="text-yellow-400" />,
            items: [
              {
                label: translation.qmHealAll || "Heal All",
                action: () => handleAction("allAction", { type: "heal" }),
              },
              {
                label: translation.qmReviveAll || "Revive All",
                action: () => handleAction("allAction", { type: "heal" }),
              },
              {
                label: translation.qmBringAll || "Bring All",
                action: () => handleAction("allAction", { type: "bring" }),
              },
              {
                label: translation.qmDeleteAllVehicles || "Delete All Vehicles",
                action: () =>
                  handleAction("deleteObjects", { type: "vehicles" }),
              },
              {
                label: translation.qmDeleteAllPeds || "Delete All Peds",
                action: () => handleAction("deleteObjects", { type: "peds" }),
              },
              {
                label: translation.qmDeleteAllObjects || "Delete All Objects",
                action: () =>
                  handleAction("deleteObjects", { type: "objects" }),
              },
              {
                label: translation.qmClearMyInventory || "Clear My Inventory",
                action: () => handleAction("clearInventory"),
              },
            ],
          },
        },
        {
          label: translation.qmOnlinePlayers || "Online Players",
          icon: <Users size={14} className="text-pink-400" />,
          submenu: {
            id: "players",
            title: translation.qmOnlinePlayers || "Online Players",
            icon: <Users size={16} className="text-pink-400" />,
            items:
              players.length === 0
                ? [
                    {
                      label:
                        translation.qmNoPlayersOnline || "No players online",
                      action: () => {},
                    },
                  ]
                : players.map((p) => ({
                    label: `[${p.id}] ${p.name}`,
                    submenu: {
                      id: `player_${p.id}`,
                      title: p.name,
                      icon: <Users size={16} className="text-pink-400" />,
                      items: [
                        {
                          label: translation.qmGoto || "Goto",
                          action: () => handlePlayerAction("goto", p.id),
                        },
                        {
                          label: translation.qmBring || "Bring",
                          action: () => handlePlayerAction("bring", p.id),
                        },
                        {
                          label: translation.qmSpectate || "Spectate",
                          action: () => handlePlayerAction("spectate", p.id),
                        },
                        {
                          label: translation.qmHeal || "Heal",
                          action: () => handlePlayerAction("heal", p.id),
                        },
                        {
                          label: translation.qmRevive || "Revive",
                          action: () => handlePlayerAction("revive", p.id),
                        },
                        {
                          label: translation.qmFreeze || "Freeze",
                          action: () => handlePlayerAction("freeze", p.id),
                        },
                        {
                          label: translation.qmKill || "Kill",
                          action: () => handlePlayerAction("kill", p.id),
                        },
                        {
                          label: translation.qmKick || "Kick",
                          action: () =>
                            handleActionWithClose(() => {
                              onPlayerAction && onPlayerAction("kick", p.id);
                            }),
                        },
                        {
                          label: translation.qmBan || "Ban",
                          action: () =>
                            handleActionWithClose(() => {
                              onPlayerAction && onPlayerAction("ban", p.id);
                            }),
                        },
                      ],
                    },
                  })),
          },
        },
      ],
    };
  };

  const rootMenu = getMenuStructure();
  const currentMenu =
    menuStack.length > 0 ? menuStack[menuStack.length - 1] : rootMenu;

  useEffect(() => {
    if (isVisible) {
      setMenuStack([]);
      setSelectedIndex(0);
    }
  }, [isVisible]);

  useEffect(() => {
    if (!isVisible) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setSelectedIndex(
          (prev) => (prev + 1) % Math.max(1, currentMenu.items.length),
        );
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setSelectedIndex(
          (prev) =>
            (prev - 1 + currentMenu.items.length) %
            Math.max(1, currentMenu.items.length),
        );
      } else if (e.key === "Enter") {
        e.preventDefault();
        const selectedItem = currentMenu.items[selectedIndex];
        if (selectedItem) {
          if (selectedItem.submenu) {
            setMenuStack((prev) => [...prev, selectedItem.submenu!]);
            setSelectedIndex(0);
          } else if (selectedItem.action) {
            selectedItem.action();
          }
        }
      } else if (e.key === "Backspace") {
        e.preventDefault();
        if (menuStack.length > 0) {
          setMenuStack((prev) => prev.slice(0, -1));
          setSelectedIndex(0);
        } else {
          sendNui("setQuickMenuStatus", { status: false });
        }
      } else if (e.key === "Escape") {
        sendNui("setQuickMenuStatus", { status: false });
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isVisible, currentMenu, menuStack, selectedIndex]);

  const itemRefs = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    if (itemRefs.current[selectedIndex]) {
      itemRefs.current[selectedIndex]?.scrollIntoView({
        behavior: "smooth",
        block: "nearest",
      });
    }
  }, [selectedIndex, menuStack]);

  if (!isVisible) return null;

  return (
    <AnimatePresence>
      {isVisible && (
        <div
          className="fixed top-1/2 right-6 -translate-y-1/2 z-[100]"
          style={{ perspective: "1200px" }}
        >
          <motion.div
            initial={{ x: "100%", opacity: 0, rotateY: -20, scale: 0.95 }}
            animate={{ x: 0, opacity: 1, rotateY: -10, scale: 1 }}
            exit={{ x: "100%", opacity: 0, rotateY: -20, scale: 0.95 }}
            transition={{ type: "spring", damping: 22, stiffness: 200 }}
            className="w-[340px] flex flex-col rounded-xl pointer-events-none origin-right"
            style={{
              background:
                "linear-gradient(145deg, rgba(30, 30, 35, 0.95) 0%, rgba(15, 15, 20, 0.98) 100%)",
              border: "1px solid rgba(255,255,255,0.08)",
              boxShadow:
                "-15px 20px 45px rgba(0,0,0,0.7), inset 1px 1px 1px rgba(255,255,255,0.1), inset -1px -1px 2px rgba(0,0,0,0.4)",
              transformStyle: "preserve-3d",
            }}
          >
            {}
            <div className="px-4 pt-4 pb-2">
              <div className="text-[10px] text-gray-400 font-bold uppercase tracking-widest flex items-center justify-between">
                <span>
                  {currentMenu.title !== "QuickMenu"
                    ? currentMenu.title
                    : translation.qmMainMenu || "Main Menu"}
                </span>
                <span className="bg-black/30 shadow-[inset_0_1px_3px_rgba(0,0,0,0.5)] border border-white/5 px-2 py-0.5 rounded text-white">
                  {selectedIndex + 1} / {Math.max(1, currentMenu.items.length)}
                </span>
              </div>
            </div>

            {}
            <div className="flex-1 overflow-y-auto h-[550px] custom-scrollbar py-1 px-1">
              {currentMenu.items.length === 0 ? (
                <div className="py-4 text-center text-xs text-gray-500">
                  {translation.qmNoOptionsAvailable || "No options available"}
                </div>
              ) : (
                currentMenu.items.map((item, idx) => {
                  const isSelected = selectedIndex === idx;
                  const isToggleOn =
                    item.isToggle && item.toggleStateKey
                      ? toggleStates[item.toggleStateKey]
                      : false;

                  return (
                    <div
                      key={idx}
                      ref={(el) => (itemRefs.current[idx] = el)}
                      className={`
                                            relative flex items-center justify-between px-4 py-3 mx-1 my-0.5 rounded-lg transition-all
                                            ${isSelected ? "bg-gradient-to-r from-blue-600/30 to-blue-500/10 text-white shadow-md" : "text-gray-400"}
                                        `}
                    >
                      <div className="flex items-center gap-2.5 z-10">
                        {item.icon && (
                          <span
                            className={
                              isSelected ? "text-blue-400" : "text-gray-500"
                            }
                          >
                            {item.icon}
                          </span>
                        )}
                        <span className="text-xs font-semibold tracking-wide">
                          {item.label}
                        </span>
                      </div>

                      <div className="flex items-center gap-2 z-10">
                        {item.rightLabel && (
                          <span className="text-[10px] font-medium opacity-60 bg-black/40 px-1.5 py-0.5 rounded">
                            {item.rightLabel}
                          </span>
                        )}

                        {item.isToggle && (
                          <div
                            className={`w-3 h-3 rounded-full border flex items-center justify-center transition-colors ${
                              isToggleOn
                                ? "bg-emerald-500 border-emerald-500"
                                : "border-gray-600 bg-black/30"
                            }`}
                          >
                            {isToggleOn && (
                              <Check size={8} className="text-white" />
                            )}
                          </div>
                        )}

                        {item.submenu && (
                          <ChevronRight
                            size={14}
                            className={
                              isSelected ? "text-blue-400" : "text-gray-600"
                            }
                          />
                        )}
                      </div>

                      {isSelected && (
                        <motion.div
                          layoutId="selectedIndicator"
                          className="absolute inset-0 bg-gradient-to-r from-blue-500/20 to-transparent border-l-2 border-blue-500 rounded-lg"
                          transition={{
                            type: "spring",
                            damping: 25,
                            stiffness: 300,
                          }}
                        />
                      )}
                    </div>
                  );
                })
              )}
            </div>

            {}
            <div className="px-4 py-2 border-t border-white/5 bg-black/20 flex items-center justify-between text-[9px] font-mono text-gray-500">
              <div className="flex items-center gap-2">
                <span>
                  <strong className="text-gray-300">↑↓</strong> Nav
                </span>
                <span>
                  <strong className="text-gray-300">↵</strong> Select
                </span>
                <span>
                  <strong className="text-gray-300">⌫</strong> Back
                </span>
              </div>
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
