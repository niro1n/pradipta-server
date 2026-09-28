import { useState } from "react";
import { motion } from "framer-motion";
import {
  Search,
  RefreshCw,
  Play,
  Square,
  Server as ServerIcon,
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
import Checkbox from "@mui/material/Checkbox";
import FormControlLabel from "@mui/material/FormControlLabel";
import { useTranslation } from "../lib/translation";
import { SeeMore } from "./ui/see-more";
import { sendNui } from "../lib/sendNui";

type ServerProps = {
  resources: ServerResource[];
};

export default function Server({ resources }: ServerProps) {
  const translation = useTranslation();
  const [searchQuery, setSearchQuery] = useState("");
  const [filterShowDefaultRess, setFilterShowDefaultRess] =
    useState<boolean>(false);
  const filteredResources = resources.filter(
    (resource) =>
      (filterShowDefaultRess
        ? true
        : resource.author !== "Cfx.re <root@cfx.re>") &&
      (
        resource.name +
        resource.author +
        resource.description +
        resource.version
      )
        .toLowerCase()
        .includes(searchQuery.toLowerCase()),
  );

  const onResourceAction = function (action: string, resName?: string) {
    sendNui(
      `resource_${action}`,
      typeof resName === "string" && ({ resName } as any),
    );
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0 }}
      className="space-y-6"
    >
      <div>
        <h1 className="text-2xl font-bold text-white flex items-center gap-2">
          <span className="w-8 h-8 rounded-lg bg-ui-success/10 flex items-center justify-center ">
            <ServerIcon size={16} className="text-white" />
          </span>
          {translation.serverManagamentHeader || "Server Management"}
        </h1>
        <p className="text-gray-400">
          {translation.afterHeader ||
            "Manage server resources and configuration"}
        </p>
      </div>

      <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
        <div className="absolute left-0 top-0 w-64 h-64 bg-ui-success/5 rounded-full blur-3xl -ml-10 -mt-10 pointer-events-none" />
        <CardHeader className="relative z-10">
          <CardTitle className="flex items-center gap-2 text-lg">
            <ServerIcon className="h-5 w-5 text-ui-success" />
            {translation.serverResources || "Server Resources"}
          </CardTitle>
          <CardDescription className="text-gray-400">
            {translation.manageResources || "Manage server resources"}
          </CardDescription>
        </CardHeader>
        <CardContent className="relative z-10">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search
                className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                size={16}
              />
              <Input
                placeholder="Search resources..."
                className="pl-9 bg-ui-layer/50 border-ui-border text-white h-11"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>

            <FormControlLabel
              control={
                <Checkbox
                  onChange={(event) =>
                    setFilterShowDefaultRess(event.target.checked)
                  }
                  className="p-0 m-0 text-white"
                  sx={{
                    padding: 0,
                    "& .MuiSvgIcon-root": {
                      fontSize: "var(--font-size)",
                    },
                    color: "white",
                    "&.Mui-checked": {
                      color: "white",
                    },
                  }}
                />
              }
              label={
                <p className="text-[var(--font-size)]">
                  {translation.showDefaultResources || "Show Default"}
                </p>
              }
              className="relative mr-0 bg-ui-layer/50 border border-ui-border hover:bg-ui-layer text-white text-[var(--font-size)] items-center gap-2 px-4 h-11 rounded-md cursor-pointer transition-colors"
              slotProps={{
                typography: {
                  className: "text-white text-[var(--font-size)] font-medium",
                },
              }}
              sx={{
                margin: 0,
              }}
            />

            <Button
              variant="outline"
              className="relative bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white items-center gap-2 h-11"
              onClick={() => onResourceAction("refresh")}
            >
              <RefreshCw size={16} className="text-ui-blue" />
              {translation.refreshButton || "Refresh"}
            </Button>
          </div>

          <div className="rounded-md border border-ui-border overflow-hidden">
            <div className="overflow-x-auto scrollbar-hide max-h-[600px]">
              <table className="w-full">
                <thead>
                  <tr className="bg-ui-layer/50 sticky top-0 z-10 backdrop-blur-md">
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.resourceName || "Name"}
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.resourceAuthor || "Author"}
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.resourceDescription || "Description"}
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.resourceStatus || "Status"}
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.resourceVersion || "Version"}
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-medium text-gray-300">
                      {translation.resourceActions || "Actions"}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {filteredResources.map((resource) => (
                    <tr
                      key={resource.name}
                      className="border-t border-ui-border hover:bg-ui-layer/50 transition-colors"
                    >
                      <td className="px-4 py-3 text-sm font-medium">
                        <SeeMore text={resource.name} showHeader={true} />
                      </td>
                      <td className="px-4 py-3 text-sm">
                        <SeeMore text={resource.author} showHeader={true} />
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-400">
                        <SeeMore
                          text={resource.description}
                          showHeader={true}
                        />
                      </td>
                      <td className="px-1.5 py-3 text-sm">
                        <Badge
                          className={
                            resource.status === "Started" ||
                            resource.status === "Starting"
                              ? "bg-ui-success/20 text-ui-success hover:bg-ui-success/30"
                              : "bg-ui-layer text-gray-400 hover:bg-ui-layer/80"
                          }
                        >
                          <SeeMore text={resource.status} showHeader={true} />
                        </Badge>
                      </td>
                      <td className="px-4 py-3 text-sm font-mono text-gray-400">
                        <SeeMore text={resource.version} showHeader={true} />
                      </td>
                      <td className="px-4 py-3 text-sm">
                        <div className="flex items-center gap-2">
                          {resource.status === "Started" ? (
                            <>
                              <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8 text-gray-400 hover:text-ui-blue hover:bg-ui-blue/10"
                                onClick={() =>
                                  onResourceAction("restart", resource.name)
                                }
                              >
                                <RefreshCw size={16} />
                              </Button>

                              <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8 text-gray-400 hover:text-ui-danger hover:bg-ui-danger/10"
                                onClick={() =>
                                  onResourceAction("stop", resource.name)
                                }
                              >
                                <Square size={16} />
                              </Button>
                            </>
                          ) : (
                            resource.status === "Stopped" && (
                              <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8 text-gray-400 hover:text-ui-success hover:bg-ui-success/10"
                                onClick={() =>
                                  onResourceAction("start", resource.name)
                                }
                              >
                                <Play size={16} />
                              </Button>
                            )
                          )}
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
