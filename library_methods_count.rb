#/usr/bin/ruby

require 'rubygems'
require 'fileutils'
require 'logger'
require 'timeout'
require 'json'
require 'dotenv'

require_relative 'model'

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
    deps = Array.new
    output.split("\n").each do |line| 
      if line
        deps.push(Dep.new(line))
      end
    end
    return deps
  end

end

class LibraryMethodsCount

  attr_accessor :library
  attr_reader :library_with_version

  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  # Warning: long taking blocking procedure
  def initialize(library_name="")
    return nil if library_name.blank?

    @tag = "[LibraryMethodsCount]"
    @gradle_env_dir = "gradle_env"
    Dotenv.load
    @library = library_name
    @library_with_version = @library.end_with?("+") ? nil : @library
  end


  def cached?
    (@library_with_version != nil) && Libraries.find_by_fqn(@library_with_version)
  end


  def compute_dependencies
    if not cached?
      # the FQN may contain a '+', meaning that we need to obtain the version and then
      # check the DB again
      process_library()
    end

    generate_response()
  end


  private

  def count_methods(dep, tmp_dir)
    res_only = false
    log_name = dep.artifact_id
    item = dep.file
    if item.end_with?(".aar")
      @@logger.debug("#{@tag} [#{log_name}] Format: AAR")
      # extract AAR's classes.jar
      system("unzip -q #{item} -d #{tmp_dir} classes.jar")
      if File.exists?("#{tmp_dir}/classes.jar")
        item = "#{tmp_dir}/classes.jar"
      else
        res_only = true
      end
    else
      @@logger.debug("#{@tag} [#{log_name}] Format: JAR")
    end

    if not res_only
      # build DEX file
      dx_path = ENV['DX_PATH']
      if dx_path.to_s.empty?
        dx_path = "dx"
      else
        dx_path = dx_path + "/dx"
      end

      if not File.exists?("#{item}")
        @@logger.error("#{@tag} [#{log_name}] Target does not exist")
        raise "Target #{item} does not exist"
      end

      begin
        Timeout::timeout(2 * 60) { # 2 minutes
          @@logger.debug("#{@tag} [#{log_name}] exec: #{dx_path} --dex --output=#{tmp_dir}/tmp.dex #{item}")
          system("#{dx_path} --dex --output=#{tmp_dir}/tmp.dex #{item}")
        }
      rescue Timeout::Error
        raise "'dx' operation timed out, invalidating current library"
      end
      
      dx_result = $?.exitstatus
      if dx_result == 0
        @@logger.debug("#{@tag} [#{log_name}] DXed successfully (result code: #{dx_result})")
      else
        @@logger.error("Could not create DEX for #{item}")
        raise "Could not create DEX for #{item}"
      end
      
      # extract methods count, update counter
      count = `cat #{tmp_dir}/tmp.dex | head -c 92 | tail -c 4 | hexdump -e '1/4 "%d\n"'`
      dep.count = count.to_i()
      dep.dex_size = File.size("#{tmp_dir}/tmp.dex")

      @@logger.debug("#{@tag} [#{log_name}] Count: #{count}")
    else
      dep.count = 0
      @@logger.debug("#{@tag} [#{log_name}] Target: res-only")
      @@logger.debug("#{@tag} [#{log_name}] Count: 0")
    end
    if File.exist?("#{tmp_dir}/classes.jar")
      File.delete("#{tmp_dir}/classes.jar")
    end
    if File.exist?("#{tmp_dir}/tmp.dex")
      File.delete("#{tmp_dir}/tmp.dex")
    end
  end

  def process_library
    # calculate dependencies with gradle
    result = `#{@gradle_env_dir}/gradlew -p #{@gradle_env_dir} -q deps -PinputDep=#{@library}`
    if $?.exitstatus != 0
      raise "Error while calculating dependencies with Gradle"
    end

    # generate Dep classes from gradle output
    deps = Dep.from_gradle_output(result)

    # filter already processed deps
    filtered_deps = deps.reject do |dep| 
      lib = Libraries.find_by_fqn(dep.fqn)
      lib and lib.id > 0
    end

    # calculate methods count for new dependencies
    rand = Random::DEFAULT.rand().to_s
    Dir.mkdir(rand)
    tmp_dir = File.absolute_path(rand)
    filtered_deps.each { |dep| count_methods(dep, tmp_dir) }
    Dir.delete(tmp_dir)

    # insert all dependencies into DB (first dep is always the requested one)
    inserted_id = -1
    deps.each_with_index do |dep, i|
      lib = nil
      if filtered_deps.index(dep) == nil
        lib = Libraries.find_by_fqn(dep.fqn)
      else
        lib = Libraries.create(fqn: dep.fqn, group_id: dep.group_id, artifact_id: dep.artifact_id, version: dep.version, count: dep.count, size: dep.size, dex_size: dep.dex_size, hit_count: 1, creation_time: Time.now.to_i, last_updated: Time.now.to_i)
      end
      if i == 0
        inserted_id = lib.id
        if @library.end_with?("+")
          @library_with_version = lib.fqn
        end
      else
        Dependencies.create(library_id: inserted_id, dependency_id: lib.id)
      end
    end

    if inserted_id < 0
      @@logger.error("DB insertion failed")
      raise "DB insertion failed"
    end
  end

  def generate_response
    lib = Libraries.where(:fqn => @library_with_version).first
    deps = Dependencies.where(library_id: lib.id).all
    deps_array = Array.new
    deps.each do |dep|
      dep_id = dep.dependency_id
      dep_lib = Libraries.find(dep_id.to_i)
      deps_array.push({ :dependency_name => dep_lib.fqn, :dependency_count => dep_lib.count, :dependency_size => dep_lib.size, :dependency_dex_size => dep_lib.dex_size })
    end

    response = {:library_fqn => lib.fqn, :library_methods => lib.count, :library_size => lib.size, :library_dex_size => lib.dex_size, :dependencies_count => deps.length, :dependencies => deps_array}

    puts response.to_json
    return response
  end

end

if __FILE__ == $0
  library_name = ARGV[0]
  LibraryMethodsCount.new(library_name).compute_dependencies()
end