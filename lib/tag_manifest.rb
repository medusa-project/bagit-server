require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require_relative 'tag_manifest_file'
require_relative 'exceptions'
require_relative 'generic_manifest'
require 'set'
require 'digest'

class TagManifest < GenericManifest
  include DataMapper::Resource

  property :id, Serial
  property :algorithm, String, :required => true
  property :version_id, Integer, :required => true

  belongs_to :version
  has n, :tag_manifest_files, :constraint => :destroy
  validates_uniqueness_of :algorithm, :scope => :version_id

  def file_name
    "tagmanifest-#{self.algorithm}.txt"
  end

  def file_collection
    self.tag_manifest_files
  end

  def exception_class
    BadTagManifestException
  end

end