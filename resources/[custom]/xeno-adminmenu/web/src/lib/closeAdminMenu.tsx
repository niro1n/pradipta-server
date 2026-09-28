import { sendNui } from "../lib/sendNui.tsx";

export const closeAdminMenu = (setIsVisible: Function) => {
  sendNui("setStatus", { status: false });
  setIsVisible(false);
};
