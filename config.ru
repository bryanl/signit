$:.unshift File.expand_path('.')
require 'sig_app'
run Sinatra::Application
