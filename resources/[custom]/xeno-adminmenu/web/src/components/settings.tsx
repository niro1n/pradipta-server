import React, { useRef } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "./ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "./ui/select";
import { Textarea } from "./ui/textarea";
import { Badge } from "./ui/badge";
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
import { WebhookConfig, StaffMember, Group, Permission } from "../types/index";
import { sendNui } from "../lib/sendNui";
import {
  Palette,
  Shield,
  Webhook,
  Save,
  Trash2,
  Plus,
  Copy,
  Check,
  Users,
  MessageSquare,
  Server,
  Zap,
  Lock,
  AlertCircle,
  Ban,
  Database,
  Monitor,
  Layout,
  Rocket,
  Wind,
  Settings as SettingsIcon,
  Link,
  Pause,
  Play,
  Edit,
  X,
  UserPlus,
  UserX,
  User,
  Crown,
  Key,
} from "lucide-react";
import { useTranslation } from "../lib/translation";
import { useState, useCallback, useEffect } from "react";
import { useTheme } from "../hooks/ThemeContext";

export default function Settings() {
  const translation = useTranslation();
  const { themeSettings, setThemeSettings, resetThemeSettings } = useTheme();
  const webhookFormRef = useRef<HTMLDivElement>(null);
  const staffFormRef = useRef<HTMLDivElement>(null);
  const groupFormRef = useRef<HTMLDivElement>(null);
  const [webhooks, setWebhooks] = useState<WebhookConfig[]>([]);

  const [newWebhook, setNewWebhook] = useState({
    name: "",
    url: "",
    events: [] as string[],
    description: "",
  });

  const [showAddWebhook, setShowAddWebhook] = useState(false);
  const [editingWebhook, setEditingWebhook] = useState<WebhookConfig | null>(
    null,
  );
  const [copiedWebhook, setCopiedWebhook] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState("appearance");

  useEffect(() => {
    setShowAddWebhook(false);
    setEditingWebhook(null);
    setNewWebhook({ name: "", url: "", events: [], description: "" });

    setShowAddStaff(false);
    setEditingStaff(null);
    setNewStaff({ name: "", identifier: "", group: "", permissions: [] });

    setShowAddGroup(false);
    setEditingGroup(null);
    setNewGroup({
      name: "",
      color: "#3b82f6",
      permissions: [],
      description: "",
    });
  }, [activeTab]);

  const [staffMembers, setStaffMembers] = useState<StaffMember[]>([]);

  const [showAddStaff, setShowAddStaff] = useState(false);
  const [editingStaff, setEditingStaff] = useState<StaffMember | null>(null);
  const [newStaff, setNewStaff] = useState({
    name: "",
    identifier: "",
    group: "",
    permissions: [] as string[],
  });

  const [groups, setGroups] = useState<Group[]>([]);
  const [deleteConfirmation, setDeleteConfirmation] = useState<{
    type: "group" | "staff" | "webhook";
    id: string;
    name: string;
  } | null>(null);
  const [showResetConfirmation, setShowResetConfirmation] = useState(false);

  const [showAddGroup, setShowAddGroup] = useState(false);
  const [editingGroup, setEditingGroup] = useState<Group | null>(null);
  const [newGroup, setNewGroup] = useState({
    name: "",
    color: "#3b82f6",
    permissions: [] as string[],
    description: "",
  });

  const availablePermissions: Permission[] = [
    {
      id: "admin.menu",
      name: "Open Menu",
      description: "Can open the admin menu",
      category: "admin",
    },
    {
      id: "player.kick",
      name: "Kick Players",
      description: "Kick players from the server",
      category: "player",
    },
    {
      id: "player.ban",
      name: "Ban Players",
      description: "Ban players from the server",
      category: "player",
    },
    {
      id: "player.unban",
      name: "Unban Players",
      description: "Unban players from the server",
      category: "player",
    },
    {
      id: "player.teleport",
      name: "Teleport Players",
      description: "Teleport players",
      category: "player",
    },
    {
      id: "player.teleport.to",
      name: "Teleport To",
      description: "Teleport to players",
      category: "player",
    },
    {
      id: "player.teleport.bring",
      name: "Bring Player",
      description: "Bring players to you",
      category: "player",
    },
    {
      id: "player.heal",
      name: "Heal Players",
      description: "Heal players",
      category: "player",
    },
    {
      id: "player.revive",
      name: "Revive Players",
      description: "Revive players",
      category: "player",
    },
    {
      id: "player.kill",
      name: "Kill Players",
      description: "Kill players",
      category: "player",
    },
    {
      id: "player.freeze",
      name: "Freeze Players",
      description: "Freeze players",
      category: "player",
    },
    {
      id: "player.spectate",
      name: "Spectate Players",
      description: "Spectate players",
      category: "player",
    },
    {
      id: "player.inventory",
      name: "View Inventory",
      description: "View player inventory",
      category: "player",
    },
    {
      id: "player.clearinventory",
      name: "Clear Inventory",
      description: "Clear player inventory",
      category: "player",
    },
    {
      id: "server.restart",
      name: "Restart Server",
      description: "Restart the server",
      category: "server",
    },
    {
      id: "server.announce",
      name: "Send Announcements",
      description: "Send server announcements",
      category: "server",
    },
    {
      id: "server.terminal",
      name: "Use Terminal",
      description: "Use live server console",
      category: "server",
    },
    {
      id: "server.resources",
      name: "Manage Resources",
      description: "Start/Stop/Restart resources",
      category: "server",
    },
    {
      id: "server.settings",
      name: "Manage Settings",
      description: "Manage server settings",
      category: "server",
    },
    {
      id: "admin.godmode",
      name: "God Mode",
      description: "Enable god mode",
      category: "admin",
    },
    {
      id: "admin.noclip",
      name: "Noclip",
      description: "Enable noclip",
      category: "admin",
    },
    {
      id: "admin.invisible",
      name: "Invisibility",
      description: "Enable invisibility",
      category: "admin",
    },
    {
      id: "admin.reports",
      name: "View Reports",
      description: "View and manage reports",
      category: "admin",
    },
    {
      id: "moderation.warn",
      name: "Warn Players",
      description: "Warn players",
      category: "moderation",
    },
    {
      id: "moderation.mute",
      name: "Mute Players",
      description: "Mute players",
      category: "moderation",
    },
    {
      id: "economy.give",
      name: "Give Money",
      description: "Give money to players",
      category: "economy",
    },
    {
      id: "economy.remove",
      name: "Remove Money",
      description: "Remove money from players",
      category: "economy",
    },
    {
      id: "economy.set",
      name: "Set Money",
      description: "Set player money",
      category: "economy",
    },
    {
      id: "economy.items",
      name: "Give Items",
      description: "Give items to players",
      category: "economy",
    },
    {
      id: "vehicles.spawn",
      name: "Spawn Vehicles",
      description: "Spawn vehicles",
      category: "vehicles",
    },
    {
      id: "vehicles.delete",
      name: "Delete Vehicles",
      description: "Delete vehicles",
      category: "vehicles",
    },
    {
      id: "vehicles.fix",
      name: "Fix Vehicles",
      description: "Fix vehicles",
      category: "vehicles",
    },
    {
      id: "world.weather",
      name: "Control Weather",
      description: "Control weather",
      category: "world",
    },
    {
      id: "world.time",
      name: "Control Time",
      description: "Control time",
      category: "world",
    },
  ];

  const webhookEvents = [
    { value: "player_join", label: "Player Join", icon: <Users size={16} /> },
    { value: "player_leave", label: "Player Leave", icon: <Users size={16} /> },
    {
      value: "chat_message",
      label: "Chat Message",
      icon: <MessageSquare size={16} />,
    },
    {
      value: "admin_action",
      label: "Admin Action",
      icon: <Shield size={16} />,
    },
    {
      value: "system_alert",
      label: "System Alert",
      icon: <AlertCircle size={16} />,
    },
    { value: "player_ban", label: "Player Ban", icon: <Ban size={16} /> },
    { value: "player_kick", label: "Player Kick", icon: <UserX size={16} /> },
    {
      value: "server_restart",
      label: "Server Restart",
      icon: <Server size={16} />,
    },
    {
      value: "resource_start",
      label: "Resource Start",
      icon: <Zap size={16} />,
    },
    { value: "resource_stop", label: "Resource Stop", icon: <Zap size={16} /> },
    {
      value: "weather_change",
      label: "Weather/Time",
      icon: <Server size={16} />,
    },
    {
      value: "report_action",
      label: "Report Action",
      icon: <MessageSquare size={16} />,
    },
    { value: "give_item", label: "Item Given", icon: <Database size={16} /> },
    {
      value: "staff_added",
      label: "Staff Added",
      icon: <UserPlus size={16} />,
    },
    {
      value: "staff_removed",
      label: "Staff Removed",
      icon: <UserX size={16} />,
    },
    {
      value: "staff_promoted",
      label: "Staff Promoted",
      icon: <Crown size={16} />,
    },
    {
      value: "group_created",
      label: "Group Created",
      icon: <Shield size={16} />,
    },
    {
      value: "group_updated",
      label: "Group Updated",
      icon: <Shield size={16} />,
    },
    {
      value: "group_deleted",
      label: "Group Deleted",
      icon: <Shield size={16} />,
    },
  ];

  const updateTheme = useCallback(
    (key: keyof typeof themeSettings, value: string) => {
      setThemeSettings((prev) => ({ ...prev, [key]: value }));
    },
    [setThemeSettings],
  );

  const handleWebhookToggle = useCallback(
    (id: string) => {
      const webhook = webhooks.find((w) => w.id === id);
      if (webhook) {
        sendNui("toggleWebhook", {
          webhookId: Number(id),
          isActive: !webhook.isActive,
        });
      }
    },
    [webhooks],
  );

  const handleWebhookDelete = useCallback((id: string, name: string) => {
    setDeleteConfirmation({ type: "webhook", id, name });
  }, []);

  const handleEditWebhook = useCallback((webhook: WebhookConfig) => {
    setEditingWebhook(webhook);
    setNewWebhook({
      name: webhook.name,
      url: webhook.url,
      events: webhook.events,
      description: webhook.description || "",
    });
    setShowAddWebhook(true);
  }, []);

  const handleCopyWebhook = useCallback((url: string) => {
    navigator.clipboard.writeText(url);
    setCopiedWebhook(url);
    setTimeout(() => setCopiedWebhook(null), 2000);
  }, []);

  const handleNewWebhookEventToggle = useCallback((event: string) => {
    setNewWebhook((prev) => {
      const events = prev.events.includes(event)
        ? prev.events.filter((e) => e !== event)
        : [...prev.events, event];
      return { ...prev, events };
    });
  }, []);

  const handleAddStaff = useCallback(() => {
    if (newStaff.name && newStaff.identifier && newStaff.group) {
      sendNui("saveStaff", { staff: newStaff });
      setNewStaff({ name: "", identifier: "", group: "", permissions: [] });
      setShowAddStaff(false);
      setEditingStaff(null);
    }
  }, [newStaff]);

  const scrollToForm = useCallback(
    (ref: React.RefObject<HTMLDivElement | null>) => {
      if (ref.current) {
        const scrollContainer = ref.current.closest(".overflow-auto");
        if (scrollContainer) {
          const elementTop =
            ref.current.getBoundingClientRect().top -
            scrollContainer.getBoundingClientRect().top +
            scrollContainer.scrollTop;
          scrollContainer.scrollTo({
            top: elementTop - 16,
            behavior: "smooth",
          });
        } else {
          ref.current.scrollIntoView({
            behavior: "smooth",
            block: "start",
            inline: "nearest",
          });
        }
      }
    },
    [],
  );

  const handleEditStaff = useCallback((staff: StaffMember) => {
    setEditingStaff(staff);
    setNewStaff({
      name: staff.name,
      identifier: staff.identifier,
      group: staff.group,
      permissions: staff.permissions,
    });
    setShowAddStaff(true);
  }, []);

  const handleUpdateStaff = useCallback(() => {
    if (
      editingStaff &&
      newStaff.name &&
      newStaff.identifier &&
      newStaff.group
    ) {
      const updatedStaff = {
        ...editingStaff,
        name: newStaff.name,
        identifier: newStaff.identifier,
        group: newStaff.group,
        permissions: newStaff.permissions,
      };
      sendNui("saveStaff", { staff: updatedStaff });
      setEditingStaff(null);
      setNewStaff({ name: "", identifier: "", group: "", permissions: [] });
      setShowAddStaff(false);
    }
  }, [editingStaff, newStaff]);

  const handleDeleteStaff = useCallback((id: string, name: string) => {
    setDeleteConfirmation({ type: "staff", id, name });
  }, []);

  const handleStaffPermissionToggle = useCallback((permission: string) => {
    setNewStaff((prev) => {
      const permissions = prev.permissions.includes(permission)
        ? prev.permissions.filter((p) => p !== permission)
        : [...prev.permissions, permission];
      return { ...prev, permissions };
    });
  }, []);

  const handleSelectAllStaffPermissions = useCallback(() => {
    setNewStaff((prev) => {
      const allIds = availablePermissions.map((p) => p.id);
      const isAllSelected = prev.permissions.length === allIds.length;
      return { ...prev, permissions: isAllSelected ? [] : allIds };
    });
  }, [availablePermissions]);

  const handleAddGroup = useCallback(() => {
    if (newGroup.name) {
      sendNui("saveGroup", { group: newGroup });
      setNewGroup({
        name: "",
        color: "#3b82f6",
        permissions: [],
        description: "",
      });
      setShowAddGroup(false);
      setEditingGroup(null);
    }
  }, [newGroup]);

  const handleEditGroup = useCallback((group: Group) => {
    setEditingGroup(group);
    setNewGroup({
      name: group.name,
      color: group.color,
      permissions: group.permissions,
      description: group.description || "",
    });
    setShowAddGroup(true);
  }, []);

  const handleUpdateGroup = useCallback(() => {
    if (editingGroup && newGroup.name) {
      const updatedGroup = {
        ...editingGroup,
        name: newGroup.name,
        color: newGroup.color,
        permissions: newGroup.permissions,
        description: newGroup.description,
      };
      sendNui("saveGroup", { group: updatedGroup });
      setEditingGroup(null);
      setNewGroup({
        name: "",
        color: "#3b82f6",
        permissions: [],
        description: "",
      });
      setShowAddGroup(false);
    }
  }, [editingGroup, newGroup]);

  const handleDeleteGroup = useCallback((id: string, name: string) => {
    setDeleteConfirmation({ type: "group", id, name });
  }, []);

  const handleGroupPermissionToggle = useCallback((permission: string) => {
    setNewGroup((prev) => {
      const permissions = prev.permissions.includes(permission)
        ? prev.permissions.filter((p) => p !== permission)
        : [...prev.permissions, permission];
      return { ...prev, permissions };
    });
  }, []);

  const handleSelectAllGroupPermissions = useCallback(() => {
    setNewGroup((prev) => {
      const allIds = availablePermissions.map((p) => p.id);
      const isAllSelected = prev.permissions.length === allIds.length;
      return { ...prev, permissions: isAllSelected ? [] : allIds };
    });
  }, [availablePermissions]);

  useEffect(() => {
    sendNui("fetchGroups");
    sendNui("fetchStaff");
    sendNui("fetchWebhooks");

    const handleMessage = (event: MessageEvent) => {
      const { action, groups, staff, webhooks: receivedWebhooks } = event.data;
      if (action === "receiveGroups") {
        setGroups(groups);
      } else if (action === "receiveStaff") {
        setStaffMembers(staff);
      } else if (action === "receiveWebhooks") {
        setWebhooks(
          receivedWebhooks.map((w: any) => ({
            ...w,
            id: String(w.id),
            isActive: w.isActive ?? w.is_active === 1,
          })),
        );
      } else if (action === "webhookTestResult") {
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  return (
    <>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            <span className="w-8 h-8 rounded-lg bg-ui-blue/10 flex items-center justify-center ">
              <Palette size={16} className="text-ui-blue" />
            </span>
            {translation.settings || "Settings"}
          </h1>
          <p className="text-gray-400 ml-11">
            {translation.settingsDescription ||
              "Customize your admin panel experience"}
          </p>
        </div>

        <Tabs
          defaultValue="appearance"
          className="w-full"
          onValueChange={(value) => setActiveTab(value)}
        >
          <TabsList className="bg-ui-layer/50 border-ui-border text-gray-400">
            <TabsTrigger
              value="appearance"
              className="data-[state=active]:bg-ui-blue/10 data-[state=active]:text-ui-blue transition-all"
            >
              <Palette size={16} className="mr-2" />
              {translation.appearance || "Appearance"}
            </TabsTrigger>
            <TabsTrigger
              value="webhooks"
              className="data-[state=active]:bg-ui-blue/10 data-[state=active]:text-ui-blue transition-all"
            >
              <Webhook size={16} className="mr-2" />
              {translation.webhooks || "Webhooks"}
            </TabsTrigger>
            <TabsTrigger
              value="staff"
              className="data-[state=active]:bg-ui-blue/10 data-[state=active]:text-ui-blue transition-all"
            >
              <Users size={16} className="mr-2" />
              {translation.staff || "Staff"}
            </TabsTrigger>
            <TabsTrigger
              value="groups"
              className="data-[state=active]:bg-ui-blue/10 data-[state=active]:text-ui-blue transition-all"
            >
              <Shield size={16} className="mr-2" />
              {translation.groups || "Groups"}
            </TabsTrigger>
          </TabsList>

          <TabsContent value="appearance" className="mt-4">
            <div className="space-y-6">
              <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
                <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
                <CardHeader className="relative z-10">
                  <CardTitle className="flex items-center gap-2 text-lg">
                    <Layout size={20} className="text-ui-blue" />
                    {translation.layoutSettings || "Layout Settings"}
                  </CardTitle>
                  <CardDescription className="text-gray-400">
                    {translation.layoutSettingsDescription ||
                      "Customize the layout and appearance"}
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4 relative z-10">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label className="text-gray-300">
                        {translation.menuIcon || "Menu Icon"}
                      </Label>
                      <div className="grid grid-cols-2 gap-2">
                        <Button
                          variant="outline"
                          className={`justify-start ${
                            themeSettings.menuIcon === "rocket"
                              ? "bg-ui-blue/10 border-ui-blue/30 text-ui-blue hover:bg-ui-blue/20"
                              : "bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer"
                          }`}
                          onClick={() => updateTheme("menuIcon", "rocket")}
                        >
                          <Rocket size={16} className="mr-2" />
                          {translation.rocket || "Rocket"}
                        </Button>
                        <Button
                          variant="outline"
                          className={`justify-start ${
                            themeSettings.menuIcon === "shield"
                              ? "bg-ui-blue/10 border-ui-blue/30 text-ui-blue hover:bg-ui-blue/20"
                              : "bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer"
                          }`}
                          onClick={() => updateTheme("menuIcon", "shield")}
                        >
                          <Shield size={16} className="mr-2" />
                          {translation.shield || "Shield"}
                        </Button>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-gray-300">
                        {translation.animationSpeed || "Animation Speed"}
                      </Label>
                      <div className="grid grid-cols-2 gap-2">
                        <Button
                          variant="outline"
                          className={`justify-start ${
                            themeSettings.animationSpeed === "fast"
                              ? "bg-ui-blue/10 border-ui-blue/30 text-ui-blue hover:bg-ui-blue/20"
                              : "bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer"
                          }`}
                          onClick={() => updateTheme("animationSpeed", "fast")}
                        >
                          <Zap size={16} className="mr-2" />
                          {translation.fast || "Fast"}
                        </Button>
                        <Button
                          variant="outline"
                          className={`justify-start ${
                            themeSettings.animationSpeed === "smooth"
                              ? "bg-ui-blue/10 border-ui-blue/30 text-ui-blue hover:bg-ui-blue/20"
                              : "bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer"
                          }`}
                          onClick={() =>
                            updateTheme("animationSpeed", "smooth")
                          }
                        >
                          <Wind size={16} className="mr-2" />
                          {translation.smooth || "Smooth"}
                        </Button>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
                <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
                <CardHeader className="relative z-10">
                  <CardTitle className="flex items-center gap-2 text-lg">
                    <SettingsIcon size={20} className="text-ui-blue" />
                    {translation.displaySettings || "Display Settings"}
                  </CardTitle>
                  <CardDescription className="text-gray-400">
                    {translation.displaySettingsDescription ||
                      "Adjust display preferences"}
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4 relative z-10">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label className="text-gray-300">
                        {translation.borderRadius || "Border Radius"}
                      </Label>
                      <Select
                        value={themeSettings.borderRadius}
                        onValueChange={(value) =>
                          updateTheme("borderRadius", value)
                        }
                      >
                        <SelectTrigger className="bg-ui-layer/50 border-ui-border text-white h-11">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent className="bg-ui-panel border-ui-border text-white">
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="0px"
                          >
                            {translation.stNone || "None"}
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="4px"
                          >
                            {translation.stSmall || "Small"}
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="8px"
                          >
                            {translation.stMedium || "Medium"}
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="12px"
                          >
                            Large
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="16px"
                          >
                            Extra Large
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-gray-300">
                        {translation.fontSize || "Font Size"}
                      </Label>
                      <Select
                        value={themeSettings.fontSize}
                        onValueChange={(value) =>
                          updateTheme("fontSize", value)
                        }
                      >
                        <SelectTrigger className="bg-ui-layer/50 border-ui-border text-white h-11">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent className="bg-ui-panel border-ui-border text-white">
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="12px"
                          >
                            {translation.stSmall || "Small"}
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="14px"
                          >
                            {translation.stMedium || "Medium"}
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="16px"
                          >
                            Large
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="18px"
                          >
                            Extra Large
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-gray-300">
                        {translation.fontFamily || "Font Family"}
                      </Label>
                      <Select
                        value={themeSettings.fontFamily}
                        onValueChange={(value) =>
                          updateTheme("fontFamily", value)
                        }
                      >
                        <SelectTrigger className="bg-ui-layer/50 border-ui-border text-white h-11">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent className="bg-ui-panel border-ui-border text-white">
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Inter, sans-serif"
                          >
                            Inter
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Arial, sans-serif"
                          >
                            Arial
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Helvetica, sans-serif"
                          >
                            Helvetica
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Roboto, sans-serif"
                          >
                            Roboto
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Open Sans, sans-serif"
                          >
                            Open Sans
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Lato, sans-serif"
                          >
                            Lato
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Poppins, sans-serif"
                          >
                            Poppins
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Times New Roman, serif"
                          >
                            Times New Roman
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Georgia, serif"
                          >
                            Georgia
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Courier New, monospace"
                          >
                            Courier New
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="Consolas, monospace"
                          >
                            Consolas
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-gray-300">
                        {translation.sidebarPosition || "Sidebar Position"}
                      </Label>
                      <Select
                        value={themeSettings.sidebarPosition || "left"}
                        onValueChange={(value) =>
                          updateTheme("sidebarPosition", value)
                        }
                      >
                        <SelectTrigger className="bg-ui-layer/50 border-ui-border text-white h-11">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent className="bg-ui-panel border-ui-border text-white">
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="left"
                          >
                            {translation.left || "Left"}
                          </SelectItem>
                          <SelectItem
                            className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                            value="right"
                          >
                            {translation.right || "Right"}
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
                <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
                <CardHeader className="relative z-10">
                  <CardTitle className="flex items-center gap-2 text-lg">
                    <Palette size={20} className="text-ui-blue" />
                    {translation.colorSettings || "Color Settings"}
                  </CardTitle>
                  <CardDescription className="text-gray-400">
                    {translation.colorSettingsDescription ||
                      "Adjust global background and text colors"}
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4 relative z-10">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label className="text-gray-300">
                        {translation.backgroundColor || "Background Color"}
                      </Label>
                      <div className="flex items-center gap-2">
                        <Input
                          type="text"
                          value={themeSettings.customBackgroundColor || ""}
                          onChange={(e) =>
                            updateTheme("customBackgroundColor", e.target.value)
                          }
                          className="bg-ui-layer/50 border-ui-border text-white flex-1 h-11"
                        />
                        <div className="relative w-11 h-11 rounded border border-ui-border shadow-sm overflow-hidden flex-shrink-0">
                          <input
                            type="color"
                            value={
                              themeSettings.customBackgroundColor?.startsWith(
                                "#",
                              )
                                ? themeSettings.customBackgroundColor.slice(
                                    0,
                                    7,
                                  )
                                : "#18181b"
                            }
                            onChange={(e) =>
                              updateTheme(
                                "customBackgroundColor",
                                e.target.value,
                              )
                            }
                            className="absolute inset-[-50%] w-[200%] h-[200%] cursor-pointer opacity-0 z-10"
                          />
                          <div
                            className="absolute inset-0 pointer-events-none"
                            style={{
                              backgroundColor:
                                themeSettings.customBackgroundColor ||
                                "#18181b",
                            }}
                          />
                        </div>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-gray-300">
                        {translation.textColor || "Text Color"}
                      </Label>
                      <div className="flex items-center gap-2">
                        <Input
                          type="text"
                          value={themeSettings.textColor || ""}
                          onChange={(e) =>
                            updateTheme("textColor", e.target.value)
                          }
                          className="bg-ui-layer/50 border-ui-border text-white flex-1 h-11"
                        />
                        <div className="relative w-11 h-11 rounded border border-ui-border shadow-sm overflow-hidden flex-shrink-0">
                          <input
                            type="color"
                            value={
                              themeSettings.textColor?.startsWith("#")
                                ? themeSettings.textColor.slice(0, 7)
                                : "#ffffff"
                            }
                            onChange={(e) =>
                              updateTheme("textColor", e.target.value)
                            }
                            className="absolute inset-[-50%] w-[200%] h-[200%] cursor-pointer opacity-0 z-10"
                          />
                          <div
                            className="absolute inset-0 pointer-events-none"
                            style={{
                              backgroundColor:
                                themeSettings.textColor || "#ffffff",
                            }}
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <div className="flex justify-end mt-4">
                <Button
                  variant="outline"
                  className="bg-ui-danger/10 text-ui-danger hover:bg-ui-danger hover:text-white border-ui-danger/20"
                  onClick={() => {
                    setShowResetConfirmation(true);
                  }}
                >
                  {translation.resetToDefault || "Reset to Default"}
                </Button>
              </div>
            </div>
          </TabsContent>

          <TabsContent value="staff" className="mt-4">
            <div className="space-y-6">
              <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
                <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
                <CardHeader className="relative z-10">
                  <div className="flex items-center justify-between">
                    <div>
                      <CardTitle className="flex items-center gap-2 text-lg">
                        <Users size={20} className="text-ui-blue" />
                        {translation.staffManagement || "Staff Management"}
                      </CardTitle>
                      <CardDescription className="text-gray-400">
                        {translation.staffManagementDescription ||
                          "Manage staff members and their permissions"}
                      </CardDescription>
                    </div>
                    <Button
                      className="bg-ui-blue hover:bg-ui-blue/80 text-white h-11"
                      onClick={() => {
                        setShowAddStaff(true);
                        setEditingStaff(null);
                        setNewStaff({
                          name: "",
                          identifier: "",
                          group: "",
                          permissions: [],
                        });

                        setTimeout(() => scrollToForm(staffFormRef), 100);
                      }}
                    >
                      <Plus size={16} className="mr-2" />
                      {translation.addStaff || "Add Staff"}
                    </Button>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4 relative z-10">
                  {staffMembers.length === 0 ? (
                    <div className="text-center py-12 text-gray-400">
                      <div className="w-16 h-16 mx-auto mb-4 bg-ui-layer/50 rounded-full flex items-center justify-center">
                        <Users size={32} className="opacity-50" />
                      </div>
                      <h3 className="text-lg font-semibold mb-2">
                        {translation.noStaffFound || "No staff members found"}
                      </h3>
                      <p className="text-sm mb-4">
                        Add your first staff member to get started
                      </p>
                      <Button
                        className="bg-ui-blue hover:bg-ui-blue/80 text-white "
                        onClick={() => {
                          setShowAddStaff(true);
                          setEditingStaff(null);
                          setNewStaff({
                            name: "",
                            identifier: "",
                            group: "",
                            permissions: [],
                          });
                          setTimeout(() => scrollToForm(staffFormRef), 100);
                        }}
                      >
                        <Plus size={16} className="mr-2" />
                        {translation.addNewStaff || "Add New Staff"}
                      </Button>
                    </div>
                  ) : (
                    <div className="rounded-md border border-ui-border overflow-hidden max-h-96 overflow-y-auto">
                      <div className="overflow-x-auto scrollbar-hide">
                        <table className="w-full text-sm">
                          <thead>
                            <tr className="bg-ui-layer/50">
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.staffID || "ID"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.staffName || "Name"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.staffIdentifier || "Identifier"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.staffGroup || "Group"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.staffPermissions || "Permissions"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.staffStatus || "Status"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.staffActions || "Actions"}
                              </th>
                            </tr>
                          </thead>
                          <tbody>
                            {staffMembers.map((staff) => (
                              <tr
                                key={staff.id}
                                className="border-t border-ui-border hover:bg-ui-layer/50 transition-colors"
                              >
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <div className="w-6 h-6 rounded-full bg-ui-blue/10 flex items-center justify-center">
                                      <span className="text-white text-xs font-bold">
                                        {staff.id}
                                      </span>
                                    </div>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm font-medium">
                                  <div className="flex items-center gap-2">
                                    <div className="w-8 h-8 rounded-full bg-ui-blue/20 flex items-center justify-center">
                                      <User
                                        size={14}
                                        className="text-ui-blue"
                                      />
                                    </div>
                                    <div>
                                      <p className="text-white">{staff.name}</p>
                                      <p className="text-xs text-gray-400">
                                        Added by {staff.addedBy}
                                      </p>
                                    </div>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm text-gray-300 font-mono">
                                  {staff.identifier}
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <Badge
                                    variant="outline"
                                    className="bg-ui-layer/50 border-ui-border text-gray-300"
                                  >
                                    {staff.group}
                                  </Badge>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <Key size={14} className="text-gray-400" />
                                    <span className="text-gray-300 text-xs">
                                      {staff.permissions.length}{" "}
                                      {translation.permissions || "permissions"}
                                    </span>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <div
                                      className={`w-2 h-2 rounded-full ${staff.isActive ? "bg-ui-success" : "bg-gray-500"}`}
                                    />
                                    <Badge
                                      variant={
                                        staff.isActive ? "default" : "secondary"
                                      }
                                      className="text-xs"
                                    >
                                      {staff.isActive
                                        ? translation.active || "Active"
                                        : translation.inactive || "Inactive"}
                                    </Badge>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-1">
                                    <Button
                                      variant="ghost"
                                      size="icon"
                                      className="h-8 w-8 text-gray-400 hover:text-white hover:bg-ui-blue/20"
                                      onClick={() => handleEditStaff(staff)}
                                      title={
                                        translation.editStaff || "Edit Staff"
                                      }
                                    >
                                      <Edit
                                        size={16}
                                        className="text-ui-blue"
                                      />
                                    </Button>
                                    <Button
                                      variant="ghost"
                                      size="icon"
                                      className="h-8 w-8 text-gray-400 hover:text-white hover:bg-ui-danger/20"
                                      onClick={() =>
                                        handleDeleteStaff(staff.id, staff.name)
                                      }
                                      title={
                                        translation.removeStaff ||
                                        "Remove Staff"
                                      }
                                    >
                                      <UserX
                                        size={16}
                                        className="text-ui-danger"
                                      />
                                    </Button>
                                  </div>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}
                </CardContent>
              </Card>

              {showAddStaff && (
                <div ref={staffFormRef}>
                  <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white">
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2">
                        {editingStaff ? (
                          <Edit size={20} />
                        ) : (
                          <UserPlus size={20} />
                        )}
                        {editingStaff
                          ? translation.editStaff || "Edit Staff Member"
                          : translation.addNewStaff || "Add New Staff Member"}
                      </CardTitle>
                      <CardDescription className="text-gray-400">
                        {editingStaff
                          ? "Edit staff details and permissions"
                          : translation.addNewStaffDescription ||
                            "Add a new staff member and assign their permissions"}
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-6">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label className="text-gray-300">
                            {translation.staffName || "Name"}
                          </Label>
                          <Input
                            placeholder={
                              translation.staffNamePlaceholder ||
                              "e.g., John Doe"
                            }
                            value={newStaff.name}
                            onChange={(e) =>
                              setNewStaff((prev) => ({
                                ...prev,
                                name: e.target.value,
                              }))
                            }
                            className="bg-ui-layer/50 border-ui-border text-white h-11"
                          />
                        </div>
                        <div className="space-y-2">
                          <Label className="text-gray-300">
                            {translation.staffIdentifier || "Identifier"}
                          </Label>
                          <Input
                            placeholder={
                              translation.staffIdentifierPlaceholder ||
                              "e.g., steam:110000123456789"
                            }
                            value={newStaff.identifier}
                            onChange={(e) =>
                              setNewStaff((prev) => ({
                                ...prev,
                                identifier: e.target.value,
                              }))
                            }
                            className="bg-ui-layer/50 border-ui-border text-white h-11"
                          />
                        </div>
                      </div>

                      <div className="space-y-2">
                        <Label className="text-gray-300">
                          {translation.assignGroup || "Assign Group"}
                        </Label>
                        <Select
                          value={newStaff.group}
                          onValueChange={(value) =>
                            setNewStaff((prev) => ({ ...prev, group: value }))
                          }
                        >
                          <SelectTrigger className="bg-ui-layer/50 border-ui-border text-white h-11">
                            <SelectValue
                              placeholder={
                                translation.selectGroup || "Select a group"
                              }
                            />
                          </SelectTrigger>
                          <SelectContent className="bg-ui-panel border-ui-border text-white">
                            {groups.map((group) => (
                              <SelectItem
                                className="hover:bg-ui-layer focus:bg-ui-layer cursor-pointer"
                                key={group.id}
                                value={String(group.id)}
                              >
                                {group.name}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <p className="text-xs text-gray-400 mt-1">
                          {translation.groupPermissionsNotice ||
                            "Staff member will inherit permissions from their assigned group. You can add specific permissions below."}
                        </p>
                      </div>

                      <div className="space-y-3">
                        <div className="flex items-center justify-between">
                          <Label className="text-gray-300">
                            {translation.specificPermissions ||
                              "Specific Permissions (Optional)"}
                          </Label>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-xs text-ui-blue hover:text-ui-blue/80 hover:bg-transparent h-auto p-0"
                            onClick={handleSelectAllStaffPermissions}
                          >
                            {newStaff.permissions.length ===
                            availablePermissions.length
                              ? "Deselect All"
                              : "Select All"}
                          </Button>
                        </div>
                        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2 max-h-48 overflow-y-auto p-2 bg-ui-layer/50 border border-ui-border/50 rounded-lg">
                          {availablePermissions.map((permission) => (
                            <Button
                              key={permission.id}
                              variant="outline"
                              size="sm"
                              className={`justify-start text-xs h-auto py-2 ${
                                newStaff.permissions.includes(permission.id)
                                  ? "bg-ui-blue border-ui-blue text-white hover:bg-ui-blue/80"
                                  : "bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer"
                              }`}
                              onClick={() =>
                                handleStaffPermissionToggle(permission.id)
                              }
                            >
                              <Key size={14} className="mr-1" />
                              {permission.name}
                            </Button>
                          ))}
                        </div>
                      </div>

                      <div className="flex gap-3 pt-4">
                        <Button
                          className="bg-ui-blue hover:bg-ui-blue/80 text-white flex-1 h-11 "
                          onClick={
                            editingStaff ? handleUpdateStaff : handleAddStaff
                          }
                          disabled={
                            !newStaff.name ||
                            !newStaff.identifier ||
                            !newStaff.group
                          }
                        >
                          <Save size={16} className="mr-2" />
                          {editingStaff
                            ? translation.saveChanges || "Save Changes"
                            : translation.saveStaff || "Save Staff Member"}
                        </Button>
                        <Button
                          variant="outline"
                          className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white h-11"
                          onClick={() => {
                            setShowAddStaff(false);
                            setEditingStaff(null);
                            setNewStaff({
                              name: "",
                              identifier: "",
                              group: "",
                              permissions: [],
                            });
                          }}
                        >
                          {translation.cancel || "Cancel"}
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                </div>
              )}
            </div>
          </TabsContent>

          <TabsContent value="groups" className="mt-4">
            <div className="space-y-6">
              <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
                <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
                <CardHeader className="relative z-10">
                  <div className="flex items-center justify-between">
                    <div>
                      <CardTitle className="flex items-center gap-2 text-lg">
                        <Shield size={20} className="text-ui-blue" />
                        {translation.groupManagement || "Group Management"}
                      </CardTitle>
                      <CardDescription className="text-gray-400">
                        {translation.groupManagementDescription ||
                          "Create and manage permission groups"}
                      </CardDescription>
                    </div>
                    <Button
                      className="bg-ui-blue hover:bg-ui-blue/80 text-white h-11"
                      onClick={() => {
                        setShowAddGroup(true);
                        setEditingGroup(null);
                        setNewGroup({
                          name: "",
                          color: "#3b82f6",
                          permissions: [],
                          description: "",
                        });

                        setTimeout(() => scrollToForm(groupFormRef), 100);
                      }}
                    >
                      <Plus size={16} className="mr-2" />
                      {translation.addGroup || "Add Group"}
                    </Button>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4 relative z-10">
                  {groups.length === 0 ? (
                    <div className="text-center py-12 text-gray-400">
                      <div className="w-16 h-16 mx-auto mb-4 bg-ui-layer/50 rounded-full flex items-center justify-center">
                        <Shield size={32} className="opacity-50" />
                      </div>
                      <h3 className="text-lg font-semibold mb-2">
                        {translation.noGroupsFound || "No groups found"}
                      </h3>
                      <p className="text-sm mb-4">
                        Create your first permission group to get started
                      </p>
                      <Button
                        className="bg-ui-blue hover:bg-ui-blue/80 text-white "
                        onClick={() => {
                          setShowAddGroup(true);
                          setEditingGroup(null);
                          setNewGroup({
                            name: "",
                            color: "#3b82f6",
                            permissions: [],
                            description: "",
                          });

                          setTimeout(() => scrollToForm(groupFormRef), 100);
                        }}
                      >
                        <Plus size={16} className="mr-2" />
                        {translation.addNewGroup || "Add New Group"}
                      </Button>
                    </div>
                  ) : (
                    <div className="rounded-md border border-ui-border overflow-hidden max-h-96 overflow-y-auto">
                      <div className="overflow-x-auto scrollbar-hide">
                        <table className="w-full text-sm">
                          <thead>
                            <tr className="bg-ui-layer/50">
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.groupID || "ID"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.groupName || "Group"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.groupColor || "Color"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.groupPermissions || "Permissions"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.groupActions || "Actions"}
                              </th>
                            </tr>
                          </thead>
                          <tbody>
                            {groups.map((group) => (
                              <tr
                                key={group.id}
                                className="border-t border-ui-border hover:bg-ui-layer/50 transition-colors"
                              >
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <div className="w-6 h-6 rounded-full bg-ui-blue/10 flex items-center justify-center">
                                      <span className="text-white text-xs font-bold">
                                        {group.id}
                                      </span>
                                    </div>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm font-medium">
                                  <div className="flex items-center gap-2">
                                    <Shield
                                      size={14}
                                      className="text-ui-blue"
                                    />
                                    <span className="text-white">
                                      {group.name}
                                    </span>
                                    {group.isDefault && (
                                      <Badge
                                        variant="default"
                                        className="text-xs"
                                      >
                                        Default
                                      </Badge>
                                    )}
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <div
                                      className="w-4 h-4 rounded-full border border-ui-border"
                                      style={{ backgroundColor: group.color }}
                                    />
                                    <span className="text-gray-300 text-xs">
                                      {group.color}
                                    </span>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <Key size={14} className="text-gray-400" />
                                    <span className="text-gray-300 text-xs">
                                      {group.permissions.length}{" "}
                                      {translation.permissions || "permissions"}
                                    </span>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-1">
                                    <Button
                                      variant="ghost"
                                      size="icon"
                                      className="h-8 w-8 text-gray-400 hover:text-white hover:bg-ui-blue/20"
                                      onClick={() => handleEditGroup(group)}
                                      title={
                                        translation.editGroup || "Edit Group"
                                      }
                                    >
                                      <Edit
                                        size={16}
                                        className="text-ui-blue"
                                      />
                                    </Button>
                                    <Button
                                      variant="ghost"
                                      size="icon"
                                      className="h-8 w-8 text-gray-400 hover:text-white hover:bg-ui-danger/20"
                                      onClick={() =>
                                        handleDeleteGroup(group.id, group.name)
                                      }
                                      title={
                                        translation.deleteGroup ||
                                        "Delete Group"
                                      }
                                      disabled={group.isDefault}
                                    >
                                      <X size={16} className="text-ui-danger" />
                                    </Button>
                                  </div>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}
                </CardContent>
              </Card>

              {showAddGroup && (
                <div ref={groupFormRef}>
                  <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white">
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2">
                        {editingGroup ? <Edit size={20} /> : <Plus size={20} />}
                        {editingGroup
                          ? translation.editGroup || "Edit Group"
                          : translation.addNewGroup || "Add New Group"}
                      </CardTitle>
                      <CardDescription className="text-gray-400">
                        {editingGroup
                          ? "Edit group details and permissions"
                          : translation.addNewGroupDescription ||
                            "Create a new permission group"}
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-6">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label className="text-gray-300">
                            {translation.groupName || "Group Name"}
                          </Label>
                          <Input
                            placeholder={
                              translation.groupNamePlaceholder ||
                              "Enter group name"
                            }
                            value={newGroup.name}
                            onChange={(e) =>
                              setNewGroup((prev) => ({
                                ...prev,
                                name: e.target.value,
                              }))
                            }
                            className="bg-ui-layer/50 border-ui-border text-white h-11"
                          />
                        </div>
                        <div className="space-y-2">
                          <Label className="text-gray-300">
                            {translation.groupColor || "Group Color"}
                          </Label>
                          <div className="flex items-center gap-2">
                            <Input
                              type="text"
                              placeholder={
                                translation.groupColorPlaceholder ||
                                "Select group color"
                              }
                              value={newGroup.color}
                              onChange={(e) =>
                                setNewGroup((prev) => ({
                                  ...prev,
                                  color: e.target.value,
                                }))
                              }
                              className="bg-ui-layer/50 border-ui-border text-white flex-1 h-11"
                            />
                            <div
                              className="w-11 h-11 rounded border border-ui-border cursor-pointer shadow-sm"
                              style={{ backgroundColor: newGroup.color }}
                              onClick={() => {
                                const input = document.createElement("input");
                                input.type = "color";
                                input.value = newGroup.color;
                                input.onchange = (e) => {
                                  const target = e.target as HTMLInputElement;
                                  setNewGroup((prev) => ({
                                    ...prev,
                                    color: target.value,
                                  }));
                                };
                                input.click();
                              }}
                            />
                          </div>
                        </div>
                      </div>

                      <div className="space-y-2">
                        <Label className="text-gray-300">
                          {translation.groupDescription || "Description"}
                        </Label>
                        <Textarea
                          placeholder={
                            translation.groupDescriptionPlaceholder ||
                            "Enter group description"
                          }
                          value={newGroup.description}
                          onChange={(e) =>
                            setNewGroup((prev) => ({
                              ...prev,
                              description: e.target.value,
                            }))
                          }
                          className="bg-ui-layer/50 border-ui-border text-white"
                          rows={3}
                        />
                      </div>

                      <div className="space-y-3">
                        <div className="flex items-center justify-between">
                          <Label className="text-gray-300">
                            {translation.groupPermissions ||
                              "Group Permissions"}
                          </Label>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-xs text-ui-blue hover:text-ui-blue/80 hover:bg-transparent h-auto p-0"
                            onClick={handleSelectAllGroupPermissions}
                          >
                            {newGroup.permissions.length ===
                            availablePermissions.length
                              ? "Deselect All"
                              : "Select All"}
                          </Button>
                        </div>
                        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2 max-h-48 overflow-y-auto p-2 bg-ui-layer/50 border border-ui-border/50 rounded-lg">
                          {availablePermissions.map((permission) => (
                            <Button
                              key={permission.id}
                              variant="outline"
                              size="sm"
                              className={`justify-start text-xs h-auto py-2 ${
                                newGroup.permissions.includes(permission.id)
                                  ? "bg-ui-blue border-ui-blue text-white hover:bg-ui-blue/80"
                                  : "bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer"
                              }`}
                              onClick={() =>
                                handleGroupPermissionToggle(permission.id)
                              }
                            >
                              <Key size={14} className="mr-1" />
                              {permission.name}
                            </Button>
                          ))}
                        </div>
                      </div>

                      <div className="flex gap-3 pt-4">
                        <Button
                          className="bg-ui-blue hover:bg-ui-blue/80 text-white flex-1 h-11 "
                          onClick={
                            editingGroup ? handleUpdateGroup : handleAddGroup
                          }
                          disabled={!newGroup.name}
                        >
                          <Save size={16} className="mr-2" />
                          {editingGroup
                            ? translation.saveChanges || "Save Changes"
                            : translation.saveGroup || "Save Group"}
                        </Button>
                        <Button
                          variant="outline"
                          className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white h-11"
                          onClick={() => {
                            setShowAddGroup(false);
                            setEditingGroup(null);
                            setNewGroup({
                              name: "",
                              color: "#3b82f6",
                              permissions: [],
                              description: "",
                            });
                          }}
                        >
                          {translation.cancel || "Cancel"}
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                </div>
              )}
            </div>
          </TabsContent>

          <TabsContent value="webhooks" className="mt-4">
            <div className="space-y-6">
              <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
                <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
                <CardHeader className="relative z-10">
                  <div className="flex items-center justify-between">
                    <div>
                      <CardTitle className="flex items-center gap-2 text-lg">
                        <Webhook size={20} className="text-ui-blue" />
                        {translation.webhookConfiguration ||
                          "Webhook Configuration"}
                      </CardTitle>
                      <CardDescription className="text-gray-400">
                        {translation.webhookConfigurationDescription ||
                          "Configure webhooks to send server events to external services"}
                      </CardDescription>
                    </div>
                    <Button
                      className="bg-ui-blue hover:bg-ui-blue/80 text-white h-11"
                      onClick={() => {
                        setShowAddWebhook(true);
                        setEditingWebhook(null);
                        setNewWebhook({
                          name: "",
                          url: "",
                          events: [],
                          description: "",
                        });

                        setTimeout(() => scrollToForm(webhookFormRef), 100);
                      }}
                    >
                      <Plus size={16} className="mr-2" />
                      {translation.addWebhook || "Add Webhook"}
                    </Button>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4 relative z-10">
                  {webhooks.length === 0 ? (
                    <div className="text-center py-12 text-gray-400">
                      <div className="w-16 h-16 mx-auto mb-4 bg-ui-layer/50 rounded-full flex items-center justify-center">
                        <Webhook size={32} className="opacity-50" />
                      </div>
                      <h3 className="text-lg font-semibold mb-2">
                        {translation.noWebhooks || "No webhooks configured"}
                      </h3>
                      <p className="text-sm mb-4">
                        {translation.addYourFirstWebhook ||
                          "Add your first webhook to get started"}
                      </p>
                      <Button
                        className="bg-ui-blue hover:bg-ui-blue/80 text-white "
                        onClick={() => {
                          setShowAddWebhook(true);
                          setEditingWebhook(null);
                          setNewWebhook({
                            name: "",
                            url: "",
                            events: [],
                            description: "",
                          });

                          setTimeout(() => scrollToForm(webhookFormRef), 100);
                        }}
                      >
                        <Plus size={16} className="mr-2" />
                        {translation.createFirstWebhook ||
                          "Create First Webhook"}
                      </Button>
                    </div>
                  ) : (
                    <div className="rounded-md border border-ui-border overflow-hidden max-h-96 overflow-y-auto">
                      <div className="overflow-x-auto scrollbar-hide">
                        <table className="w-full text-sm">
                          <thead>
                            <tr className="bg-ui-layer/50">
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.webhookID || "ID"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.webhookName || "Name"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.webhookUrl || "URL"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.webhookEvents || "Events"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.webhookStatus || "Status"}
                              </th>
                              <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                                {translation.webhookActions || "Actions"}
                              </th>
                            </tr>
                          </thead>
                          <tbody>
                            {webhooks.map((webhook) => (
                              <tr
                                key={webhook.id}
                                className="border-t border-ui-border hover:bg-ui-layer/50 transition-colors"
                              >
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <div className="w-6 h-6 rounded-full bg-ui-blue/10 flex items-center justify-center">
                                      <span className="text-white text-xs font-bold">
                                        {webhook.id}
                                      </span>
                                    </div>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm font-medium">
                                  <div className="flex items-center gap-2">
                                    <Webhook
                                      size={14}
                                      className="text-ui-blue"
                                    />
                                    <span className="text-white">
                                      {webhook.name}
                                    </span>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <Link size={14} className="text-gray-400" />
                                    <span
                                      className="text-gray-300 text-xs font-mono max-w-32 truncate"
                                      title={webhook.url}
                                    >
                                      {webhook.url}
                                    </span>
                                    <Button
                                      variant="ghost"
                                      size="icon"
                                      className="h-6 w-6 text-gray-400 hover:text-white hover:bg-ui-layer"
                                      onClick={() =>
                                        handleCopyWebhook(webhook.url)
                                      }
                                      title={translation.copyUrl || "Copy URL"}
                                    >
                                      {copiedWebhook === webhook.url ? (
                                        <Check
                                          size={12}
                                          className="text-ui-success"
                                        />
                                      ) : (
                                        <Copy size={12} />
                                      )}
                                    </Button>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <Zap size={14} className="text-gray-400" />
                                    <span className="text-gray-300 text-xs">
                                      {webhook.events.length}{" "}
                                      {translation.events || "events"}
                                    </span>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-2">
                                    <div
                                      className={`w-2 h-2 rounded-full ${webhook.isActive ? "bg-ui-success" : "bg-gray-500"}`}
                                    />
                                    <Badge
                                      variant={
                                        webhook.isActive
                                          ? "default"
                                          : "secondary"
                                      }
                                      className="text-xs"
                                    >
                                      {webhook.isActive
                                        ? translation.active || "Active"
                                        : translation.inactive || "Inactive"}
                                    </Badge>
                                  </div>
                                </td>
                                <td className="px-4 py-3 text-sm">
                                  <div className="flex items-center gap-1">
                                    <Button
                                      variant="ghost"
                                      size="icon"
                                      className="h-8 w-8 text-gray-400 hover:text-white hover:bg-ui-blue/20"
                                      onClick={() => handleEditWebhook(webhook)}
                                      title={
                                        translation.editWebhook ||
                                        "Edit Webhook"
                                      }
                                    >
                                      <Edit
                                        size={16}
                                        className="text-ui-blue"
                                      />
                                    </Button>
                                    <Button
                                      variant="ghost"
                                      size="icon"
                                      className="h-8 w-8 text-gray-400 hover:text-white hover:bg-ui-layer"
                                      onClick={() =>
                                        handleWebhookToggle(webhook.id)
                                      }
                                      title={
                                        webhook.isActive
                                          ? translation.deactivate ||
                                            "Deactivate"
                                          : translation.activate || "Activate"
                                      }
                                    >
                                      {webhook.isActive ? (
                                        <Pause size={16} />
                                      ) : (
                                        <Play size={16} />
                                      )}
                                    </Button>
                                    <Button
                                      variant="ghost"
                                      size="icon"
                                      className="h-8 w-8 text-gray-400 hover:text-white hover:bg-ui-danger/20"
                                      onClick={() =>
                                        handleWebhookDelete(
                                          webhook.id,
                                          webhook.name,
                                        )
                                      }
                                      title={translation.delete || "Delete"}
                                    >
                                      <Trash2
                                        size={16}
                                        className="text-ui-danger"
                                      />
                                    </Button>
                                  </div>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}
                </CardContent>
              </Card>

              {showAddWebhook && (
                <div ref={webhookFormRef}>
                  <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white">
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2">
                        {editingWebhook ? (
                          <Edit size={20} />
                        ) : (
                          <Plus size={20} />
                        )}
                        {editingWebhook
                          ? translation.editWebhook || "Edit Webhook"
                          : translation.addNewWebhook || "Add New Webhook"}
                      </CardTitle>
                      <CardDescription className="text-gray-400">
                        {editingWebhook
                          ? "Edit webhook configuration"
                          : translation.addNewWebhookDescription ||
                            "Configure a new webhook to receive server events"}
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-6">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label className="text-gray-300">
                            {translation.webhookName || "Webhook Name"}
                          </Label>
                          <Input
                            placeholder={
                              translation.webhookNamePlaceholder ||
                              "e.g., Discord Logs"
                            }
                            value={newWebhook.name}
                            onChange={(e) =>
                              setNewWebhook((prev) => ({
                                ...prev,
                                name: e.target.value,
                              }))
                            }
                            className="bg-ui-layer/50 border-ui-border text-white h-11"
                          />
                        </div>
                        <div className="space-y-2">
                          <Label className="text-gray-300">
                            {translation.webhookUrl || "Webhook URL"}
                          </Label>
                          <Input
                            placeholder={
                              translation.webhookUrlPlaceholder ||
                              "https://discord.com/api/webhooks/..."
                            }
                            value={newWebhook.url}
                            onChange={(e) =>
                              setNewWebhook((prev) => ({
                                ...prev,
                                url: e.target.value,
                              }))
                            }
                            className="bg-ui-layer/50 border-ui-border text-white h-11"
                          />
                        </div>
                      </div>

                      <div className="space-y-2">
                        <Label className="text-gray-300">
                          {translation.webhookDescription ||
                            "Description (Optional)"}
                        </Label>
                        <Textarea
                          placeholder={
                            translation.webhookDescriptionPlaceholder ||
                            "Brief description of this webhook's purpose"
                          }
                          value={newWebhook.description}
                          onChange={(e) =>
                            setNewWebhook((prev) => ({
                              ...prev,
                              description: e.target.value,
                            }))
                          }
                          className="bg-ui-layer/50 border-ui-border text-white"
                          rows={3}
                        />
                      </div>

                      <div className="space-y-3">
                        <Label className="text-gray-300">
                          {translation.selectEvents || "Select Events"}
                        </Label>
                        <div className=" scroll-mt-16 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2 max-h-48 overflow-y-auto p-2 bg-ui-layer/50 border border-ui-border/50 rounded-lg">
                          {webhookEvents.map((event) => (
                            <Button
                              key={event.value}
                              variant="outline"
                              size="sm"
                              className={`justify-start text-xs h-auto py-2 ${
                                newWebhook.events.includes(event.value)
                                  ? "bg-ui-blue border-ui-blue text-white hover:bg-ui-blue/80"
                                  : "bg-ui-layer/50 border-ui-border text-gray-300 hover:bg-ui-layer"
                              }`}
                              onClick={() =>
                                handleNewWebhookEventToggle(event.value)
                              }
                            >
                              {event.icon}
                              <span className="ml-1">{event.label}</span>
                            </Button>
                          ))}
                        </div>
                      </div>

                      <div className="flex gap-3 pt-4">
                        <Button
                          className="bg-ui-blue hover:bg-ui-blue/80 text-white flex-1 h-11 "
                          onClick={() => {
                            const webhookPayload = editingWebhook
                              ? {
                                  ...editingWebhook,
                                  name: newWebhook.name,
                                  url: newWebhook.url,
                                  events: newWebhook.events,
                                  description: newWebhook.description,
                                }
                              : {
                                  name: newWebhook.name,
                                  url: newWebhook.url,
                                  events: newWebhook.events,
                                  description: newWebhook.description,
                                };
                            sendNui("saveWebhook", { webhook: webhookPayload });
                            setShowAddWebhook(false);
                            setEditingWebhook(null);
                            setNewWebhook({
                              name: "",
                              url: "",
                              events: [],
                              description: "",
                            });
                          }}
                          disabled={!newWebhook.name || !newWebhook.url}
                        >
                          <Save size={16} className="mr-2" />
                          {editingWebhook
                            ? translation.saveChanges || "Save Changes"
                            : translation.saveWebhook || "Save Webhook"}
                        </Button>
                        <Button
                          variant="outline"
                          className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white h-11"
                          onClick={() => {
                            setShowAddWebhook(false);
                            setEditingWebhook(null);
                            setNewWebhook({
                              name: "",
                              url: "",
                              events: [],
                              description: "",
                            });
                          }}
                        >
                          {translation.cancel || "Cancel"}
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                </div>
              )}
            </div>
          </TabsContent>
        </Tabs>
      </div>

      <AlertDialog
        open={showResetConfirmation}
        onOpenChange={setShowResetConfirmation}
      >
        <AlertDialogContent className="bg-ui-layer border-ui-border text-white">
          <AlertDialogHeader>
            <AlertDialogTitle>
              {translation.confirmResetTitle || "Reset to Default?"}
            </AlertDialogTitle>
            <AlertDialogDescription className="text-gray-400">
              {translation.confirmResetDescription ||
                "Are you sure you want to reset all appearance settings to their defaults? This action cannot be undone."}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="bg-ui-layer/50 border-ui-border text-white hover:bg-ui-layer hover:text-white">
              {translation.cancel || "Cancel"}
            </AlertDialogCancel>
            <AlertDialogAction
              className="bg-ui-danger text-white hover:bg-ui-danger/80"
              onClick={() => {
                resetThemeSettings();
                setShowResetConfirmation(false);
              }}
            >
              {translation.confirmReset || "Reset Settings"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <AlertDialog
        open={!!deleteConfirmation}
        onOpenChange={(open) => !open && setDeleteConfirmation(null)}
      >
        <AlertDialogContent className="bg-ui-layer border-ui-border text-white">
          <AlertDialogHeader>
            <AlertDialogTitle>Are you sure?</AlertDialogTitle>
            <AlertDialogDescription className="text-gray-400">
              This action cannot be undone. This will permanently delete{" "}
              {deleteConfirmation?.type === "staff"
                ? "the staff member"
                : deleteConfirmation?.type === "group"
                  ? "the group"
                  : "the webhook"}
              <span className="font-semibold text-white ml-1">
                {deleteConfirmation?.name}
              </span>
              .
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="bg-ui-layer/50 border-ui-border text-white hover:bg-ui-layer hover:text-white">
              Cancel
            </AlertDialogCancel>
            <AlertDialogAction
              className="bg-ui-danger text-white hover:bg-ui-danger/80"
              onClick={() => {
                if (deleteConfirmation?.type === "group") {
                  sendNui("deleteGroup", { groupId: deleteConfirmation.id });
                } else if (deleteConfirmation?.type === "staff") {
                  sendNui("deleteStaff", { staffId: deleteConfirmation.id });
                } else if (deleteConfirmation?.type === "webhook") {
                  sendNui("deleteWebhook", {
                    webhookId: Number(deleteConfirmation.id),
                  });
                }
                setDeleteConfirmation(null);
              }}
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
