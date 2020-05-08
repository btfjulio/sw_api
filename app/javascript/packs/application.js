import "bootstrap";
import $ from "jquery";
import "select2/dist/css/select2.css";
import "select2";
import "animate.css";

const refreshStatus = () => {
  let list = document.querySelectorAll(".saudi_choice");
  list.forEach((dropdown) => {
    dropdown.addEventListener("change", (e) => {
      e.currentTarget.closest("form").submit();
    });
  });
};

const initSelect2 = (tag) => {
  $(tag).select2({
    placeholder: "Selecione os filtros..",
    width: "160px",
  }); // (~ document.querySelectorAll)
};

document.querySelectorAll('.select2').forEach(initSelect2)



refreshStatus();
