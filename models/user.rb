class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :encrypted_password, type: String

end