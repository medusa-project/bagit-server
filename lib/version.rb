require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require 'fileutils'
require_relative 'manifest'
require_relative 'tag_manifest'
require_relative 'exceptions'
require_relative 'validation'
require_relative 'bagit_file_utilities'
require_relative 'bag_info_file_utilities'
require_relative 'fetch_file'
require 'uuid'
require 'bagit'

class Version < Object
  include DataMapper::Resource

  property :id, Serial
  property :version_id, String, :required => true
  property :bag_id, Integer, :required => true
  property :tag_file_encoding, String

  belongs_to :bag
  has n, :manifests, :constraint => :destroy
  has n, :tag_manifests, :constraint => :destroy
  has 1, :validation, :constraint => :destroy

  validates_presence_of :version_id
  validates_uniqueness_of :version_id, :scope => :bag_id

  before :create do
    self.validation = Validation.new
  end

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
    backup_file = nil
    with_content_path_for(path) do |content_path|
      FileUtils.mkdir_p(File.dirname(content_path))
      if File.exists?(content_path)
        backup_file = File.join(Bag.tmp_directory, UUID.generate)
        FileUtils.move(content_path, backup_file)
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
            File.delete(content_path) if File.exists?(content_path)
            FileUtils.move(backup_file, content_path) if backup_file and File.exists?(backup_file)
            raise
          end
        end
      end
    end
  ensure
    File.delete(backup_file) if backup_file and File.exists?(backup_file)
  end

  def has_bag_files?
    File.exists?(self.bagit_file_path) and File.exists?(self.bag_info_file_path)
  end

  #if the file is in no manifest or fails check-summing for a manifest it is in then raise an exception. Otherwise true.
  def verify_data_file(path)
    containing_manifests = self.manifests.select { |manifest| manifest.manifest_files.first(path: path) }
    raise FileNotInManifestException unless containing_manifests.size > 0
    bad_checksum_manifest = containing_manifests.detect do |manifest|
      manifest.digest(path) != manifest.manifest_files.first(path: path).checksum
    end
    raise IncorrectChecksumException if bad_checksum_manifest
    true
  end

  #tag files don't need to be in any manifest, but if they are in any then the checksum has to match
  def verify_tag_file(path)
    self.update_if_manifest(path)
    self.update_if_tag_manifest(path)
    self.verify_if_fetch(path)
    containing_tag_manifests = self.tag_manifests.select { |tag_manifest| tag_manifest.tag_manifest_files.first(path: path) }
    bad_checksum_tag_manifest = containing_tag_manifests.detect do |tag_manifest|
      tag_manifest.digest(path) != tag_manifest.tag_manifest_files.first(path: path).checksum
    end
    raise IncorrectChecksumException if bad_checksum_tag_manifest
    true
  end

  def bagit_file_path
    File.join(self.path, 'bagit.txt')
  end

  def bag_info_file_path
    File.join(self.path, 'bag-info.txt')
  end

  def fetch_file_path
    File.join(self.path, 'fetch.txt')
  end

  def verify_if_fetch(file)
    return true unless FetchFile.fetch_file?(file)
    raise BadFetchFileException unless FetchFile.is_valid?(self.fetch_file_path)
  end

  #if the file is a manifest then update it. If it doesn't exist, create it.
  def update_if_manifest(file)
    return unless (algorithm = manifest_algorithm_or_nil(file))
    manifest = self.manifests.first(algorithm: algorithm) || self.manifests.create(algorithm: algorithm)
    manifest.update_from_file
    self.validation_status = :unvalidated
  end

  #the file is a tag manifest then update it. If it doesn't exist, create it.
  def update_if_tag_manifest(file)
    return unless (algorithm = tag_manifest_algorithm_or_nil(file))
    tag_manifest = self.tag_manifests.first(algorithm: algorithm) || self.tag_manifests.create(algorithm: algorithm)
    tag_manifest.update_from_file
    self.validation_status = :unvalidated
  end

  #Return nil if the path is not for a manifest; otherwise return the algorithm string
  def manifest_algorithm_or_nil(path)
    path.match(/^manifest-(\w+)\.txt$/)
    $1
  end

  #Return nil if the path is not for a tag manifest; otherwise return the algorithm string
  def tag_manifest_algorithm_or_nil(path)
    path.match(/^tagmanifest-(\w+)\.txt$/)
    $1
  end

  def read_content(path)
    with_content_path_for(path, error_unless_exists: true) do |full_path|
      File.read(full_path)
    end
  end

  def delete_content(path)
    with_content_path_for(path, error_unless_exists: true) do |full_path|
      raise FileNotFound unless File.exists?(full_path)
      File.delete(full_path)
      algorithm = manifest_algorithm_or_nil(path)
      if algorithm
        self.manifests.first(algorithm: algorithm).destroy
      end
    end
  end

  def with_content_path_for(path, error_unless_exists: nil)
    content_path = File.join(self.path, path)
    raise FileNotFound if error_unless_exists and !File.exists?(content_path)
    yield content_path
  end

  def accepts_content?
    [:unvalidated, :invalid].include?(self.validation_status)
  end

  def accepts_content_deletion?
    [:unvalidated, :invalid].include?(self.validation_status)
  end

  def commitable?
    self.validation_status == :valid
  end

  def commit
    self.validation_status = :committed
  end

  def validation_status
    self.validation.status
  end

  def validation_status=(status)
    self.validation.status = status
    self.validation.save!
  end

  def verify_bagit_file
    raise BadBagitFileException unless BagitFileUtilities.valid_bagit_file?(self.bagit_file_path)
    self.tag_file_encoding = BagitFileUtilities.encoding(self.bagit_file_path).to_s
  end

  def verify_bag_info_file
    raise BadBagInfoFileException unless BagInfoFileUtilities.valid_bag_info_file?(self.bag_info_file_path, self.tag_file_encoding)
  end

  #TODO This could take a long time and is a good candidate for delay
  def fetch
    self.validation_status = :uploading
    FetchFile.fetch_version(self)
  ensure
    self.validation_status = :unvalidated
  end

  #TODO This could take a long time and is a good candidate for delay
  #TODO Store validation errors with the validation
  def validate
    original_status = self.validation_status
    self.transaction do
      self.validation_status = :validating
      self.validation.clear_errors
      bagit = BagIt::Bag.new(self.path)
      unless bagit.complete? and bagit.consistent?
        self.validation.be_invalid_with_errors(bagit.errors)
        return
      end
      self.validation_status = :valid
    end
  rescue Exception
    self.validation_status = original_status
    raise
  end

end