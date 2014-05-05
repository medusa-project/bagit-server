require 'uri'
require 'open-uri'

module FetchFile
  module_function

  def fetch_file?(file)
    file == 'fetch.txt'
  end

  def is_valid?(file)
    File.open(file).each_line do |line|
      return false unless self.valid_fetch_line?(line)
    end
    return true
  end

  def valid_fetch_line?(line)
    return false unless line.match(/^(\S+)\s+(\S+)\s+(.+)$/)
    url, size, path = $1, $2, $3
    self.valid_url?(url) and self.valid_size?(size) and self.valid_path?(path)
  end

  #We require the url to be an ftp or http(s) url
  def valid_url?(url)
    uri = URI(url)
    uri.is_a?(URI::FTP) or uri.is_a?(URI::HTTP)
  end

  #TODO perhaps check this, e.g. that it is a valid path under the version path
  #currently we just require that it is not empty
  def valid_path?(path)
    return true
  end

  def valid_size?(size)
    size == '-' || size.match(/\d+/)
  end

  #TODO manage the read/write better, so we don't have to read the entire stream at once
  #TODO the bagit gem provides something that will do this, but as of 0.3.2 it does it
  #incorrectly, fetching to the data directory instead of the base. So if that gets
  #fixed then perhaps use that.
  #TODO decide what to do if a requested file is already present. Probably best is to omit it.
  #This would allow a reasonable retry if this fails - any files that are interrupted in process
  #will fail validation and can then be removed and the fetch retried.
  def fetch_version(version)
    File.open(version.fetch_file_path).each_line do |line|
      line.match(/^(\S+)\s+(\S+)\s+(.+)$/)
      url, size, path = $1, $2, $3
      output_path = File.join(version.path, path)
      FileUtils.mkdir_p(File.dirname(output_path))
      File.open(output_path, 'w') do |f|
        remote_content = open(url)
        f.write remote_content.read
      end
    end
  end

end