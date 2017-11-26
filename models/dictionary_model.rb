class DictionaryModel
  include Mongoid::Document
  
  field :word, type: String
  field :meaning, type: String
  
  validates_presence_of :word
  validates_presence_of :meaning

end