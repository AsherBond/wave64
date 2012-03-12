require 'sinatra'
require 'haml'
require 'cgi'
require 'net/https'
require 'image_size'
require 'base64'
require 'json'
require 'sass/plugin/rack'

use Sass::Plugin::Rack

# Display home
get '/' do
  haml :index
end

# Wave64 endpoint
get '/w*' do  
  # Set Content/Type as JSON
  content_type :json
  
  # Get the unescaped URL
  url = CGI::unescape(params[:url])
  url = url.sub('https', 'http')
  puts url
  
  # Get the image from URL
  image = Net::HTTP.get_response(URI.parse(url)).body
  
  # Get the image type and dimensions
  meta      = ImageSize.new(image)
  type      = meta.get_type
  width     = meta.w
  height    = meta.h
  
  # Create data prefix
  prefix = "data:image/#{ type.downcase };base64,"
  
  # Base64 encode the image
  base64 = Base64.encode64(image)
  
  # Combine the prefix and base64 image
  image_data = prefix + base64
  
  # Combine data with image dimensions and encode into JSON
  image_json = {
    :width => width,
    :height => height,
    :data => image_data
  }.to_json
  
  # Wrap callback around JSON and Return
  "#{ params[:callback] }(#{ image_json });"
end
