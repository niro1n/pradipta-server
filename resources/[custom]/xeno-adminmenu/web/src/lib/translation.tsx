import React from "react";
import { createContext, useContext, useState, useEffect } from "react";

const TranslationContext = createContext<Record<string, string>>({});

import { sendNui } from "./sendNui";

export const TranslationProvider = ({
  children,
}: {
  children: React.ReactNode;
}) => {
  const [translation, setTranslation] = useState<Record<string, string>>({});

  useEffect(() => {
    const loadTranslation = async () => {
      try {
        const data = await sendNui<Record<string, string>>("getTranslations");
        if (data) {
          setTranslation(data);
        }
      } catch (error) {
        console.error("Error loading translation from NUI:", error);
      }
    };

    loadTranslation();
  }, []);

  return (
    <TranslationContext.Provider value={translation}>
      {children}
    </TranslationContext.Provider>
  );
};

export const useTranslation = () => {
  return useContext(TranslationContext);
};
