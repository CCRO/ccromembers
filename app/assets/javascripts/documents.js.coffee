# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('#document_content').bind 'textselect', (evt, string, element) ->
    if string != ""
      document.getElementById('add_comment_quote').innerHTML = string
      $('#btn-add_comment').show()
    else
      document.getElementById('add_comment_quote').innerHTML = string
      $('#btn-add_comment').hide()
  $(document).scroll ->
    if $(document).scrollTop() < 28
      $('#document_header_wrapper').removeClass("bottom-shadow")
    else
      $('#document_header_wrapper').addClass("bottom-shadow")
    if $(document).scrollTop() < 45
      $('#document_header_wrapper.bottom-shadow').css('padding-bottom', $(document).scrollTop() + 75 )
    else
      $('#document_header_wrapper.bottom-shadow').css('padding-bottom', 45 + 75 )
