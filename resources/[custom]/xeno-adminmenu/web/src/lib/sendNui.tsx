const resourceName = (window as any).GetParentResourceName
  ? (window as any).GetParentResourceName()
  : "xeno-adminmenu";

type NuiResponse = {
  status: "ok" | "error";
  message?: string;
  [key: string]: any;
};

export const sendNui = async (
  action: string,
  data: Record<string, any> = {},
): Promise<any | NuiResponse | null> => {
  try {
    const res = await fetch(`https://${resourceName}/${action}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    });

    if (!res.ok) {
      console.error(` HTTP ${res.status} on ${action}`);
      return { status: "error", message: `HTTP ${res.status}` };
    }

    return await res.json();
  } catch (error) {
    return { status: "error", message: "Fetch exception" };
  }
};
