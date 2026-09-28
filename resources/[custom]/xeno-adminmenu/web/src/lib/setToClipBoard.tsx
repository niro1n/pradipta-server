export const copyToClipboard = async (text: string) => {
  try {
    const input = document.createElement("textarea");
    input.innerHTML = text;
    document.body.appendChild(input);
    input.select();
    document.execCommand("copy");
    document.body.removeChild(input);
    return true;
  } catch (error) {
    console.error("Copy to clipboard failed:", error);
    return false;
  }
};
