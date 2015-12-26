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
    # the FQN may contain a '+', meaning that we need to obtain the version and then
    # check the DB again
    (@library_with_version != nil) && Libraries.find_by_fqn(@library_with_version)
  end


  def compute_dependencies
    process_library() unless cached?

    generate_response()
  end
  

  def count_methods(dep)
    SdkService.open_workspace(dep.artifact_id) do |service|
      jar = service.get_jar(dep.file)

      if jar
        dep.count, dep.dex_size = service.dex(jar)
        LOGGER.debug("#{@tag} [#{dep.artifact_id}] Count: #{dep.count}")
      else
        dep.count = 0
        LOGGER.debug("#{@tag} [#{dep.artifact_id}] Target: res-only")
        LOGGER.debug("#{@tag} [#{dep.artifact_id}] Count: 0")
      end
    end
  end


  def process_library
    # generate Dep classes from gradle
    deps = GradleService.get_deps(@library)

    # filter already processed deps
    filtered_deps = deps.reject { |dep| Libraries.exists?(fqn: dep.fqn) }

    # calculate methods count for new dependencies
    filtered_deps.each { |dep| count_methods(dep) }

    current_lib_dep = deps.first
    actual_deps = deps[1..-1]
    actual_deps.each do |dep|
      Libraries.create_from_dep(dep)
      Dependencies.create(library_name: current_lib_dep.fqn, dependency_name: dep.fqn)
    end

    lib = Libraries.create_from_dep(current_lib_dep)

    @library_with_version = lib.fqn
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
