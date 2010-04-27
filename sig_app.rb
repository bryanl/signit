require 'sinatra'
require 'erubis'
require 'RMagick'
require 'memcache-client'

set :public,   File.expand_path(File.dirname(__FILE__) + '/public')
set :views,    File.expand_path(File.dirname(__FILE__) + '/views')
disable :run, :reload

get '/' do 
  erb :index
end

post '/' do
  @path = params[:path]
  cache = MemCache.new
  key = (0...8).map{65.+(rand(25)).chr}.join
  cache.set key, @path
  erb "<img src='/signature.png?key=#{key}'><p><a href='/'>start over</a>"
end

get '/signature.png' do
  content_type 'image/png'

  cache = MemCache.new
  path = cache.get params[:key]

  canvas = Magick::Image.new(500, 200)
  gc = Magick::Draw.new
  gc.stroke('black')
  gc.stroke_width(5)

  path = cache.get params[:key]
  path.split(/ /).each do |stroke|
    origin = stroke
    line = stroke.gsub('M', 'L')
    gc.path [origin, line].join(" ")
  end

  gc.draw canvas
  canvas.format = 'png'
  canvas.to_blob
end
