$(".thumb-container .thumb-delete").click(function(event) {
  $.get('/delete/select/' + $(this).parents('.thumb-container').data('image'), function(data){
    $(".thumb-container[data-image='" + data.split(':')[1] + "']").remove();
  });
});
$(".thumb-container .thumb-censor").click(function(event) {
  $.get('/censor/select/' + $(this).parents('.thumb-container').data('image'), function(data){
    $(".thumb-container[data-image='" + data.split(':')[1] + "']").remove();
  });
});
$(".thumb-container .thumb-publish").click(function(event) {
  $.get('/publish/select/' + $(this).parents('.thumb-container').data('image'), function(data){
    $(".thumb-container[data-image='" + data.split(':')[1] + "']").remove();
  });
});
$("#next-page").click( function(event) {
  window.location = window.location.origin + window.location.pathname.replace(/\/?[0-9]*$/,'') + '/' + ( Number(window.location.pathname.match(/[0-9]*$/)[0]) + $(".thumb-container").size() )
  return false;
});
