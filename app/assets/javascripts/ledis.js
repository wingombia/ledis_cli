$(document).on("turbolinks:load", () => {
    function focus_input(){
        $("#terminal").focus().val(">");
    }
    
    function display(input, is_result = false) {
        let result = $("#result");
        if (!is_result){
            result.append("<div class='input'>>\t" + input + "</div>");
        } else {
            result.append("<div>\t" + input + "</div>");
        }
    }

    let input_history = [];
    let current_input = -1;
    focus_input();

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
                }
            });

            input_history.push(command);
            current_input = input_history.length;

            display(command);
            focus_input();
        }
    })

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