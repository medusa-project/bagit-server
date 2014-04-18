class GenericManifest < Object

  def file_name
    raise 'Subclass responsibility'
  end

  def path
    File.join(self.version.path, self.file_name)
  end

  #for now we assume we only use an algorithm that is available via Ruby's Digest::<ALG> in the standard library
  def digest(path)
    Kernel.const_get("Digest::#{self.algorithm.upcase}").send(:file, File.join(self.version.path, path))
  end

  def update_from_file
    db_hash = Hash.new.tap do |h|
      self.file_collection.each do |manifest_file|
        h[manifest_file.path] = manifest_file
      end
    end
    file_hash = Hash.new.tap do |h|
      File.open(self.path).each_line do |line|
        raise(self.exception_class, "Bad manifest entry: #{line}") unless line.match(/^(\h+)\s+\*?(.*)$/)
        checksum, path = $1, $2
        raise(self.exception_class, "Repeat manifest path: #{line}") if h[path]
        h[path] = checksum
      end
    end
    db_hash_paths = db_hash.keys.to_set
    file_hash_paths = file_hash.keys.to_set
    (db_hash_paths - file_hash_paths).each do |path|
      db_hash[path].destroy
    end
    (file_hash_paths - db_hash_paths).each do |path|
      self.file_collection.create(path: path, checksum: file_hash[path])
    end
    db_hash.each do |path, manifest_file|
      if manifest_file.checksum != file_hash[path]
        manifest_file.checksum = file_hash[path]
        manifest_file.save!
      end
    end
  end

  def file_collection
    raise 'Subclass responsibility'
  end

  def exception_class
    raise 'Subclass responsibility'
  end

end