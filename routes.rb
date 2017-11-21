require 'sinatra'
require 'mongoid'
require 'bcrypt'
require './models/user'

Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))
# no need to create or migrate db, as soon as your first record/document is created, your database will be created and you can see it in the mongo shell (type mongo in cli) using: <show dbs> command
# dont forget to run the mongo server: brew services start mongodb 

enable :sessions

# To run the app: rackup -p 3000 -s puma

configure do
  set :erb, :layout => :'layouts/layout'
end

get '/' do
  erb :"home/index"
end

['/users', '/users/'].each do |path|
  get path do
    @users = User.all
    erb :"users/index"
  end
end


# new
['/users/new', '/users/new/', '/users/signup/', '/users/sign_up/'].each do |path|
  get path do
    @user = User.new
    erb :"users/new"
  end
end


# sign_up
post "/users" do
 @user = User.new(params[:user])
 @user.encrypted_password = BCrypt::Password.create(params[:user][:encrypted_password])
 if @user.save
  session[:user_id] = @user.id
  redirect "users/#{@user.id}"
 else
  erb :"users/new"
 end
end


# sign_in page
get '/users/sign_in' do
  erb :"sessions/new"
end

# sign_in authenticate
post '/users/sign_in' do
  @user = User.find_by(email: params[:session][:email])
  # Note that since bcrypt is a 1 way encryption the line below and the line below that are not equivalent
  # params[:session][:encrypted_password] == BCrypt::Password.new(@user.encrypted_password) # this will give false, its not equivalent to the line below
  if BCrypt::Password.new(@user.encrypted_password) == params[:session][:encrypted_password]
    puts "Password is correct"
    session[:user_id] = @user.id
  else
    puts "Password is not correct"
  end
  redirect '/'
end

# sign_out
delete '/users/sign_out' do
  session[:user_id] = nil
  redirect '/'
end


# show
get '/users/:id' do
  @user = User.find(params[:id])
  erb :"users/show"
end


