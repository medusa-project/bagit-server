require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require_relative 'manifest_file'
require_relative 'exceptions'
require 'set'
require 'digest'

class Manifest < Object
  include DataMapper::Resource

  property :id, Serial
  property :algorithm, String, :required => true
  property :version_id, Integer, :required => true

  belongs_to :version
  has n, :manifest_files, :constraint => :destroy
  validates_uniqueness_of :algorithm, :scope => :version_id

  #Synchronize the manifest files of this manifest from the corresponding
  #manifest file in the version's bag
  def update_from_file
    db_hash = Hash.new.tap do |h|
      self.manifest_files.each do |manifest_file|
        h[manifest_file.path] = manifest_file
      end
    end
    file_hash = Hash.new.tap do |h|
      File.open(self.path).each_line do |line|
        raise(BadManifestException, "Bad manifest entry: #{line}") unless line.match(/^(\h+)\s+\*?(.*)$/)
        checksum, path = $1, $2
        raise(BadManifestException, "Repeat manifest path: #{line}") if h[path]
        h[path] = checksum
      end
    end
    db_hash_paths = db_hash.keys.to_set
    file_hash_paths = file_hash.keys.to_set
    (db_hash_paths - file_hash_paths).each do |path|
      db_hash[path].destroy
    end
    (file_hash_paths - db_hash_paths).each do |path|
      self.manifest_files.create(path: path, checksum: file_hash[path])
    end
    db_hash.each do |path, manifest_file|
      if manifest_file.checksum != file_hash[path]
        manifest_file.checksum = file_hash[path]
        manifest_file.save!
      end
    end
  end

  def file_name
    "manifest-#{self.algorithm}.txt"
  end

  def path
    File.join(self.version.path, self.file_name)
  end

  #for now we assume we only use an algorithm that is available via Ruby's Digest::<ALG> in the standard library
  def digest(path)
    Kernel.const_get("Digest::#{self.algorithm.upcase}").send(:file, File.join(self.version.path, path))
  end

end