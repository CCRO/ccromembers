# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
window.redact = (selector) ->
  $('div.page :not(h1,ol,' + selector + ')').addClass('redacted')
  $('div.page ol li:not(.redacted)').parents('ol').addClass('visible')
  $('div.page ol:not(.visible)').addClass('redacted')
  return true

window.clear_redact = (selector) ->
  $('div.page .redacted').removeClass('redacted')
  $('div.page .visible').removeClass('visible')
  return true

jQuery ->
  $('div.page').wrap('<div class="page-shadow">')