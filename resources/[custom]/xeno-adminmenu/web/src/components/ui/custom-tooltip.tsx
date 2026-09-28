import React, { useState, useRef, useEffect } from "react";
import { cn } from "../../lib/utils";

interface CustomTooltipProps {
  children: React.ReactNode;
  content: React.ReactNode;
  className?: string;
  side?: "top" | "bottom" | "left" | "right";
}

export function CustomTooltip({
  children,
  content,
  className,
  side = "top",
}: CustomTooltipProps) {
  const [isVisible, setIsVisible] = useState(false);
  const tooltipRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLDivElement>(null);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  const handleMouseEnter = () => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
    setIsVisible(true);
  };

  const handleMouseLeave = () => {
    timeoutRef.current = setTimeout(() => {
      setIsVisible(false);
    }, 100);
  };

  const getPositionStyles = () => {
    switch (side) {
      case "top":
        return {
          tooltip: {
            bottom: "100%",
            left: "50%",
            transform: "translateX(-50%) translateY(-8px)",
          },
          arrow: {
            bottom: "-6px",
            left: "50%",
            transform: "translateX(-50%) rotate(45deg)",
            borderTop: "1px solid rgba(75, 85, 99, 0.4)",
            borderLeft: "1px solid rgba(75, 85, 99, 0.4)",
          },
        };
      case "bottom":
        return {
          tooltip: {
            top: "100%",
            left: "50%",
            transform: "translateX(-50%) translateY(8px)",
          },
          arrow: {
            top: "-6px",
            left: "50%",
            transform: "translateX(-50%) rotate(45deg)",
            borderBottom: "1px solid rgba(75, 85, 99, 0.4)",
            borderRight: "1px solid rgba(75, 85, 99, 0.4)",
          },
        };
      case "left":
        return {
          tooltip: {
            right: "100%",
            top: "50%",
            transform: "translateY(-50%) translateX(-8px)",
          },
          arrow: {
            right: "-6px",
            top: "50%",
            transform: "translateY(-50%) rotate(45deg)",
            borderBottom: "1px solid rgba(75, 85, 99, 0.4)",
            borderLeft: "1px solid rgba(75, 85, 99, 0.4)",
          },
        };
      case "right":
        return {
          tooltip: {
            left: "100%",
            top: "50%",
            transform: "translateY(-50%) translateX(8px)",
          },
          arrow: {
            left: "-6px",
            top: "50%",
            transform: "translateY(-50%) rotate(45deg)",
            borderTop: "1px solid rgba(75, 85, 99, 0.4)",
            borderRight: "1px solid rgba(75, 85, 99, 0.4)",
          },
        };
    }
  };

  const positionStyles = getPositionStyles();

  return (
    <div
      className="relative inline-block"
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      ref={triggerRef}
    >
      {children}
      <div
        ref={tooltipRef}
        className={cn(
          "absolute z-50 px-3 py-1.5 text-sm rounded-md",
          "bg-gray-800/95 backdrop-blur-sm text-white",
          "border border-ui-border/50 shadow-lg",
          "transition-all duration-200 ease-out",
          "whitespace-nowrap",
          isVisible
            ? "opacity-100 scale-100"
            : "opacity-0 scale-95 pointer-events-none",
          className,
        )}
        style={positionStyles.tooltip}
      >
        <div className="relative z-10">{content}</div>
        <div
          className="absolute w-2 h-2 bg-gray-800/95 backdrop-blur-sm"
          style={positionStyles.arrow}
        />
      </div>
    </div>
  );
}
