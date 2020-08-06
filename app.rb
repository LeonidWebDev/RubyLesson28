require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new "leprosorium.db"
  db.results_as_hash = true
end

before do
  init_db
end

get '/' do
  erb '<h3>Hello from sinatra</h3>'
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]
  erb "Thanks for your'e post"
end

