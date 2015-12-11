class Dep
  attr_accessor :fqn
  attr_accessor :group_id
  attr_accessor :artifact_id
  attr_accessor :version
  attr_accessor :file
  attr_accessor :size
  attr_accessor :count
  attr_accessor :dex_size

  def initialize(line)
    @group_id, @artifact_id, @version, @file, @size = line.split("|")
    @fqn = "#{group_id}:#{artifact_id}:#{version}"
  end

  def self.from_gradle_output(output)
    output.split("\n").compact.map { |line| Dep.new(line) }
  end

end