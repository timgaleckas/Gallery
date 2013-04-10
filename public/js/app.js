$("#photos img").click(function(event) {
    var image = $(this).attr("src");
    $(this).toggleClass("selected");
    $.get('/select/'+image, function(data) {
        //$('#selected').append(data);
    });
});
