require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' #gem install sinatra-reloader
require 'pony'
require 'sqlite3'


def get_db
  return SQLite3::Database.new "barbershop.db"
end

def set_masters 
  @barbers.each do |brb|
    db = SQLite3::Database.new "barbershop.db"
    db.execute 'insert into Barbers (master)
    values (?)', brb
  end  
end

def is_set_masters?
  db = SQLite3::Database.new "barbershop.db"
  db.execute 'select master from Barbers where id = 1' do |row|
    return row[0].to_s
  end
end

before do  # run before every method (befor configure, before get, before post)
  @barbers = ["Whalter White", "Jessi Pinkman", "Gus Fring"]
end

configure do
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS
   "Users" 
   (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "username" TEXT,
      "phone" TEXT,
      "datestamp" TEXT,
      "master" TEXT,
      "color" TEXT
    )'
  db.execute 'CREATE TABLE IF NOT EXISTS
  "Barbers" 
  (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "master" TEXT
    )'

  if  is_set_masters? == @barbers[0]
    
  else
    set_masters
  end

end

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about' do
  erb :about
end

get '/visit_form' do
  erb :visit_form
end

get '/login/form' do
  erb :login_form
end

get '/contacts' do
  erb :contacts
end

get '/showusers' do
  db = get_db
  db.results_as_hash = true
  @results = db.execute 'select * from Users order by id desc'

  erb :showusers
end

post '/visit_form' do
  @master = params[:master]
  @clientname = params[:clientname]
  @userphone = params[:userphone]
  @userdate = params[:userdate]
  @color = params[:colorpicker]

  hh = {:clientname => "Введите имя",
        :userphone => "Введите номер телефона",
        :userdate => "Введите время посещения"}
  
  hh.each do |key, value|
    if params[key] == ""
      @error = hh[key]
      return erb :visit_form
    end
  end

  if @error != ""
    erb :visit_form
  end  
  
  f = File.open "./public/users.txt", "a"
  f.write "Master: #{@master}, User: #{@clientname}, Phone: #{@userphone}, Time: #{@userdate}, Color: #{@color}\n" 
  f.close

  db = get_db
  db.execute "insert into Users (username, phone, datestamp, master, color)
   values (?, ?, ?, ?, ?)", [@clientname, @userphone, @userdate, @master, @color]

  return erb "<h2>Спасибо, Вы записались</h2>"

end  

post '/contacts' do
  @usermail = params[:userMail]
  @usertext = params[:userText]

  hh = {:userMail => "Введите почтовый адрес",
        :userText => "Введите интересующий тариф"}
  
  hh.each do |key, value|
    if params[key] == ""
      @error = hh[key]
      return erb :contacts
    end
  end

  f = File.open "./public/contacts.txt", "a"
  f.write "Mail: #{@usermail}, Message: #{@usertext}\n" 
  f.close

  Pony.mail(
  :mail => params[:userMail],
  :body => params[:userText],
  :to => 'Leon.Work.g@gmail.com',
  :subject => params[:userMail] + " has contacted you",
  :body => params[:message],
  :port => '587',
  :via => :smtp,
  :via_options => { 
    :address              => 'smtp.gmail.com', 
    :port                 => '587', 
    :enable_starttls_auto => true, 
    :user_name            => 'lumbee', 
    :password             => 'p@55w0rd', 
    :authentication       => :plain, 
    :domain               => 'localhost.localdomain'
  })
  erb :contacts
end

post '/login/attempt' do
  session[:identity] = params['username']
  @username = params[:username]
  @userpassword = params[:userpassword]
  if @username == "admin" && @userpassword == "secret"
    erb :admin_room
  else 
      where_user_came_from = session[:previous_url] || '/'
      redirect to where_user_came_from
  end  
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end



