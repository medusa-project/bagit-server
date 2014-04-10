require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require 'fileutils'
require_relative 'manifest'
require_relative 'exceptions'
require 'uuid'

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

  #TODO this could take some time - a better approach may be to move this to a trash directory
  #and then clean that up asynchronously
  after :destroy do
    FileUtils.rm_rf(self.path)
  end

  def path
    File.join(self.bag.path, self.id.to_s)
  end

  def url_path
    File.join(self.bag.url_path, 'versions', self.version_id)
  end

  #We first detect if the file to be written exists.
  #If so we move it out of the way; if not we note its nonexistence.
  #We then write the new file.
  #Then if a block is supplied we execute in a transaction.
  # if we get any errors we roll back the transaction, remove the new file,
  # restore the old copy of the file (if it exists), and reraise the exception.
  # If we succeed we remove the old version if we stored it.
  #If no block is supplied we just remove the old file.
  def protected_write_to_path(path, io)
    #TODO check that the file join below winds up inside the content directory, e.g. if '..' or the like are used
    #TODO write in a way that doesn't require us to read the whole io stream at once
    content_file = File.join(self.path, path)
    FileUtils.mkdir_p(File.dirname(content_file))
    backup_file = nil
    if File.exists?(content_file)
      backup_file = File.join(Bag.tmp_directory, UUID.generate)
      FileUtils.move(content_file, backup_file)
    end
    File.open(File.join(self.path, path), 'w:binary') do |f|
      f.write(io.read)
    end
    if block_given?
      Version.transaction do |t|
        begin
          yield
        rescue Exception
          t.rollback
          File.delete(content_file) if File.exists?(content_file)
          FileUtils.move(backup_file, content_file) if backup_file and File.exists?(backup_file)
          raise
        end
      end
    end
  ensure
    File.delete(backup_file) if backup_file and File.exists?(backup_file)
  end

  def has_bag_files?
    File.exists?(self.bagit_file_path) and File.exists?(self.bag_info_file_path)
  end

  #if the file is in no manifest or fails checksumming for a manifest it is in then raise an exception. Otherwise true.
  def verify_data_file(path)
    containing_manifests = self.manifests.select {|manifest| manifest.manifest_files.first(path: path)}
    raise FileNotInManifestException unless containing_manifests.size > 0
    bad_checksum_manifest = containing_manifests.detect do |manifest|
      manifest.digest(path) != manifest.manifest_files.first(path: path).checksum
    end
    raise IncorrectChecksumException if bad_checksum_manifest
    true
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