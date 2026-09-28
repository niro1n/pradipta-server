import React from "react";

import { motion } from "framer-motion";
import {
  LayoutDashboard,
  Users,
  Server,
  Wrench,
  MessageSquare,
  Terminal,
  Menu,
  X,
  Rocket,
  Ban,
  Settings,
  Shield,
  ClipboardList,
  ScrollText,
  ClipboardCheck,
} from "lucide-react";
import { useState } from "react";
import { Button } from "./ui/button";
import { cn } from "../lib/utils";
import { useTranslation } from "../lib/translation";
import { useTheme } from "../hooks/ThemeContext";
import pradiptaLogo from "../assets/logo/pradipta-logo-512.png";

type SidebarProps = {
  activeTab: string;
  onTabChange: (tab: string) => void;
  isMobile: boolean;
};

type NavItem = {
  id: string;
  label: string;
  subtitle?: string;
  icon: React.ReactNode;
  color: string;
};

export default function Sidebar({
  activeTab,
  onTabChange,
  isMobile,
}: SidebarProps) {
  const [isCollapsed, setIsCollapsed] = useState(isMobile);
  const { themeSettings } = useTheme();
  const translation = useTranslation();
  const settingsItem: NavItem = {
    id: "settings",
    label: translation.sidebarSettings || "Settings",
    icon: <Settings size={20} />,
    color: "from-indigo-700 to-violet-700",
  };
  const navItems: NavItem[] = [
    {
      id: "dashboard",
      label: translation.dashboardSideBar || "Dashboard",
      subtitle: "Server overview and stats",
      icon: <LayoutDashboard size={20} />,
      color: "from-pink-500 to-rose-500",
    },
    {
      id: "players",
      label: translation.sidebarPlayers || "Players",
      subtitle: "Online players and actions",
      icon: <Users size={20} />,
      color: "from-cyan-500 to-blue-500",
    },
    {
      id: "server",
      label: translation.sidebarServer || "Server",
      subtitle: "Server management",
      icon: <Server size={20} />,
      color: "from-green-500 to-emerald-500",
    },
    {
      id: "tools",
      label: translation.sidebarTools || "Tools",
      subtitle: "Admin tools & controls",
      icon: <Wrench size={20} />,
      color: "from-amber-500 to-orange-500",
    },
    {
      id: "chat",
      label: translation.sidebarChat || "Chat",
      subtitle: "Server chat & commands",
      icon: <MessageSquare size={20} />,
      color: "from-purple-500 to-violet-500",
    },
    {
      id: "terminal",
      label: translation.sidebarTerminal || "Terminal",
      subtitle: "Live server console",
      icon: <Terminal size={20} />,
      color: "from-green-500 to-emerald-500",
    },
    {
      id: "reports",
      label: translation.sidebarReports || "Reports",
      subtitle: "Manage server reports",
      icon: <ClipboardList size={20} />,
      color: "from-yellow-500 to-orange-500",
    },
    {
      id: "logs",
      label: translation.sidebarLogs || "Logs",
      subtitle: "Server activity logs",
      icon: <ScrollText size={20} />,
      color: "from-amber-500 to-yellow-500",
    },
    {
      id: "bans",
      label: translation.sidebarBans || "Bans",
      subtitle: "Manage banned players",
      icon: <Ban size={20} />,
      color: "from-orange-500 to-red-500",
    },
    {
      id: "approvals",
      label: "Approvals",
      subtitle: "Admin registrations",
      icon: <ClipboardCheck size={20} />,
      color: "from-blue-500 to-cyan-500",
    },
  ];

  return (
    <motion.div
      className={cn(
        "bg-black/10 border-r border-ui-border h-full flex flex-col transition-all duration-300 ease-in-out",
        isCollapsed ? "w-20" : "w-[280px]",
      )}
      initial={{ x: isMobile ? -250 : 0 }}
      animate={{ x: 0 }}
    >
      <div className="flex items-center justify-between p-4 border-b border-ui-border">
        {!isCollapsed ? (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="flex items-center gap-3 min-w-0"
          >
            <div className="w-10 h-10 rounded-lg bg-black/40 border border-white/10 flex items-center justify-center overflow-hidden p-1 shadow-inner shrink-0">
              <img src={pradiptaLogo} alt="Pradipta Logo" className="w-full h-full object-contain" />
            </div>
            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <h1 className="text-base font-extrabold text-white tracking-wider truncate">
                  PRADIPTA
                </h1>
                <span className="text-[10px] font-semibold px-1.5 py-0.5 rounded bg-[#d4af37]/20 text-[#d4af37] border border-[#d4af37]/30 shrink-0">
                  ADMIN
                </span>
              </div>
              <p className="text-[10px] font-medium text-gray-400 tracking-wider uppercase truncate">
                ADMINISTRATIVE CONSOLE
              </p>
            </div>
          </motion.div>
        ) : (
          <div className="w-8 h-8 rounded-lg bg-black/40 border border-white/10 flex items-center justify-center overflow-hidden p-1 shrink-0">
            <img src={pradiptaLogo} alt="Pradipta Logo" className="w-full h-full object-contain" />
          </div>
        )}
        <Button
          variant="ghost"
          size="icon"
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="text-ui-textMuted hover:text-white hover:bg-white/5"
        >
          {isCollapsed ? <Menu size={20} /> : <X size={20} />}
        </Button>
      </div>

      <div className="flex flex-col flex-1">
        <div className="flex flex-col gap-1.5 p-3">
          {navItems.map((item) => (
            <Button
              key={item.id}
              variant={activeTab === item.id ? "default" : "ghost"}
              className={cn(
                "justify-start gap-3.5 transition-all h-auto py-2.5 px-3 rounded-md",
                activeTab === item.id
                  ? `bg-[#d4af37]/15 text-[#d4af37] border border-[#d4af37]/30 shadow-sm`
                  : "hover:bg-white/5 text-ui-textMuted hover:text-white border border-transparent",
              )}
              onClick={() => onTabChange(item.id)}
            >
              <div className="flex items-center justify-center min-w-[20px]">
                {item.icon}
              </div>
              {!isCollapsed && (
                <div className="flex flex-col items-start truncate">
                  <span className="font-semibold text-sm leading-tight">
                    {item.label}
                  </span>
                  <span
                    className={cn(
                      "text-[10px] leading-tight mt-0.5 opacity-70",
                      activeTab === item.id
                        ? "text-[#d4af37]"
                        : "text-ui-textMuted",
                    )}
                  >
                    {item.subtitle}
                  </span>
                </div>
              )}
            </Button>
          ))}
        </div>
        <div className="mt-auto flex flex-col items-center">
          <div className="border-t border-ui-border w-full" />
          <Button
            key={settingsItem.id}
            variant={activeTab === settingsItem.id ? "default" : "ghost"}
            className={cn(
              "justify-start gap-3.5 transition-all h-auto py-3 px-4 w-full rounded-none",
              activeTab === settingsItem.id
                ? `bg-[#d4af37]/15 text-[#d4af37] border-t border-[#d4af37]/30`
                : "hover:bg-white/5 text-ui-textMuted hover:text-white border-t border-transparent",
            )}
            onClick={() => onTabChange(settingsItem.id)}
          >
            <div className="flex items-center justify-center min-w-[20px]">
              {settingsItem.icon}
            </div>
            {!isCollapsed && (
              <div className="flex flex-col items-start truncate">
                <span className="font-semibold text-sm leading-tight">
                  {settingsItem.label}
                </span>
                <span
                  className={cn(
                    "text-[10px] leading-tight mt-0.5 opacity-70",
                    activeTab === settingsItem.id
                      ? "text-[#d4af37]"
                      : "text-ui-textMuted",
                  )}
                >
                  {translation.sbSystemConfig || "System configuration"}
                </span>
              </div>
            )}
          </Button>
        </div>
      </div>
    </motion.div>
  );
}
