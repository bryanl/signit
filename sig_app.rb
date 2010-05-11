require 'sinatra'
require 'erubis'
require 'RMagick'
require 'memcached'
require 'digest/md5'

set :public,   File.expand_path(File.dirname(__FILE__) + '/public')
set :views,    File.expand_path(File.dirname(__FILE__) + '/views')
disable :run, :reload

configure do
  CACHE = Memcached.new
end

get '/' do 
  erb :index
end

def path2png(path)
  canvas = Magick::Image.new(500, 200)
  gc = Magick::Draw.new
  gc.stroke('black')
  gc.stroke_width(1)

  path.split(/ /).each do |stroke|
    stroke.scan(%r{^M(\d+,\d+),(\d+,\d+)$}) {
      gc.path("M#{$1} L#{$2}")
    }
  end

  gc.draw canvas
  canvas.format = 'png'
  canvas.to_blob
end

post '/' do
  path = params[:path]
  key = Digest::MD5.hexdigest(path)
  CACHE.set key, path2png(path)
  erb "<img src='/signatures/#{key}.png'/><p><a href='/'>start over</a>"
end

get '/signatures/:key.png' do
  content_type 'image/png'

  CACHE.get params[:key]
end

__END__

@@ layout
<html>
<head>
<title>signit!</title>
<meta name="viewport" content="user-scalable=no,width=device-width, maximum-scale=1.0" />
<script src="jquery-1.4.2.min.js" type="text/javascript" charset="utf-8"></script>
<script src="raphael-min.js" type="text/javascript" charset="utf-8"></script>
<script src="freehand.js" type="text/javascript" charset="utf-8"></script>

<style type="text/css" media="screen">
  #signature {
    border: 1px solid #000;
    height: 150px;
    width: 300px;
    cursor: crosshair;
  }
</style>
</head>
<body ontouchmove="event.preventDefault();return false;">
<%= yield %>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-358596-5");
pageTracker._trackPageview();
} catch(err) {}</script>
</body>
</html>
