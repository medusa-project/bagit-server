require 'dm-core'
require 'dm-validations'
require 'dm-constraints'
require_relative 'version'
require 'fileutils'
require 'uuid'
require 'cattr'

class Bag
  include DataMapper::Resource

  property :id, Serial
  property :bag_id, String, :unique => true, :required => true

  validates_presence_of :bag_id

  has n, :versions, :constraint => :destroy

  cattr_accessor :root_dir, :tmp_dir

  before :create do
    FileUtils.mkdir_p(self.path)
  end

  #TODO this could take some time. A better approach might be to simply move the directory
  #somewhere else on the same volume and then to delete via a cron job or another service
  after :destroy do
    FileUtils.rm_rf(self.path)
  end

  def self.root_directory
    self.root_dir ||= "bags-#{BagitServer.settings.environment}"
  end

  #we set this up inside of the environment's bag directory so that move operations will be fast
  def self.tmp_directory
    self.tmp_dir ||= File.join(self.root_directory, 'tmp')
    FileUtils.mkdir_p(self.tmp_dir) unless Dir.exists?(self.tmp_dir)
    self.tmp_dir
  end

  def self.ensure_bag(bag_id)
    self.first(bag_id: bag_id) || self.create(bag_id: bag_id)
  end

  def ensure_version(version_id)
    version_id = UUID.generate if (version_id.nil? or version_id.empty?)
    self.versions.first(version_id: version_id) || self.versions.create(version_id: version_id)
  end

  def path
    File.join(Bag.root_directory, self.id.to_s)
  end

  def url_path
    self.bag_id
  end

end