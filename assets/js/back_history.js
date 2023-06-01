export default {
    mounted() {
      document.getElementById("back_history_button").addEventListener(
        "click",
        function () {
          window.history.back();
        }
      );
    },
  };