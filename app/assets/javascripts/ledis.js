$(document).on("turbolinks:load", () => {
    function focus_input(){
        $("#terminal").focus().val(">");
    }
    function updateScroll(){
        let result = $("#result");
        console.log(result.scrollTop() + " " + result[0].scrollHeight);
        result.scrollTop(result[0].scrollHeight);// - result[0].clientHeight);
    }
    //Display result
    function display(input, is_result = false) {
        let result = $("#result");
        if (!is_result){
            result.append("<div class='input'>>\t" + input + "</div>");
        } else {
            result.append("<div>\t" + input + "</div>");
        }
        updateScroll();
    }

    let input_history = [];
    let current_input = -1;
    focus_input();
    //Send input to /parse
    $("#terminal").on("keydown", (event) => {
        let input = $("#terminal");
        if (event.which == 13){
            let command = input.val().slice(1);
            $.ajax({
                url: "parse",
                type: "post",
                data: {
                    command: command
                },
                dataType: "json",
                success: (data, status, xhr) => {
                    display(data.result, true);
                },
                error: (xhr, status, exception) => {
                    display(`<div class=\"error\">\t(error) AJAX failed: ${status} </div>`, true);
                } 
            });

            input_history.push(command);
            current_input = input_history.length;

            display(command);
            focus_input();
        }
    })
    //Input history
    $("#terminal").on("keydown", (event) => {
        let input = $("#terminal");
        if (input_history.length > 0){
            
            if (event.which == 38){
                (current_input > 0) ? current_input -= 1 : ""
                input.val(">" + input_history[current_input]).focus();
                event.preventDefault();
            } else if (event.which == 40){
                if (current_input < input_history.length - 1){
                    current_input += 1
                    input.val(">" + input_history[current_input]);
                } else {
                    if (current_input < input_history.length) current_input += 1;
                    focus_input();
                }
            }
            
        }
        if (event.which == 8 && input.val().length == 1){
            event.preventDefault();
        }
    })
})