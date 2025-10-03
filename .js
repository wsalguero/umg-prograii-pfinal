document.getElementById("btn-cf").addEventListener("click", function (el) {
  el.preventDefault();

  const input = document.getElementById("inp-nit");

  if (input.value === "CF") {
    input.removeAttribute("disabled");
    input.value = "";

    return;
  } else {
    input.setAttribute("disabled", "true");
    input.value = "CF";

    return;
  }
});
