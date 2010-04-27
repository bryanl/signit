(function($){
  $.fn.signaturepad = function(options) {
    var defaults = {
      formid: "signature_form"
    };
    var options = $.extend(defaults, options);

    return this.each(function() {
      var pad = $(this)

      var paper = Raphael(this.id, 500, 250);
      var writing = false;
      var startpoint;

      pad.mousedown(function(event) {
        writing = true;
        startpoint = event.pageX + "," + event.pageY;
      }).mouseup(function(){
        writing = false;
      }).mousemove(function(event){
        if(writing) {
          var currentpoint = event.pageX + "," + event.pageY;
          currentpath = "M" + startpoint + "," + currentpoint;
          startpoint = currentpoint
          paper.path(currentpath);
          var stored_current_path = $("#signature_form input[name=path]").val();
          stored_current_path = stored_current_path + " " + currentpath;
          $("#signature_form input[name=path]").val(stored_current_path);
        }
      });
    });
  };
})(jQuery);
