$("#photos img").click(function(event) {
  var image = $(this);
  $.get(image.data('select-url'), function(data) {
    if(data.split(':')[0] == 'removed'){
      image.removeClass("selected");
    }
    if(data.split(':')[0] == 'added'){
      image.addClass("selected");
    }
  });
});
