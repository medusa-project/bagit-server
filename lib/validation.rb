require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require 'dm-types'

class Validation < Object
  include DataMapper::Resource

  property :id, Serial
  property :version_id, Integer, :required => true
  property :status, Enum[:unvalidated, :validating, :invalid, :valid, :committed, :uploading], :default => :unvalidated

  belongs_to :version

  def to_json
    {:status => self.status}.to_json
  end

end