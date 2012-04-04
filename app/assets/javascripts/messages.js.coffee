# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $("div.hidden_form > a.toggle_form").click (event) -> 
    event.preventDefault()
    $(this).hide()
    $(this).siblings('form').show()
  $("div.hidden_form > * > a.close_form").click (event) -> 
    event.preventDefault()
    $(this).closest('div.hidden_form').children('a.toggle_form').show()
    $(this).closest('form').hide()
  $(".ribbon-left").after('<br /><br /><br />')  
