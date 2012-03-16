(function() {
  $(function() {
    var canvas, context, height, width;
    canvas = $("#waveform")[0];
    context = canvas.getContext("2d");
    width = context.canvas.clientWidth;
    height = context.canvas.clientHeight;
    canvas.setAttribute("width", width);
    canvas.setAttribute("height", height);
    SC.initialize({
      client_id: "YOUR_CLIENT_ID"
    });
    return SC.get("/tracks/33820987", function(track) {
      return $.wave64(track.waveform_url, height, width, [0, 255, 0], function(data) {
        return context.putImageData(data, 0, 0);
      });
    });
  });
}).call(this);
