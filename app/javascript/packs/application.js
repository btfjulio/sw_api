import "bootstrap";
import $ from "jquery";
import "select2";
import 'animate.css';

const refreshStatus = () => {
  let list = document.querySelectorAll(".saudi_choice");
  list.forEach(dropdown => {
    dropdown.addEventListener("change", e => {
      e.currentTarget.closest("form").submit();
    });
  });
};


const initSelect2 = () => {
  $(".select2").select2({
    placeholder: "Select filters"
  }); // (~ document.querySelectorAll)
};

initSelect2();

refreshStatus();