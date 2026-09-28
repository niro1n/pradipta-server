import * as React from "react";
import { cn } from "../../lib/utils";

type TooltipProps = {
  children: React.ReactNode;
  content: React.ReactNode;
  delay?: number;
  side?: "top" | "right" | "bottom" | "left";
  className?: string;
  contentClassName?: string;
};

const TooltipContext = React.createContext<{
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
} | null>(null);

const TooltipProvider = ({ children }: { children: React.ReactNode }) => {
  const [open, setOpen] = React.useState(false);
  return (
    <TooltipContext.Provider value={{ open, setOpen }}>
      {children}
    </TooltipContext.Provider>
  );
};

const useTooltip = () => {
  const context = React.useContext(TooltipContext);
  if (!context) {
    throw new Error("useTooltip must be used within a TooltipProvider");
  }
  return context;
};

const Tooltip = ({
  children,
  content,
  delay = 300,
  side = "top",
  className,
  contentClassName,
}: TooltipProps) => {
  const [isOpen, setIsOpen] = React.useState(false);
  const timeoutRef = React.useRef<ReturnType<typeof setTimeout>>(undefined);
  const tooltipRef = React.useRef<HTMLDivElement>(null);

  const showTooltip = () => {
    timeoutRef.current = setTimeout(() => setIsOpen(true), delay);
  };

  const hideTooltip = () => {
    clearTimeout(timeoutRef.current);
    setIsOpen(false);
  };

  React.useEffect(() => {
    return () => {
      clearTimeout(timeoutRef.current);
    };
  }, []);

  React.useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        tooltipRef.current &&
        !tooltipRef.current.contains(event.target as Node)
      ) {
        hideTooltip();
      }
    };

    if (isOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [isOpen]);

  const positionClasses = {
    top: "bottom-full left-1/2 transform -translate-x-1/2 mb-2",
    right: "left-full top-1/2 transform -translate-y-1/2 ml-2",
    bottom: "top-full left-1/2 transform -translate-x-1/2 mt-2",
    left: "right-full top-1/2 transform -translate-y-1/2 mr-2",
  };

  return (
    <div
      className={cn("relative inline-block", className)}
      onMouseEnter={showTooltip}
      onMouseLeave={hideTooltip}
      onClick={(e) => {
        e.stopPropagation();
        setIsOpen(!isOpen);
      }}
    >
      {children}
      {isOpen && (
        <div
          ref={tooltipRef}
          className={cn(
            "absolute z-50 min-w-max rounded-md border border-ui-border bg-gray-800 px-3 py-1.5 text-sm text-gray-200 shadow-md animate-in fade-in-0 zoom-in-95",
            positionClasses[side],
            contentClassName,
          )}
        >
          {content}
          <div
            className={`absolute w-2 h-2 bg-gray-800 transform rotate-45 border-r border-b border-ui-border ${
              {
                top: "bottom-[-4px] left-1/2 -translate-x-1/2",
                right: "left-[-4px] top-1/2 -translate-y-1/2",
                bottom: "top-[-4px] left-1/2 -translate-x-1/2",
                left: "right-[-4px] top-1/2 -translate-y-1/2",
              }[side]
            }`}
          />
        </div>
      )}
    </div>
  );
};

const TooltipTrigger = ({
  children,
  asChild = false,
  ...props
}: {
  children: React.ReactNode;
  asChild?: boolean;
} & React.HTMLAttributes<HTMLElement>) => {
  if (asChild) {
    return React.cloneElement(children as React.ReactElement, {
      ...props,
    });
  }
  return <span {...props}>{children}</span>;
};

const TooltipContent = ({
  children,
  className,
  ...props
}: {
  children: React.ReactNode;
  className?: string;
} & React.HTMLAttributes<HTMLDivElement>) => {
  return (
    <div
      className={cn(
        "z-50 min-w-max rounded-md border border-ui-border bg-gray-800 px-3 py-1.5 text-sm text-gray-200 shadow-md",
        className,
      )}
      {...props}
    >
      {children}
    </div>
  );
};

export { Tooltip, TooltipTrigger, TooltipContent, TooltipProvider };
