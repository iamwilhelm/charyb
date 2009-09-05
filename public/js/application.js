$(document).ready(function() {
    $("a.get").click(function() {
        url = $(this).attr("data-href");
        target = $(this).attr("data-target");
        $.get(url, function(data) { 
            $(target).html(data) 
        });
    });
});
