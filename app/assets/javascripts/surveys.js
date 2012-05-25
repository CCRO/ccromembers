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
