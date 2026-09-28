import React, {
  useRef,
  useState,
  useEffect,
  useCallback,
  useMemo,
} from "react";
import { motion } from "framer-motion";
import {
  Car,
  Shield,
  Zap,
  Map,
  Users,
  Heart,
  Sparkles,
  Box,
  Cloud,
  CloudRain,
  CloudLightning,
  Snowflake,
  Moon,
  ChevronDown,
  MessageSquareWarning,
  SunDim,
  Sun,
  CloudHail,
  CloudFog,
  Haze,
  MountainSnow,
  SunSnow,
  CloudRainWind,
  LightbulbOff,
  SunMedium,
  CloudDrizzle,
  CloudSnow,
  Sunrise,
  Sunset,
  Wrench,
  Globe,
  Megaphone,
  AlertTriangle,
  FastForward,
  Navigation,
  RotateCw,
  Settings,
  User,
  Wallet,
  Gift,
  Trash2,
  Crosshair,
  MapPin,
  Eye,
  Speaker,
  Activity,
  Shirt,
  Ban,
} from "lucide-react";
import { Card, CardContent } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "./ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "./ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { useTranslation } from "../lib/translation";
import { sendNui } from "../lib/sendNui";
import { SpawnVehicleModal } from "./spawn-vehicle-modal";
import { GiveItemModal } from "./give-item-modal";

let memories = {
  godMode: false,
  vehs: [] as string[],
  superJump: false,
  invisibility: false,
  vehicleGodMode: false,
  weatherTypeNow: "CLEAR",
  showCoordinates: false,
  noclip: false,
  fastRun: false,
  playerIds: false,
  infiniteStamina: false,
};

interface TimeAndWeatherModalProps {
  isOpen: boolean;
  onOpenChange: (open: boolean) => void;
  translation: Record<string, string>;
  weatherTypes: { value: string; label: string; icon: React.ReactNode }[];
  weatherTypeNow: string;
  weatherDropdownOpen: boolean;
  setWeatherDropdownOpen: React.Dispatch<React.SetStateAction<boolean>>;
  setWeatherTypeNow?: React.Dispatch<React.SetStateAction<string>>;
  customTimeHours: string;
  setCustomTimeHours: React.Dispatch<React.SetStateAction<string>>;
  customTimeMinutes: string;
  setCustomTimeMinutes: React.Dispatch<React.SetStateAction<string>>;
  dynamicWater: boolean;
  setDynamicWater: React.Dispatch<React.SetStateAction<boolean>>;
  instantWeather: boolean;
  setInstantWeather: React.Dispatch<React.SetStateAction<boolean>>;
  tsunami: boolean;
  setTsunami: React.Dispatch<React.SetStateAction<boolean>>;
  blackout: boolean;
  setBlackout: React.Dispatch<React.SetStateAction<boolean>>;
}

