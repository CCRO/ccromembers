jQuery ->
  $('#questions').sortable(
    axis: 'y',
    update: ->
      alert('updated!')
  );