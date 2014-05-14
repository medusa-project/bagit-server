class ValidationError < Object
  include DataMapper::Resource

  property :id, Serial
  property :validation_id, Integer, :required => true
  #It's a little heavy-handed to make this text, but with a path in the
  #message it could easily go longer than a String will allow
  property :message, Text, :required => true

  belongs_to :validation

end