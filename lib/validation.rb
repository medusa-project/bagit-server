require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require 'dm-types'
require_relative 'validation_error'

class Validation < Object
  include DataMapper::Resource

  property :id, Serial
  property :version_id, Integer, :required => true
  property :status, Enum[:unvalidated, :validating, :invalid, :valid, :committed, :uploading], :default => :unvalidated

  belongs_to :version
  has n, :validation_errors, :constraint => :destroy

  def to_json
    {status: self.status,
     errors: self.error_messages}.to_json
  end

  def error_messages
    self.validation_errors.all.collect { |error| error.message }
  end

  def clear_errors
    self.validation_errors.all.each {|error| error.destroy}
  end

  def add_error(message)
    self.validation_errors.create(message: message)
  end

  #The errors argument is a Validatable errors object, so the actual errors are
  #in the errors field, which is nil or a hash
  def be_invalid_with_errors(errors)
    error_hash = (errors.errors || Hash.new).reverse_merge({completeness: [], consistency: []})
    self.status = :invalid
    self.save!
    error_hash[:completeness].each do |error_message|
      self.add_error(error_message)
    end
    error_hash[:consistency].each do |error_message|
      self.add_error(self.consistency_error_message(error_message))
    end
  end

  #We want a slightly different form here than the bagit gem will provide
  def consistency_error_message(error_message)
    path = self.version.path + '/'
    error_message.sub(path, '')
  end

end