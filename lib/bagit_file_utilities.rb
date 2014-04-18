module BagitFileUtilities
  module_function

  def valid_bagit_file?(file)
    lines = File.readlines(file, :encoding => 'UTF-8')
    return false unless lines.length == 2
    return false unless version_line?(lines[0])
    return false unless encoding_line?(lines[1])
    true
  end

  def version_line?(line)
    line.match(/^BagIt-Version: \d+\.\d+$/)
  end

  def encoding_line?(line)
    line.match(/^Tag-File-Character-Encoding: (.*)$/)
    Encoding.find($1) rescue false
  end

  def encoding(file)
    lines = File.readlines(file, :encoding => 'UTF-8')
    lines[1].match(/^Tag-File-Character-Encoding: (.*)$/)
    Encoding.find($1)
  end

end