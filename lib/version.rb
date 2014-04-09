require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require 'fileutils'
require_relative 'manifest'

class Version < Object
  include DataMapper::Resource

  property :id, Serial
  property :version_id, String, :required => true, :unique => :bag_id
  property :bag_id, Integer, :required => true

  belongs_to :bag
  has n, :manifests, :constraint => :destroy

  validates_presence_of :version_id

  after :create do
    FileUtils.mkdir_p(self.path)
  end

  after :destroy do
    FileUtils.rm_rf(self.path)
  end

  def path
    File.join(self.bag.path, self.id.to_s)
  end

  def url_path
    File.join(self.bag.url_path, 'versions', self.version_id)
  end

  def write_to_path(path, io)
    #TODO check that the file join below winds up inside the content directory, e.g. if '..' or the like are used
    #TODO write in a way that doesn't require us to read the whole io stream at once
    File.open(File.join(self.path, path), 'w:binary') do |f|
      f.write(io.read)
    end
  end

  def has_bag_files?
    File.exists?(self.bagit_file_path) and File.exists?(self.bag_info_file_path)
  end

  def bagit_file_path
    File.join(self.path, 'bagit.txt')
  end

  def bag_info_file_path
    File.join(self.path, 'bag-info.txt')
  end

  #if the file is a manifest then update it. If it doesn't exist, create it.
  def update_manifest_if_manifest(file)
    return unless file.match(/manifest-(\w+)\.txt/)
    algorithm = $1
    manifest = self.manifests.first(algorithm: algorithm) || self.manifests.create(algorithm: algorithm)
    manifest.update_from_file
  end

end