(function($){
  $.fn.signaturepad = function(options) {
    var defaults = {
      formid: "signature_form"
    };
    var options = $.extend(defaults, options);

    return this.each(function() {
      var pad = $(this);
      var node = pad[0];

      var paper = Raphael(this.id, 300, 150);
      var writing = false;
      var startpoint;

      function startEvent(event) {
        writing = true;
        if (event.touches) {
          if (event.touches.length == 1) {
            var touch = event.touches[0];
            startpoint = touch.pageX + "," + touch.pageY;
          }
        }
        else {
          startpoint = event.pageX + "," + event.pageY;
        }
      }

      function stopEvent(event) {
        writing = false;
      }

      function updatePath(currentpoint) {
        var currentpath = "M" + startpoint + "," + currentpoint;
        startpoint = currentpoint
        paper.path(currentpath);
        var stored_current_path = $("#signature_form input[name=path]").val();
        stored_current_path = stored_current_path + " " + currentpath;
        $("#signature_form input[name=path]").val(stored_current_path);
      }

      function moveEvent(event) {
        if (writing) {
          if (event.touches) {
            if (event.touches.length == 1) {
              var touch = event.touches[0];
              updatePath(touch.pageX + "," + touch.pageY);
            }
            else { /* multi touch */ }
          }
          else {
            updatePath(event.pageX + "," + event.pageY);
          }
        }
      }

      pad.mousedown(startEvent).mouseup(stopEvent).mousemove(moveEvent);

      //node
        //.live('touchstart', startEvent)
        //.live('touchend', stopEvent)
        //.live('touchcancel', stopEvent)
        //.live('touchmove', moveEvent);

      if (node.addEventListener) {
        node.addEventListener('touchstart', startEvent, false);
        node.addEventListener('touchend', stopEvent, false);
        node.addEventListener('touchcancel', stopEvent, false);
        node.addEventListener('touchmove', moveEvent, false);
      }

    });
  };
})(jQuery);
