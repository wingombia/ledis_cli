$(document).on("turbolinks:load", () => {
    let input_history = [""];
    let current_input = 0;
    
    function display(input, is_result = false) {
        let result = $("#result");
        if (!is_result){
            result.append(">\t" + input + "<br>");
        } else {
            result.append(input + "<br>");
        }
    }

    $("#terminal").on("keydown", (event) => {
        let input = $("#terminal");
        if (event.which == 13){
            $.ajax({
                url: "parse",
                type: "post",
                data: {
                    command: input.val()
                },
                dataType: "json",
                success: (data, status, xhr) => {
                    display(data.result, true);
                }
            });

            input_history.push(input.val());
            current_input = input_history.length;

            display(input.val());
            input.val("");
        }
    })

    $("#terminal").on("keydown", (event) => {
        let input = $("#terminal");
        if (input_history.length > 0){
            if (event.which == 38){
                (current_input > 0) ? current_input -= 1 : current_input = input_history.length - 1
                input.val(input_history[current_input]);
            } else if (event.which == 40){
                (current_input < input_history.length - 1) ? current_input += 1 : ""
                input.val(input_history[current_input]);
            }
            
        }
    })
})