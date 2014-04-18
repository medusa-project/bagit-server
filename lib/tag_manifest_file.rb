require 'dm-core'
require 'dm-validations'

class TagManifestFile < Object
  include DataMapper::Resource

  property :id, Serial
  property :path, Text, :required => true
  property :checksum, String, :required => true
  property :tag_manifest_id, Integer, :required => true

  belongs_to :tag_manifest
  validates_uniqueness_of :path, :scope => :tag_manifest_id
end