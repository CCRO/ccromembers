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