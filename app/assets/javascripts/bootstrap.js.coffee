jQuery ->
  $("a[rel=popover]").popover({placement: 'bottom'})
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  
  $modal = $('#modal-window')
  $modal.modal({backdrop: true, keyboard: true, show: false})
  
  $("a[rel=modal-person]").click (event) -> 
    event.preventDefault()
    $modal.modal('show')
  $('.datepicker').datepicker()
  $('textarea.simple_editor').wysihtml5()
  simple_editor = window.wysihtml5.Editor
  simple_editor.bind 'focus', (evt, string, element) ->
    $('#message_content-wysihtml5-toolbar').show(250)
    console.log 'focus'
  simple_editor.bind 'blur', (evt, string, element) ->
    $('#message_content-wysihtml5-toolbar').hide(250)
    console.log 'blur'
    