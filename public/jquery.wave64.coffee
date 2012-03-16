# Wave64
# =============
# [Wave64](http://wave64.it) adds cross-domain SoundCloud waveform image support for your HTML5 canvas hacks.
# This plugin allows you to quickly color any SoundCloud waveform using Wave64 and canvas.

# Credits
# -------------
# Wave64 is Copyright (c) 2012 [Lee Martin](http://lee.ma/rtin) and [SoundCloud](http://soundcloud.com), released under the MIT License.
# Inspired by [Max Novakovic's](http://twitter.com/maxnovakovic) jQuery plugin, [$.getImageData](http://www.maxnov.com/getimagedata/).

# Usage
# -------------
# Simple call the `$.wave64()` function providing a waveform url, height, width, RGB array, and callback.
# Here's an example using the [SoundCloud JS SDK](http://developers.soundcloud.com/docs/javascript-sdk):
#     SC.get("/tracks/33820987", function(track){
#       $.wave64(track.waveform_url, height, width, [255, 102, 0], function(data){
#         context.putImageData(data, 0, 0)
#       });
#     });

$ ->
  
  ### Get Scaled Image Data ###  
  # This function loops through every pixel of the original waveform image and changes the pixel color according to a nearest pixel algorithm.
  # Originally written by [Alexander Kovalev](https://twitter.com/a_kovalev).
  
  getScaledImageData = (image, height, width, color) ->
    
    # Adjust the given pixel's color using the nearest pixel algorithm and append to scaled_data.
        
    populateScaledImageData = (x, y, image_data, offset) ->
      index         = ( Math.floor(y / scaleY) * orig_width + Math.floor(x / scaleX) ) * 4
      index_scaled  = offset + (y * width + x) * 4
      
      alpha         = image_data.data[index + 3]
      isOpaque      = alpha is 255
      
      scaled_data.data[index_scaled]     = if isOpaque then color[0] else 0
      scaled_data.data[index_scaled + 1] = if isOpaque then color[1] else 0
      scaled_data.data[index_scaled + 2] = if isOpaque then color[2] else 0
      scaled_data.data[index_scaled + 3] = alpha
  
      index_scaled
    
    orig_width  = image.width    
    scaleX = precise(width / image.width, 4)
    scaleY = precise(height / image.height, 4)
    
    # Pull the image data from original image using `canvas`.
    
    orig            = document.createElement("canvas")
    orig.width      = image.width
    orig.height     = image.height
    orig_context    = orig.getContext("2d")    
    orig_context.drawImage(image, 0, 0, image.width, image.height, 0, 0, image.width, image.height)    
    orig_data       = orig_context.getImageData(0, 0, image.width, image.height)
    
    # Create a `canvas` that we'll use to store the scaled and _colored_ image data.
    
    scaled          = document.createElement("canvas")
    scaled.width    = width
    scaled.height   = height
    scaled_context  = scaled.getContext("2d")
    scaled_data     = scaled_context.getImageData(0, 0, width, height)
    
    # Loop through every single pixel of the original image data and call the `populateScaledImageData` function from above.
    
    y = 0    
    while y < height
      x = 0
      while x < width
        lastIndex = populateScaledImageData(x, y, orig_data, 0)
        x++
      y++
      
    # Return the scaled image data.
      
    scaled_data
    
  ### Precise ###
  # Calculate the rounded precision given said number and precision.
  
  precise = (number, precision) ->
    precision = Math.pow(10, precision)
    Math.round(number * precision) / precision
  
  $.fn.wave64 = (url, height, width, rgb, callback) ->
    $.wave64(url, height, width, rgb, callback)
    
  ### Wave64 Function ###
  # Give the provided waveform url, height, width, and rgb array:
  # 1. Ping Wave64's endpoint to receive a base64 encoded version of the original waveform image.
  # 2. Create a local image using Javascript's `Image()` function given the received JSON data.
  # 3. Wait for the image to loaded.
  # 4. Finally, call this plugin's `getScaledImageData` and pass the response to the provided callback function.
    
  $.wave64 = (url, height, width, rgb, callback) ->    
    $.getJSON "http://wave64.it/w?callback=?", url: url, (data) ->      
      waveform        = new Image()
      waveform.src    = data.data      
      waveform.onload = () ->        
        callback getScaledImageData(waveform, height, width, rgb)
