import { Users, Shield, Wifi, X } from "lucide-react";
import { useTranslation } from "../lib/translation";
import { closeAdminMenu } from "../lib/closeAdminMenu";
import { cn } from "../lib/utils";

type ServerStatsProps = {
  stats: {
    onlinePlayers: number;
    activeAdmins: number;
    maxPlayers: number;
    averagePing: number;
    mapResources: number;
  };
  setIsVisible: Function;
};

export default function ServerStats({ stats, setIsVisible }: ServerStatsProps) {
  const translation = useTranslation();

  return (
    <div className="h-16 border-b border-ui-border bg-ui-layer/50 flex items-center px-6 relative">
      <div className="flex items-center gap-6 overflow-x-auto justify-center scrollbar-hide w-full">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-ui-blue/10 flex items-center justify-center shadow-md ">
            <Users size={14} className="text-ui-blue" />
          </div>
          <div>
            <span className="text-xs text-ui-textMuted">
              {translation.playersInStatus || "Players"}
            </span>
            <p className="text-sm font-medium text-white">
              {stats.onlinePlayers}/{stats.maxPlayers}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-ui-violet/10 flex items-center justify-center shadow-md ">
            <Shield size={14} className="text-ui-violet" />
          </div>
          <div>
            <span className="text-xs text-ui-textMuted">
              {translation.statusAdmins || "Admins"}
            </span>
            <p className="text-sm font-medium text-white">
              {stats.activeAdmins}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <div
            className={cn(
              "w-8 h-8 rounded-full flex items-center justify-center shadow-md",
              stats.averagePing === 0
                ? "bg-ui-textMuted/10 text-ui-textMuted shadow-ui-textMuted/20"
                : stats.averagePing <= 33
                  ? "bg-ui-success/10 text-ui-success "
                  : stats.averagePing <= 66
                    ? "bg-ui-amber/10 text-ui-amber "
                    : "bg-ui-danger/10 text-ui-danger ",
            )}
          >
            <Wifi size={14} />
          </div>
          <div>
            <span className="text-xs text-ui-textMuted">
              {translation.averagePing || "Average Ping"}
            </span>
            <p className="text-sm font-medium text-white">
              {stats.averagePing}
            </p>
          </div>
        </div>
      </div>
      <div className="cursor-pointer text-ui-textMuted hover:text-white transition-colors absolute right-6 top-1/2 -translate-y-1/2">
        <X
          size={24}
          strokeWidth={2}
          absoluteStrokeWidth
          onClick={() => closeAdminMenu(setIsVisible)}
        />
      </div>
    </div>
  );
}
