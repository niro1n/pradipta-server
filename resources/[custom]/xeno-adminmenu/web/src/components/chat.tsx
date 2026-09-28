import React from "react";

import { useState, useRef, useEffect } from "react";
import { motion } from "framer-motion";
import { Send, User, Shield } from "lucide-react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import type { ChatMessage } from "../types";
import { useTranslation } from "../lib/translation";
import { sendNui } from "../lib/sendNui";

type ChatProps = {
  messages: ChatMessage[];
};

export default function Chat({ messages }: ChatProps) {
  const [newMessage, setNewMessage] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const translation = useTranslation();

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0 }}
      className="space-y-4"
    >
      <div>
        <h1 className="text-2xl font-bold text-white flex items-center gap-2">
          <span className="w-8 h-8 rounded-lg bg-ui-violet/10 flex items-center justify-center ">
            <Shield size={16} className="text-ui-violet" />
          </span>
          {translation.adminHeader || "Admin Chat"}
        </h1>
        <p className="text-gray-400 ml-11">
          {translation.adminChat || "Communicate with other administrators"}
        </p>
      </div>

      <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white relative overflow-hidden">
        <div className="absolute right-0 top-0 w-64 h-64 bg-ui-violet/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
        <CardHeader className="relative z-10">
          <CardTitle className="flex items-center gap-2 text-lg">
            <Shield className="h-5 w-5 text-ui-violet" />
            {translation.chatAdminHeader || "Chat"}
          </CardTitle>
          <CardDescription className="text-gray-400">
            {translation.communication || "Admin communication channel"}
          </CardDescription>
        </CardHeader>
        <CardContent className="relative z-10">
          <div className="flex flex-col h-[575px]">
            <div className="flex-1 overflow-y-auto scrollbar-hide mb-4 space-y-3 pr-2">
              {messages.map((message, index) => (
                <div
                  key={index}
                  className={`flex items-start gap-3 p-3 rounded-lg ${message.author === "Admin"
                    ? "bg-ui-violet/10 border border-ui-violet/20"
                    : "bg-ui-layer/50 border border-ui-border/50"
                    }`}
                >
                  <div
                    className={`w-8 h-8 rounded-full flex items-center justify-center shadow-md ${message.author === "Admin"
                      ? "bg-ui-violet/20 shadow-ui-violet/10"
                      : "bg-ui-layer/80"
                      }`}
                  >
                    {message.author === "Admin" ? (
                      <Shield size={14} className="text-ui-violet" />
                    ) : (
                      <User size={14} className="text-gray-300" />
                    )}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <span
                        className={`text-sm font-bold ${message.author === "Admin"
                          ? "text-ui-violet"
                          : "text-gray-300"
                          }`}
                      >
                        {message.author}
                      </span>
                      <span className="text-[10px] uppercase font-bold text-ui-textMuted">
                        {message.timestamp}
                      </span>
                    </div>
                    <p className="text-sm text-gray-200 mt-1">
                      {message.message}
                    </p>
                  </div>
                </div>
              ))}
              <div ref={messagesEndRef} />
            </div>

            <div className="flex gap-2 pt-2 border-t border-ui-border/50">
              <Input
                placeholder={translation.chatPlaceholder || "Type a message..."}
                className="bg-ui-layer/50 border-ui-border text-white h-11"
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    if (newMessage === "") return;
                    sendNui("sendNewMessage", {
                      message: newMessage,
                      timestamp: new Date().toLocaleTimeString([], {
                        hour: "2-digit",
                        minute: "2-digit",
                      }),
                    });
                    setNewMessage("");
                  }
                }}
              />
              <Button
                className="bg-ui-violet hover:bg-ui-violet/80 text-white h-11 w-11 px-0 "
                onClick={() => {
                  if (newMessage === "") return;
                  sendNui("sendNewMessage", {
                    message: newMessage,
                    timestamp: new Date().toLocaleTimeString([], {
                      hour: "2-digit",
                      minute: "2-digit",
                    }),
                  });
                  setNewMessage("");
                }}
              >
                <Send size={16} />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  );
}
