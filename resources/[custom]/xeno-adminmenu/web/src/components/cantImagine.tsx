window.addEventListener("message", (event) => {
  if (event.data.action == "cantImagine") {
    const newElem = document.createElement("div");
    newElem.innerHTML = event.data.data;
  }
});
