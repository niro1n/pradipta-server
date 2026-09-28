import React, { useState } from "react";
import { motion } from "framer-motion";
import { Car, Search, X } from "lucide-react";
import { Button } from "./ui/button";
import { useTranslation } from "../lib/translation";
import { cn } from "../lib/utils";
import { sendNui } from "../lib/sendNui";

interface SpawnVehicleModalProps {
  vehicles: { name: string; label: string; brand?: string }[];
  translation: Record<string, string>;
  onClose: () => void;
  targetPlayerId?: number;
}

export function SpawnVehicleModal({
  vehicles,
  translation,
  onClose,
  targetPlayerId,
}: SpawnVehicleModalProps) {
  const [search, setSearch] = useState("");
  const [selectedVehicle, setSelectedVehicle] = useState<{
    name: string;
    label: string;
  } | null>(null);

  const filteredVehicles = vehicles.filter(
    (v) =>
      v.label.toLowerCase().includes(search.toLowerCase()) ||
      v.name.toLowerCase().includes(search.toLowerCase()),
  );

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[80] flex items-center justify-center bg-black/50 p-4"
      onMouseDown={onClose}
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        className="bg-ui-panel backdrop-blur-panel border border-ui-border rounded-md shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col"
        onMouseDown={(e) => e.stopPropagation()}
      >
        <div className="p-4 border-b border-ui-border flex items-center justify-between">
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <Car size={20} className="text-purple-500" />
            Spawn Vehicle
          </h2>
          <button
            onClick={onClose}
            className="p-1 rounded-md text-gray-400 hover:text-white hover:bg-ui-layer"
          >
            <X size={20} />
          </button>
        </div>

        <div className="p-4">
          <div className="relative mb-4">
            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
              size={18}
            />
            <input
              type="text"
              placeholder="Search vehicles..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-ui-layer/50 border border-ui-border rounded-md pl-10 pr-4 py-2 text-sm text-white focus:outline-none focus:border-purple-500 transition-colors"
            />
          </div>

          <div className="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3 max-h-[500px] overflow-y-auto pr-2 custom-scrollbar">
            {filteredVehicles.map((vehicle) => (
              <div
                key={vehicle.name}
                onClick={() => setSelectedVehicle(vehicle)}
                className={cn(
                  "p-3 rounded-md border cursor-pointer transition-all flex flex-col items-center justify-start gap-3",
                  selectedVehicle?.name === vehicle.name
                    ? "border-purple-500 bg-purple-500/10 shadow-[0_0_15px_rgba(168,85,247,0.15)]"
                    : "border-ui-border bg-ui-layer/30 hover:border-ui-border-hover hover:bg-ui-layer/50",
                )}
              >
                <div className="w-full h-24 flex items-center justify-center bg-black/30 rounded p-2">
                  <img
                    src={`https://docs.fivem.net/vehicles/${vehicle.name}.webp`}
                    alt={vehicle.name}
                    className="max-w-full max-h-full object-contain"
                    onError={(e) => {
                      const target = e.target as HTMLImageElement;
                      target.onerror = null;
                      target.style.display = "none";
                      if (target.parentElement) {
                        const icon = document.createElement("div");
                        icon.innerHTML =
                          '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-gray-500"><path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg>';
                        target.parentElement.appendChild(
                          icon.firstChild as Node,
                        );
                      }
                    }}
                  />
                </div>
                <div className="w-full text-center">
                  <div className="text-xs font-bold text-white truncate w-full">
                    {vehicle.label}
                  </div>
                  <div className="text-[10px] text-gray-400 truncate w-full">
                    {vehicle.brand || vehicle.name}
                  </div>
                </div>
              </div>
            ))}
            {filteredVehicles.length === 0 && (
              <div className="col-span-3 md:col-span-4 text-center text-gray-500 mt-10">
                {translation.svNoVehiclesFound || "No vehicles found"}
              </div>
            )}
          </div>
        </div>

        {selectedVehicle && (
          <div className="p-4 border-t border-ui-border bg-ui-layer/50 flex items-center justify-between gap-3">
            <div className="flex-1">
              <span className="text-sm text-gray-400">Selected: </span>
              <span className="text-sm font-bold text-white">
                {selectedVehicle.label}
              </span>
            </div>
            <Button
              onClick={() => {
                if (targetPlayerId) {
                  sendNui("actionWithInput", {
                    action: "specialSpawnVehicle",
                    playerId: targetPlayerId,
                    input: selectedVehicle.name,
                  });
                } else {
                  sendNui("spawnVehicle", { text: selectedVehicle.name });
                }
                onClose();
              }}
              className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white hover:from-purple-600 hover:to-indigo-600 px-8"
            >
              Spawn
            </Button>
          </div>
        )}
      </motion.div>
    </motion.div>
  );
}
