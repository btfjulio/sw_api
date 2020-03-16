import "bootstrap";
import 'animate.css';

const refreshStatus = () => {
  let list = document.querySelectorAll(".saudi_choice");
  list.forEach(dropdown => {
    dropdown.addEventListener("change", e => {
      e.currentTarget.closest("form").submit();
    });
  });
};

refreshStatus();