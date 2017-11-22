class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :encrypted_password, type: String



  # Note that since bcrypt is a 1 way encryption the line below and the line below that are not equivalent
  # params[:session][:encrypted_password] == BCrypt::Password.new(@user.encrypted_password) # this will give false, its not equivalent to the line below
  # BCrypt::Password.new(@user.encrypted_password) == params[:session][:encrypted_password] # this will give true and is the same as the one in the method below

  def password_is_correct?(entered_password)
    BCrypt::Password.new(self.encrypted_password).is_password?(entered_password)
  end


end