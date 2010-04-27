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
