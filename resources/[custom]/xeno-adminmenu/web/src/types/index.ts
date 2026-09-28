export type Ban = {
  id: number;
  playerName: string;
  playerId: number;
  reason: string;
  admin: string;
  date: string;
  duration: string;
  status: "Active" | "Expired";
};

export type Player = {
  id: number;
  name: string;
  isStaff?: boolean;
  liveData?: {
    status: string;
    health: number;
    armor: number;
    position: string;
    cash: number;
    bank: number;
    ping: number;
    lastActive: string;
    hunger: number;
    thirst: number;
    job: string;
  };
  identifiers: string[];
  bans?: Ban[];
  isDead: boolean;
  items: {
    name: string;
    label: string;
    count: number;
    fastSlot?: boolean;
    iconPath: string;
  }[];
};

export type ServerResource = {
  name: string;
  author: string;
  description: string;
  status: string;
  version: string;
};

export type LogEntry = {
  id: number;
  type: string;
  message: string;
  timestamp: string;
};

export type ChatMessage = {
  id: number;
  author: string;
  message: string;
  timestamp: string;
};

export type Warn = {
  author: string;
  reason: string;
  active: boolean;
  executionTime: string;
};

export type WebhookConfig = {
  id: string;
  name: string;
  url: string;
  events: string[];
  isActive: boolean;
  description?: string;
};

export type StaffMember = {
  id: string;
  name: string;
  identifier: string;
  group: string;
  permissions: string[];
  isActive: boolean;
  addedBy: string;
  addedDate: string;
};

export type Group = {
  id: string;
  name: string;
  color: string;
  permissions: string[];
  description?: string;
  isDefault: boolean;
};

export type Permission = {
  id: string;
  name: string;
  description: string;
  category: string;
};
