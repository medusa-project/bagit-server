require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require_relative 'manifest_file'
require_relative 'exceptions'
require_relative 'generic_manifest'
require 'set'
require 'digest'

class Manifest < GenericManifest
  include DataMapper::Resource

  property :id, Serial
  property :algorithm, String, :required => true
  property :version_id, Integer, :required => true

  belongs_to :version
  has n, :manifest_files, :constraint => :destroy
  validates_uniqueness_of :algorithm, :scope => :version_id

  def file_collection
    self.manifest_files
  end

  def exception_class
    BadManifestException
  end

  def file_name
    "manifest-#{self.algorithm}.txt"
  end

end