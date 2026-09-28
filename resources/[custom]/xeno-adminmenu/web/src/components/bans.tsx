import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import {
  Ban,
  Search,
  Filter,
  Clock,
  User,
  AlertTriangle,
  Unlock,
  Trash,
  Plus,
  Info,
  Edit,
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "./ui/dialog";
import { useTranslation } from "../lib/translation";
import { SeeMore } from "./ui/see-more";
import { sendNui } from "../lib/sendNui";

type Ban = {
  banId: number;
  playerName: string;
  authorName: string;
  ids: string[];
  reason: string;
  regDate: string;
  expDate: string;
};

export default function Bans() {
  const [searchQuery, setSearchQuery] = useState("");
  const [filterStatus, setFilterStatus] = useState<string | null>(null);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [idsModalOpen, setIdsModalOpen] = useState(false);
  const [unbanModalOpen, setUnbanModalOpen] = useState(false);
  const [selectedBan, setSelectedBan] = useState<Ban | null>(null);
  const [selectedBanIds, setSelectedBanIds] = useState<string[]>([]);
  const [editReason, setEditReason] = useState("");
  const [editDuration, setEditDuration] = useState("");
  const translation = useTranslation();
  const enableMockData = false;
  const [bans, setBans] = useState<Ban[]>(
    enableMockData
      ? [
          {
            banId: 1,
            playerName: "John Doe",
            authorName: "author1",
            ids: ["steam:000"],
            reason: "Cheatifghgfhgfhgfng",
            regDate: "15/03/2024 14:30:00",
            expDate: "22/03/2024 14:30:00",
          },
          {
            banId: 2,
            playerName: "Jane Smith",
            authorName: "author2",
            ids: ["steam:000"],
            reason: "Toxic behavior",
            regDate: "14/03/2024 10:15:00",
            expDate: "13/04/2024 10:15:00",
          },
          {
            banId: 3,
            playerName: "Bob Johnson",
            authorName: "author1",
            ids: ["steam:000"],
            reason: "Exploiting",
            regDate: "10/03/2024 18:45:00",
            expDate: "Permanent",
          },
        ]
      : [],
  );

  const filteredBans = bans.filter((ban) => {
    const matchesSearch =
      ban.playerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      ban.banId.toString().includes(searchQuery) ||
      ban.reason.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesFilter = filterStatus ? ban.expDate === filterStatus : true;

    return matchesSearch && matchesFilter;
  });

  useEffect(() => {
    sendNui("fetchBans", { page: 1, limit: 100, search: "", filter: "Active" });

    const messageListener = (event: MessageEvent) => {
      if (event.data.action === "loadBans") {
        const formattedBans = (event.data.bans || []).map((b: any) => ({
          banId: b.ban_id,
          playerName: b.player_name,
          authorName: b.banned_by_name,
          ids: [
            b.license,
            b.license2,
            b.steam,
            b.discord,
            b.fivem,
            b.xbl,
            b.live,
            b.ip,
          ].filter(Boolean),
          reason: b.reason,
          regDate: new Date(b.created_at).toLocaleString(),
          expDate: b.is_permanent
            ? "Permanent"
            : new Date(Number(b.expire)).toLocaleString(),
        }));
        setBans(formattedBans);
      }
    };
    window.addEventListener("message", messageListener);
    return () => window.removeEventListener("message", messageListener);
  }, []);

  const handleEditBan = () => {
    if (!selectedBan) return;
    const newData: any = {};
    if (editReason.trim() !== "") newData.reason = editReason;
    if (editDuration !== "") newData.durationHours = Number(editDuration);

    sendNui("editBan", { banId: selectedBan.banId, newData });
    setEditModalOpen(false);
    setSelectedBan(null);
    setTimeout(
      () =>
        sendNui("fetchBans", {
          page: 1,
          limit: 100,
          search: searchQuery,
          filter: filterStatus || "Active",
        }),
      500,
    );
  };

  const handleUnban = () => {
    if (!selectedBan) return;
    sendNui("unbanPlayer", { banId: selectedBan.banId });
    setUnbanModalOpen(false);
    setSelectedBan(null);
    setTimeout(
      () =>
        sendNui("fetchBans", {
          page: 1,
          limit: 100,
          search: searchQuery,
          filter: filterStatus || "Active",
        }),
      500,
    );
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0 }}
      className="space-y-4"
    >
      <div>
        <h1 className="text-2xl font-bold text-white flex items-center gap-2">
          <span className="w-8 h-8 rounded-lg bg-ui-danger/10 flex items-center justify-center ">
            <Ban size={16} className="text-ui-danger" />
          </span>
          {translation.bansHeader || "Bans Management"}
        </h1>
        <p className="text-gray-400 ml-11">
          {translation.bansDescription || "View and manage player bans"}
        </p>
      </div>

      <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
        <div className="absolute right-0 top-0 w-64 h-64 bg-ui-danger/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
        <CardHeader className="relative z-10">
          <CardTitle className="flex items-center gap-2 text-lg">
            <Ban className="h-5 w-5 text-ui-danger" />
            {translation.bansList || "Bans List"}
          </CardTitle>
          <CardDescription className="text-gray-400">
            {translation.bansListDescription ||
              "Currently active and expired bans"}
          </CardDescription>
        </CardHeader>
        <CardContent className="py-3 relative z-10 flex flex-col h-[575px]">
          <div className="flex flex-col md:flex-row gap-4 mb-6 shrink-0">
            <div className="relative flex-1">
              <Search
                className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                size={16}
              />
              <Input
                placeholder={
                  translation.searchBans || "Search by name, ID or reason..."
                }
                className="pl-9 bg-ui-layer/50 border-ui-border text-white h-11"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="outline"
                  className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white flex items-center gap-2 h-11"
                >
                  <Filter size={16} className="text-ui-textMuted" />
                  {translation.filterBans || "Filter"}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent className="bg-ui-layer border-ui-border text-white cursor-pointer">
                <DropdownMenuItem
                  className="hover:bg-ui-layer focus:bg-ui-layer"
                  onClick={() => setFilterStatus(null)}
                >
                  {translation.filterAllBans || "All Bans"}
                </DropdownMenuItem>
                <DropdownMenuItem
                  className="hover:bg-ui-layer focus:bg-ui-layer"
                  onClick={() => setFilterStatus("Permanent")}
                >
                  {translation.filterPermanentBans || "Permanent"}
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          <div className="rounded-md border border-ui-border overflow-hidden flex-1 flex flex-col">
            <div className="overflow-x-auto overflow-y-auto flex-1 custom-scrollbar relative min-h-0">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-ui-layer/50">
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-300">
                      {translation.bannedPlayer || "Player"}
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-300">
                      {translation.banAuthor || "Author"}
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-300">
                      {translation.banRegDate || "Registration Date"}
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-300">
                      {translation.banExpDate || "Experience Date"}
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-300">
                      {translation.banReason || "Reason"}
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-300">
                      {translation.banActions || "Actions"}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {filteredBans.map((ban) => (
                    <tr className="border-t border-ui-border hover:bg-ui-layer/50 transition-colors">
                      <td className="px-4 py-3 text-xs text-gray-300">
                        <div className="flex items-center gap-1.5">
                          <User size={14} className="text-gray-400" />
                          {ban.playerName}
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-300">
                        {ban.authorName}
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-300">
                        <div className="flex items-center gap-1.5">
                          {ban.regDate}
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-300">
                        {ban.expDate}
                      </td>
                      <td className="px-4 py-3 text-xs text-gray-300">
                        <div className="flex items-center gap-1.5">
                          <SeeMore text={ban.reason} showHeader={true} />
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs">
                        <div className="flex items-center gap-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 text-xs text-gray-400 hover:text-ui-success hover:bg-ui-success/10"
                            onClick={() => {
                              setSelectedBan(ban);
                              setUnbanModalOpen(true);
                            }}
                          >
                            <Unlock size={14} className="mr-1" />
                            {translation.unban || "Unban"}
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 text-xs text-gray-400 hover:text-ui-blue hover:bg-ui-blue/10"
                            onClick={() => {
                              setSelectedBan(ban);
                              setEditReason(ban.reason);
                              setEditDuration("");
                              setEditModalOpen(true);
                            }}
                          >
                            <Edit size={14} className="mr-1" />
                            {translation.editBan || "Edit"}
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 text-xs text-gray-400 hover:text-ui-blue hover:bg-ui-blue/10"
                            onClick={() => {
                              setSelectedBanIds(ban.ids);
                              setIdsModalOpen(true);
                            }}
                          >
                            <Info size={14} className="mr-1" />
                            {translation.seeIdentifiers || "Ids"}
                          </Button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {filteredBans.length === 0 && (
                <div className="absolute inset-0 flex flex-col items-center justify-center text-gray-400 pointer-events-none pb-12">
                  <Ban size={32} className="mb-2 text-gray-500" />
                  <p>{translation.noBansFound || "No bans found"}</p>
                </div>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      <Dialog open={editModalOpen} onOpenChange={setEditModalOpen}>
        <DialogContent className="bg-ui-layer border-ui-border text-white">
          <DialogHeader>
            <DialogTitle>{translation.editBan || "Edit Ban"}</DialogTitle>
            <DialogDescription className="text-gray-400">
              {translation.editBanDesc ||
                "Update the ban reason or change the duration. Set duration to 0 for a permanent ban."}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <label className="text-sm text-gray-300">
                {translation.reason || "Reason"}
              </label>
              <Input
                value={editReason}
                onChange={(e) => setEditReason(e.target.value)}
                className="bg-ui-layer border-ui-border text-white"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm text-gray-300">
                {translation.durationHours || "Duration (Hours)"}
              </label>
              <Input
                type="number"
                value={editDuration}
                onChange={(e) => setEditDuration(e.target.value)}
                placeholder={
                  translation.keepCurrent || "Leave empty to keep current"
                }
                className="bg-ui-layer border-ui-border text-white"
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setEditModalOpen(false)}
              className="bg-ui-layer border-ui-border hover:bg-ui-layer/80"
            >
              {translation.cancel || "Cancel"}
            </Button>
            <Button
              onClick={handleEditBan}
              className="bg-ui-blue hover:bg-ui-blue/90 text-white"
            >
              {translation.saveChanges || "Save Changes"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={idsModalOpen} onOpenChange={setIdsModalOpen}>
        <DialogContent className="bg-ui-layer border-ui-border text-white">
          <DialogHeader>
            <DialogTitle>
              {translation.identifiers || "Player Identifiers"}
            </DialogTitle>
            <DialogDescription className="text-gray-400">
              {translation.identifiersDesc ||
                "All registered identifiers for this player."}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2 py-4">
            {selectedBanIds.map((id, index) => (
              <div
                key={index}
                className="p-2 bg-ui-layer/50 border border-ui-border rounded text-sm text-gray-300"
              >
                {id}
              </div>
            ))}
            {selectedBanIds.length === 0 && (
              <div className="text-sm text-gray-400 text-center py-2">
                {translation.noIdsFound || "No identifiers found."}
              </div>
            )}
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIdsModalOpen(false)}
              className="bg-ui-layer border-ui-border hover:bg-ui-layer/80"
            >
              {translation.close || "Close"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={unbanModalOpen} onOpenChange={setUnbanModalOpen}>
        <DialogContent className="bg-ui-layer border-ui-border text-white">
          <DialogHeader>
            <DialogTitle>
              {translation.confirmUnban || "Confirm Unban"}
            </DialogTitle>
            <DialogDescription className="text-gray-400">
              {translation.confirmUnbanDesc ||
                "Are you sure you want to unban this player?"}
            </DialogDescription>
          </DialogHeader>
          <div className="py-4 text-center">
            <p className="text-gray-300 font-medium">
              {selectedBan?.playerName}{" "}
              <span className="text-gray-500 font-normal">
                ({selectedBan?.banId})
              </span>
            </p>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setUnbanModalOpen(false)}
              className="bg-ui-layer border-ui-border hover:bg-ui-layer/80"
            >
              {translation.cancel || "Cancel"}
            </Button>
            <Button
              onClick={handleUnban}
              className="bg-ui-success hover:bg-ui-success/90 text-white"
            >
              {translation.unban || "Unban"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </motion.div>
  );
}
