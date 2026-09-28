const observer = new MutationObserver(() => {
  const inputs: HTMLInputElement[] = document.querySelectorAll(
    "input[type='number']",
  ) as any;
  if (typeof inputs === "object" && inputs.length > 0) {
    inputs.forEach((currInput) => {
      currInput.max = String(Number(currInput.max) + 1);

      currInput.addEventListener("keydown", (e) => {
        const min = Number(currInput.min);
        const max = Number(currInput.max) - 1;
        let value = Number(currInput.value);

        if (e.key === "ArrowUp") {
          e.preventDefault();
          value = value >= max ? min : value + 1;
          currInput.value = String(value);
        }

        if (e.key === "ArrowDown") {
          e.preventDefault();
          value = value <= min ? max : value - 1;
          currInput.value = String(value);
        }
      });

      currInput.addEventListener("input", () => {
        const min = Number(currInput.min);
        const max = Number(currInput.max) - 1;
        let value = Number(currInput.value);
        if (value > max) {
          currInput.value = String(min);
        } else if (value < min) {
          currInput.value = String(max);
        }
      });
    });
  }
});

observer.observe(document.body, {
  childList: true,
  subtree: true,
});
