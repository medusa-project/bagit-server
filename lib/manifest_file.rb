require 'dm-core'
require 'dm-validations'

class ManifestFile < Object
  include DataMapper::Resource

  property :id, Serial
  property :path, Text, :required => true
  property :checksum, String, :required => true
  property :manifest_id, Integer, :required => true

  belongs_to :manifest
  validates_uniqueness_of :path, :scope => :manifest_id
end