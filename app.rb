require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb '<h3>Hello from sinatra</h3>'
end

get '/new' do
  erb :new
end

