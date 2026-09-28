export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        border: "oklch(var(--border) / <alpha-value>)",
        background: "oklch(var(--background) / <alpha-value>)",
        foreground: "oklch(var(--foreground) / <alpha-value>)",
        ring: "oklch(var(--ring) / <alpha-value>)",
        ui: {
          bg: "#07080a",
          panel: "rgba(17, 19, 24, 0.94)",
          layer: "rgba(255, 255, 255, 0.035)",
          border: "rgba(255, 255, 255, 0.08)",
          textMuted: "#9aa0a6",
          gold: "#d4af37",
          goldHover: "#e2c158",
          orange: "#d4af37",
          orangeBright: "#e2c158",
          success: "#10b981",
          info: "#38bdf8",
          danger: "#ef4444",
          violet: "#d4af37",
          blue: "#3b82f6",
          amber: "#f59e0b",
          pink: "#ec4899",
          yellow: "#eab308",
        },
      },
      boxShadow: {
        "ui-soft": "0 12px 36px rgba(0,0,0,0.5)",
        "ui-glow": "0 0 18px rgba(212, 175, 55, 0.35)",
      },
      borderRadius: {
        "panel-xl": "8px",
        "card": "6px",
        "badge": "4px",
      },
      backdropBlur: {
        panel: "12px",
      },
      keyframes: {
        pulseDot: {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: ".4" },
        },
      },
      animation: {
        pulseDot: "pulseDot 1.8s ease-in-out infinite",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};
