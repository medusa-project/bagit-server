module BagInfoFileUtilities
  module_function

  def valid_bag_info_file?(file, encoding)
    encoding ||= 'UTF-8'
    lines = File.readlines(file, encoding)
    return true if lines.length == 0
    first_line = lines.shift
    return false unless element_starting_line?(first_line)
    lines.all? {|line| element_starting_line?(line) or element_continuation_line?(line)}
  end

  def element_starting_line?(line)
    line.match(/^\S+\s*:\s*.*$/)
  end

  def element_continuation_line?(line)
    line.match(/^[[:blank:]]+/)
  end

end