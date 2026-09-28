import React from "react";
import ReactDOM from "react-dom/client";
import AdminPanel from "./components/admin-panel";
import Warn from "./components/warn";
import Announcement from "./components/announcement";
import ReportApp from "./components/report-app";
import Coordinates from "./components/coordinates";
import { ThemeProvider } from "./hooks/ThemeContext";
import "./index.css";

import { TranslationProvider } from "./lib/translation";

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <TranslationProvider>
      <ThemeProvider>
        <AdminPanel />
        <Warn />
        <Announcement />
        <ReportApp />
        <Coordinates />
      </ThemeProvider>
    </TranslationProvider>
  </React.StrictMode>,
);
