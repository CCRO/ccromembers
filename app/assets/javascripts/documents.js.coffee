# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('#document_content').bind 'textselect', (evt, string, element) ->
    if string != ""
      document.getElementById('add_comment_quote').innerHTML = string
      $('#btn-add_comment').show()
    else
      $('#btn-add_comment').hide()