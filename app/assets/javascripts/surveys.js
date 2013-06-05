//= require jqcloud

var jqThis = $('#adjinput'), //object of the input field in jQuery
    fontSize = parseInt( jqThis.css('font-size') ) / 2, //its font-size
    //its min Width (the box won't become smaller than this
    minWidth= parseInt( jqThis.css('min-width') ), 
    //its maxWidth (the box won't become bigger than this)
    maxWidth= parseInt( jqThis.css('max-width') );

jqThis.bind('keydown', function(e){ //on key down
   var newVal = (this.value.length * fontSize); //compute the new width

   if( newVal  > minWidth && newVal <= maxWidth ) //check to see if it is within Min and Max
       this.style.width = newVal + 'px'; //update the value.
});


jQuery(function($) {
  $("a[rel='new_question_type']").on('click', function(event) {
    event.preventDefault();
    $('.add_question_form input#question_response_type').prop('value', $(this).data('qtype'));
    $('.add_question_form input#question_prompt').prop('placeholder', 'Prompt for ' +$(this).data('qtype')  + ' question');
    $('.add_question_form').show();
    $("div#add_question #question_prompt").focus();
  });
});

jQuery(function($) {
  $('#questions').sortable( {
    axis: 'y',
    update: function() {
      $.post($(this).data('update-url'), $(this).sortable('serialize'));
  }});
});