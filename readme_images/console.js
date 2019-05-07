document.addEventListener("DOMContentLoaded", function() {
  document.querySelector("button").addEventListener("click", function() {
    html2canvas(document.querySelector("pre")).then(canvas => {
      window.open(canvas.toDataURL());
    });
  });
});
