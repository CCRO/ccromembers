# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
window.redact = (selector) ->
  $('div.page :not(h1,ul.nav, ul.nav ul,ul.nav li,ol,' + selector + ')').addClass('redacted')
  $('div.page ol li:not(.redacted)').parents('ol').addClass('visible')
  $('div.page ol:not(.visible)').addClass('redacted')
  return true

window.clear_redact = (selector) ->
  $('div.page .redacted').removeClass('redacted')
  $('div.page .visible').removeClass('visible')
  return true
 
jQuery ->
  $('#document_content').bind 'textselect', (evt, string, element) ->
    if string != ""
      document.getElementById('comment_quote').value = string
      document.getElementById('add_comment_quote').innerHTML = string
      $('#btn-add_comment').show()
    else
      document.getElementById('comment_quote').value = string
      document.getElementById('add_comment_quote').innerHTML = string
      $('#btn-add_comment').hide()

  $('#notices').data('fade', 'show')
  $(document).on 'scroll', (evt, string, element) ->
    if $(document).scrollTop() < 28
      $('#document_header_wrapper').removeClass("bottom-shadow")
      if $('#notices').data('fade') == 'hide'
        $('#notices').fadeTo(250, 1.0 )
        $('#notices').data('fade', 'show')
    else
      $('#document_header_wrapper').addClass("bottom-shadow")
      if $('#notices').data('fade') == 'show'
        $('#notices').fadeTo(250, 0.50 )
        $('#notices').data('fade', 'hide')
    if $(document).scrollTop() < 45
      $('#document_header_wrapper.bottom-shadow').css('padding-bottom', $(document).scrollTop() + 85 )
    else
      $('#document_header_wrapper.bottom-shadow').css('padding-bottom', 45 + 85 )

  $('#notices, #notices > *').mouseenter ->
    if $('#notices').data('fade') == 'hide'
      $(this).closest('div').fadeTo(250, 1.0 )
      $('#notices').data('fade', 'show')
  $('a#toggle-toc').click ->
    $('#sections-nav li:not(#control)').toggleClass('hide')
    $(this).children('i').toggleClass('icon-chevron-down')
    $(this).children('i').toggleClass('icon-chevron-up')
    
    $.cookie("doc-toggle-toc", $('ul#sections-nav li:not(#control):first').hasClass('hide'))
  $('a#toggle-views').click ->
    $('#doc-views-nav li:not(#control)').toggleClass('hide')
    $(this).children('i').toggleClass('icon-chevron-down')
    $(this).children('i').toggleClass('icon-chevron-up')
    $.cookie("doc-toggle-views", $('ul#doc-views-nav li:not(#control):first').hasClass('hide'))
  if $.cookie("doc-toggle-views") != 'true'
    $('#doc-views-nav li:not(#control)').toggleClass('hide')
    $('ul#doc-views-nav li#control a').children('i').toggleClass('icon-chevron-down')
    $('ul#doc-views-nav li#control a').children('i').toggleClass('icon-chevron-up')
    $.cookie("doc-toggle-views", $('ul#doc-views-nav li:not(#control):first').hasClass('hide'))
  if $.cookie("doc-toggle-toc") == 'true'
    $('#sections-nav li:not(#control)').toggleClass('hide')
    $('ul#sections-nav li#control a').children('i').toggleClass('icon-chevron-down')
    $('ul#sections-nav li#control a').children('i').toggleClass('icon-chevron-up')
    $.cookie("doc-toggle-views", $('ul#sections-nav li:not(#control):first').hasClass('hide'))
  $('#doc-toggle-pub').click (event) ->
    event.preventDefault()
    $(this).toggleClass('btn-danger').toggleClass('btn-success')
    if $(this).hasClass('btn-success')
      $(this).html('<i class="icon-ok icon-white"></i> Published')
    else
      $(this).html('<i class="icon-remove icon-white"></i> Draft')

    
    