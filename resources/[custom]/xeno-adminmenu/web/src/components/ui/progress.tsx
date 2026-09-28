import * as React from "react";
import * as ProgressPrimitive from "@radix-ui/react-progress";

import { cn } from "../../lib/utils";

interface ProgressProps extends React.ComponentPropsWithoutRef<
  typeof ProgressPrimitive.Root
> {
  indicatorClassName?: string | string[];
}

const getColor = function (width: any, colors: any) {
  if (typeof colors !== "object" || !Array.isArray(colors)) return;

  if (width <= 33) {
    return colors[1];
  } else if (width > 33 && width <= 66) {
    return colors[2];
  } else if (width > 66) {
    return colors[3];
  }
};

const Progress = React.forwardRef<
  React.ElementRef<typeof ProgressPrimitive.Root>,
  ProgressProps
>(({ className, value = 0, indicatorClassName, ...props }, ref) => (
  <ProgressPrimitive.Root
    ref={ref}
    className={cn(
      "relative h-2 w-full overflow-hidden rounded-full bg-primary/20",
      className,
    )}
    {...props}
  >
    <ProgressPrimitive.Indicator
      className={cn(
        "h-full w-full flex-1 bg-primary transition-all",
        typeof indicatorClassName === "string"
          ? indicatorClassName
          : indicatorClassName
            ? [0]
            : "",
        typeof indicatorClassName === "object"
          ? getColor(value, indicatorClassName)
          : "",
      )}
      style={{ width: `${value}%` }}
    />
  </ProgressPrimitive.Root>
));

Progress.displayName = ProgressPrimitive.Root.displayName;

export { Progress };