const TimeAndWeatherModal = React.memo(
  ({
    isOpen,
    onOpenChange,
    translation,
    weatherTypes,
    weatherTypeNow,
    weatherDropdownOpen,
    setWeatherDropdownOpen,
    setWeatherTypeNow,
    customTimeHours,
    setCustomTimeHours,
    customTimeMinutes,
    setCustomTimeMinutes,
    dynamicWater,
    setDynamicWater,
    instantWeather,
    setInstantWeather,
    tsunami,
    setTsunami,
    blackout,
    setBlackout,
  }: TimeAndWeatherModalProps) => {
    const handleWeatherSelect = useCallback(
      async (weatherValue: string, e: React.MouseEvent) => {
        e.stopPropagation();
        setWeatherTypeNow && setWeatherTypeNow(weatherValue);
        setWeatherDropdownOpen(false);
        if (await sendNui("setWeather", { weather: weatherValue })) {
          setWeatherDropdownOpen(false);
        }
      },
      [setWeatherDropdownOpen, setWeatherTypeNow],
    );

    const handleOptionToggle = useCallback(
      (option: any, e: React.MouseEvent) => {
        e.stopPropagation();
        const newState = !option.state;
        option.setState(newState);
        sendNui(option.key, { state: newState });
      },
      [],
    );

    const handleTimeSet = useCallback((time: string, e: React.MouseEvent) => {
      e.stopPropagation();
      sendNui("setTime", { time });
    }, []);

    const handleCustomTimeSet = useCallback(
      (e: React.MouseEvent) => {
        e.stopPropagation();
        sendNui("setTime", { time: `${customTimeHours}:${customTimeMinutes}` });
      },
      [customTimeHours, customTimeMinutes],
    );

    const weatherOptions = useMemo(
      () => [
        {
          key: "dynamicWater",
          label: translation.dynamicWater || "Dynamic Water",
          icon: <Zap size={16} className="mr-2" />,
          state: dynamicWater,
          setState: setDynamicWater,
        },
        {
          key: "instantWeather",
          label: translation.instantWeatherChange || "Instant Weather",
          icon: <Sparkles size={16} className="mr-2" />,
          state: instantWeather,
          setState: setInstantWeather,
        },
        {
          key: "tsunami",
          label: translation.tsunami || "Tsunami",
          icon: <CloudRain size={16} className="mr-2" />,
          state: tsunami,
          setState: setTsunami,
        },
        {
          key: "blackout",
          label: translation.blackout || "Blackout",
          icon: <Shield size={16} className="mr-2" />,
          state: blackout,
          setState: setBlackout,
        },
      ],
      [
        translation,
        dynamicWater,
        setDynamicWater,
        instantWeather,
        setInstantWeather,
        tsunami,
        setTsunami,
        blackout,
        setBlackout,
      ],
    );

    const currentWeather = useMemo(
      () => weatherTypes.find((w) => w.value === weatherTypeNow),
      [weatherTypes, weatherTypeNow],
    );

    return (
      <Dialog open={isOpen} onOpenChange={onOpenChange}>
        <DialogContent className="bg-ui-layer border-ui-border text-white max-w-4xl">
          <DialogHeader>
            <DialogTitle className="text-lg font-bold">
              {translation.weatherControl || "Weather & Time"}
            </DialogTitle>
            <DialogDescription className="sr-only">
              {translation.tlWeatherTimeSettings || "Weather and time settings"}
            </DialogDescription>
          </DialogHeader>
          <div className="grid grid-cols-[1fr,auto,1fr] gap-6">
            <div className="space-y-4">
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted block mb-2">
                  {translation.selectWeather || "Select Weather"}
                </label>
                <div className="relative">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      setWeatherDropdownOpen(!weatherDropdownOpen);
                    }}
                    className="w-full flex items-center justify-between p-3 bg-ui-layer/50 border border-ui-border rounded-lg text-white hover:bg-ui-layer transition-colors"
                  >
                    <div className="flex items-center">
                      {currentWeather && (
                        <>
                          {currentWeather.icon}
                          <span>{currentWeather.label}</span>
                        </>
                      )}
                    </div>
                    <ChevronDown
                      size={16}
                      className={`transition-transform ${weatherDropdownOpen ? "rotate-180" : ""}`}
                    />
                  </button>
                  {weatherDropdownOpen && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-ui-panel border border-ui-border rounded-lg shadow-xl z-10 max-h-60 overflow-hidden overflow-y-auto">
                      {weatherTypes.map((weather) => (
                        <button
                          key={weather.value}
                          onClick={(e) => handleWeatherSelect(weather.value, e)}
                          className="w-full flex items-center p-3 text-left text-white hover:bg-ui-layer transition-colors"
                        >
                          {weather.icon}
                          {weather.label}
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              </div>
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted block mb-2 mt-4">
                  {translation.moreOptions || "Effects"}
                </label>
                <div className="space-y-2">
                  {weatherOptions.map((option) => (
                    <div
                      key={option.key}
                      className="flex items-center justify-between p-3 bg-ui-layer/50 rounded-lg border border-ui-border hover:bg-ui-layer transition-colors"
                    >
                      <div className="flex items-center">
                        {option.icon}
                        <span className="text-sm text-gray-200">
                          {option.label}
                        </span>
                      </div>
                      <button
                        onClick={(e) => handleOptionToggle(option, e)}
                        className={`relative inline-flex h-5 w-9 items-center rounded-full transition-colors focus:outline-none ${option.state ? "bg-ui-blue" : "bg-gray-600"}`}
                      >
                        <span
                          className={`inline-block h-3 w-3 transform rounded-full bg-white transition-transform ${option.state ? "translate-x-5" : "translate-x-1"}`}
                        />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            </div>
            <div className="w-px bg-ui-border h-full"></div>
            <div className="space-y-4">
              <label className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted block mb-2">
                {translation.timeControl || "Time Control"}
              </label>
              <div className="grid grid-cols-2 gap-2">
                <Button
                  variant="outline"
                  className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white"
                  onClick={(e) => handleTimeSet("8:00", e)}
                >
                  <Sunrise size={14} className="mr-2" />
                  {translation.setMorning || "Morning"}
                </Button>
                <Button
                  variant="outline"
                  className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white"
                  onClick={(e) => handleTimeSet("10:00", e)}
                >
                  <SunDim size={14} className="mr-2" />
                  {translation.setDay || "Day"}
                </Button>
                <Button
                  variant="outline"
                  className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white"
                  onClick={(e) => handleTimeSet("12:00", e)}
                >
                  <SunMedium size={14} className="mr-2" />
                  {translation.setNoon || "Noon"}
                </Button>
                <Button
                  variant="outline"
                  className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white"
                  onClick={(e) => handleTimeSet("14:00", e)}
                >
                  <Sun size={14} className="mr-2" />
                  {translation.setAfternoon || "Afternoon"}
                </Button>
                <Button
                  variant="outline"
                  className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white"
                  onClick={(e) => handleTimeSet("19:00", e)}
                >
                  <Sunset size={14} className="mr-2" />
                  {translation.setEvening || "Evening"}
                </Button>
                <Button
                  variant="outline"
                  className="bg-ui-layer/50 border-ui-border hover:bg-ui-layer text-white"
                  onClick={(e) => handleTimeSet("00:00", e)}
                >
                  <Moon size={14} className="mr-2" />
                  {translation.setNight || "Night"}
                </Button>
              </div>
              <div className="space-y-3 mt-4">
                <label className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted block">
                  {translation.tlCustomTime || "Custom Time"}
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <Input
                    type="number"
                    placeholder="HH"
                    className="bg-ui-layer/50 border-ui-border text-center text-white"
                    min="0"
                    max="23"
                    value={customTimeHours}
                    onChange={(e) => setCustomTimeHours(e.target.value)}
                  />
                  <Input
                    type="number"
                    placeholder="MM"
                    className="bg-ui-layer/50 border-ui-border text-center text-white"
                    min="0"
                    max="59"
                    value={customTimeMinutes}
                    onChange={(e) => setCustomTimeMinutes(e.target.value)}
                  />
                </div>
                <Button
                  className="w-full bg-ui-blue hover:bg-ui-blue/80 text-white"
                  onClick={handleCustomTimeSet}
                >
                  {translation.set || "Set Custom Time"}
                </Button>
              </div>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    );
  },
);

interface ToolsProps {
  vehicles: { name: string; label: string; brand?: string }[];
  items: { name: string; label: string; image?: string }[];
}

export default function Tools({ vehicles, items }: ToolsProps) {
  const translation = useTranslation();
  const staffMsgRef = useRef<HTMLInputElement>(null);

  const [godModeStatus, setGodModeStatus] = useState<boolean>(memories.godMode);
  const [vehicleGodModeStatus, setVehicleGodModeStatus] = useState<boolean>(
    memories.vehicleGodMode,
  );
  const [superJumpActivated, setSuperJumpActivated] = useState<boolean>(
    memories.superJump,
  );
  const [invisibility, setInvisibility] = useState<boolean>(
    memories.invisibility,
  );
  const [showCoordinates, setShowCoordinates] = useState<boolean>(
    memories.showCoordinates,
  );
  const [noclip, setNoclip] = useState<boolean>(memories.noclip);
  const [fastRun, setFastRun] = useState<boolean>(memories.fastRun);
  const [playerIds, setPlayerIds] = useState<boolean>(memories.playerIds);
  const [infiniteStamina, setInfiniteStamina] = useState<boolean>(
    memories.infiniteStamina,
  );

  const [timeAndWeatherModalOpen, setTimeAndWeatherModalOpen] =
    useState<boolean>(false);
  const [spawnVehModal, setSpawnVehModal] = useState<boolean>(false);
  const [moneyModal, setMoneyModal] = useState<boolean>(false);
  const [itemModal, setItemModal] = useState<boolean>(false);

  const [customTimeHours, setCustomTimeHours] = useState<string>("12");
  const [customTimeMinutes, setCustomTimeMinutes] = useState<string>("00");
  const [dynamicWater, setDynamicWater] = useState<boolean>(false);
  const [instantWeather, setInstantWeather] = useState<boolean>(false);
  const [tsunami, setTsunami] = useState<boolean>(false);
  const [blackout, setBlackout] = useState<boolean>(false);
  const [weatherTypeNow, setWeatherTypeNow] = useState<string>(
    memories.weatherTypeNow,
  );
  const [weatherDropdownOpen, setWeatherDropdownOpen] =
    useState<boolean>(false);

  const [vehicleModel, setVehicleModel] = useState("");
  const [moneyAmount, setMoneyAmount] = useState("");
  const [moneyAccount, setMoneyAccount] = useState("bank");
  const [itemName, setItemName] = useState("");
  const [itemAmount, setItemAmount] = useState("1");
  const [announcementType, setAnnouncementType] = useState("info");
  const [announcementNumber, setAnnouncementNumber] = useState("");
  const [announcementMsg, setAnnouncementMsg] = useState("");

  const weatherTypes = useMemo(
    () => [
      {
        value: "CLEAR",
        label: translation.clearWeather || "Clear",
        icon: <SunDim size={16} className="mr-2" />,
      },
      {
        value: "EXTRASUNNY",
        label: translation.extraSunny || "Extra sunny",
        icon: <Sun size={16} className="mr-2" />,
      },
      {
        value: "CLOUDS",
        label: translation.coulds || "Clouds",
        icon: <Cloud size={16} className="mr-2" />,
      },
      {
        value: "OVERCAST",
        label: translation.overcast || "Overcast",
        icon: <Cloud size={16} className="mr-2" />,
      },
      {
        value: "RAIN",
        label: translation.rain || "Rain",
        icon: <CloudRain size={16} className="mr-2" />,
      },
      {
        value: "CLEARING",
        label: translation.clearing || "Clearing",
        icon: <CloudHail size={16} className="mr-2" />,
      },
      {
        value: "THUNDER",
        label: translation.thunder || "Thunder",
        icon: <CloudLightning size={16} className="mr-2" />,
      },
      {
        value: "SMOG",
        label: translation.smog || "Smog",
        icon: <CloudFog size={16} className="mr-2" />,
      },
      {
        value: "FOGGY",
        label: translation.foggy || "Foggy",
        icon: <Haze size={16} className="mr-2" />,
      },
      {
        value: "XMAS",
        label: translation.xmas || "XMAS",
        icon: <MountainSnow size={16} className="mr-2" />,
      },
      {
        value: "SNOW",
        label: translation.snow || "Snow",
        icon: <Snowflake size={16} className="mr-2" />,
      },
      {
        value: "SNOWLIGHT",
        label: translation.snowlight || "Snowlight",
        icon: <SunSnow size={16} className="mr-2" />,
      },
      {
        value: "BLIZZARD",
        label: translation.blizzard || "Blizzard",
        icon: <CloudRainWind size={16} className="mr-2" />,
      },
      {
        value: "HALLOWEEN",
        label: translation.halloween || "Halloween",
        icon: <LightbulbOff size={16} className="mr-2" />,
      },
      {
        value: "NEUTRAL",
        label: translation.neutral || "Neutral",
        icon: <SunMedium size={16} className="mr-2" />,
      },
      {
        value: "RAIN_HALLOWEEN",
        label: translation.rain_halloween || "Halloween + Rain",
        icon: <CloudDrizzle size={16} className="mr-2" />,
      },
      {
        value: "SNOW_HALLOWEEN",
        label: translation.snow_halloween || "Halloween + Snow",
        icon: <CloudSnow size={16} className="mr-2" />,
      },
    ],
    [translation],
  );

  const container = useMemo(
    () => ({
      hidden: { opacity: 0 },
      show: { opacity: 1, transition: { staggerChildren: 0.05 } },
    }),
    [],
  );
  const item = useMemo(
    () => ({ hidden: { opacity: 0, y: 10 }, show: { opacity: 1, y: 0 } }),
    [],
  );

  useEffect(() => {
    memories = {
      godMode: godModeStatus,
      vehs: memories.vehs,
      superJump: superJumpActivated,
      invisibility,
      vehicleGodMode: vehicleGodModeStatus,
      weatherTypeNow,
      showCoordinates,
      noclip,
      fastRun,
      playerIds,
      infiniteStamina,
    };
  }, [
    godModeStatus,
    superJumpActivated,
    invisibility,
    vehicleGodModeStatus,
    weatherTypeNow,
    showCoordinates,
    noclip,
    fastRun,
    playerIds,
    infiniteStamina,
  ]);

  const toggleAction = useCallback(
    (state: boolean, setter: Function, nuiEvent: string, extraData = {}) => {
      const newState = !state;
      sendNui(nuiEvent, { state: newState, ...extraData }).then(
        (res) => res && setter(newState),
      );
    },
    [],
  );

  const handleAnnouncementSend = useCallback(() => {
    if (announcementMsg.length > 0) {
      sendNui("announcement", {
        msg: announcementMsg,
        type: announcementType,
        duration: announcementNumber,
      });
      setAnnouncementMsg("");
      setAnnouncementNumber("");
    }
  }, [announcementMsg, announcementType, announcementNumber]);

  const ButtonAction = ({
    icon: Icon,
    label,
    onClick,
    className = "",
  }: any) => (
    <button
      onClick={onClick}
      className={`h-14 px-4 rounded-xl border border-ui-border bg-gradient-to-r from-ui-layer/50 to-ui-layer hover:to-ui-layer/80 transition-all flex items-center gap-3 text-white text-left ${className}`}
    >
      <div className="w-8 h-8 rounded-lg bg-black/20 flex items-center justify-center">
        <Icon size={16} className="text-gray-300" />
      </div>
      <span className="font-bold text-sm">{label}</span>
    </button>
  );

  const PowerToggle = ({
    state,
    setter,
    event,
    extraData,
    icon: Icon,
    label,
    colorClass,
  }: any) => (
    <button
      onClick={() => toggleAction(state, setter, event, extraData)}
      className={`h-14 px-4 rounded-xl border transition-all flex items-center justify-between ${
        state
          ? `bg-${colorClass}/10 border-${colorClass}/50 `
          : "bg-ui-layer/50 border-ui-border hover:bg-ui-layer"
      }`}
    >
      <div className="flex items-center gap-3">
        <div
          className={`w-8 h-8 rounded-lg flex items-center justify-center ${state ? `bg-${colorClass} text-white` : "bg-black/20 text-gray-400"}`}
        >
          <Icon size={16} />
        </div>
        <span className="font-bold text-white text-sm">{label}</span>
      </div>
      <div
        className={`w-3 h-3 rounded-full ${state ? `bg-${colorClass} shadow-[0_0_10px_currentColor]` : "bg-gray-600"}`}
      />
    </button>
  );

  return (
    <motion.div
      initial="hidden"
      animate="show"
      variants={container}
      className="space-y-6 pb-10"
    >
      <motion.div variants={item}>
        <h1 className="text-2xl font-bold text-white flex items-center gap-2">
          <span className="w-8 h-8 rounded-lg bg-ui-amber/10 flex items-center justify-center ">
            <Settings size={16} className="text-ui-amber" />
          </span>
          Control Center
        </h1>
        <p className="text-gray-400 mt-1">
          Compact categorized tools and entity controls.
        </p>
      </motion.div>

      {}
      <motion.div variants={item}>
        <Card className="bg-ui-panel backdrop-blur-panel border-ui-border text-white overflow-hidden relative">
          <div className="absolute right-0 top-0 w-64 h-64 bg-ui-blue/5 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none" />
          <CardContent className="p-6 relative z-10">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-8 h-8 rounded-lg bg-ui-amber/10 flex items-center justify-center ">
                <Megaphone size={16} className="text-ui-amber" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-white">
                  {translation.tlServerAnnouncement || "Server Announcement"}
                </h3>
                <p className="text-[10px] text-ui-textMuted uppercase tracking-wider mt-0.5">
                  Send a live notice to all online players
                </p>
              </div>
            </div>

            <div className="flex flex-col md:flex-row gap-4 mb-4">
              <div className="w-full md:w-1/3">
                <label className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted block mb-2">
                  Notice Type
                </label>
                <Select
                  onValueChange={setAnnouncementType}
                  value={announcementType}
                >
                  <SelectTrigger className="bg-ui-layer/50 border-ui-border text-white h-11">
                    <SelectValue placeholder="Type" />
                  </SelectTrigger>
                  <SelectContent className="bg-ui-panel border-ui-border text-white">
                    <SelectItem value="info">Information</SelectItem>
                    <SelectItem value="warning">Warning</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="w-full md:w-2/3">
                <label className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted block mb-2">
                  Duration (ms)
                </label>
                <Input
                  type="number"
                  placeholder="Duration (optional)"
                  className="bg-ui-layer/50 border-ui-border text-white h-11"
                  value={announcementNumber}
                  onChange={(e) => setAnnouncementNumber(e.target.value)}
                  max={100000}
                  min={0}
                />
              </div>
            </div>

            <div className="mb-4">
              <label className="text-[10px] font-bold uppercase tracking-wider text-ui-textMuted block mb-2">
                Announcement Message
              </label>
              <textarea
                className="w-full bg-ui-layer/50 border border-ui-border rounded-lg text-white p-3 focus:outline-none focus:ring-1 focus:ring-ui-amber/50 min-h-[80px] resize-none"
                placeholder="Type your clear message here..."
                value={announcementMsg}
                onChange={(e) => setAnnouncementMsg(e.target.value)}
              />
            </div>

            <div className="flex justify-end">
              <Button
                className="bg-ui-amber hover:bg-ui-amber/80 text-white h-10 px-6"
                onClick={handleAnnouncementSend}
              >
                <Megaphone size={14} className="mr-2" /> Send Announcement
              </Button>
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {}
      <Tabs defaultValue="powers" className="w-full">
        <TabsList className="bg-ui-layer/50 border border-ui-border p-1 rounded-xl h-auto flex flex-wrap justify-start gap-1 mb-6">
          <TabsTrigger
            value="powers"
            className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange data-[state=active]:shadow-ui-soft py-2 px-4 transition-all"
          >
            <Shield size={16} />{" "}
            <span className="font-medium text-sm">Powers</span>
          </TabsTrigger>
          <TabsTrigger
            value="health"
            className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange data-[state=active]:shadow-ui-soft py-2 px-4 transition-all"
          >
            <Heart size={16} />{" "}
            <span className="font-medium text-sm">Health</span>
          </TabsTrigger>
          <TabsTrigger
            value="vehicle"
            className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange data-[state=active]:shadow-ui-soft py-2 px-4 transition-all"
          >
            <Car size={16} />{" "}
            <span className="font-medium text-sm">Vehicle</span>
          </TabsTrigger>
          <TabsTrigger
            value="appearance"
            className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange data-[state=active]:shadow-ui-soft py-2 px-4 transition-all"
          >
            <User size={16} />{" "}
            <span className="font-medium text-sm">Appearance</span>
          </TabsTrigger>
          <TabsTrigger
            value="economy"
            className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange data-[state=active]:shadow-ui-soft py-2 px-4 transition-all"
          >
            <Wallet size={16} />{" "}
            <span className="font-medium text-sm">Economy</span>
          </TabsTrigger>
          <TabsTrigger
            value="world"
            className="flex items-center gap-2 rounded-lg data-[state=active]:bg-ui-panel data-[state=active]:text-ui-orange data-[state=active]:shadow-ui-soft py-2 px-4 transition-all"
          >
            <Globe size={16} />{" "}
            <span className="font-medium text-sm">World & Utility</span>
          </TabsTrigger>
        </TabsList>

        <div className="bg-ui-panel backdrop-blur-panel border-ui-border border rounded-xl p-6">
          {}
          <TabsContent
            value="powers"
            className="mt-0 focus-visible:outline-none space-y-4"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
              <PowerToggle
                state={godModeStatus}
                setter={setGodModeStatus}
                event="godMode"
                icon={Shield}
                label="Godmode"
                colorClass="ui-violet"
              />
              <PowerToggle
                state={noclip}
                setter={setNoclip}
                event="noclip"
                icon={Navigation}
                label="Noclip"
                colorClass="ui-blue"
              />
              <PowerToggle
                state={invisibility}
                setter={setInvisibility}
                event="invisibility"
                icon={Sparkles}
                label="Invisibility"
                colorClass="ui-blue"
              />
              <PowerToggle
                state={superJumpActivated}
                setter={setSuperJumpActivated}
                event="superJump"
                icon={Zap}
                label="Super Jump"
                colorClass="ui-amber"
              />
              <PowerToggle
                state={fastRun}
                setter={setFastRun}
                event="fastRun"
                icon={FastForward}
                label="Fast Run"
                colorClass="ui-amber"
              />
              <PowerToggle
                state={infiniteStamina}
                setter={setInfiniteStamina}
                event="infiniteStamina"
                icon={Activity}
                label="Infinite Stamina"
                colorClass="ui-success"
              />
              <PowerToggle
                state={playerIds}
                setter={setPlayerIds}
                event="playerIds"
                icon={Eye}
                label="Player IDs"
                colorClass="ui-success"
              />
            </div>
          </TabsContent>

          {}
          <TabsContent
            value="health"
            className="mt-0 focus-visible:outline-none space-y-4"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
              <ButtonAction
                icon={Heart}
                label="Revive Self"
                onClick={() => sendNui("healSelf")}
              />
              <ButtonAction
                icon={Heart}
                label="Revive All"
                onClick={() => sendNui("allAction", { type: "revive" })}
              />
              <ButtonAction
                icon={Activity}
                label="Heal Self"
                onClick={() => sendNui("healSelf")}
              />
              <ButtonAction
                icon={Activity}
                label="Heal All"
                onClick={() => sendNui("allAction", { type: "heal" })}
              />
            </div>
          </TabsContent>

          {}
          <TabsContent
            value="vehicle"
            className="mt-0 focus-visible:outline-none space-y-4"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
              <PowerToggle
                state={vehicleGodModeStatus}
                setter={setVehicleGodModeStatus}
                event="godMode"
                extraData={{ type: "vehicle" }}
                icon={Shield}
                label="Vehicle Godmode"
                colorClass="ui-violet"
              />
              <ButtonAction
                icon={Car}
                label="Spawn Vehicle"
                onClick={() => setSpawnVehModal(true)}
              />
              <ButtonAction
                icon={Wrench}
                label="Repair Vehicle"
                onClick={() => sendNui("repairVehicle")}
              />
              <ButtonAction
                icon={RotateCw}
                label="Flip Vehicle"
                onClick={() => sendNui("flipVehicle")}
              />
              <ButtonAction
                icon={Zap}
                label="Upgrade Vehicle"
                onClick={() => sendNui("upgradeVehicle")}
              />
              <ButtonAction
                icon={Trash2}
                label="Delete Vehicle"
                onClick={() => sendNui("deleteObjects", { type: "vehicles" })}
              />
            </div>
          </TabsContent>

          {}
          <TabsContent
            value="appearance"
            className="mt-0 focus-visible:outline-none space-y-4"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
              <ButtonAction
                icon={User}
                label="Change Skin"
                onClick={() => sendNui("changeSkin")}
              />
              <ButtonAction
                icon={Shirt}
                label="Clothing Menu"
                onClick={() => sendNui("clothingMenu")}
              />
            </div>
          </TabsContent>

          {}
          <TabsContent
            value="economy"
            className="mt-0 focus-visible:outline-none space-y-4"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
              <ButtonAction
                icon={Wallet}
                label="Give Self Money"
                onClick={() => setMoneyModal(true)}
              />
              <ButtonAction
                icon={Gift}
                label="Give Self Item"
                onClick={() => setItemModal(true)}
              />
              <ButtonAction
                icon={Trash2}
                label="Clear Inventory"
                onClick={() => sendNui("clearInventory")}
              />
            </div>
          </TabsContent>

          {}
          <TabsContent
            value="world"
            className="mt-0 focus-visible:outline-none space-y-4"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
              <ButtonAction
                icon={Cloud}
                label="Weather & Time"
                onClick={() => setTimeAndWeatherModalOpen(true)}
              />
              <ButtonAction
                icon={MapPin}
                label="Teleport To Waypoint"
                onClick={() => sendNui("tpm")}
              />
              <PowerToggle
                state={showCoordinates}
                setter={setShowCoordinates}
                event="changeCoordsShowStatus"
                icon={Crosshair}
                label="Coordinates"
                colorClass="ui-amber"
              />

              <ButtonAction
                icon={Users}
                label="Delete All Peds"
                onClick={() => sendNui("deleteObjects", { type: "peds" })}
              />
              <ButtonAction
                icon={Box}
                label="Delete All Objects"
                onClick={() => sendNui("deleteObjects", { type: "objects" })}
              />
              <ButtonAction
                icon={Users}
                label="Bring All"
                onClick={() => sendNui("allAction", { type: "bring" })}
              />
              <ButtonAction
                icon={Ban}
                label="Kick All"
                onClick={() => sendNui("allAction", { type: "kick" })}
              />
            </div>

            <div className="mt-6 pt-4 border-t border-ui-border/50">
              <label className="text-xs font-bold text-white block mb-2">
                Staff Communications
              </label>
              <div className="flex gap-2 mb-2">
                <Input
                  placeholder="Message to staff..."
                  className="bg-ui-layer/50 border-ui-border text-white h-10"
                  ref={staffMsgRef}
                />
              </div>
              <div className="grid grid-cols-2 gap-2 max-w-sm">
                <Button
                  className="bg-ui-layer hover:bg-ui-layer/80 border border-ui-border text-xs text-white"
                  onClick={() =>
                    staffMsgRef.current &&
                    sendNui("sendStaffMsg", {
                      type: 1,
                      msg: staffMsgRef.current.value,
                    })
                  }
                >
                  All Staff
                </Button>
                <Button
                  className="bg-ui-layer hover:bg-ui-layer/80 border border-ui-border text-xs text-white"
                  onClick={() =>
                    staffMsgRef.current &&
                    sendNui("sendStaffMsg", {
                      type: 2,
                      msg: staffMsgRef.current.value,
                    })
                  }
                >
                  Online Staff
                </Button>
              </div>
            </div>
          </TabsContent>
        </div>
      </Tabs>

      {}
      <TimeAndWeatherModal
        isOpen={timeAndWeatherModalOpen}
        onOpenChange={setTimeAndWeatherModalOpen}
        translation={translation}
        weatherTypes={weatherTypes}
        weatherTypeNow={weatherTypeNow}
        weatherDropdownOpen={weatherDropdownOpen}
        setWeatherDropdownOpen={setWeatherDropdownOpen}
        setWeatherTypeNow={setWeatherTypeNow}
        customTimeHours={customTimeHours}
        setCustomTimeHours={setCustomTimeHours}
        customTimeMinutes={customTimeMinutes}
        setCustomTimeMinutes={setCustomTimeMinutes}
        dynamicWater={dynamicWater}
        setDynamicWater={setDynamicWater}
        instantWeather={instantWeather}
        setInstantWeather={setInstantWeather}
        tsunami={tsunami}
        setTsunami={setTsunami}
        blackout={blackout}
        setBlackout={setBlackout}
      />

      {spawnVehModal && (
        <SpawnVehicleModal
          vehicles={vehicles}
          translation={translation}
          onClose={() => setSpawnVehModal(false)}
        />
      )}

      <Dialog open={moneyModal} onOpenChange={setMoneyModal}>
        <DialogContent className="bg-ui-layer border-ui-border text-white max-w-md">
          <DialogHeader>
            <DialogTitle>Give Money</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div>
              <label className="text-xs font-bold text-ui-textMuted uppercase mb-2 block">
                Account Type
              </label>
              <Select value={moneyAccount} onValueChange={setMoneyAccount}>
                <SelectTrigger className="bg-ui-layer/50 border-ui-border text-white">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-ui-panel border-ui-border text-white">
                  <SelectItem value="bank">Bank</SelectItem>
                  <SelectItem value="cash">Cash</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div>
              <label className="text-xs font-bold text-ui-textMuted uppercase mb-2 block">
                Amount
              </label>
              <Input
                type="number"
                placeholder="1000"
                value={moneyAmount}
                onChange={(e) => setMoneyAmount(e.target.value)}
                className="bg-ui-layer/50 border-ui-border text-white"
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              onClick={() => {
                setMoneyModal(false);
                sendNui("giveMoney", {
                  account: moneyAccount,
                  amount: moneyAmount,
                });
              }}
              className="bg-ui-success hover:bg-ui-success/80 text-white"
            >
              Give Money
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {itemModal && (
        <GiveItemModal
          items={items}
          translation={translation}
          onClose={() => setItemModal(false)}
        />
      )}
    </motion.div>
  );
}
