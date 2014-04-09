require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require_relative 'manifest_file'

class Manifest < Object
  include DataMapper::Resource

  property :id, Serial
  property :algorithm, String, :unique => :version_id, :required => true
  property :version_id, Integer, :required => true

  belongs_to :version
  has n, :manifest_files, :constraint => :destroy

  #Synchronize the manifest files of this manifest from the corresponding
  #manifest file in the version's bag
  def update_from_file

  end

end