import { useState, useEffect, useRef } from "react";
import { motion } from "framer-motion";
import {
  Search,
  Filter,
  Eye,
  Ban,
  UserX,
  Zap,
  Heart,
  Users,
  BadgeCheck,
  Shield,
  Clock,
  Briefcase,
  DollarSign,
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
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "./ui/dropdown-menu";
import { CustomTooltip } from "./ui/custom-tooltip";
import { Player } from "../types";
import { useTranslation } from "../lib/translation";
import { CopyableText } from "./ui/copyable-text";
import { SeeMore } from "./ui/see-more";

type PlayersProps = {
  players: Player[];
  onOpenPlayerModal: (player: Player) => void;
  onPlayerAction: (action: string, playerId: number) => void;
};

let memory = {
  loopRunning: false,
  currLoopEnded: false,
};

export default function Players({
  players,
  onOpenPlayerModal,
  onPlayerAction,
}: PlayersProps) {
  const translation = useTranslation();
  const [searchQuery, setSearchQuery] = useState("");
  const [filterStatus, setFilterStatus] = useState<string | null>(null);
  const [averagePlaytime, setAveragePlaytime] = useState<string>();
  const [lastUpdatedMins, setLastUpdatedMins] = useState<number | string>(
    translation.unknownValue?.toLowerCase() || "unknown",
  );
  const lastUpdatedMinsRef = useRef<number>(0);

  const filteredPlayers = players.filter((player) => {
    const matchesSearch =
      player.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      player.id.toString().includes(searchQuery);
    const matchesFilter = filterStatus
      ? filterStatus === "Staff" && player.isStaff
      : true;

    return matchesSearch && matchesFilter;
  });

  window.addEventListener("message", (event) => {
    if (event.data.action == "setAveragePlaytime") {
      setAveragePlaytime(event.data.value);
    }
  });

  useEffect(() => {
    lastUpdatedMinsRef.current = 0;
    setLastUpdatedMins(lastUpdatedMinsRef.current);

    if (memory.loopRunning) {
      memory.loopRunning = false;

      const interval = setInterval(() => {
        if (memory.currLoopEnded) {
          memory.currLoopEnded = false;

          clearInterval(interval);

          memory.loopRunning = true;
          const loopInterval = setInterval(() => {
            if (!memory.loopRunning) {
              memory.currLoopEnded = true;
              return clearInterval(loopInterval);
            }

            lastUpdatedMinsRef.current += 1;
            setLastUpdatedMins(lastUpdatedMinsRef.current);
          }, 60000);
        }
      }, 10);
    } else {
      memory.loopRunning = true;
      const loopInterval = setInterval(() => {
        if (!memory.loopRunning) {
          memory.currLoopEnded = true;
          return clearInterval(loopInterval);
        }

        lastUpdatedMinsRef.current += 1;
        setLastUpdatedMins(lastUpdatedMinsRef.current);
      }, 60000);
    }
  }, [players]);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0 }}
      className="space-y-4"
    >
      <div>
        <h1 className="text-2xl font-bold text-white flex items-center gap-2">
          <span className="w-8 h-8 rounded-lg bg-ui-blue/10 flex items-center justify-center ">
            <Users size={16} className="text-ui-blue" />
          </span>
          {translation.playerManagamentHeader || "Player Management"}
        </h1>
        <p className="text-gray-400 ml-11">
          {translation.afterManagamentHeader ||
            "View and manage connected players"}
        </p>
      </div>

      <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
        <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
        <CardHeader className="relative z-10">
          <CardTitle className="flex items-center gap-2 text-lg">
            <BadgeCheck className="h-5 w-5 text-ui-blue" />
            {translation.playerHeaderTwo || "Players List"}
          </CardTitle>
          <CardDescription className="text-gray-400">
            {translation.afterHeaderTwoPlayer || "Currently connected players"}
          </CardDescription>
        </CardHeader>
        <CardContent className="py-3 relative z-10">
          <div className="flex items-center">
            <div className="flex items-center gap-2 text-sm text-gray-400">
              <Clock size={14} />
              <span>
                {translation.lastUpdated
                  ? translation.lastUpdated.replace(
                      "%s",
                      String(lastUpdatedMins),
                    )
                  : `Last updated: ${lastUpdatedMins} minutes ago`}
              </span>
            </div>
          </div>

          <div className="flex flex-col md:flex-row gap-4 mt-4 mb-6">
            <div className="relative flex-1">
              <Search
                className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                size={16}
              />
              <Input
                placeholder="Search by name or ID..."
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
                  {translation.filterPlayers || "Filter"}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent className="bg-ui-layer border-ui-border text-white cursor-pointer">
                <DropdownMenuItem
                  className="hover:bg-ui-layer focus:bg-ui-layer"
                  onClick={() => setFilterStatus(null)}
                >
                  {translation.filterAllPlayers || "All Players"}
                </DropdownMenuItem>
                <DropdownMenuItem
                  className="hover:bg-ui-layer focus:bg-ui-layer"
                  onClick={() => setFilterStatus("Staff")}
                >
                  {translation.filterByStaff || "Staff Players"}
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          <div className="rounded-md border border-ui-border overflow-hidden max-h-96 overflow-y-auto">
            <div className="overflow-x-auto scrollbar-hide">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-ui-layer/50">
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.playerID || "ID"}
                    </th>
                    <th className="px-[5.2rem] py-3 text-left text-sm font-medium text-gray-300">
                      {translation.playerName || "Name"}
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.playerJob || "Job"}
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.playerActions || "Actions"}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {filteredPlayers.map((player) => (
                    <tr
                      key={player.id}
                      className="border-t border-ui-border hover:bg-ui-layer/50 transition-colors"
                    >
                      <td className="px-4 py-3 text-sm">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-full bg-ui-blue/10 flex items-center justify-center shadow-md shadow-ui-blue/10">
                            <span className="text-ui-blue text-xs font-bold">
                              {player.id}
                            </span>
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-sm font-medium">
                        <div className="flex items-center gap-2 ml-[4rem]">
                          {player.isStaff && (
                            <Shield size={14} className="text-ui-violet" />
                          )}
                          <SeeMore
                            text={player.name}
                            showHeader={true}
                            headerTitle="Player Name"
                          />
                        </div>
                      </td>
                      <td className="px-4 py-3 text-sm">
                        <div className="flex items-center gap-2">
                          <Briefcase size={14} className="text-ui-textMuted" />
                          <span className="text-gray-300">
                            {player.liveData?.job ||
                              translation.unknownValue ||
                              "Unknown"}
                          </span>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-sm">
                        <div className="flex items-center gap-1">
                          <CustomTooltip
                            content={translation.viewPlayer || "View Player"}
                          >
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8 text-ui-blue hover:bg-ui-blue/10 transition-colors"
                              onClick={() => onOpenPlayerModal(player)}
                            >
                              <Eye size={16} />
                            </Button>
                          </CustomTooltip>

                          <CustomTooltip
                            content={translation.kickPlayer || "Kick Player"}
                          >
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8 text-ui-danger hover:bg-ui-danger/10 transition-colors"
                              onClick={() => onPlayerAction("kick", player.id)}
                            >
                              <UserX size={16} />
                            </Button>
                          </CustomTooltip>

                          <CustomTooltip
                            content={translation.banPlayer || "Ban Player"}
                          >
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8 text-ui-orange hover:bg-ui-orange/10 transition-colors"
                              onClick={() => onPlayerAction("ban", player.id)}
                            >
                              <Ban size={16} />
                            </Button>
                          </CustomTooltip>

                          <CustomTooltip
                            content={translation.gotoPlayer || "Go To"}
                          >
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8 text-ui-violet hover:bg-ui-violet/10 transition-colors"
                              onClick={() => onPlayerAction("goto", player.id)}
                            >
                              <Zap size={16} />
                            </Button>
                          </CustomTooltip>

                          <CustomTooltip
                            content={translation.healPlayer || "Heal Player"}
                          >
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8 text-ui-success hover:bg-ui-success/10 transition-colors"
                              onClick={() => onPlayerAction("heal", player.id)}
                            >
                              <Heart size={16} />
                            </Button>
                          </CustomTooltip>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  );
}
