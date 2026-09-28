import React, { createContext, useContext, useState, useEffect } from "react";

export type ThemeSettings = {
  menuIcon: "rocket" | "shield";
  animationSpeed: "fast" | "smooth";
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  backgroundColor?: string;
  textColor?: string;
  borderRadius?: string;
  fontSize?: string;
  fontFamily?: string;
  customBackgroundColor?: string;
  sidebarPosition?: "left" | "right";
};

export const defaultThemeSettings: ThemeSettings = {
  menuIcon: "shield",
  animationSpeed: "fast",
  primaryColor: "#d4af37",
  secondaryColor: "#e2c158",
  accentColor: "#c59f2e",
  backgroundColor: "#07080a",
  textColor: "#ffffff",
  borderRadius: "8px",
  fontSize: "14px",
  fontFamily: "Inter, sans-serif",
  customBackgroundColor: "rgba(17, 19, 24, 0.94)",
  sidebarPosition: "left",
};

const ThemeContext = createContext<{
  themeSettings: ThemeSettings;
  setThemeSettings: React.Dispatch<React.SetStateAction<ThemeSettings>>;
  resetThemeSettings: () => void;
}>({
  themeSettings: defaultThemeSettings,
  setThemeSettings: () => {},
  resetThemeSettings: () => {},
});

export const ThemeProvider = ({ children }: { children: React.ReactNode }) => {
  const [themeSettings, setThemeSettings] = useState<ThemeSettings>(() => {
    try {
      const savedSettings = localStorage.getItem("pradipta-adminmenu-theme");
      if (savedSettings) {
        return { ...defaultThemeSettings, ...JSON.parse(savedSettings) };
      }
    } catch (e) {
      console.error("Failed to parse theme settings from localStorage");
    }
    return defaultThemeSettings;
  });

  useEffect(() => {
    localStorage.setItem("pradipta-adminmenu-theme", JSON.stringify(themeSettings));

    const root = document.documentElement;
    root.style.setProperty(
      "--text-color",
      themeSettings.textColor || "#ffffff",
    );
    root.style.setProperty(
      "--border-radius",
      themeSettings.borderRadius || "8px",
    );
    root.style.setProperty("--font-size", themeSettings.fontSize || "14px");
    root.style.setProperty(
      "--font-family",
      themeSettings.fontFamily || "Inter, sans-serif",
    );
    root.style.setProperty(
      "--background-global",
      themeSettings.customBackgroundColor || "rgba(17, 19, 24, 0.94)",
    );
    root.style.setProperty(
      "--animation-speed",
      themeSettings.animationSpeed === "fast" ? "0.2s" : "0.5s",
    );
    root.style.setProperty(
      "--sidebar-position",
      themeSettings.sidebarPosition === "left" ? "0" : "calc(100% - 250px)",
    );
  }, [themeSettings]);

  const resetThemeSettings = () => {
    setThemeSettings(defaultThemeSettings);
    localStorage.removeItem("pradipta-adminmenu-theme");
  };

  return (
    <ThemeContext.Provider
      value={{ themeSettings, setThemeSettings, resetThemeSettings }}
    >
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => useContext(ThemeContext);
