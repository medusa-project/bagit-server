require 'dm-core'
require 'dm-validations'
require 'fileutils'

class Version < Object
  include DataMapper::Resource

  property :id, Serial
  property :version_id, String, :required => true, :unique => :bag_id
  property :bag_id, Integer, :required => true

  belongs_to :bag

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
    File.open(File.join(self.path, path), 'w:binary') do |f|
      f.write(io.read)
    end
  end

end