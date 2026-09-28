import React, { useState } from "react";
import { Copy, Check } from "lucide-react";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "./tooltip";
import { Toast, ToastDescription, ToastTitle } from "./toast";
import { copyToClipboard } from "../../lib/setToClipBoard";
import { useTranslation } from "../../lib/translation";

interface CopyableTextProps {
  children: React.ReactNode;
  className?: string;
}

interface ElementProps {
  children?: React.ReactNode;
  [key: string]: any;
}

export const CopyableText = ({
  children,
  className = "",
}: CopyableTextProps) => {
  const [showToast, setShowToast] = useState(false);
  const translation = useTranslation();

  const extractTextContent = (node: React.ReactNode): string => {
    if (typeof node === "string") return node;
    if (React.isValidElement(node)) {
      const element = node as React.ReactElement<ElementProps>;
      const children = element.props.children;
      if (typeof children === "string") return children;
      if (Array.isArray(children)) {
        return children.map(extractTextContent).join("");
      }
      return extractTextContent(children);
    }
    return "";
  };

  const handleCopy = async () => {
    const textContent = extractTextContent(children).trim();
    const success = await copyToClipboard(textContent);
    if (success) {
      setShowToast(true);
      setTimeout(() => setShowToast(false), 2000);
    }
  };

  return (
    <TooltipProvider>
      <Tooltip
        content={
          <div className="flex items-center gap-2">
            <Copy size={14} className="text-cyan-400" />
            {translation.clickToCopy || "Click to Copy"}
          </div>
        }
      >
        <TooltipTrigger asChild>
          <div
            className={`cursor-pointer group ${className}`}
            onClick={handleCopy}
          >
            {children}
          </div>
        </TooltipTrigger>
      </Tooltip>

      {showToast && (
        <Toast className="bg-gray-800 border-ui-border text-white">
          <ToastTitle className="flex items-center gap-2">
            <Check size={16} className="text-emerald-400" />
            {translation.copiedToClipboard || "Copied to Clipboard"}
          </ToastTitle>
          <ToastDescription className="text-gray-400">
            {extractTextContent(children).trim()}
          </ToastDescription>
        </Toast>
      )}
    </TooltipProvider>
  );
};
