(function() {
  $(function() {
    /* Get Scaled Image Data */
    var getScaledImageData, precise;
    getScaledImageData = function(image, height, width, color) {
      var lastIndex, orig, orig_context, orig_data, orig_width, populateScaledImageData, scaleX, scaleY, scaled, scaled_context, scaled_data, x, y;
      populateScaledImageData = function(x, y, image_data, offset) {
        var alpha, index, index_scaled, isOpaque;
        index = (Math.floor(y / scaleY) * orig_width + Math.floor(x / scaleX)) * 4;
        index_scaled = offset + (y * width + x) * 4;
        alpha = image_data.data[index + 3];
        isOpaque = alpha === 255;
        scaled_data.data[index_scaled] = isOpaque ? color[0] : 0;
        scaled_data.data[index_scaled + 1] = isOpaque ? color[1] : 0;
        scaled_data.data[index_scaled + 2] = isOpaque ? color[2] : 0;
        scaled_data.data[index_scaled + 3] = alpha;
        return index_scaled;
      };
      orig_width = image.width;
      scaleX = precise(width / image.width, 4);
      scaleY = precise(height / image.height, 4);
      orig = document.createElement("canvas");
      orig.width = image.width;
      orig.height = image.height;
      orig_context = orig.getContext("2d");
      orig_context.drawImage(image, 0, 0, image.width, image.height, 0, 0, image.width, image.height);
      orig_data = orig_context.getImageData(0, 0, image.width, image.height);
      scaled = document.createElement("canvas");
      scaled.width = width;
      scaled.height = height;
      scaled_context = scaled.getContext("2d");
      scaled_data = scaled_context.getImageData(0, 0, width, height);
      y = 0;
      while (y < height) {
        x = 0;
        while (x < width) {
          lastIndex = populateScaledImageData(x, y, orig_data, 0);
          x++;
        }
        y++;
      }
      return scaled_data;
    };
    /* Precise */
    precise = function(number, precision) {
      precision = Math.pow(10, precision);
      return Math.round(number * precision) / precision;
    };
    $.fn.wave64 = function(url, height, width, rgb, callback) {
      return $.wave64(url, height, width, rgb, callback);
    };
    /* Wave64 Function */
    return $.wave64 = function(url, height, width, rgb, callback) {
      return $.getJSON("http://wave64.it/w?callback=?", {
        url: url
      }, function(data) {
        var waveform;
        waveform = new Image();
        waveform.src = data.data;
        return waveform.onload = function() {
          return callback(getScaledImageData(waveform, height, width, rgb));
        };
      });
    };
  });
}).call(this);
