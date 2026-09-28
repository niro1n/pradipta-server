import React, { useState } from "react";
import { motion } from "framer-motion";
import { Gift, Search, X } from "lucide-react";
import { Button } from "./ui/button";
import { useTranslation } from "../lib/translation";
import { cn } from "../lib/utils";
import { sendNui } from "../lib/sendNui";

interface GiveItemModalProps {
  items: { name: string; label: string; image?: string }[];
  translation: Record<string, string>;
  onClose: () => void;
  targetPlayerId?: number;
}

export function GiveItemModal({
  items,
  translation,
  onClose,
  targetPlayerId,
}: GiveItemModalProps) {
  const [search, setSearch] = useState("");
  const [selectedItem, setSelectedItem] = useState<{
    name: string;
    label: string;
    image?: string;
  } | null>(null);
  const [amount, setAmount] = useState(1);

  const filteredItems = items.filter(
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
        className="bg-ui-panel backdrop-blur-panel border border-ui-border rounded-md shadow-2xl w-full max-w-4xl overflow-hidden flex flex-col"
        onMouseDown={(e) => e.stopPropagation()}
      >
        <div className="p-4 border-b border-ui-border flex items-center justify-between">
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <Gift size={20} className="text-pink-500" />
            {translation.giveItem || "Give Item"}
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
              placeholder="Search items..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-ui-layer/50 border border-ui-border rounded-md pl-10 pr-4 py-2 text-sm text-white focus:outline-none focus:border-pink-500 transition-colors"
            />
          </div>

          <div className="grid grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-2 max-h-[450px] overflow-y-auto pr-2 custom-scrollbar">
            {filteredItems.map((item) => (
              <div
                key={item.name}
                onClick={() => setSelectedItem(item)}
                className={cn(
                  "p-3 rounded-md border cursor-pointer transition-all flex flex-col items-center justify-start gap-2",
                  selectedItem?.name === item.name
                    ? "border-pink-500 bg-pink-500/10"
                    : "border-ui-border bg-ui-layer/30 hover:border-ui-border-hover hover:bg-ui-layer/50",
                )}
              >
                <div className="w-12 h-12 flex items-center justify-center bg-black/20 rounded p-1 mb-1">
                  {item.image ? (
                    <img
                      src={
                        item.image.startsWith("nui://")
                          ? item.image
                          : `nui://qb-inventory/html/images/${item.image}`
                      }
                      alt={item.name}
                      className="max-w-full max-h-full object-contain"
                      onError={(e) => {
                        (e.target as HTMLImageElement).style.display = "none";
                      }}
                    />
                  ) : (
                    <Gift
                      size={24}
                      className={
                        selectedItem?.name === item.name
                          ? "text-pink-400"
                          : "text-gray-400"
                      }
                    />
                  )}
                </div>
                <span className="text-[11px] leading-tight text-gray-300 font-medium text-center truncate w-full">
                  {item.label}
                </span>
              </div>
            ))}
            {filteredItems.length === 0 && (
              <div className="col-span-full text-center text-gray-500 mt-10">
                {translation.giNoItemsFound || "No items found"}
              </div>
            )}
          </div>
        </div>

        {selectedItem && (
          <div className="p-4 border-t border-ui-border bg-ui-layer/50 flex flex-col gap-4">
            <div className="flex items-center gap-4 flex-wrap">
              <div className="flex-1 min-w-[200px]">
                <span className="text-sm text-gray-400">Selected: </span>
                <span className="text-sm font-bold text-white">
                  {selectedItem.label}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-sm text-gray-400">Amount:</span>
                <input
                  type="number"
                  min="1"
                  value={amount}
                  onChange={(e) =>
                    setAmount(Math.max(1, parseInt(e.target.value) || 1))
                  }
                  className="w-24 bg-ui-layer/50 border border-ui-border rounded-md px-2 py-2 text-sm text-white focus:outline-none focus:border-pink-500"
                />
              </div>
            </div>
            <Button
              onClick={() => {
                if (targetPlayerId) {
                  sendNui("giveItem", {
                    playerId: targetPlayerId,
                    item: selectedItem.name,
                    count: amount,
                  });
                } else {
                  sendNui("giveItem", { item: selectedItem.name, amount });
                }
                onClose();
              }}
              className="w-full bg-gradient-to-r from-pink-500 to-rose-500 text-white hover:from-pink-600 hover:to-rose-600 font-bold py-5"
            >
              Give {amount}x {selectedItem.label}
            </Button>
          </div>
        )}
      </motion.div>
    </motion.div>
  );
}
