import { useState } from "react";
import { useTranslation } from "../../lib/translation";

interface SeeMoreProps {
  text: string;
  maxLength?: number;
  className?: string;
  showHeader?: boolean;
  headerTitle?: string;
}

export function SeeMore({
  text,
  maxLength = 14,
  className = "",
  showHeader = false,
  headerTitle = "Ban Reason",
}: SeeMoreProps) {
  const [isExpanded, setIsExpanded] = useState(false);
  const translation = useTranslation();

  if (text.length <= maxLength) {
    return <span className={className}>{text}</span>;
  }

  const truncatedText = text.substring(0, maxLength) + "...";
  return (
    <div className="inline-block">
      <div className="flex items-start gap-2">
        <span
          className={`${className} ${(!isExpanded && "select-none") || "select-text"} ${isExpanded ? "whitespace-pre-wrap break-words" : ""} max-w-xs cursor-pointer transition-colors duration-200 ${!isExpanded ? "hover:bg-purple-900/10" : ""}`}
          onClick={() => {
            if (
              !window.getSelection() ||
              window.getSelection()?.toString() === "" ||
              !text.includes(
                (window.getSelection() as any).toString() ||
                  "23543759743674765746798547t784yhgfdbgvfdjnkb547878459y678457694567t478tgfbkl-",
              )
            )
              setIsExpanded(!isExpanded);
          }}
          title={
            isExpanded
              ? translation["seeLess"] || "See less"
              : translation.seeMore || "See more"
          }
        >
          {isExpanded ? text : truncatedText}
        </span>
      </div>
    </div>
  );
}
