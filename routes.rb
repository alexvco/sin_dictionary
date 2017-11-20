require 'sinatra'
require 'mongoid'
require './models/user'

Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))
# no need to create or migrate db, as soon as your first record/document is created, your database will be created and you can see it in the mongo shell (type mongo in cli) using: <show dbs> command
# dont forget to run the mongo server: brew services start mongodb 


# To run the app: rackup -p 3000 -s puma


get '/' do
  "hello"
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


#create
post "/users" do
 @user = User.new(params[:user])
 if @user.save
  redirect "users/#{@user.id}"
 else
  erb :"users/new"
 end
end




# show
get '/users/:id' do
  @user = User.find(params[:id])
  erb :"users/show"
end
