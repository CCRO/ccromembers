# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	$('#person_password_confirmation').bind 'keyup', (evt, string, element) ->
    if $('#person_password_confirmation').val() == $('#person_password').val() || $('#person_password_confirmation').val() == ""
      $(this).closest('div.control-group').removeClass('error')
      $(this).siblings('p.help-block').text("")
      $('input[type=submit]').removeClass('disabled').removeAttr('disabled')
    else 
      $(this).closest('div.control-group').addClass('error')
      $(this).siblings('p.help-block').text("Passwords do not match.")
      $('input[type=submit]').addClass('disabled').attr('disabled','disabled')
      