#/usr/bin/ruby

require 'rubygems'
require 'fileutils'
require 'logger'
require 'timeout'
require 'json'
require 'dotenv'


class LibraryMethodsCount

  attr_accessor :library
  attr_reader :library_with_version

  # Warning: long taking blocking procedure
  def initialize(library_name="")
    return nil if library_name.blank?

    @tag = "[LibraryMethodsCount]"
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
    LOGGER.debug("#{dep} #{tmp_dir} #{item}")
    if item.end_with?(".aar")
      LOGGER.debug("#{@tag} [#{log_name}] Format: AAR")
      # extract AAR's classes.jar
      system("unzip -q #{item} -d #{tmp_dir} classes.jar")
      if File.exists?("#{tmp_dir}/classes.jar")
        item = "#{tmp_dir}/classes.jar"
      else
        res_only = true
      end
    else
      LOGGER.debug("#{@tag} [#{log_name}] Format: JAR")
    end

    if not res_only
      # make sure our jar actually contains .class files :)
      `unzip -l #{item} | grep -x .*\.class$`
      if $?.exitstatus != 0
        res_only = true
        LOGGER.debug("#{@tag} [#{log_name}] Empty JAR file (no .class files found), consider as res-only")
      end
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
        LOGGER.error("#{@tag} [#{log_name}] Target does not exist")
        raise "Target #{item} does not exist"
      end

      begin
        Timeout::timeout(2 * 60) { # 2 minutes
                                   LOGGER.debug("#{@tag} [#{log_name}] exec: #{dx_path} --dex --output=#{tmp_dir}/tmp.dex #{item}")
                                   system("#{dx_path} --dex --output=#{tmp_dir}/tmp.dex #{item}")
                                   }
      rescue Timeout::Error
        raise "'dx' operation timed out, invalidating current library"
      end

      dx_result = $?.exitstatus
      if dx_result == 0
        LOGGER.debug("#{@tag} [#{log_name}] DXed successfully (result code: #{dx_result})")
      else
        LOGGER.error("Could not create DEX for #{item}")
        raise "Could not create DEX for #{item}"
      end

      # extract methods count, update counter
      count = `cat #{tmp_dir}/tmp.dex | head -c 92 | tail -c 4 | hexdump -e '1/4 "%d\n"'`
      dep.count = count.to_i()
      dep.dex_size = File.size("#{tmp_dir}/tmp.dex")

      LOGGER.debug("#{@tag} [#{log_name}] Count: #{count}")
    else
      dep.count = 0
      LOGGER.debug("#{@tag} [#{log_name}] Target: res-only")
      LOGGER.debug("#{@tag} [#{log_name}] Count: 0")
    end

    [
      "#{tmp_dir}/classes.jar",
      "#{tmp_dir}/tmp.dex"
    ].map { |f| File.delete(f) if File.exists?(f) }
  end

  def process_library
    # generate Dep classes from gradle
    deps = GradleService.get_deps(@library)

    # filter already processed deps
    filtered_deps = deps.reject { |d| Libraries.exists?(d.fqn) }

    # calculate methods count for new dependencies
    rand = Random::DEFAULT.rand().to_s
    Dir.mkdir(rand)
    tmp_dir = File.absolute_path(rand)
    filtered_deps.each { |dep| count_methods(dep, tmp_dir) }
    Dir.delete(tmp_dir)

    current_lib = deps.first
    actual_deps = deps[1..-1]
    actual_deps.each do |dep|
      Dependencies.create(library_name: current_lib.fqn, dependency_name: dep.fqn)
    end

    lib = Libraries.where(
      fqn: current_lib.fqn, group_id: current_lib.group_id, artifact_id: current_lib.artifact_id,
      version: current_lib.version, count: current_lib.count, size: current_lib.size, dex_size: current_lib.dex_size,
    ).first_or_create
    lib.hit_count += 1
    lib.save!

    @library_with_version = lib.fqn

    # Can it really happen?
    if inserted_id < 0
      LOGGER.error("DB insertion failed")
      raise "DB insertion failed"
    end
  end

  def generate_response
    lib = Libraries.where(:fqn => @library_with_version).first
    deps = Dependencies.where(library_name: lib.fqn).all
    deps_array = Array.new
    deps.each do |dep|
      dep_name = dep.dependency_name
      dep_lib = Libraries.find_by_fqn(dep_name)
      deps_array.push({ :dependency_name => dep_lib.fqn, :dependency_count => dep_lib.count, :dependency_size => dep_lib.size, :dependency_dex_size => dep_lib.dex_size })
    end

    response = {:library_fqn => lib.fqn, :library_methods => lib.count, :library_size => lib.size, :library_dex_size => lib.dex_size, :dependencies_count => deps.length, :dependencies => deps_array}

    LOGGER.info response.to_json
    return response
  end
end
