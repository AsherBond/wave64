$ ->  
  canvas  = $("#waveform")[0]
  context = canvas.getContext("2d")
  width   = context.canvas.clientWidth
  height  = context.canvas.clientHeight
  
  canvas.setAttribute("width", width)
  canvas.setAttribute("height", height)
  
  SC.initialize
    client_id: "YOUR_CLIENT_ID"
  
  SC.get "/tracks/33820987", (track) ->
    $.wave64 track.waveform_url, height, width, [0, 255, 0], (data) ->
      context.putImageData(data, 0, 0)
