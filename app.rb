require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb '<h1>Hello from sinatra</h1>'
end

