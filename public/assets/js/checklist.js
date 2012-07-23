$("tr.ingredient").click(function() {
  var select, input;
  select = $(this).children('.item-select');
  input = select.children('input');
  if (input.is(':checked')) {
    input.prop('checked', false);
    select.removeClass('selected');
  }
  else {
    input.prop('checked', true);
    select.addClass('selected');
  }
}).hover(function() {
  // hide all others
  $(".description").hide();
  //$(this).children().last().children('div').css('display', 'inline-block');
  $(this).find('.description').css('display', 'inline-block');
  var x = $(this).offset().top
  $('.arrow').css({'top' : x, 'display': 'inline-block'});
});



