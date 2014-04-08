require 'dm-core'
require 'dm-validations'
require_relative 'version'
require 'fileutils'

class Bag
  include DataMapper::Resource

  property :id, Serial
  property :bag_id, String, :unique => true, :required => true

  validates_presence_of :bag_id

  has n, :versions

  before :create do
    FileUtils.mkdir_p(self.path)
  end

  def self.root_directory
    @@root_directory ||= "bags-#{BagitServer.settings.environment}"
  end

  def self.ensure_bag(bag_id)
    self.first(bag_id: bag_id) || self.create(bag_id: bag_id)
  end

  def ensure_version(version_id)
    self.versions.first(version_id: version_id) || self.versions.create(version_id: version_id)
  end

  def path
    File.join(Bag.root_directory, self.id.to_s)
  end

end