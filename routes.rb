require 'sinatra'
require 'mongoid'
require 'bcrypt'
require './models/user'
require './models/dictionary_model'
require './helpers/app_helpers'

Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))
# no need to create or migrate db, as soon as your first record/document is created, your database will be created and you can see it in the mongo shell (type mongo in cli) using: <show dbs> command
# dont forget to run the mongo server: brew services start mongodb 

enable :sessions

configure do
  set :erb, :layout => :'layouts/layout'
end




# To run the app: rackup -p 3000 -s puma


get '/' do
  erb :"home/index"
end


get '/search' do
  erb :"home/search"
end

post '/search' do
  @match = DictionaryModel.find_by(word: params[:word])
  erb :"home/search"
end






# This is how you do a before action in sinatra
get '/upload', :authenticate_user => true do
  @message = session[:invalid_file] if session[:invalid_file].present?
  session[:invalid_file] = nil
  erb :"home/upload_form"
end


post '/upload' do
  puts params.inspect
  tempfile = params[:uploadfile][:tempfile]

  FileUtils.mkdir_p("tmp/")
  uploadPath = 'tmp/' + Time.new.strftime("%Y-%m-%d-%H-%M-%S") + ".yaml"

  if FileUtils.copy_file(tempfile.path, uploadPath)
    @message = "File upload failed"
  else
    @message = "File upload done"
  end

  begin
    @words = YAML.load_file(uploadPath)
  rescue
    session[:invalid_file] = "Invalid YAML file"
    redirect '/upload' and return
  end

  @words.each do |word, meaning|
    existing = DictionaryModel.where(:word => word.to_s).all

    existingCounter = 0

    existing.each do 
      existing[existingCounter].delete
      existingCounter = existingCounter + 1
    end

    d = DictionaryModel.new(:word => word.to_s)
    d.meaning = meaning.to_s
    
    begin
      d.save
    rescue
      @message = "Unable to save into Database"
    end
  end

  erb :"home/upload_form"
end




#--------------------------------------------------------SESSIONS------------------------------------------------------------#
# sign_in page
get '/users/sign_in' do
  erb :"sessions/new"
end

# sign_in authenticate
post '/users/sign_in' do
  entered_password = params[:session][:encrypted_password]
  @user = User.find_by(email: params[:session][:email])
  if @user && @user.password_is_correct?(entered_password)
    session[:user_id] = @user.id
    redirect '/'
  else
    puts "Incorrect email / password"
    erb :"/sessions/new"
  end
end

# sign_out
delete '/users/sign_out' do
  session[:user_id] = nil
  redirect '/'
end
#---------------------------------------------------------------------------------------------------------------------------#











#-----------------------------------------------------USERS------------------------------------------------------------------#
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

# show
get '/users/:id' do
  @user = User.find(params[:id])
  erb :"users/show"
end
#---------------------------------------------------------------------------------------------------------------------------#




