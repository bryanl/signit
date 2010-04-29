require 'sinatra'
require 'erubis'
require 'RMagick'

set :public,   File.expand_path(File.dirname(__FILE__) + '/public')
set :views,    File.expand_path(File.dirname(__FILE__) + '/views')
disable :run, :reload

configure do
  require 'memcached'
  CACHE = Memcached.new
end


get '/' do 
  erb :index
end

post '/' do
  @path = params[:path]
  cache = Memcached.new
  key = (0...8).map{65.+(rand(25)).chr}.join
  cache.set key, @path
  erb "<img src='/signature.png?key=#{key}'><p><a href='/'>start over</a>"
end

get '/signature.png' do
  content_type 'image/png'

  cache = Memcached.new
  path = cache.get params[:key]

  canvas = Magick::Image.new(500, 200)
  gc = Magick::Draw.new
  gc.stroke('black')
  gc.stroke_width(1)

  path = cache.get params[:key]
  path.split(/ /).each do |stroke|
    stroke.scan(%r{^M(\d+,\d+),(\d+,\d+)$}) {
      gc.path("M#{$1} L#{$2}")
    }
  end

  gc.draw canvas
  canvas.format = 'png'
  canvas.to_blob
end

__END__

@@ layout
<html>
<head>
<title>signit!</title>
<script src="jquery-1.4.2.min.js" type="text/javascript" charset="utf-8"></script>
<script src="raphael-min.js" type="text/javascript" charset="utf-8"></script>
<script src="freehand.js" type="text/javascript" charset="utf-8"></script>

<style type="text/css" media="screen">
  #signature {
    border: 1px solid #000;
    height: 250px;
    width: 500px;
    cursor: crosshair;
  }
</style>
</head>
<body>
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
